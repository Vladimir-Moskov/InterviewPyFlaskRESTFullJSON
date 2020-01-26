import requests
import json
from groupe_currency_util.currency_parser import currency_json_to_dic

# api-endpoint
URL = "http://127.0.0.1:5001/api/v1/groupCurrency"

data_json = currency_json_to_dic()
request_self = requests.post(url=URL, json=json.dumps(data_json))
print(request_self)

fields = "currency,country,city"
request_self = requests.get(url=URL, params={"token": "xxx", "parameters": fields})
print(request_self.json())