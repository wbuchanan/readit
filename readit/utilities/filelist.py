import glob
from itertools import chain

def filelist(root: str, recursive: bool = True) -> [str]:
    """
    Defines a function used to retrieve all of the file paths matching a
    directory string expression.
    :param root: The root directory/file to begin looking for files that will be read.
    :param recursive: Indicates whether or not glob should search for the file name string recursively
    :return: Returns a list of strings containing fully specified file paths that will be consumed and combined.
    """
    listoffiles = [ glob.glob(filenm, recursive=recursive) for filenm in root ]
    return unfold(listoffiles)

def unfold(filepaths: [str]) -> [str]:
    """
    Defines a function that is used to convert a list of lists into a single flattened list.
    :param filepaths: An object containing a list of lists of file paths that should be flattened into
    a single list.
    :return: A single list containing all of the file paths.
    """
    return list(chain(*filepaths))

