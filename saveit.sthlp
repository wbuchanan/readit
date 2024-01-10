{smcl}
{vieweralsosee "readit" "readit"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] save" "mansection D save"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] export excel" "mansection D exportexcel"}{...}
{vieweralsosee "[D] putexcel" "mansection D putexcel"}{...}
{vieweralsosee "[D] export delimited" "mansection D exportdelimited"}{...}
{vieweralsosee "[D] outfile" "mansection D outfile"}{...}
{vieweralsosee "[D] export sasxport8" "mansection D exportsasxport8"}{...}
{vieweralsosee "[D] export dbase" "mansection D exportdbase"}{...}
{viewerjumpto "Syntax" "saveit##syntax"}{...}
{viewerjumpto "Description" "saveit##description"}{...}
{viewerjumpto "File Type Inference" "saveit##filetypes"}{...}
{viewerjumpto "Options" "saveit##options"}{...}
{viewerjumpto "Data Fidelity" "saveit##datafidelity"}{...}
{viewerjumpto "Pandas" "saveit##pandas"}{...}
{viewerjumpto "Examples" "saveit##examples"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:saveit} file [{cmd:,} {it:options}]{p_end}

{p 4 4 2}The {cmd:saveit} command accepts a file path as the first argument. It then uses the the Python package Pandas to save the data in one of a variety of file formats, expanding the types of files that can saved from Stata. {p_end}

{marker description}{...}
{title:Description}

{p 4 4 2}For all functionality to work correctly, {cmd: saveit} requires the 
following Python packages to be installed:{p_end}
{p2colset 8 24 24 8}
{p2line}
{p2col :{opt File types}}{opt Package}{p_end}
{p2line}
{p2col :{opt All}}pandas{p_end}
{p2col :{opt Apache Arrow}}pyarrow{p_end}
{p2col :{opt Apache Parquet}}fastparquet or pyarrow{p_end}
{p2col :{opt Excel}}openpyxl or xlsxwriter{p_end}
{p2line}

{marker filetypes}{...}
{title:File Type Inference}

{p 4 4 2}{cmd:saveit}, by default, uses a mapping from file extensions to file types in order 
to dispatch the appropriate I/O methods for a given file. (This can be overridden with the {it:type} option.){p_end}
{p2colset 8 24 24 8}
{p2line}
{p2col :{opt Extension}}{opt File Type}{p_end}
{p2line}
{p2col :{opt .xls}}MS Excel{p_end}
{p2col :{opt .xlsx}}MS Excel{p_end}
{p2col :{opt .csv}}Comma Delimited{p_end}
{p2col :{opt .pkl}}Pickle{p_end}
{p2col :{opt .pickle}}Pickle{p_end}
{p2col :{opt .json}}JSON{p_end}
{p2col :{opt .html}}HTML{p_end}
{p2col :{opt .feather}}Apache Arrow/Parquet{p_end}
{p2col :{opt .parquet}}Parquet{p_end}
{p2line}

{marker options}{...}
{title:Options}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt t:ype}}Use this option if you want to explicitly specify the file type rather than use automatic inference based on file extensions.{p_end}
{synopt :{opt rep:lace}}Optional argument to overwrite an existing file when using the {opt save} option.{p_end}
{synopt :{opt pd_options}}See {help saveit##pandas:Pandas Options} for more info about using Pandas options.  {p_end}
{synoptline}

{marker datafidelity}{...}
{title:Data Fidelity}

{p 4 4 2}The conversion process to a Pandas DataFrame in memory and then to the file format on disk may convert some variable types and discard Stata metadata (e.g., variable labels, value labels, variable formats, dataset label, and dataset characterics). When converting to Pandas DataFrames, (1) all Stata string types are converted to a single generic string type, and (2) we store all Stata meta-data plus the original Stata variable types in the DataFrame's {it: .attrs} dictionary under the key 'stata_metadata'. (Note: we do not use Pandas categorical variables for variables with value labels as they are a bit more restrictive). Two file formats, pickle and parquet, can exactly store all the Pandas types and preserve this metatdata, which means that if we read that data back using a program that uses that metadata (e.g., {cmd: readit}), we will automatically convert string variables back to their original type and restore all metadata, ensuring the exact same dataset is restored. Other formats do not retain this metadata. Saving to the feather format can exactly store all the Pandas variable types, but does not store the metadata. Restoring a file will therefore not differentiate the string types. Other format additionally have more restrictive variable storage formats than Pandas. Saving to excel, csv, json, and html will convert all numerical variables to a generic floating point number and all string variables to a generic string type.

{marker pandas}{...}
{title:Pandas Options}
{break}
{p 8 4 2}Additional parameters can be passed to the Pandas I/O routines through {it: pd_options()}. For full information regarding the options available we recommend consulting the 
references available here: {browse "https://pandas.pydata.org/pandas-docs/stable/reference/io.html":https://pandas.pydata.org/pandas-docs/stable/reference/io.html}.{p_end}

{p 8 4 2}To use any of these options, enclose them in a single set of quotation 
marks after all other options have been specified (note the comma between the two options below):  {p_end}

{p 12 8 2}
pd_options("sheet_name='auto', engine='openpyxl'")
{p_end}

{p 8 4 2}When specifying string arguments for parameters that will be passed on to the 
Pandas I/O methods, use the apostrophe (i.e., right tick mark) to pass string 
values.{p_end}


{p 4 4 2}Note: {cmd:saveit} automatically specifies {it: index=False} for those file-types that accept that argument.  {p_end}


{marker examples}{...}
{title:Examples}

{p 4 4 2}Save a parquet file:{p_end}

{p 8 4 2}{hi:saveit auto.parquet, replace}{p_end}

{p 4 4 2}Save an Excel file to a specific sheet using a particular engine.{p_end}

{p 8 4 2}{hi:saveit auto.xls, replace pd_options("sheet_name='auto', engine='openpyxl'")}{p_end}

