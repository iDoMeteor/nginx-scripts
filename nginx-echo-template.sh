echo "include /etc/nginx/templates/subdomain-01.conf
include /etc/nginx/templates/subdomain-02.conf
server_name $HOST;
include /etc/nginx/templates/subdomain-03.conf
server_name $HOST;
include /etc/nginx/templates/subdomain-04.conf"
