# CIM

Cyber Incident Monitor im Projekt Beemaster.

## ELK Stack

Zur Logaggregation, Persistenz und Visualisierung wird der ELK Stack genutzt. Die einzelnen Komponenten finden sich in dockerisierter Form in den entsprechenden Ordnern.

## Cluster Aufbau

Zum Start verwenden alle Skripte das in diesem Repo befindliche `docker-compose.yml`. Darin findet sich eine Service-Komposition zum Starten eines Kibana und Logstash, sowie 3 Elasticsearch Nodes, aufgeteilt in einen Master und zwei Slaves. Über Umgebungsvariablen wird den einzelnen Cluster Komponenten mitgeteilt, welchem Einsatzzweck sie dienen, dementsprechend werden ggf andere Konfigurationsparameter verwendet (ES slave / master).

**Achtung**: Es sollteen mindestens 8GB RAM auf dem Hostsystem für das CIM zur Verfügung stehen


#### Run

Siehe auch weiter unten für die [initiale Index-Erzeugung](#init_es) bei Elasticsearch.

Elasticsearch benötigt per default einen großen ``mmap`` count, es muss folgender Befehl ausgeführt werden auf jedem Elasticsearch Hostsystem: `sysctl -w vm.max_map_count=262144`. Eine genaue Beschreibung findet sich [hier](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html). Diese Einstellung wird vom `run.sh` Skript in diesem Repository automatisch mit gesetzt; dieses Skript sollte zum starten verwendet werden. Ob das CIM korrekt gestartet wurde, kann man `docker ps` verifiziert werden.

###### Server deployment

Für Starts des CIM auf einem Server sollte das `cim-up.sh` Skript verwendet werden. Es schreibt einen mit Datum versehenen Log und forked sämtliche Prozesse in den Hintergrund.

###### Manueller Start

Das `docker-compose.yml` aus diesem Repository kann direkt zum manuellen Start des CIM verwendet werden: `docker-compose up --build`


## Use

Auf dem Hostsystem wird nach Start des CIM ein Port exportiert. Dieser kann beispielsweise mit `netstat -tulpen` inspiziert werden. Es sollte lediglich `127.0.0.1:5600` exportiert werden. Dahinter lauscht das Kibana Webinterface. Restliche, Cluster-interne Kommunikation findet in einem Docker Subnet statt.

Kibana ist damit noch nicht von Außerhalb des Hostsystems erreichbar, denn es bindet nicht auf 0.0.0.0. Das hat den Grund, dass wir im Beemaster Projekt einen Reverseproxy mit BasicAuth und Https verwenden, um das Kibana vor unbefugten Zugriffen zu schützen. 

Dieser Port-Export kann in der `docker-compose.yml` geändert werden, Kibana kann öffentlich unter bspw. Port 5601 erreichbar gemacht werden indem 
```
ports:
  - "127.0.0.1:5600:5601"
```
geändert wird zu
```
ports:
  - "5601:5601"
```


#### Logstash

Logstash aggregiert sämtliche vom Bro Master erstellten Logs. Diese Logs müssen für Logstash zugänglich gemacht werden. Im Beemaster Projekt geschieht dies über ein Mountvolume. Der Ordner, in dem der Bro Master seine Logdateien ablegt, wird in den Logstash Container gemounted. Auch dies kann in der `docker-compose.yml` geändert werden.

Im Ordner `logstash/config` liegt die verwendete Konfiguration. Für jede von Bro erstellte Datei gibt es dort ein eigenen eigenen Block.

<a name="init_es"/>
#### Elasticsearch Initiale Index Erzeugung

Leider tritt mit der aktuellen ES Version ein Fehlverhalten für den ersten Start der Software auf. Elasticsearch bleibt in einer Loop gefangen, in der neue Indices nicht korrekt erstellt werden.

Die Lösung (nur beim ersten Start!) ist, einmal alle Indices zu löschen und sie wieder neu erstellen zu lassen.

```
docker exec -ti mpidscim_es-master_1 bash
curl -XDELETE http://localhost:9200/.kibana
```

#### Elasticsearch Feld Indizierung

Damit Elasticsearch die Felder der gespeicherten JSON Nachrichten richtig durchsuchbar macht, müssen diese bekannt gemacht werden. 

In der Kibana Weboberfläche zunächst auf `Management` klicken, dann dort den `logstash-*` Index auswählen und das orange `refresh` Symbol einmal klicken. 