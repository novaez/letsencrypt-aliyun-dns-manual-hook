#!/usr/bin/env bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"
EMAIL=
DOMAIN=
FORCE=

while getopts "m:d:fn:" opt; do
  case $opt in
    m)
      EMAIL=${OPTARG}
      ;;
    d)
      DOMAIN=${OPTARG}
      ;;
    f)
      FORCE=1
      ;;
    n)
      TLD_LEN=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

if [ -z "${DOMAIN}" ]; then
  echo "Option:-d is necessary."
  exit 1
fi

cmd="certbot certonly"
if [ -n "${EMAIL}" ]; then
  cmd="${cmd} --email ${EMAIL} "
fi

if [ -n "${FORCE}" ]; then
  cmd="${cmd} --force-renewal "
fi

cmd="${cmd} -n --manual-public-ip-logging-ok --agree-tos --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory --manual --manual-auth-hook 'python $DIR/manual-hook.py --auth ${TLD_LEN}' --manual-cleanup-hook 'python $DIR/manual-hook.py --cleanup' -d ${DOMAIN} -d *.${DOMAIN}"

eval ${cmd}
