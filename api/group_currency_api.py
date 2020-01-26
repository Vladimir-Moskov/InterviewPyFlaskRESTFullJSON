from flask import Flask
from flask_restful import Api
from api.resources.group_currency import GroupCurrencyAPI

PORT_API_APP = "5001"
SERVER_NAME_API_APP = '/api/v1'
DEBUG_GLOBAL = True

app = Flask(__name__)
api = Api(app, prefix=SERVER_NAME_API_APP)

api.add_resource(GroupCurrencyAPI, '/groupCurrency',  endpoint="groupCurrency_data", methods=['GET', 'POST'])

# http://127.0.0.1:5001/api/v1/groupCurrency
if __name__ == '__main__':
    app.run(port=PORT_API_APP, debug=DEBUG_GLOBAL)