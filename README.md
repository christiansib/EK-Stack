# CIM

Cyber Incident Monitor im Projekt Beemaster

### ELK Stack

Vorerst wird der volle ELK Stack genutzt. Die einzelnen Komponenten finden sich in Dockerisierter Form in den entsprechenden Ordnern.

*Run*

Das hier scheint notwendig zu sein, muss auf dem **Docker-Host** ausgeührt werden (sprich DEINEM Laptop):
`-w vm.max_map_count=262144`

Anschließend ein kleines Setup mit einer ES Node, einem Kibana und einem LS starten:
`docker-compose up`
Dafür muss docker-compose installiert sein.
