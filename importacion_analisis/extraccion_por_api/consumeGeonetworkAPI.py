import requests
with open("../../../../../access_dump/accesos", "r") as f:
    lines=[line.rstrip() for line in f]

lGeon = lines.index("# API geonetwork")
usuario = lines[lGeon + 1].replace("usuario: ","")
passw = lines[lGeon + 2].replace("password: ","")
apiurl_search = "http://geonetwork.humboldt.org.co/geonetwork/srv/eng/xml.search"
apiurl_metaGet = "http://geonetwork.humboldt.org.co/geonetwork/srv/eng/xml.metadata.get"

headers_search = {'content-type': 'application/json', 'Accept': 'application/json', 'User-Agent': 'python-requests/2.32.3'}

se = requests.get(apiurl_search, headers=headers_search, auth=(usuario,passw))

