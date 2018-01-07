# Bold Leads Nginx Scripts

## nginx-add-php-vhost.sh

Usage:
```bash
nginx-disable-vhost.sh -h <FQDN> -r <DOCUMENT_ROOT> [--verbose] [--yes]
nginx-disable-vhost.sh --host <FQDN> --root <DOCUMENT_ROOT> [--verbose] [--yes]
```

Use the -y option in scripts to prevent the script asking if it should restart
Nginx.  It will then restart Nginx itself if there are no errors.

## nginx-disable-vhost.sh

Use this script to prevent Nginx from responding to requests to a fully
qualified domain name.  Technically, it removes the symbolic link from
sites-enabled/ while leaving the actual file residing in sites/available.
```bash
nginx-disable-vhost.sh -h <FQDN> [--verbose] [--yes]
nginx-disable-vhost.sh --host <FQDN> [--verbose] [--yes]
```

## nginx-enable-vhost.sh

Use this script to reverse the effects of nginx-disable-vhost.sh.
```bash
nginx-enable-vhost.sh -h <FQDN> [--verbose] [--yes]
nginx-enable-vhost.sh --host <FQDN> [--verbose] [--yes]
```


## nginx-remove-vhost.sh

Use this script to reverse the effects of nginx-disable-vhost.sh.
```bash
nginx-remove-vhost.sh -h <FQDN> [--verbose] [--yes]
nginx-remove-vhost.sh --host <FQDN> [--verbose] [--yes]
```


