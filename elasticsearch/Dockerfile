FROM elasticsearch:5

# use the official upstream repo from elastic.co. NO TROUBLE! :)

ENV ES_JAVA_OPTS="-Des.path.conf=/etc/elasticsearch"
CMD ["-E", "network.host=0.0.0.0", "-E", "discovery.zen.minimum_master_nodes=1"]