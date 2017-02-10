# CIM

The Cyber-Incident-Monitor of Beemaster. It features the visualization of logs and offers to inspect and search data.


## ELK stack

The ELK stack is used for logaggregation (Logstash), persistency/search (Elasticsearch) and visualization (Kibana). A Docker setup for the different components is to be found in the respective folders.

## Cluster setup

The [docker-compose](docker-compose.yaml) file of this repository is used for starting a CIM cluster. It consists of one Logstash and one Kibana node, as well as three Elasticsearch nodes. The ES nodes are split into one master and two slaves, where the slaves are solely responsible for persisting data. They are mirrored copies of each other. Environment variables are used to decide the purpose of a cluster node.

**Warning**: For running the CIM cluster you should at least have 8GB of RAM.


#### Start up

For starting you should use [`run.sh`](run.sh). At the first startup, you have to initialize the Elasticsearch index. See below for [initial index creation](#init_es)

By default, Elasticsearch needs some quite big ``mmap`` count. For ES being able to start, the following command has to be run on the Elasticsearch hostsystem (not inside the container, real host): `sysctl -w vm.max_map_count=262144`. Please find more detail in the official [docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html). This property is set automatically by the `run.sh` script. To verify the CIM started correctly, use `docker ps`.

###### Server deployment

For server installations of the CIM, you can use the `cim-up.sh` script. It writes a dedicated logfile and decouples all processes from the current usersession.

###### Manual start

The `docker-compose.yml` of this repo can be used to start the CIM manually: `docker-compose up --build`


## Usage

After starting the CIM, one port gets bound to the hostsystem. You can inspect it with eg `netstat -tulpen`. The only exposed port should be `127.0.0.1:5600` (global expose is not wanted, only local). Kibana is listening behind this port. All other internal cluster communcation is boxed by a Docker subnet.

This way, Kibana is not reachable from outside the hostsystem, since it does not bind to `0.0.0.0`. This is because at Beemaster we use a reverseproxy with HTTPS and BasicAuth for security reasons.

##### Port accessability

It is possible to change to locally exposed port to a publicly exposed port by doing the following changes to the `docker-compose.yaml`

```yaml
ports:
  - "127.0.0.1:5600:5601"
```
change to
```yaml
ports:
  - "5601:5601"
```

#### Logstash

Logstash is used for logaggregation of all Bro master logs. The logs have to be made available inside the logstash container. Thus, we use a mountvolume for the folder that is used by the Bro master. It is possible to change the logfile location within the `docker-compose.yml`.

The logstash configuration can be found at `logstash/config`. The config features one block of parsing instructions per logfile that is written by the Bro master.

<a name="init_es"/>
#### Elasticsearch
##### Initial index creation

Unfortunately there exists a bug in the current Elasticsearch version 5.1.1. ES falls into a loop failing to create empty indices.

The solution (just for the very first start!) is to clean and recreate the `.kibana` index once.

Example shell code, assuming your Elasticsearch master is called `mpids_es-master_1`:
```shell
docker exec -ti mpidscim_es-master_1 bash
curl -XDELETE http://localhost:9200/.kibana
```

##### Field indexing

For ES being able to search the JSON message fields correctly, the message fields have to be analyzed. Go to the Kibana webinterface and click `Management`, then `Index patterns`. Select the `logstash-*` index and then hit the orange `refresh` button. This makes ES index all fields that are unknown to it (eg. if you have a new log file you want to start viszualizing).