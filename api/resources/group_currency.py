"""
    RestFull Resource - POST/GET request handlers
"""

from flask_restful import Resource
from flask import request, jsonify
import json
from groupe_currency_util.currency_parser import groupe_currency_dic
from functools import wraps

# base authorization token - just left it here for validation
SECRET_TOKEN = "RevolutAPI"


def base_auth(func):
    """
     api request  base authorization decorator
    :param func: decorated function
    :return: decorator
    """
    @wraps(func)
    def decorated(*args, **kwargs):
        authorized = False
        try:
            # check is request has right token on it
            token = request.args.get('token')
            authorized = SECRET_TOKEN == token
        except Exception as error:
            pass

        if authorized:
            # continue normally
            return func(*args, **kwargs)
        else:
            # return http error - 500
            errors = {
                'AutorizationError': {
                    'message': "Asses Deny",
                    'status': 500,
                    'extra': "Please, provide secure token",
                },
            }
            return errors, 500
    return decorated


class GroupCurrencyAPI(Resource):
    """
          GroupCurrencyAPI interface
      """
    iMDB = []

    @base_auth
    def get(self, expense_id: int = None):
        """
        Get one Expense item by id
        :param expense_id:
        :return: JSON data, response code, header
        """

        # query_data = Expense.query_get_all(expense_id)
        # query_data = Expense.query_get_all_join_employee(expense_id)
        # result = ExpenseSchema().dump(query_data, many=(expense_id is None))
        parameters = []
        try:
            parameters = request.args.get('parameters')
            parameters = parameters.split(',')
        except Exception as error:
            parameters = []

        result = groupe_currency_dic(GroupCurrencyAPI.iMDB, *parameters)
        # return {'status': 'success', 'data': result}, 200, {'Access-Control-Allow-Origin': '*'}
        return jsonify(result)

    @base_auth
    def post(self):
        """
        create new Expense item
        :return: JSON data, response code, header
       """
        json_value = request.get_json()
        data = json.loads(json_value)
        GroupCurrencyAPI.iMDB = data
        result = "post"
        return {'status': 'success', 'data': result}, 201, {'Access-Control-Allow-Origin': '*'}
