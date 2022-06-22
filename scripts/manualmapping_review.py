"""
Python script to review and summarise the initial manual mapping exercise
for OpenGWAS traits to EFO
"""

# Libraries

from manmap import *

sheet_ids = {
    "Benjamin": "1d32FA5-Yw-1MQFMX5ONBPCMWryt49THnROL2AS8u5hw",
    "Rebecca": "1JDv-ycajsd-32W2tigyd5hdNd9PXuasBbOHJdx0G7fs",
    "Samuel": "1i0LevfdgQaRkmPnCLA8k1pzmyvI1Y4jd1bBFPh3FH0Y",
    "Ryan": "1BH0xST8Iqe4hazhadLVmxduzGTxvKnSwXJcoaiRdeH4",
    "Maria": "1zAldGEGRb3H0apLO529i7JqM7QnsZ_z4",
    "Zak": "1fxgEGT34gHdRuUhazWNddUETMd5GLzgoJUbQ1M8C__o",
    "Marina": "1VVWSo_4gvp3JmIy5ycC9RfXFc1zUPf-0Uk-isoyAi-k",
    "Giulio": "1aYOWaNoO37eOzI3ZCXrEF1EmcgujW-Z9Jn7KnlmY_8A",
}
pairs = [("Rebecca", "Samuel"), ("Zak", "Marina")]
sheets = {}

for id in sheet_ids.keys():
    res = getspreadsheet(sheet_ids[id], "assigned_traits")
    sheets[id] = res

column_labels = ["Exact", "Broad", "Narrow", "Inad", "Inex", "non-EFO"]

for person in sheet_ids.keys():
    print(f"Person: {person}\n==================")
    summary = person_summary(sheets[person])
    print(
        pd.DataFrame(summary, columns=column_labels, index=["Auto1", "Auto2", "Auto3"])
    )
    print("=============================================\n")

print("\n\n")

for pair in pairs:
    print(f"Pair: {pair[0]}, {pair[1]}\n=========================")
    tool1, tool2, tool3 = pair_compare(sheets[pair[0]], sheets[pair[1]])
    print("\nAutomated tool 1")
    print(pd.DataFrame(tool1, columns=column_labels, index=column_labels))
    print("\nAutomated tool 2")
    print(pd.DataFrame(tool2, columns=column_labels, index=column_labels))
    print("\nAutomated tool 3")
    print(pd.DataFrame(tool3, columns=column_labels, index=column_labels))
    print("=============================================\n")
