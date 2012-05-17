require 'json'

# Views are stored as JSON files in the conf_dir. Default for the conf_dir is
# in /var/lib/ganglia/conf. You can change that by specifying an alternate
# directory in conf.php ie.
#
#    $conf['conf_dir'] = "/var/www/html/conf"
#
# You can create or edit existing
# files. Name for a view needs to start with view_ and end with .json e.g.
# view_1.json or view_jira_servers.json. It needs to be unique. This is an
# example definition of a view which will result with a view with 3 different
# graphs.
#
# * key       -	Expected Value
# * view_name -	Name of the view
# * view_type - Standard or Regex. Regex view allows you to specify
#               regex to match hosts.
# * items	    - An array of hashes, describing which metrics should
#               be part of the view.
#
# items member hashes should contain the following:
# * key             -	Expected Value
# * hostname        - Hostname of the host for which we want metric/graph displayed
# * metric          - Name of the metric e.g. load_one.
# * graph	          - Graph Name e.g. cpu_report, load_report.
#                     You can use only metric or graph keys but not both
# * aggregate_graph - If this value exists and is set to true item defines
#                     an aggregate graph. This item needs a hash of
#                     regular expressions and a description.
#
# If you add aggregate_graph item you need to specify a
# host_regex_hash that contains list of of regex elements. Please check the
# example for guidance on how to do it.

#  {
#   "view_name":"jira",
#   "items":[
#     {
#       "hostname":"web01.domain.com",
#       "graph":"cpu_report"
#     },
#     {
#       "hostname":"web02.domain.com",
#       "graph":"load_report"
#     },
#     {
#       "aggregate_graph":"true",
#       "host_regex":[
#         {
#           "regex":"web[2-7]"
#         },
#         {
#           "regex":"web50"
#         }],
#       "metric_regex":[
#         {
#           "regex":"load_one"
#         }],
#       "graph_type":"stack",
#       "title":"Location Web Servers load",
#       "vertical_label":"CPU",
#       "warning":"1",
#       "critical":"2"
#     }],
#  "view_type":"standard"
#  }

action :create do
  template view_name do
    cookbook "ganglia"
    source "web/view.json.erb"
    variables(
      :name => new_resource.name,
      :type => new_resource.type,
      :items_as_json => JSON.pretty_generate(new_resource.items)
    )
    owner "www-data"
    group "www-data"
    mode "0644"
  end
end

action :remove do
  file view_name do
    action :delete
  end
end

def view_name
  "/var/lib/ganglia/conf/view_#{new_resource.name}.json"
end
