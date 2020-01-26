"""
    Just simple Flask restfull application as is - API for Task 2

    'Create a REST service from the first task. Make sure your methods support basic auth. Input
    json should be received via POST request, nesting parameters should be specified as request
    parameters.'

    application endpoint - # http://127.0.0.1:5001/api/v1/groupCurrency
"""

from flask import Flask
from flask_restful import Api
from api.resources.group_currency import GroupCurrencyAPI

# api default port -
PORT_API_APP = "5001"
# api url root
SERVER_NAME_API_APP = '/api/v1'
DEBUG_GLOBAL = True

# initialize flask and RestFull api
app = Flask(__name__)
api = Api(app, prefix=SERVER_NAME_API_APP)

# api url mapping
api.add_resource(GroupCurrencyAPI, '/groupCurrency',  endpoint="groupCurrency_data", methods=['GET', 'POST'])

if __name__ == '__main__':
    app.run(port=PORT_API_APP, debug=DEBUG_GLOBAL)