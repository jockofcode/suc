#!/usr/bin/bash
set -euxo pipefail

usage(){
    cat <<EOF
suc_channel.

Create (or reconfigure if it already exists) a suc channel.

Usage:
    suc_channel.sh -h
    suc_channel.sh [(-p|-d) <group>] -c <channel>

Options:
    -h            Show this text.
    -p <group>    Only members of <group> will be able to read and write to channel (p for "Private").
    -d <group>    Only members of <group> will be able to read channel.
                  All members of the suc group will be able to write (typically to request access, d for "Dropbox").
    -c <channel>  Channel name. If no -p or -d option is provided, the channel will be public:
                  anybody in the suc group will be able to read it and write to it.

EOF
    exit "$1"
}

install-channel(){
    WRITERS="$1"  # User and group with same name, who can write
    READERS="$2"  # Group, who can read
    CHANNEL="$3"  # Channel name
    SUC=/usr/bin/suc_"$WRITERS"  # Binary name
    if [ "$WRITERS" = "suc" ]
    then
        SUC=/usr/bin/suc  # Default back to suc instead of suc_suc
    fi

    # Ensure readers group exists
    if ! getent group | grep -E "^${READERS}:"
    then
        groupadd "$READERS"
    fi
    # Ensure writers group exists
    if ! getent group | grep -E "^${WRITERS}:"
    then
        groupadd "$WRITERS"
    fi
    # Ensure writer user exists
    if ! grep -E "^${WRITERS}:" /etc/passwd
    then
        useradd --home-dir=/ --gid="$WRITERS" --no-create-home --shell=/usr/bin/nologin "$WRITERS"
    fi
    # Ensure channel exists
    if [ ! -f /var/lib/suc/"$CHANNEL" ]
    then
        touch /var/lib/suc/"$CHANNEL"
    fi

    # user WRITERS can rw, group READERS can r, o can nothing
    chown "$WRITERS":"$READERS" /var/lib/suc/"$CHANNEL"
    chmod u=rw,g=r /var/lib/suc/"$CHANNEL"

    # group WRITERS can launch suc as user WRITERS and thus can w.
    chown "$WRITERS":"$WRITERS" "$SUC"
    chmod 04754 "$SUC"
}

PUBLIC=true
while getopts :hp:d:c: flag
do
    case "${flag}" in
        d ) GROUP="${OPTARG}"
            DROPBOX=true;;
        p ) GROUP="${OPTARG}"
            PRIVATE=true;;
        c ) CHANNEL="${OPTARG}";;
        h ) usage 0 ;;
        * ) usage 1 ;;
    esac
done
if [ -z ${CHANNEL+x} ]
then
    usage 1
fi
if [ "$PRIVATE" = true ]
then
    install-channel "$GROUP" "$GROUP" "$CHANNEL"
elif [ "$DROPBOX" = true ]
then
    install-channel suc "$GROUP" "$CHANNEL"
elif [ "$PUBLIC" = true ]
then
    install-channel suc suc "$CHANNEL"
fi
