# CIM

Cyber Incident Monitor im Projekt Beemaster

## ELK Stack

Vorerst wird der volle ELK Stack genutzt. Die einzelnen Komponenten finden sich in Dockerisierter Form in den entsprechenden Ordnern.

####Run

Das hier scheint notwendig zu sein, muss auf dem **Docker-Host** ausgeührt werden (sprich DEINEM Laptop):
`sysctl -w vm.max_map_count=262144`

Anschließend ein kleines Setup mit einer ES Node, einem Kibana und einem LS starten:
`docker-compose up`
Dafür muss docker-compose installiert sein.

Alternativ kann auch das `run.sh` Script genutzt werden.


#### Use

Auf deinem Rechner werden nun Ports exportiert. Du kannst über `localhost:5601` die Weboberfläche von Kibana besuchen. Wunder dich nicht, die Indices sind leer und auch sonst kann man grade nicht viel tun.
Auf `localhost:5000` kannst du Logstash Daten übergeben, mit denen passiert aber noch nichts sinnvolles.
