"""
Downloading all COT reports from the offical source

Jon V (darksun4@gmail.com)
23rd of January 2017
"""
from datetime import datetime, timedelta
from cot import _download_report

if __name__ == "__main__":
    start, end = datetime(2005, 01, 4), datetime(2017, 01, 23)
    days = (start + timedelta(days=i) for i in range((end - start).days + 1))
    all_tuesdays = [d for d in days if d.weekday() == 1]

    print str(all_tuesdays[0].month).zfill(2) + "/" + str(all_tuesdays[0].day).zfill(2) + "/" + str(all_tuesdays[0].year)
    
    for tuesday in all_tuesdays:
        str_tuesday = str(tuesday.month).zfill(2) + "/" + str(tuesday.day).zfill(2) + "/" + str(tuesday.year)
        
        try:
            print _download_report(str_tuesday)
        except:
            print "Something went wrong"
