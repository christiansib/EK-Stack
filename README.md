# CIM

Der Cyber Incident Monitor im Projekt Beemaster nutzt Kibana zur Visualisierung.

## ELK-Stack
Zur Logaggregation (Logstash), Persistenz (Elasticsearch) und Visualisierung (Kibana) wird der ELK-Stack genutzt. Die einzelnen Komponenten finden sich in dockerisierter Form in den entsprechenden Ordnern.

## Cluster-Aufbau

Zum Start verwenden alle Skripte das in diesem Repository befindliche `docker-compose.yml`. Die darin beschriebene Service-Komposition startet eine Kibana- und Logstash- sowie drei Elasticsearch-Nodes (aufgeteilt in einen Master und zwei Slaves). Über Umgebungsvariablen wird den einzelnen Cluster-Komponenten mitgeteilt, welchem Einsatzzweck sie dienen. Dementsprechend werden ggf. andere Konfigurationsparameter verwendet (ES slave / master).

**Achtung**: Es sollten mindestens 8GB RAM auf dem Hostsystem für das CIM zur Verfügung stehen


#### Starten

Zum Starten sollte das [`run.sh`](run.sh) Skript verwendet werden. Beim ersten Start muss der Elasticsearch-Index initialisiert werden. Siehe weiter unten [initiale Index-Erzeugung](#init_es) bei Elasticsearch.

Elasticsearch benötigt standardmäßig einen großen ``mmap`` count. Damit es zu keinen Speicherfehlern kommt, muss folgender Befehl auf jedem Elasticsearch Hostsystem ausgeführt werden: `sysctl -w vm.max_map_count=262144`. Eine genaue Beschreibung findet sich [hier](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html). Diese Einstellung wird vom `run.sh` Skript in diesem Repository automatisch mit gesetzt; dieses Skript sollte zum Starten verwendet werden. Ob das CIM korrekt gestartet wurde, kann mit Hilfe von `docker ps` verifiziert werden.

###### Server-Deployment

Für Starts des CIM auf einem Server sollte das `cim-up.sh` Skript verwendet werden. Es schreibt ein mit Datum versehene Logdatei und forked sämtliche Prozesse in den Hintergrund.

###### Manueller Start

Das `docker-compose.yml` aus diesem Repository kann direkt zum manuellen Start des CIM verwendet werden: `docker-compose up --build`


## Verwendung

Auf dem Hostsystem wird nach Start des CIM ein Port nach außen freigegeben. Dieser kann beispielsweise mit `netstat -tulpen` inspiziert werden. Es sollte lediglich `127.0.0.1:5600` zugänglich sein. Hinter diesem Port lauscht das Kibana-Webinterface. Restliche Cluster-interne Kommunikation findet in einem Docker Subnet statt.

Kibana ist damit noch nicht von Außerhalb des Hostsystems erreichbar, da es *nicht* auf `0.0.0.0` bindet. Das hat den Grund, dass wir im Beemaster Projekt einen Reverseproxy mit BasicAuth und HTTPS verwenden, um das Kibana vor unbefugten Zugriffen zu schützen. 

##### Port für Zugriff von außen anpassen
Der Port-Export kann in der `docker-compose.yml` geändert werden. Kibana kann z.B. öffentlich unter Port 5601 erreichbar gemacht werden indem 
```yaml
ports:
  - "127.0.0.1:5600:5601"
```
geändert wird zu
```yaml
ports:
  - "5601:5601"
```


#### Logstash

Logstash aggregiert sämtliche vom Bro-Master erstellten Logs. Diese Logs müssen für Logstash zugänglich gemacht werden. Im Beemaster Projekt geschieht dies über ein Mountvolume. Der Ordner, in dem der Bro-Master seine Logdateien ablegt, wird in den Logstash Container gemounted. Auch dies kann in der `docker-compose.yml` geändert werden.

Im Ordner `logstash/config` liegt die verwendete Konfiguration. Für jede von Bro erstellte Datei gibt es dort einen eigenen Block.

<a name="init_es"/>
#### Elasticsearch
##### Initiale Index-Erzeugung

Leider tritt mit der aktuellen Elasticsearch-Version 5.1.1 ein Fehlverhalten beim ersten Start der Software auf. Elasticsearch bleibt in einer Loop gefangen, in der neue Indices nicht korrekt erstellt werden.

Die Lösung (nur beim ersten Start!) ist, einmal alle Indices zu löschen und sie wieder neu erstellen zu lassen.
Beispielhafter Shell-Code:
```shell
docker exec -ti mpidscim_es-master_1 bash
curl -XDELETE http://localhost:9200/.kibana
```

##### Feld-Indizierung

Damit Elasticsearch die Felder der gespeicherten JSON-Nachrichten durchsuchbar macht, müssen diese bekannt gemacht werden. 

Dazu in der Kibana Weboberfläche zunächst auf `Management` klicken, dann dort den `logstash-*` Index auswählen und das orange `refresh` Symbol einmal klicken.
