"""
Functions for review of manual mapping
"""

import requests as req
import pandas as pd
import numpy as np


def getspreadsheet(sheetid, sheetname):
    """
    Receives a Google Sheets URL, downloads to a dataframe and returns this
    """
    url = f"https://docs.google.com/spreadsheets/d/{sheetid}/gviz/tq?tqx=out:csv&sheet={sheetname}"
    gs_df = pd.read_csv(url, keep_default_na=False)  # Read Google sheet as csv
    result = parse_df(gs_df)
    return result


def parse_df(df):
    """
    Parse the dataframe to remove issues and harmonise terms
    """
    if "Exact non-EFO" not in list(df.columns):
        df["Exact non-EFO"] = df["Exact"].astype(str) + "-" + df["non-EFO"].astype(str)
    if "inadequate" not in list(df.columns):
        df["inadequate"] = ""
    for column in [
        "exact mapping",
        "broad mapping",
        "narrow mapping",
        "inadequate",
        "incorrect",
        "Exact non-EFO",
    ]:
        df[column] = df[column].apply(
            lambda x: "" if str(x) == "-" or len(str(x)) == 0 else x
        )  # set null values to empty
        df[column] = df[column].apply(
            lambda x: str(x).replace(",", " ").split()
        )  # convert comma- or space-delimited strings to lists
        df[column] = df[column].apply(
            remove_url_prefix
        )  # remove url prefix from each item in list
    for column in ["Identifier1", "Identifier2", "Identifier3"]:
        df[column] = df[column].apply(
            remove_url_prefix
        )  # remove url prefix from auto-tool mappings
    return df


def remove_url_prefix(col):
    """
    Remove URLs, just keeping last item
    """
    if not isinstance(col, list):  # Automatic tool mapping columns only have 1 ID
        col = [col]
    if len(col) > 0:
        res = []
        for item in col:
            try:
                res.append(
                    item.rsplit("/", 1)[1]
                )  # Retain only the right-hand part of URL after last "/"
            except IndexError:
                res.append(item)
    else:
        res = col
    return res


def pair_compare(mappingdf1, mappingdf2):
    """
    Compare two mapping efforts
    """
    targetcolumns = {
        "exact mapping": 0,
        "broad mapping": 1,
        "narrow mapping": 2,
        "inadequate": 3,
        "incorrect": 4,
        "Exact non-EFO": 5,
    }
    sourcecolumns = ["Identifier1", "Identifier2", "Identifier3"]
    pairdf = pd.merge(
        mappingdf1,
        mappingdf2,
        how="inner",
        left_on="OpenGWAS.Trait",
        right_on="OpenGWAS.Trait",
        suffixes=("_x", "_y"),
    )
    tool1, tool2, tool3 = np.zeros((6, 6)), np.zeros((6, 6)), np.zeros((6, 6))
    for index, row in pairdf.iterrows():
        for sourcecolumn in sourcecolumns:
            for targetcolumnx in targetcolumns.keys():
                a = row[targetcolumnx + "_x"]
                for targetcolumny in targetcolumns.keys():
                    b = row[targetcolumny + "_y"]
                    if (
                        row[sourcecolumn + "_y"][0] in a
                        and row[sourcecolumn + "_y"][0] in b
                    ):
                        if sourcecolumn == "Identifier1":
                            tool1[
                                targetcolumns[targetcolumnx],
                                targetcolumns[targetcolumny],
                            ] += 1
                        elif sourcecolumn == "Identifier2":
                            tool3[
                                targetcolumns[targetcolumnx],
                                targetcolumns[targetcolumny],
                            ] += 1
                        elif sourcecolumn == "Identifier3":
                            tool3[
                                targetcolumns[targetcolumnx],
                                targetcolumns[targetcolumny],
                            ] += 1
    return (tool1, tool2, tool3)


def person_summary(mappingdf):
    """
    Summarise the results from one person
    """
    targetcolumns = {
        "exact mapping": 0,
        "broad mapping": 1,
        "narrow mapping": 2,
        "inadequate": 3,
        "incorrect": 4,
        "Exact non-EFO": 5,
    }
    sourcecolumns = {"Identifier1": 0, "Identifier2": 1, "Identifier3": 2}
    result = np.zeros((3, 6))
    for index, row in mappingdf.iterrows():
        for targetcolumn in targetcolumns.keys():
            for sourcecolumn in sourcecolumns.keys():
                if row[sourcecolumn][0] in row[targetcolumn]:
                    result[
                        sourcecolumns[sourcecolumn], targetcolumns[targetcolumn]
                    ] += 1
    return result
