#!/usr/bin/env python3
import logging
import time

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s [%(levelname)s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

period = 0

while True:
        period += 1
        if period < 7:
                logging.info('we get a log off in period {0}'.format(period))
        elif period < 10:
                logging.warning('uhh, there\'s something strange in period {0}'.format(period))
        else:
                logging.error('argh, this went wrong, we reset the whole thing in period {0}'.format(period))
                period = 0
        time.sleep(15 - period)
