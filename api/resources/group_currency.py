"""
    RestFull Resource - POST/GET request handlers

    * there is no logging in api app - flask default logging enough for now
"""
# TODO: handle server errors properly

from flask_restful import Resource
from flask import request, jsonify
import json
from groupe_currency_util.currency_parser import groupe_currency_dic
from functools import wraps

# base authorization token - just left it here for validation
SECRET_TOKEN = "TOKEN_InterviewPyFlaskRESTFullJSON"


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
          to POST Json data and GET it grouped by fields
      """
    iMDB = []

    @base_auth
    def get(self):
        """
        Get JSON grouped by fields - from url arg parameters, with coma separated fields name

        :return: JSON data, with response code
        """
        # get args from request - 'nesting parameters should be specified as request'
        parameters = []
        try:
            parameters = request.args.get('parameters')
            parameters = parameters.split(',')
        except Exception as error:
            # in case of any problem just ignore them - error tolerated behaviour, some time maybe not a good idea,
            # - just for code tack could be done in this way
            parameters = []
        # process json conversion and return result
        result = groupe_currency_dic(GroupCurrencyAPI.iMDB, *parameters)
        return jsonify(result)

    @base_auth
    def post(self):
        """
        update iMDB with new data - always override mode
        :return: response code
       """
        try:
            # set data into iMDB
            json_value = request.get_json()
            data = json.loads(json_value)
            GroupCurrencyAPI.iMDB = data
        except Exception as error:
            # return error in case of any problem
            result = "iMDB has not been updated with new data."
            return {'status': 'error', 'data': result, 'error': repr(error)}, 500

        result = "iMDB has been updated with new data."
        return {'status': 'success', 'data': result}, 201
