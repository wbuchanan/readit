import json
import jsonschema
import inspect
from pandas import read_stata, \
    read_csv, \
    read_excel, \
    read_spss, \
    read_sas, \
    read_html, read_pickle, \
    read_table, \
    read_json, \
    read_fwf, \
    read_feather, \
    read_parquet, \
    read_hdf
try:
    from pandas.io.json import json_normalize  # old location
except:
    from pandas import json_normalize

PANDAS_IO = [ read_stata, read_csv, read_excel, read_spss, read_sas,
              read_html, read_pickle, read_table, read_json, read_fwf,
              read_feather, read_parquet, read_hdf, json_normalize ]


def validate_config(config: {}) -> bool:
    """
    A function that validates the configuration object.
    :param config: A readit configuration object.
    :return: A boolean indicating whether the
    """
    schema = json.load('./readit.schema.json')
    try:
        jsonschema.validate(config, schema)
        return True
    except jsonschema.ValidationError as error:
        print('Configuration for readit contained an error: %s'.format(error))
        return False

def get_signatures() -> {}:
    """
    Helper method used to identify the valid arguments that can be passed
    to any of the pandas IO functions used by the program
    :return: Returns a dictionary containing the available arguments for each pandas IO method
    """
    # Creates an empty dictionary to collect the function names and signatures
    sigreturn = {}
    # Loops over the functions that are used for IO operations
    for io in PANDAS_IO:
        # Gets the name of the function in question
        funcname = io.__name__
        # Gets the list of arguments that the function can take
        args = list(inspect.signature(io).parameters.keys())
        # Adds the arguments to the dictionary with the function name as the key
        sigreturn[funcname] = args
    # Returns the dictionary object
    return sigreturn
