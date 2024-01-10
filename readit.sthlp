{smcl}
{vieweralsosee "saveit" "saveit"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] append" "mansection D append"}{...}
{vieweralsosee "[D] use" "mansection D use"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] import excel" "mansection D importexcel"}{...}
{vieweralsosee "[D] import delimited" "mansection D importdelimited"}{...}
{vieweralsosee "[D] import spss" "mansection D importspss"}{...}
{vieweralsosee "[D] import sas" "mansection D importsas"}{...}
{vieweralsosee "[D] infix (fixed format)" "mansection D infix(fixedformat)"}{...}
{vieweralsosee "[D] infile (fixed format)" "mansection D infile2"}{...}
{viewerjumpto "Syntax" "readit##syntax"}{...}
{viewerjumpto "Description" "readit##description"}{...}
{viewerjumpto "File Type Inference" "readit##filetypes"}{...}
{viewerjumpto "Options" "readit##options"}{...}
{viewerjumpto "Examples" "readit##examples"}{...}
{viewerjumpto "Pandas" "readit##pandas"}{...}
{viewerjumpto "Additional Information" "readit##additional"}{...}
{viewerjumpto "Contact" "readit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:readit} [ file(s) ] [{cmd:,} {it:options}]{p_end}

{p 4 4 2}The {cmd:readit} command accepts one or many file/directory paths as the first argument passed to the command.  When specifying the files/directories to search you must enclose the entire argument in {help quotes##double:double quotes} and surround each file/directory with matching right {help quotes##single:single quotes}.  For example, assuming there is a subdirectory named test in which you wish to combine all Stata and SPSS files you would type: {p_end}

{p 8 32 2}{cmd:readit} "'test/*.dta', 'test/*.sav'", ...{p_end}

{p 4 4 2}{cmd:readit} can then automatically format your argument correctly for the Python code it uses.{p_end}

{marker description}{...}
{title:Description}

{p 4 4 2}{cmd:readit} can be used to read individual, or multiple, files from 
disk in a single command without writing intermediate files to the local file 
system.  The use of datetime variables has not yet been tested at this time.  {p_end}

{p 4 4 2}For all functionality to work correctly, {help readit} requires the 
following Python packages to be installed:{p_end}
{p2colset 8 24 24 8}
{p2line}
{p2col :{opt Package}}{opt Version}{p_end}
{p2line}
{p2col :{opt pandas}}>= 1.0.0 (for all core functionality){p_end}
{p2col :{opt pyarrow}}>= 0.17.1 (for Apache Arrow/Parquet files){p_end}
{p2col :{opt fastparquet}}>= 0.4.0 (for Parquet files){p_end}
{p2col :{opt xlrd}}>= 1.2.0 (for MS Excel files){p_end}
{p2col :{opt pyreadstat}}>= 1.0.0 (for SPSS and SAS files){p_end}
{p2col :{opt h5py}}>= 2.10.0 (for HDF5 files){p_end}
{p2col :{opt numexpr}}>= 2.7.1 (for HDF5 files){p_end}
{p2col :{opt Cython}}>= 0.21 (for HDF5 files){p_end}
{p2col :{opt tables}}>= 3.6.1 (for HDF5 files){p_end}
{p2line}

{p 8 8 8}{it:Note: A future release of {hi:readit} will be pip installable which will take care of Python dependencies for users automatically}.{p_end}

{marker filetypes}{...}
{title:File Type Inference}

{p 4 4 2}{cmd:readit} uses a mapping from file extensions to file types in order 
to dispatch the appropriate I/O methods for a given file.  The file type mappings 
are listed below in order to clarify how {cmd:readit} will respond when it 
encounters files with the following extensions:{p_end}
{p2colset 8 24 24 8}
{p2line}
{p2col :{opt Extension}}{opt File Type}{p_end}
{p2line}
{p2col :{opt .dta}}Stata{p_end}
{p2col :{opt .xls}}MS Excel{p_end}
{p2col :{opt .xlsx}}MS Excel{p_end}
{p2col :{opt .csv}}Comma Delimited{p_end}
{p2col :{opt .pkl}}Pickle{p_end}
{p2col :{opt .pickle}}Pickle{p_end}
{p2col :{opt .sas7bdat}}SAS{p_end}
{p2col :{opt .xport}}SAS{p_end}
{p2col :{opt .tab}}Tab Delimited{p_end}
{p2col :{opt .tsv}}Tab Delimited{p_end}
{p2col :{opt .dat}}Fixed-With Format{p_end}
{p2col :{opt .txt}}Fixed-With Format{p_end}
{p2col :{opt .json}}JSON{p_end}
{p2col :{opt .html}}HTML{p_end}
{p2col :{opt .feather}}Apache Arrow/Parquet{p_end}
{p2col :{opt .parquet}}Parquet{p_end}
{p2col :{opt .h5}}HDF5{p_end}
{p2col :{opt .sav}}SPSS{p_end}
{p2line}

{marker options}{...}
{title:Options}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt t:ypes}}Use this option if you want to specify a single file type for all files being consumed.{p_end}
{synopt :{opt ren:ame}}This option allows you to rename variables after the files are appended to each other.  You must pass the mappings to this parameter as a set of key value pairs with the following format: 'oldName1': 'newName1', 
'oldName2': 'newName2'.{p_end}
{synopt :{opt nodet:ect}}Option to turn off file type inference. (see {help readit##filetypes:File Type Inference} for details){p_end}
{synopt :{opt norec:ursive}}Option to prevent {cmd:readit} from performing a recursive search on the string(s) passed to the command.{p_end}
{synopt :{opt rawj:son}}This option is used to use the {it:read_json} method of pandas.  If not specified, any JSON data will be read in using the load method of the json module and passed to the {it:json_normalize} method of pandas.{p_end}
{synopt :{opt sav:e}}Optional argument to specify a file in which the result of the command would be saved.{p_end}
{synopt :{opt rep:lace}}Optional argument to overwrite an existing file when using the {opt save} option.{p_end}
{synopt :{opt c:lear}}Option to clear existing data from memory.{p_end}
{synopt :{opt pandas opts}}See {help readit##pandas:Pandas Options} for default values used by pandas (and the parameters to which options can be passed).  {p_end}
{synoptline}

{marker examples}{...}
{title:Examples}

{p 4 4 2}Read and append all SPSS files in a directory:{p_end}

{p 8 4 2}{hi:readit "'test/*.sav'", c}{p_end}

{p 4 4 2}Read and append all files in a directory and rename the gear_ratio variable:{p_end}

{p 8 4 2}{hi:readit "'test/auto*'", ren('gear_ratio': 'gratio') c}{p_end}

{p 4 4 2}Read and append all CSV, Feather, and SPSS files, rename some variables, and pass some options to the underlying Python library:{p_end}

{p 8 8 2}{hi:readit "'test/*.csv', 'test/*.feather', 'test/*.sav'", ren('src2' : 'backupsrc', 'gear_ratio' : 'gearRatio', 'datatype': 'filetype') "sep = ',', na_values = '', convert_categoricals = False"}{p_end}


{marker pandas}{...}
{title:Pandas Options}
{break}
{p 8 4 2}The following section provides information about default values that are 
passed to {browse "https://pandas.pydata.org/pandas-docs/stable/reference/io.html":Pandas I/O} functions
by default.  {help readit} will handle appropriate dispatch of parameters/arguments based on file types
automatically.  For additional information regarding the options available from the 
{browse "https://pandas.pydata.org/pandas-docs/stable/reference/io.html":Pandas I/O} 
functions, we recommend consulting the {browse "https://pandas.pydata.org/pandas-docs/stable/reference/io.html":Pandas I/O} 
references available here: {browse "https://pandas.pydata.org/pandas-docs/stable/reference/io.html":https://pandas.pydata.org/pandas-docs/stable/reference/io.html}.{p_end}

{p 8 4 2}{it:Note: The chunksize and iterator options should not be used at this time as they return a generator instead of a DataFrame object;} {it:the options are listed here for informational purposes and potential future implementation only.}{p_end}

{p 8 4 2}To use any of these options, enclose them in a single set of quotation 
marks after all other options have been specified:  {p_end}

{p 12 8 2}
"convert_dates = False, names = [ 'var1', 'var2', 'var3', 'var4']"
{p_end}

{p 8 4 2}When specifying arguments for parameters that will be passed on to the 
Pandas I/O methods use the apostrophe (i.e., right tick mark) to pass string 
values.{p_end}


{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab: Stata}
{synopt :{opt convert_dates}} Default(convert_dates=True) {p_end}
{synopt :{opt convert_categoricals}} Default(convert_categoricals=True) {p_end}
{synopt :{opt index_col}} Default(index_col=None) {p_end}
{synopt :{opt convert_missing}} Default(convert_missing=False) {p_end}
{synopt :{opt preserve_dtypes}} Default(preserve_dtypes=True) {p_end}
{synopt :{opt columns}} Default(columns=None) {p_end}
{synopt :{opt order_categoricals}} Default(order_categoricals=True) {p_end}
{synopt :{opt chunksize}} Default(chunksize=None) {p_end}
{synopt :{opt iterator}} Default(iterator=False) {p_end}
{syntab: CSV}
{synopt :{opt sep}} Default(sep=',') {p_end}
{synopt :{opt delimiter}} Default(delimiter=None) {p_end}
{synopt :{opt header}} Default(header='infer') {p_end}
{synopt :{opt names}} Default(names=None) {p_end}
{synopt :{opt index_col}} Default(index_col=None) {p_end}
{synopt :{opt usecols}} Default(usecols=None) {p_end}
{synopt :{opt squeeze}} Default(squeeze=False) {p_end}
{synopt :{opt prefix}} Default(prefix=None) {p_end}
{synopt :{opt mangle_dupe_cols}} Default(mangle_dupe_cols=True) {p_end}
{synopt :{opt dtype}} Default(dtype=None) {p_end}
{synopt :{opt engine}} Default(engine=None) {p_end}
{synopt :{opt converters}} Default(converters=None) {p_end}
{synopt :{opt true_values}} Default(true_values=None) {p_end}
{synopt :{opt false_values}} Default(false_values=None) {p_end}
{synopt :{opt skipinitialspace}} Default(skipinitialspace=False) {p_end}
{synopt :{opt skiprows}} Default(skiprows=None) {p_end}
{synopt :{opt skipfooter}} Default(skipfooter=0) {p_end}
{synopt :{opt nrows}} Default(nrows=None) {p_end}
{synopt :{opt na_values}} Default(na_values=None) {p_end}
{synopt :{opt keep_default_na}} Default(keep_default_na=True) {p_end}
{synopt :{opt na_filter}} Default(na_filter=True) {p_end}
{synopt :{opt verbose}} Default(verbose=False) {p_end}
{synopt :{opt skip_blank_lines}} Default(skip_blank_lines=True) {p_end}
{synopt :{opt parse_dates}} Default(parse_dates=False) {p_end}
{synopt :{opt infer_datetime_format}} Default(infer_datetime_format=False) {p_end}
{synopt :{opt keep_date_col}} Default(keep_date_col=False) {p_end}
{synopt :{opt date_parser}} Default(date_parser=None) {p_end}
{synopt :{opt dayfirst}} Default(dayfirst=False) {p_end}
{synopt :{opt cache_dates}} Default(cache_dates=True) {p_end}
{synopt :{opt iterator}} Default(iterator=False) {p_end}
{synopt :{opt chunksize}} Default(chunksize=None) {p_end}
{synopt :{opt compression}} Default(compression='infer') {p_end}
{synopt :{opt thousands}} Default(thousands=None) {p_end}
{synopt :{opt decimal}} Default(decimal:str='.') {p_end}
{synopt :{opt lineterminator}} Default(lineterminator=None) {p_end}
{synopt :{opt quotechar}} Default(quotechar='"') {p_end}
{synopt :{opt quoting}} Default(quoting=0) {p_end}
{synopt :{opt doublequote}} Default(doublequote=True) {p_end}
{synopt :{opt escapechar}} Default(escapechar=None) {p_end}
{synopt :{opt comment}} Default(comment=None) {p_end}
{synopt :{opt encoding}} Default(encoding=None) {p_end}
{synopt :{opt dialect}} Default(dialect=None) {p_end}
{synopt :{opt error_bad_lines}} Default(error_bad_lines=True) {p_end}
{synopt :{opt warn_bad_lines}} Default(warn_bad_lines=True) {p_end}
{synopt :{opt delim_whitespace}} Default(delim_whitespace=False) {p_end}
{synopt :{opt low_memory}} Default(low_memory=True) {p_end}
{synopt :{opt memory_map}} Default(memory_map=False) {p_end}
{synopt :{opt float_precision}} Default(float_precision=None) {p_end}
{syntab: MS Excel}
{synopt :{opt sheet_name}} Default(sheet_name=0) {p_end}
{synopt :{opt header}} Default(header=0) {p_end}
{synopt :{opt names}} Default(names=None) {p_end}
{synopt :{opt index_col}} Default(index_col=None) {p_end}
{synopt :{opt usecols}} Default(usecols=None) {p_end}
{synopt :{opt squeeze}} Default(squeeze=False) {p_end}
{synopt :{opt dtype}} Default(dtype=None) {p_end}
{synopt :{opt engine}} Default(engine=None) {p_end}
{synopt :{opt converters}} Default(converters=None) {p_end}
{synopt :{opt true_values}} Default(true_values=None) {p_end}
{synopt :{opt false_values}} Default(false_values=None) {p_end}
{synopt :{opt skiprows}} Default(skiprows=None) {p_end}
{synopt :{opt nrows}} Default(nrows=None) {p_end}
{synopt :{opt na_values}} Default(na_values=None) {p_end}
{synopt :{opt keep_default_na}} Default(keep_default_na=True) {p_end}
{synopt :{opt verbose}} Default(verbose=False) {p_end}
{synopt :{opt parse_dates}} Default(parse_dates=False) {p_end}
{synopt :{opt date_parser}} Default(date_parser=None) {p_end}
{synopt :{opt thousands}} Default(thousands=None) {p_end}
{synopt :{opt comment}} Default(comment=None) {p_end}
{synopt :{opt skipfooter}} Default(skipfooter=0) {p_end}
{synopt :{opt convert_float}} Default(convert_float=True) {p_end}
{synopt :{opt mangle_dupe_cols}} Default(mangle_dupe_cols=True) {p_end}
{synopt :{opt kwds}} Default(**kwds) {p_end}
{syntab: SPSS}
{synopt :{opt usecols}} Default(usecols:Union[Sequence[str], NoneType]=None) {p_end}
{synopt :{opt convert_categoricals}} Default(convert_categoricals:bool=True) {p_end}
{syntab: SAS}
{synopt :{opt format}} Default(format=None) {p_end}
{synopt :{opt index}} Default(index=None) {p_end}
{synopt :{opt encoding}} Default(encoding=None) {p_end}
{synopt :{opt chunksize}} Default(chunksize=None) {p_end}
{synopt :{opt iterator}} Default(iterator=False) {p_end}
{syntab: HTML}
{synopt :{opt match}} Default(match='.+') {p_end}
{synopt :{opt flavor}} Default(flavor=None) {p_end}
{synopt :{opt header}} Default(header=None) {p_end}
{synopt :{opt index_col}} Default(index_col=None) {p_end}
{synopt :{opt skiprows}} Default(skiprows=None) {p_end}
{synopt :{opt attrs}} Default(attrs=None) {p_end}
{synopt :{opt parse_dates}} Default(parse_dates=False) {p_end}
{synopt :{opt thousands}} Default(thousands=',') {p_end}
{synopt :{opt encoding}} Default(encoding=None) {p_end}
{synopt :{opt decimal}} Default(decimal='.') {p_end}
{synopt :{opt converters}} Default(converters=None) {p_end}
{synopt :{opt na_values}} Default(na_values=None) {p_end}
{synopt :{opt keep_default_na}} Default(keep_default_na=True) {p_end}
{synopt :{opt displayed_only}} Default(displayed_only=True) {p_end}
{syntab: Pickle}
{synopt :{opt compression}} Default(compression:Union[str, NoneType]='infer') {p_end}
{syntab: Tab Delimited}
{synopt :{opt sep}} Default(sep='\t') {p_end}
{synopt :{opt delimiter}} Default(delimiter=None) {p_end}
{synopt :{opt header}} Default(header='infer') {p_end}
{synopt :{opt names}} Default(names=None) {p_end}
{synopt :{opt index_col}} Default(index_col=None) {p_end}
{synopt :{opt usecols}} Default(usecols=None) {p_end}
{synopt :{opt squeeze}} Default(squeeze=False) {p_end}
{synopt :{opt prefix}} Default(prefix=None) {p_end}
{synopt :{opt mangle_dupe_cols}} Default(mangle_dupe_cols=True) {p_end}
{synopt :{opt dtype}} Default(dtype=None) {p_end}
{synopt :{opt engine}} Default(engine=None) {p_end}
{synopt :{opt converters}} Default(converters=None) {p_end}
{synopt :{opt true_values}} Default(true_values=None) {p_end}
{synopt :{opt false_values}} Default(false_values=None) {p_end}
{synopt :{opt skipinitialspace}} Default(skipinitialspace=False) {p_end}
{synopt :{opt skiprows}} Default(skiprows=None) {p_end}
{synopt :{opt skipfooter}} Default(skipfooter=0) {p_end}
{synopt :{opt nrows}} Default(nrows=None) {p_end}
{synopt :{opt na_values}} Default(na_values=None) {p_end}
{synopt :{opt keep_default_na}} Default(keep_default_na=True) {p_end}
{synopt :{opt na_filter}} Default(na_filter=True) {p_end}
{synopt :{opt verbose}} Default(verbose=False) {p_end}
{synopt :{opt skip_blank_lines}} Default(skip_blank_lines=True) {p_end}
{synopt :{opt parse_dates}} Default(parse_dates=False) {p_end}
{synopt :{opt infer_datetime_format}} Default(infer_datetime_format=False) {p_end}
{synopt :{opt keep_date_col}} Default(keep_date_col=False) {p_end}
{synopt :{opt date_parser}} Default(date_parser=None) {p_end}
{synopt :{opt dayfirst}} Default(dayfirst=False) {p_end}
{synopt :{opt cache_dates}} Default(cache_dates=True) {p_end}
{synopt :{opt iterator}} Default(iterator=False) {p_end}
{synopt :{opt chunksize}} Default(chunksize=None) {p_end}
{synopt :{opt compression}} Default(compression='infer') {p_end}
{synopt :{opt thousands}} Default(thousands=None) {p_end}
{synopt :{opt decimal}} Default(decimal:str='.') {p_end}
{synopt :{opt lineterminator}} Default(lineterminator=None) {p_end}
{synopt :{opt quotechar}} Default(quotechar='"') {p_end}
{synopt :{opt quoting}} Default(quoting=0) {p_end}
{synopt :{opt doublequote}} Default(doublequote=True) {p_end}
{synopt :{opt escapechar}} Default(escapechar=None) {p_end}
{synopt :{opt comment}} Default(comment=None) {p_end}
{synopt :{opt encoding}} Default(encoding=None) {p_end}
{synopt :{opt dialect}} Default(dialect=None) {p_end}
{synopt :{opt error_bad_lines}} Default(error_bad_lines=True) {p_end}
{synopt :{opt warn_bad_lines}} Default(warn_bad_lines=True) {p_end}
{synopt :{opt delim_whitespace}} Default(delim_whitespace=False) {p_end}
{synopt :{opt low_memory}} Default(low_memory=True) {p_end}
{synopt :{opt memory_map}} Default(memory_map=False) {p_end}
{synopt :{opt float_precision}} Default(float_precision=None) {p_end}
{syntab: JSON}
{synopt :{opt orient}} Default(orient=None) {p_end}
{synopt :{opt typ}} Default(typ='frame') {p_end}
{synopt :{opt dtype}} Default(dtype=None) {p_end}
{synopt :{opt convert_axes}} Default(convert_axes=None) {p_end}
{synopt :{opt convert_dates}} Default(convert_dates=True) {p_end}
{synopt :{opt keep_default_dates}} Default(keep_default_dates=True) {p_end}
{synopt :{opt numpy}} Default(numpy=False) {p_end}
{synopt :{opt precise_float}} Default(precise_float=False) {p_end}
{synopt :{opt date_unit}} Default(date_unit=None) {p_end}
{synopt :{opt encoding}} Default(encoding=None) {p_end}
{synopt :{opt lines}} Default(lines=False) {p_end}
{synopt :{opt chunksize}} Default(chunksize=None) {p_end}
{synopt :{opt compression}} Default(compression='infer') {p_end}
{syntab: Fixed-Width Format}
{synopt :{opt colspecs}} Default(colspecs='infer') {p_end}
{synopt :{opt widths}} Default(widths=None) {p_end}
{synopt :{opt infer_nrows}} Default(infer_nrows=100) {p_end}
{synopt :{opt kwds}} Default(**kwds) {p_end}
{syntab: Feather}
{synopt :{opt columns}} Default(columns=None) {p_end}
{synopt :{opt use_threads}} Default(use_threads:bool=True) {p_end}
{syntab: Parquet}
{synopt :{opt engine}} Default(engine:str='auto') {p_end}
{synopt :{opt columns}} Default(columns=None) {p_end}
{synopt :{opt kwargs}} Default(**kwargs) {p_end}
{syntab: HDF5}
{synopt :{opt key}} Default(key=None) {p_end}
{synopt :{opt mode}} Default(mode:str='r') {p_end}
{synopt :{opt errors}} Default(errors:str='strict') {p_end}
{synopt :{opt where}} Default(where=None) {p_end}
{synopt :{opt start}} Default(start:Union[int, NoneType]=None) {p_end}
{synopt :{opt stop}} Default(stop:Union[int, NoneType]=None) {p_end}
{synopt :{opt columns}} Default(columns=None) {p_end}
{synopt :{opt iterator}} Default(iterator=False) {p_end}
{synopt :{opt chunksize}} Default(chunksize:Union[int, NoneType]=None) {p_end}
{synopt :{opt kwargs}} Default(**kwargs) {p_end}
{synoptline}

{marker additional}{...}
{title:Additional Information}
{p 4 4 8}{browse "https://wbuchanan.github.io/stataConference2020-readit":2020 Stata Conference slides about readit}{p_end}

{marker contact}{...}
{title:Contact}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Director{p_end}
{p 4 4 6}{browse "https://www.fcps.net/Domain/2284":Office of Grants, Research, Accountability, & Data}{p_end}
{p 4 4 8}Billy.Buchanan at fayette [dot] kyschools [dot] us{p_end}
