#!/bin/sh

echo "Starte Mapping für Index: Honeypot"
curl -XPUT 'localhost:9200/honeypot?pretty' -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "_default_": {
      "properties": {
        "date": {
          "type":   "date",
          "format": "yyyy-MM-dd'\''T'\''HH:mm:ss.SSSSSS"
        }
      }
    }
  }
}
'
echo "Lade Beispiel logs in Elasticsearch"
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/err/_bulk?pretty' --data-binary @err.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/file/_bulk?pretty' --data-binary @file.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/info/_bulk?pretty' --data-binary @info.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/login/_bulk?pretty' --data-binary @login.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/request/_bulk?pretty' --data-binary @request.json
curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/honeypot/response/_bulk?pretty' --data-binary @response.json

echo "Fertig. Jetzt in Kibana nach dem Index: Honeypot suchen und date als Zeitstempel auswählen."