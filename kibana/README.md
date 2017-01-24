# CIM

## Kibana Dashboard Management

In Kibana, click on "Management" in the left menu and on the next page on
"Saved Objects". Here you can manage the Dashboard and its Visualizations.

#### Export
Use the "Export Everything" button to export the Dashboard *together* with its Visualizations.
Be advised that also searches etc. get exported.
Be sure that your Kibana contains *only and all* you want to export.

#### Import
* **Be sure that all fields exist before importing** Visualization. If a field
cannot be found you get an error message and the Visualization will not be 
imported.
  * In an ideal world, you have at least one entry in every logfile logstash can
  provide.
  * Just in case, update the "Index Patterns" (do **not** delete it)
* Import [the file](export-everything-dashboards-vis.json).


#### New Visualizations

Rule of thumb: Define the data source (aka query) in your Visualization, so it
does not depend on anything else (do **not** use saved queries).