from os import path
import json
from . import CONSTS


def make_config(files: [str], renameAll: str, globalOptions: str, globalFileType: str,
                fileoptions: { str : str }) -> {}:
    """
    A function to generate a configuration object if the command is called without a configuration file
    :param files: A list of files to iterate over to construct the config object.
    :param renameAll: A string to be processed into a dictionary to define renaming of variables across all files.
    :param globalOptions: A string to be processed into a dictionary to define optional arguments to be passed
    when reading each file.
    :param globalFileType: A string containing a file type value to pass to all files in the list
    :return: Returns a dictionary object following the readit datamodel for processing.
    """
    fileobjs = [{'filenm': file,
                 'ext': get_extension(file),
                 'filetype': get_type(get_extension(file))} for file in files]
    config = {'renameAll': renameAll,
              'globalOptions': option_parser(globalOptions),
              'globalFileType': globalFileType,
              'files': fileobjs}
    return config

def option_parser(optstring: str) -> {}:
    """
    A function to handle parsing option strings.
    :param optstring: A string containing key value pairs for options
    :return: A Python dictionary created from the parsed key-value pairs.
    """
    return eval('dict(' + optstring + ')')

def read_config(conf: str) -> {}:
    """
    A function to read the configuration file if one is provided
    :param conf: The file path to the configuration file.
    :return: Returns a dictionary object following the readit datamodel for processing.
    """
    return json.load(conf)

def get_extension(filepath: str) -> str:
    """
    Gets the file extension for an individual file path and returns the file type
    :param filepath: A file path
    :return: A string containing the file extension
    """
    return path.splitext(filepath)[1]

def get_type(extension: str) -> str:
    """
    Gets the type of data file based on inference from the file extension.
    :param extension: A file extension
    :return: A string containing a data file type.
    """
    return CONSTS.FILE_TYPE.get(extension)

