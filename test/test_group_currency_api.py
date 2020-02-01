"""
    just a minimal amount of tests - have time shortage

    * btw - run api application first
"""

import pytest
import requests
import json
from groupe_currency_util.currency_parser import currency_json_to_dic
from api.resources.group_currency import SECRET_TOKEN
# api-endpoint
URL = "http://127.0.0.1:5001/api/v1/groupCurrency"


@pytest.fixture(scope='module')
def post_data():
    data_json = currency_json_to_dic()
    request_self = requests.post(url=URL, json=json.dumps(data_json), params={"token": SECRET_TOKEN})
    assert request_self.status_code == 201


def test_groupcurrency_post_no_token():
    data_json = currency_json_to_dic()
    request_self = requests.post(url=URL, json=json.dumps(data_json))
    assert request_self.status_code == 500


def test_groupcurrency_post_wrong_token():
    data_json = currency_json_to_dic()
    request_self = requests.post(url=URL, json=json.dumps(data_json), params={"token": 'NOT_SECRET_TOKEN'})
    assert request_self.status_code == 500


def test_groupcurrency_post_right_token():
    data_json = currency_json_to_dic()
    request_self = requests.post(url=URL, json=json.dumps(data_json), params={"token": SECRET_TOKEN})
    assert request_self.status_code == 201


def test_groupcurrency_get_wrong_token(post_data):
    fields = "currency,country,city"
    request_self = requests.get(url=URL, params={"token": "xxx", "parameters": fields})
    assert request_self.status_code == 500


def test_groupcurrency_get_right_token(post_data):
    fields = "currency,country,city"
    request_self = requests.get(url=URL, params={"token": SECRET_TOKEN, "parameters": fields})
    assert request_self.status_code == 200
