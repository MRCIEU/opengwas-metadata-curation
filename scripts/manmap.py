"""
Functions for review of manual mapping
"""

import requests as req
import pandas as pd

def getspreadsheet(sheetid,sheetname):
    """
    Receives a Google Sheets URL, downloads to a dataframe and returns this
    """
    url = f"https://docs.google.com/spreadsheets/d/{sheetid}/gviz/tq?tqx=out:csv&sheet={sheetname}"
    gs_df = pd.read_csv(url, keep_default_na=False)
    result = parse_df(gs_df)
    return(result)

def parse_df(df):
    """
    Parse the dataframe to remove issues and harmonise terms
    """
    if "Exact non-EFO" not in list(df.columns):
        df["Exact non-EFO"] = df['Exact'].astype(str) +"-"+ df["non-EFO"].astype(str)
    if "inadequate" not in list(df.columns):
        df["inadequate"] = ""
    for column in ["exact mapping","broad mapping","narrow mapping","inadequate","incorrect","Exact non-EFO"]:
        df[column] = df[column].apply(lambda x: "" if str(x) == "-" or len(str(x)) == 0 else x)
        df[column] = df[column].apply(lambda x: str(x).replace(","," ").split())
        df[column] = df[column].apply(remove_url_prefix)
    for column in ["Identifier1","Identifier2","Identifier3"]:
        df[column] = df[column].apply(remove_url_prefix)
    return(df)

def remove_url_prefix(col):
    """
    Remove URLs, just keeping last item
    """
    if not isinstance(col, list):
        col = [col]
    if len(col) > 0:
        res = []
        for item in col:
            try:
                res.append(item.rsplit("/",1)[1])
            except IndexError:
                res.append(item)
    else:
        res = col
    return(res)


