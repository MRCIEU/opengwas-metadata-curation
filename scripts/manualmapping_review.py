"""
Python script to review and summarise the initial manual mapping exercise
for OpenGWAS traits to EFO
"""

# Libraries

from manmap import *

sheet_ids = {"Benjamin":"1d32FA5-Yw-1MQFMX5ONBPCMWryt49THnROL2AS8u5hw",
        "Rebecca":"1JDv-ycajsd-32W2tigyd5hdNd9PXuasBbOHJdx0G7fs",
        "Samuel":"1i0LevfdgQaRkmPnCLA8k1pzmyvI1Y4jd1bBFPh3FH0Y",
        "Ryan":"1BH0xST8Iqe4hazhadLVmxduzGTxvKnSwXJcoaiRdeH4",
        "Maria":"1zAldGEGRb3H0apLO529i7JqM7QnsZ_z4",
        "Zak":"1fxgEGT34gHdRuUhazWNddUETMd5GLzgoJUbQ1M8C__o",
        "Marina":"1VVWSo_4gvp3JmIy5ycC9RfXFc1zUPf-0Uk-isoyAi-k",
        "Giulio":"1aYOWaNoO37eOzI3ZCXrEF1EmcgujW-Z9Jn7KnlmY_8A"}

for id in sheet_ids.keys():
    print(id)
    res = getspreadsheet(sheet_ids[id],"assigned_traits")
    res.to_csv(id+".csv")


