# CIM

Cyber Incident Monitor im Projekt Beemaster

## ELK Stack

Vorerst wird der volle ELK Stack genutzt. Die einzelnen Komponenten finden sich in Dockerisierter Form in den entsprechenden Ordnern.

#### Run

Das hier scheint notwendig zu sein, muss auf dem **Docker-Host** ausgeührt werden (sprich DEINEM Laptop bzw. dem Server) :
`sysctl -w vm.max_map_count=262144`. Das Setting legt fest, wie viel Elasticsearch (Java VM) maximal an Memory allockieren darf. Und es möchte gerne mehr als den Standard haben.

Anschließend ein kleines Setup mit einer ES Node, einem Kibana und einem LS starten:
`docker-compose up`
Dafür muss docker-compose installiert sein.

Alternativ kann auch das `run.sh` Script genutzt werden.

**Achtung**: Du solltest mindestens 8GB RAM auf deinem Laptop / Rechner zur Verfügung haben. Sonst wirds ungemütlich.


#### Use

Auf deinem Rechner werden nun Ports exportiert. Du kannst über `localhost:5600` die Weboberfläche von Kibana besuchen. Wunder dich nicht, die Indices sind leer und auch sonst kann man grade nicht viel tun.
Auf `localhost:5000` kannst du Logstash Daten übergeben, mit denen passiert aber noch nichts sinnvolles.

#### Logstash

Im Ordner `logstash/config` liegt eine rudimentäre Beispielconfig. Wenn man diese Config ändert, muss man den container neu bauen - dazu sollte es in unserem Fall ausreichen, die `run.sh` erneut auszuführen. Die Config wird in den Logstash Container kopiert.


## CIM Server Deployment

Es gibt ein `cim-up.sh` script, das genutzt werden sollte, wenn das CIM auf dem Server gestartet wird. Es entkoppelt den Prozess von der aktuellen Session und schreibt alles, was die Container zu sagen haben in eine Logdatei. Das ist wichtig, denn wenn wirklich mal was kaputt geht und die Uni Logs sehen will, dann haben wir sie.

Kopiere den CIM Ordner nach `/opt`, setze die Berechtigungen falls nötig und führe `./cim-up.sh` aus.

## Initial Index Creation

Leider tritt mit der aktuellen ES Version ein Fehlverhalten für den ersten Start der Software auf. Elasticsearch bleibt in einer Loop gefangen, in der neue Indices nicht korrekt erstellt werden.

Die Lösung (nur beim ersten Start!!!!) ist, einmal alle Indices zu löschen und sie wieder neu erstellen zu lassen.

```
docker exec -ti mpidscim_es-master_1 bash
curl -XDELETE http://localhost:9200/.kibana
```
