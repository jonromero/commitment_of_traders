"""
Downloading all COT reports from the official source
and adding some info as a CSV

Jon V (darksun4@gmail.com)
23rd of January 2017
"""
from datetime import datetime, timedelta
from cot import _download_report, process
import locale

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

    csv_file = open("all_data.csv", "w+")
    csv_file.write("non_com_long;non_com_short;spreads;com_long;com_short;date\n")
    
    start, end = datetime(2005, 01, 4), datetime(2017, 01, 23)
    days = (start + timedelta(days=i) for i in range((end - start).days + 1))
    all_tuesdays = [d for d in days if d.weekday() == 1]

    print str(all_tuesdays[0].month).zfill(2) + "/" + str(all_tuesdays[0].day).zfill(2) + "/" + str(all_tuesdays[0].year)
    
    for tuesday in all_tuesdays:
        str_tuesday = str(tuesday.month).zfill(2) + "/" + str(tuesday.day).zfill(2) + "/" + str(tuesday.year)

        try:
            report =_download_report(str_tuesday)
            with open(report, 'r') as fd:
                data, current, changes = process(fd.readlines(), 'EURO')
                for c in current[:5]:
                    csv_file.write(str(locale.atoi(c))+";")

            csv_file.write(str_tuesday+"\n")
            
        except:
            print "Something went wrong"


