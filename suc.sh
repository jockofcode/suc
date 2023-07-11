# set -euo pipefail
while /usr/bin/true
do
    read -r line || exit 0  # EOF
    /usr/bin/echo "$(/usr/bin/date --iso-8601=seconds)" "$(printf "%-9s" "$(/usr/bin/id --user --name --real)")" "$line" >> /var/lib/suc/"$1"
done
