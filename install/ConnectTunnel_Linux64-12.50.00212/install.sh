#!/bin/bash

XG_CWD=$PWD
XG_TAR="ConnectTunnel-Linux64-12.50.00212.tar.bz2"

# FIXME: this path cannot be changed yet.
XG_INSTDIR=/usr/local/Aventail

# Space-delimited paths that we examine for dependencies
XG_LIBPATHS="/usr/lib /lib"

# Lib path for 64-bit machines
XG_LIBPATHS_64="/usr/lib32 /usr/lib64 /lib64"

XG_KVER=`uname -r`
XG_OS=`uname`
XG_ARCH=`uname -m`

XG_INSTOS=Linux
XG_VER="12.50.00212"

XG_PRODUCT="Connect Tunnel"
XG_AVC=AvConnect

function nicever {
    echo "$@" | sed -re 's/^([0-9]+)\.([0-9])([0-9])[0-9]*\./\1.\2.\3./'
}

if [ "$XG_VER" == "" ]; then
    XG_VER=`cat version 2>/dev/null`
fi

if [ "$XG_VER" != "" ]; then
    XG_TVER=" `nicever $XG_VER`"
fi

for arg in $*; do
    if [ "$arg" == "--auto" ]; then
        AUTOINST=y
    fi
done

function xg_irresolvable_dependencies {
    echo "One or more dependencies cannot be resolved."
    echo "$XG_PRODUCT install failed."
    echo "To uninstall, run /usr/local/Aventail/uninstall.sh"
    echo
    echo "Error details:"
    ldd $XG_INSTDIR/$XG_AVC
    return 1
}

function xg_resolve_in_path {
    basef=$1
    wanted=$2
    libpath=$3

    if [ ! -d "$libpath" ]; then
        # We can't meaningfully report the problem without spamming the console
        # since this function can be called many times.
        return 1
    fi

    if [ -f "$libpath/$wanted" ]; then
        return 0
    fi

    if [ -f "$libpath/$basef" ]; then
        echo "Linking $wanted to $libpath/$basef"
        ln -sf "$libpath/$basef" "$libpath/$wanted"
        return 0
    fi

    # We need to grub around a bit. Ick
    for rfile in `ls $libpath/$basef.* 2>/dev/null`; do
        if [ -f "$rfile" ]; then
            echo "Linking $wanted to $rfile"
            ln -sf "$rfile" "$libpath/$wanted"
            return 0
        fi
    done

    return 1
}

function xg_resolve_dependency {
    basef=$1
    wanted=$2

    if [ "$XG_ARCH" == "x86_64" -o "$XG_ARCH" == "X86_64" ]; then
        echo "Resolving dependencies for 64-bit OS ..."

        for libdir in $XG_LIBPATHS_64; do
            xg_resolve_in_path "$basef" "$wanted" "$libdir" && break
        done
    fi

    for libdir in $XG_LIBPATHS; do
        xg_resolve_in_path "$basef" "$wanted" "$libdir" && return 0
    done

    xg_irresolvable_dependencies

    return 1
}

function xg_fix_dependencies {
    ldd $XG_INSTDIR/$XG_AVC 2>&1 | grep 'not found' | awk '{print $1}' \
            | while read brokefile
    do
        basefile=`echo $brokefile | sed -e 's/\.so.*$/.so/'`
        if [ "$basefile" == "libcrypto.so" ]; then
            xg_resolve_dependency $basefile $brokefile || return 1
        else
            xg_irresolvable_dependencies
            return 1
        fi
    done
    return $?
}

function xg_setup_certificates {
    # Do we have a /usr/share/ssl/cert.pem? (Red Hat)
    RED_HAT_CERTS=/usr/share/ssl/cert.pem
    OTHER_CERTS=/etc/ssl/certs
    CERT_TBZ=certs.tar.bz2
    if [ -r "$RED_HAT_CERTS" ]; then
        echo "Using $RED_HAT_CERTS"
        ln -sf "$RED_HAT_CERTS" "$XG_INSTDIR/cert.pem"
        rm "$XG_INSTDIR/$CERT_TBZ"
        return 0
    fi

    if [ -d "$OTHER_CERTS" -a "`ls $OTHER_CERTS/*.pem 2>/dev/null`" != "" ]
    then
        echo "Using certificates in $OTHER_CERTS"
        ln -sf "$OTHER_CERTS" "$XG_INSTDIR/certs"
        rm "$XG_INSTDIR/$CERT_TBZ"
        return 0
    fi

    echo "Unpacking certificates"
    tar xf "$XG_INSTDIR/$CERT_TBZ" --bzip2 -C "$XG_INSTDIR"
    rm "$XG_INSTDIR/$CERT_TBZ"
    return 0
}

function xg_cmdrun {
    CMD_TO_RUN=$1
    shift

    if [ "`which $CMD_TO_RUN 2>/dev/null`" == "" ]; then
        NEWCMD=
        WHEREIS_CMD=`whereis -b $CMD_TO_RUN`
        for wseg in $WHEREIS_CMD; do
            if [ -f "$wseg" -a -x "$wseg" ]; then
                NEWCMD=`echo "$wseg " | \
                    perl -le 'print <STDIN>=~m{(\S+/$ARGV[0]) }' $CMD_TO_RUN`
                if [ "$NEWCMD" != "" ]; then
                    $NEWCMD $*
                    return $?
                fi
            fi
        done
        # Can't find it
        echo
        echo "Can't find $CMD_TO_RUN in PATH, and whereis reports this:"
        whereis -b $CMD_TO_RUN
        return 1
    fi

    $CMD_TO_RUN $*
    return $?
}

function xg_check_tun {
    echo -n "Looking for tun driver...  "
    XG_TUNDEV=/dev/net/tun

    xg_cmdrun modprobe tun
    if [ "$?" != "0" ]; then
        if [ ! -c "$XG_TUNDEV" ]; then
            echo "$XG_PRODUCT cannot be installed, Can't find tun module"
            return 1
        else
            echo "$XG_TUNDEV is present, assuming static kernel."
        fi
    else
        echo "tun is present and correct."
    fi

    XG_TUNDIR=/dev/net
    if [ ! -d "$XG_TUNDIR" ]; then
        echo "Can't find $XG_TUNDIR, attempting mkdir..."
        mkdir "$XG_TUNDIR"
        if [ "$?" != "0" ]; then
            echo "Unable to create $XG_TUNDIR, aborting install."
            return 1
        else
            echo "Created $XG_TUNDIR."
        fi
    fi

    if [ ! -c "$XG_TUNDEV" ]; then
        echo "Can't find $XG_TUNDEV, attempting mknod..."
        mknod "$XG_TUNDEV" c 10 200
        if [ "$?" != "0" ]; then
            echo "Unable to set up $XG_TUNDEV, aborting install."
            return 1
        else
            echo "Created $XG_TUNDEV."
        fi
    fi
    return 0
}

function xg_check_old_installs {
    if [ -d "$XG_INSTDIR" ]; then
        XG_OLDVER=`cat $XG_INSTDIR/version 2>/dev/null`
        if [ "$XG_OLDVER" != "" ]; then
            XG_TOLDVER=" (`nicever $XG_OLDVER`)"
        fi

        if [ "$XG_OLDVER" == "$XG_VER" ]; then
            XG_SAMEVER=1
            echo "This version of $XG_PRODUCT is already installed."
        else
            echo "$XG_PRODUCT$XG_TOLDVER is already installed."
        fi

        if [ "$UID" != "0" ]; then
            if [ "$XG_SAMEVER" != "" ]; then
                echo "If you wish to re-install, please uninstall first."
                echo "(Run $XG_INSTDIR/uninstall.sh)"
            else
                echo "Please uninstall it (run $XG_INSTDIR/uninstall.sh)" \
                     "and re-run this installer."
            fi
            return 1
        fi

        if [ "$XG_TVER" != "" ]; then
            XG_TNEWVER=" with$XG_TVER"
        fi

        if [ "$AUTOINST" == "" ]; then
            if [ "$XG_SAMEVER" != "" ]; then
                echo -n "Would you like to reinstall it? (y/n) "
            else
                echo -n "Would you like to replace it$XG_TNEWVER? (y/n) "
            fi
            read -n1 overwriteold
            echo
            if [ "$overwriteold" != "y" -a "$overwriteold" != "Y" ]; then
                echo "$XG_PRODUCT installation canceled."
                return 1
            fi
        fi

        if [ -x "$XG_INSTDIR/uninstall.sh" ]; then
            $XG_INSTDIR/uninstall.sh
            if [ "$?" != "0" ]; then
                echo "Failed to uninstall existing $XG_PRODUCT, cannot " \
                     "continue."
                return 1
            fi
        else
            echo "$XG_INSTDIR/uninstall.sh seems to be missing..."
            echo "Please uninstall $XG_PRODUCT manually (delete $XG_INSTDIR)."
            return 1
        fi
    fi
    return 0
}

if [ ! -f "$XG_TAR" ]; then
    XG_TAR=`ls ConnectTunnel*.tar.bz2 2>/dev/null`
    # We also fail if there's more than one tarball.
    if [ ! -f "$XG_TAR" ]; then
        echo "Can't find archive for installation"
        exit 2
    fi
fi

if [ "$XG_OS" != "$XG_INSTOS" ]; then
    if [ "$AUTOINST" != "" ]; then
        echo "$XG_INSTOS installer running on $XG_OS, aborting." >&2
        exit 1
    fi

    echo "This is a $XG_INSTOS installer, you appear to be running $XG_OS."
    echo -n "Are you sure you want to continue? (y/n)"
    read -n1 strangeos
    echo
    if [ "$strangeos" != "y" -a "$strangeos" != "Y" ]; then
        exit 1
    fi

    echo "So be it..."
fi

if [ "$UID" != "0" ]; then
    if [ "$AUTOINST" != "" ]; then
        echo "Need root privileges to install $XG_PRODUCT." >&2
        echo "Can't install as $USER ($UID), aborting..." >&2
        exit 1
    fi

    echo "This installer needs to be run as root, you are $USER."
    echo -n "Try to install anyway? (y/n)"
    read -n1 nonrootresponse
    echo
    if [ "$nonrootresponse" != "y" -a "$nonrootresponse" != "Y" ]; then
        exit 1
    fi
fi

######################################################################
# Change to filesystem root to install

cd /
if [ "$UID" == "0" ]; then
    echo "Installing $XG_PRODUCT$XG_TVER..."
else
    echo "Attempting to install $XG_PRODUCT$XG_TVER..."
fi

xg_check_old_installs || exit 1

# Check if we have the tun module and set up device nodes before starting
# the actual install.
xg_check_tun || exit 1

if ! [ -x "$(command -v bzip2)" ]; then
  echo "bzip2 is required for installation"
  exit 1
fi

echo "Unpacking archive $XG_TAR..."
tar xf "$XG_CWD/$XG_TAR" --bzip2 &>/dev/null

echo "Setting up permissions..."
chmod +x  "$XG_INSTDIR/startct.sh"
chmod +x  "$XG_INSTDIR/uninstall.sh"
chmod +x  "$XG_INSTDIR/startctui.sh"
chmod 755 "$XG_INSTDIR/$XG_AVC"

[ -f "$XG_CWD/version" ] && cp "$XG_CWD/version" "$XG_INSTDIR"

# AvConnect is setuid. Maybe we should ask the user if this is
# what they want?
chown -R root:root "$XG_INSTDIR"
chmod 4755 "$XG_INSTDIR/$XG_AVC"

xg_setup_certificates

ln -fs /usr/local/Aventail/startct.sh /usr/bin/startct
ln -fs /usr/local/Aventail/startctui.sh /usr/bin/startctui

# Repeated dependency checker, so that we bail out if one of our symlinks
# went rogue

xg_fix_dependencies || exit 1
xg_fix_dependencies || exit 1

# And one last direct check, since xg_fix_dependencies is prone to false cheer
UNFOUND=`ldd $XG_INSTDIR/$XG_AVC 2>&1 | grep 'not found'`
if [ "$UNFOUND" != "" ]; then
    echo "Aborting install, $XG_AVC has unresolved dependencies"
    ldd "$XG_INSTDIR/$XG_AVC"
    exit 1
fi

function xg_check_java() {
    echo -n "Looking for Java 11.0 or newer...  "

    if type -p java; then
        echo Java executable found in PATH
        _java=java
    elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
        echo Java executable found in JAVA_HOME
        _java="$JAVA_HOME/bin/java"
    else
        echo "Java not found"
        return 1
    fi

    if [[ "$_java" ]]; then
        version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
        echo Java version "$version"
        version=$("$_java" -version 2>&1 | sed -n ';s/.* version "\([0-9]*\).*".*/\1/p;')

        if [ "$version" -ge 11 ]; then
            echo "Java 11.0 or newer version found"
        else
            echo "Java 11.0 or newer version not found"
            return 1
        fi
    fi

    return 0
}

xg_check_java || exit 1

function add_linux_shortcuts() {
    parents=("$@")
    for parent in "${parents[@]}"; do
        if [ -d "$parent" ]; then
            cat > "$parent/connect-tunnel.desktop" << EOF
[Desktop Entry]
Version=1.0
Exec=startctui
GenericName=SonicWall VPN Connection
Icon=/usr/local/Aventail/logo.png
Name=$XG_PRODUCT
StartupNotify=false
StartupWMClass=com-sonicwall-nixconnect-ConnectApplication
Terminal=false
Type=Application
Categories=GNOME;GTK;Network;
EOF

            chown $SUDO_USER:$SUDO_USER "$parent/connect-tunnel.desktop"
            chmod 0755 "$parent/connect-tunnel.desktop"
        fi
    done
}

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
shortcuts=("$USER_HOME/Desktop" "$USER_HOME/.gnome-desktop" "$USER_HOME/.local/share/applications")

echo "Creating shortcuts..."
add_linux_shortcuts "${shortcuts[@]}"

echo "Done installing $XG_PRODUCT."
echo ""
echo "Use 'startct' to start $XG_PRODUCT (requires Java 11.0 or newer)"
echo "Use 'startctui' to run the $XG_PRODUCT graphical interface (requires Java 11.0 or newer)"
