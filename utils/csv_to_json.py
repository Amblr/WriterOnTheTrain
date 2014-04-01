#!/usr/bin/env python
import csv
import sys
import json
import numpy as np
import random



fake_chapter = 1.0
days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
day_mask_vals = {d:2**i for (i,d) in enumerate(days)}

def get_day_mask(blob):
	day_items = {d:blob[d] for d in days}
	mask = 0
	for d in days:
		if day_items[d].strip():
			mask += day_mask_vals[d]
	if mask==0 or blob['Any Day']=='yes':
		mask = sum(day_mask_vals.values())
	for d in days:
		del blob[d]
	del blob['Any Day']
	return mask

def transform(blob):
	global fake_chapter
	for (k,v) in blob.items():
		blob[k] = v.strip()

	blob['dayMask'] = get_day_mask(blob)
	#get day of week mask
	if not blob['Position'].strip():
		blob['Position'] = str(fake_chapter)
		fake_chapter += 0.1

	del blob['Number 1']

	#Location
	if not blob['Lat']:
		blob['Lat'] = -51.1 + np.random.randn()*0.1
		blob['Lon'] = -1.0 + np.random.randn()*0.1

	if not blob.get('Time of Day'):
		blob['Time of Day'] = random.choice(['any'])

	if not blob.get('Window'):
		blob['Window'] = random.choice(['either','either','left','right'])

	if not blob.get('Direction of Travel'):
		blob['Direction of Travel'] = random.choice(['West > East', 'East > West'])
	blob['Direction of Travel'] = blob.get('Direction of Travel')[-4:]

	if not blob.get("Phase of Journey"):
		blob['Phase of Journey'] = ''
	else:
		blob['Phase of Journey'] = int(blob['Phase of Journey'][6:])





def csv_to_json(csv_filename, json_filename):
	blobs = list(csv.DictReader(open(csv_filename)))
	for b in blobs:
		transform(b)
		for k,v in b.items():
			print '% 20s: %s' % (k,v)
		print
		print
	json.dump(blobs,open(json_filename,'w'), indent=4)


if __name__ == '__main__':
	csv_to_json(sys.argv[1],sys.argv[2])
