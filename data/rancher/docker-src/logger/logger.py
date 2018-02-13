#!/usr/bin/env python3
import logging
import time
import sys

# just a basic logging
# logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s [%(levelname)s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

# log different to stdout and stderr
root = logging.getLogger()
root.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(name)s [%(levelname)s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

ch_stdout = logging.StreamHandler(sys.stdout)
ch_stdout.setLevel(logging.DEBUG)
ch_stdout.setFormatter(formatter)

ch_stderr = logging.StreamHandler(sys.stderr)
ch_stderr.setLevel(logging.WARNING)
ch_stderr.setFormatter(formatter)

root.addHandler(ch_stdout)
root.addHandler(ch_stderr)

period = 0

while True:
        period += 1
        if period < 7:
                logging.info('we got a log off in period {0}'.format(period))
        elif period < 10:
                logging.warning('uhh, there\'s something strange in period {0}'.format(period))
        else:
                logging.error('argh, this went wrong, we reset the whole thing in period {0}'.format(period))
                period = 0
        time.sleep(15 - period)
