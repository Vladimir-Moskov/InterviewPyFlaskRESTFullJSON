"""
    just a minimal amount of tests - have time shortage

"""
import os
import pytest
import json
import groupe_currency_util.currency_parser as currency_parser


def test_groupe_currency_dic_positive():
    """
    Just simple verify case from task
    :return: Test result
    """
    fields = ["currency", "country", "city"]
    data_json = currency_parser.currency_json_to_dic()
    result = currency_parser.groupe_currency_dic(data_json, *fields)
    expected_result = currency_parser.currency_json_to_dic("../resource/currency_output.json")
    assert result == expected_result


def test_groupe_currency_dic_positive_no_fields():
    """
    Just simple verify case from task, but no fields provided
    :return: Test result
    """
    data_json = currency_parser.currency_json_to_dic()
    result = currency_parser.groupe_currency_dic(data_json)
    assert result == data_json


def test_groupe_currency_simple_dic_positive():
    """
    Just simple verify one item object
    :return: Test result
    """
    fields = ["amount"]
    data_json = currency_parser.currency_json_to_dic("../resource/currency_simple.json")
    result = currency_parser.groupe_currency_dic(data_json, *fields)
    expected_result = currency_parser.currency_json_to_dic("../resource/currency_simple_output.json")
    assert result == expected_result


def test_groupe_currency_simple_dic_positive_no_fields():
    """
    Just simple verify one item object,  but no fields provided
    :return: Test result
    """
    data_json = currency_parser.currency_json_to_dic("../resource/currency_simple.json")
    result = currency_parser.groupe_currency_dic(data_json)
    assert result == data_json


def test_groupe_currency_empty_dic_positive_no_fields():
    """
    Just simple verify one item object,  but no fields provided
    :return: Test result
    """
    data_json = []
    result = currency_parser.groupe_currency_dic(data_json)
    assert result == data_json
