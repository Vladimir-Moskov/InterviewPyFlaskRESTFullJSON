
# no panda usage
import json
from collections import namedtuple
from itertools import groupby
import sys, os, getopt

currency_json_file_name = "../resource/currency.json"
# currency_dto = namedtuple("CurrencyDTO", "currency, country, city, amount")


def currency_json_to_dic():
    currency_data = None
    basepath = os.path.dirname(__file__)
    filepath = os.path.abspath(os.path.join(basepath, currency_json_file_name))
    with open(filepath) as json_file:
        currency_data = json.load(json_file)

    return currency_data


def _delete_key(dic_val, key_val):
    dic_val.pop(key_val, None)
    return dic_val


def groupe_currency_dic(currency_data_ar, *args):
    if len(currency_data_ar) > 0 and len(args) > 0:
        current_key = args[0]
        currency_data_ar.sort(key=lambda currency_data: currency_data[current_key])
        groups = groupby(currency_data_ar, lambda currency_data: currency_data[current_key])
        groups_dic = {key: list(map(lambda dic_val: _delete_key(dic_val, current_key), value)) for key, value in groups}
        for key, sub_item in groups_dic.items():
            groups_dic[key] = groupe_currency_dic(sub_item, *args[1:])
        return groups_dic
    return currency_data_ar


def main(data=None):
    if not data:
        currency_data = currency_json_to_dic()
    else:
        currency_data = data
    currency_dic = groupe_currency_dic(currency_data, 'currency', 'country', 'city')

    currency_dic_str = json.dumps(currency_dic, indent=4, sort_keys=True)
    sys.stdout.write(currency_dic_str)


if __name__ == '__main__':
    data = sys.stdin.readlines()
    args = sys.argv
    sys.stdout.write(repr(args))
    sys.stdout.write(repr(data))
    main()

# C:\Users\bobam\PycharmProjects\InterviewPyRevolut\groupe_currency_util\currency_parser.py
# C:\Users\bobam\PycharmProjects\InterviewPyRevolut\groupe_currency_util\currency_parser.py

# cat C:\Users\bobam\PycharmProjects\InterviewPyRevolut\resource\currency.json | python currency_parser.py currency country city
# type C:\Users\bobam\PycharmProjects\InterviewPyRevolut\resource\currency.json | python currency_parser.py currency country city

