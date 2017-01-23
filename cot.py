"""
Downloading and processing COT reports

Usage:
  cot.py latest <currency>
  cot.py --date <report_date> <currency>
  cot.py --from-file <filename> <currency>
  
Example:
  cot.py latest EURO
  cot.py --date 01/19/2017 YEN

Options:
  -h, --help

Jon V (darksun4@gmail.com)
19th of January 2017
"""

from docopt import docopt
import urllib

def process(lines_of_cot, commodity_name='EURO FX'):
    idx = 0
    for idx in range(0, len(lines_of_cot)):
        if commodity_name in lines_of_cot[idx]:
            results = {}
            data = lines_of_cot[idx:idx+19]
            current = " ".join(data[9].split()).split(" ")
            changes = " ".join(data[12].split()).split(" ")
            results['non-commercial'] = {'current': {'long': current[0],
                                                     'short': current[1], 'spreads': current[2]},
                                         'changes': {'long': changes[0],
                                                     'short': changes[1],
                                                     'spreads': changes[2]}}
            
            results['commercial'] = {'current': {'long': current[3],
                                                 'short': current[4],
                                                 'spreads': current[5]},
                                     'changes': {'long': changes[3],
                                                 'short': changes[4],
                                                 'spreads': changes[5]}}

            return results
        
    return 0


def _download_report(date_to_get='latest'):
    filename = urllib.URLopener()
    base_filename =  "Data/latest.htm"
    
    if date_to_get == 'latest':
        filename.retrieve("http://www.cftc.gov/dea/futures/deacmesf.htm", base_filename)
    else:
        base_url = 'http://www.cftc.gov/files/dea/cotarchives/%year%/futures/deacmesf%month%%day%%Year%.htm'
        base_filename = 'Data/%month%%day%%Year%.htm'

        month, day, year = date_to_get.split('/')
        base_url = base_url.replace('%year%', year).replace('%month%', month). replace('%day%', day).replace('%Year%', year[2:])
        base_filename = base_filename.replace('%month%', month).replace('%day%', day).replace('%Year%', year[2:])

        print base_url
        filename.retrieve(base_url, base_filename)
        
    filename.close()

    return base_filename

if __name__ == "__main__":
    arguments = docopt(__doc__)

    if arguments['latest'] or arguments['--date']:
        if arguments['latest']:
            report_date = 'latest'

        elif (arguments['--date']):
            report_date = arguments['<report_date>']

        report = _download_report(report_date)
        
    if arguments['--from-file'] :
        report = arguments['<filename>']
        report_date = None

    with open(report, 'r') as fd:
        print "Report date:", report_date
        print "-------------------------"
        print process(fd.readlines(), arguments['<currency>'])


