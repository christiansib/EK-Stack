# MP-IDS Cyber Incident Monitor

The Beemaster cyber incident monitor (CIM) features the visualization of (meta) alerts and allows to inspect and search the log files containing them.


## ELK Stack

The ELK stack is used for log file aggregation (Logstash), persistency/search (Elasticsearch) and visualization (Kibana). A Docker setup for the different components is to be found in the respective folders.

## Cluster Setup

The [docker-compose](docker-compose.yml) file of this repository is used for starting a CIM cluster. It consists of one Logstash and one Kibana node, as well as three Elasticsearch (ES) nodes. The ES nodes are splitted into one master and two slaves. The slaves are solely responsible for persisting data and mirrored copies of each other. Environment variables are used to decide the purpose of a cluster node.

**Warning**: For running the CIM cluster you should have at least 8GB of RAM.


#### Start-Up

For starting you should use [`run.sh`](run.sh). At the first start-up, you must initialize the Elasticsearch index. See below for [initial index creation](#init_es)

By default, Elasticsearch needs some quite big ``mmap`` count. For ES being able to start, the following command must be executed on the Elasticsearch hostsystem (not inside the container, real host): `sysctl -w vm.max_map_count=262144`. Please find more details in the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html). This property is set automatically by the `run.sh` script. Use `docker ps` to verify that the CIM started correctly.

###### Server Deployment

For server installations of the CIM, you can use the `cim-up.sh` script. It writes a dedicated log file and decouples all processes from the current user session.

###### Manual Start

The `[docker-compose.yml](docker-compose.yml)` in this repository can be used to start the CIM manually: `docker-compose up --build`


## Usage

After starting the CIM, one port gets bound to the host system. You can inspect it using for example `netstat -tulpen`. The only exposed port should be `127.0.0.1:5600` (global expose is not appreciated, only local). Kibana is listening behind this port. A Docker subnet boxes all other internal cluster communication.

This way, Kibana is not reachable from outside the host system, since it does not bind to `0.0.0.0`. We do this, because we use a reverse proxy with HTTPS and BasicAuth for security reasons.

##### Port Accessibility

It is possible to change to locally exposed port to a publicly exposed port by doing the following changes to the `docker-compose.yml`

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

Logstash is used for log aggregation of all Bro master log files. These files have to be made available inside the Logstash container. Thus, we use a mount volume for the folder that is used by the Bro master. It is possible to change the log file location within the `docker-compose.yml`.

The Logstash configuration can be found at `logstash/config`. The configuration features one block of parsing instructions per log file.

<a name="init_es"/>
#### Elasticsearch
##### Initial Index Creation

Unfortunately, there exists a bug in the current Elasticsearch version 5.1.1. ES falls into a loop failing to create empty indices.

The solution (only for the very first start!) is to clean and recreate the `.kibana` index once.

Example shell code, assuming your Elasticsearch master is called `mpids_es-master_1`:
```shell
docker exec -ti mpidscim_es-master_1 bash
curl -XDELETE http://localhost:9200/.kibana
```

##### Field Indexing

The message fields have to be analysed, otherwise ES is not able to search the JSON message fields correctly. Go to the Kibana web interface and click `Management`, then `Index patterns`. Select the `logstash-*` index and hit the orange `refresh` button. This makes ES index all fields that are unknown to it (e.g. if you have a new log file you want to start visualizing).


## License attributions

The whole Elasticstack is licensed under the Apache License v2 ([Elasticsearch](https://github.com/elastic/elasticsearch/blob/master/LICENSE.txt), [Logstash](https://github.com/elastic/logstash/blob/master/LICENSE), [Kibana](https://github.com/elastic/kibana/blob/master/LICENSE.md))

Beemaster does solely use the Elastic software without any modification of source code. All credits regarding any Elastic product to the respective creators of those projects. Beemaster does not claim to own, modify or redistribute any of the used software components. The applied MIT license only regards the work done during the Beemaster project, including but not limitting to the creation of dashboards, provided scripts and configuration files.