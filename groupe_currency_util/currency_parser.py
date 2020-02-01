"""
    This is basically implementation for

    'write a program that will parse
    this json, and return a nested dictionary of dictionaries of arrays, with keys specified in
    command line arguments and the leaf values as arrays of flat dictionaries matching appropriate
    groups '
    .....
    'Please note, that the nesting keys should be stripped out from the dictionaries in the leaves.
    Also please note that the program should support an arbitrary number of arguments, that is
    arbitrary levels of nesting.'

    Input example in "../resource/currency.json"
    Output example in "../resource/currency_output.json"

    *requirement - no panda usage

    Example of use:

        Windows:
            - 'type InterviewPyFlaskRESTFullJSON\resource\currency.json | python currency_parser.py currency country city'

        Linux:
            - 'cat InterviewPyFlaskRESTFullJSON\resource\currency.json | python currency_parser.py currency country city'

"""
import logging
import json
from collections import namedtuple
from itertools import groupby
import sys
import os

# test file to have default json data
currency_json_file_name = "../resource/currency.json"

# this DTO maybe used for json validation
# currency_dto = namedtuple("CurrencyDTO", "currency, country, city, amount")


# setup logger
app_root_logger = logging.getLogger("InterviewPyFlaskRESTFullJSON")
app_root_logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stderr)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
app_root_logger.addHandler(handler)


def currency_json_to_dic(file_name=None):
    """
    Load default JSON data from local file - testing/debugging purposes

    :return:  json data object with currency info
    """
    if not file_name:
        file_name = currency_json_file_name
    currency_data = None
    try:
        app_root_logger.info(f"Process {__name__} - started.")
        basepath = os.path.dirname(__file__)
        filepath = os.path.abspath(os.path.join(basepath, file_name))
        with open(filepath) as json_file:
            currency_data = json.load(json_file)
    except Exception as error:
        app_root_logger.error(f"Exception in {currency_json_to_dic.__name__}", exc_info=True)
    finally:
        app_root_logger.info(f"Process {currency_json_to_dic.__name__} - end.")
    return currency_data


def _delete_key(dic_val, key_val):
    """
    helper function to delete Obsolete fields from object

    :param dic_val: dictionary/object which needs field to be removed
    :param key_val: key/field needs to be removed
    :return: original dic_val without deleted field
    """
    dic_val.pop(key_val, None)
    return dic_val


def groupe_currency_dic(currency_data_ar, *args):
    """
    Actually this is solution - json parser and grouper by provided fields list.
    This function calls recursively - (not the best solution performance/efficiency wise, but
    looks very nice as an example "code beauty" and "pythonic code" - minimalistic and simple)

    Recursion not suppose to be overflowed - according to given conditions

    :param currency_data_ar: array of flat json objects
    :param args: list of fields for grouping
    :return: groped json in requested format
    """
    try:
        # simple validation before start
        if len(currency_data_ar) > 0 and len(args) > 0:
            # get first field
            current_key = args[0]
            # sort array by this field - according provided output, data needs to be sorted
            currency_data_ar.sort(key=lambda currency_data: currency_data[current_key])
            # group all items by the field with itertools groupby
            groups = groupby(currency_data_ar, lambda currency_data: str(currency_data[current_key]))
            # remove fields from all items
            groups_dic = {key: list(map(lambda dic_val: _delete_key(dic_val, current_key), value)) for key, value in groups}
            # continue grouping for the remaining field for every nested object
            for key, sub_item in groups_dic.items():
                groups_dic[key] = groupe_currency_dic(sub_item, *args[1:])
            return groups_dic
    except Exception as error:
        app_root_logger.error(f"Exception in {groupe_currency_dic.__name__}", exc_info=True)

    return currency_data_ar


def main(json_data, json_fields):
    """
    for use as stand alon script/program - apply json transformation over given data
    from command line or from file

    :param json_data:  array of flat json objects
    :param json_fields:  field to group by
    :return: None, just print result in stdout
    """
    try:
        app_root_logger.info(f"Process {main.__name__} - started.")
        # no data - read from file
        if not json_data:
            currency_data = currency_json_to_dic()
        # data passed - just use it
        else:
            # convert byte array to json str
            #json_data = json_data[0].decode('utf8').replace("'", '"')
            currency_data = json.loads(json_data)
        # get json processing result
        currency_dic = groupe_currency_dic(currency_data, *json_fields)

        # format json beauty
        currency_dic_str = json.dumps(currency_dic, indent=4, sort_keys=True)
        # print result into stdout
        sys.stdout.write(currency_dic_str)
    except Exception as error:
        app_root_logger.error(f"Exception in {main,__name__}", exc_info=True)
    finally:
        app_root_logger.info(f"Process {main.__name__} - end.")

# for use as stand alon script/program
if __name__ == '__main__':
    # TODO: add command line args validation and better parser
    try:
        app_root_logger.info(f"Process {__name__} - started.")
        args = sys.argv
        json_fields = []
        data = None
        # get list of fields from command line arguments
        if len(args) == 1:
            # debug mod - take default params
            # json_fields = ["currency", "country", "city"]
            app_root_logger.warning(f"No any arguments has been provided")
        elif len(args) > 1:
            # first arg is script name - just ignore it
            json_fields = args[1:]

        if "--help" in json_fields:
            # print help - "You can use argparse, to specify parameters. --help should print out usage instructions."
            # docstring should serve user needs
            sys.stdout.write(__doc__)
        else:
            # read array of flat json objects from stdin - as it was asked in task
            data = sys.stdin.readlines()
            if isinstance(data, list):
                # file content from console needs some converting efforts
                 data = "".join(data)

            # run program
            main(data, json_fields)
    except Exception as error:
        app_root_logger.error(f"Exception in {__name__}", exc_info=True)
    finally:
        app_root_logger.info(f"Process {__name__} - end.")


