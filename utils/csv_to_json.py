#!/usr/bin/env python
import csv
import sys
import json
import numpy as np
import collections


fake_chapter = 666.0
days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
day_mask_vals = {d:2**i for (i,d) in enumerate(days)}

def get_day_mask(blob):
	day_items = {d:blob[d] for d in days}
	mask = 0
	for d in days:
		if day_items[d].strip():
			mask |= day_mask_vals[d]
	if mask==0:
		mask = sum(day_mask_vals.values())
	for d in days:
		del blob[d]

	return mask

def transform(blob, ignore_position_missing):
	global fake_chapter
	for (k,v) in blob.items():
		blob[k] = v.strip()

	blob['dayMask'] = get_day_mask(blob)
	#get day of week mask
	error = []
	if not blob['Position'].strip():
		if not ignore_position_missing:
			error.append("Entry has no position (chapter number)")
		blob['Position'] = str(fake_chapter)
		fake_chapter += 0.1


	if blob['Longitude']:
		blob['Lon'] = str(float(blob['Longitude']))
	else:
		blob["Lon"] = ""

	if blob['Latitude']:
		blob['Lat'] = str(float(blob['Latitude']))
	else:
		blob["Lat"] = ""

	del blob['Latitude']
	del blob['Longitude']


	if not blob.get('Time of Day'):
		blob['Time of Day'] = 'any'

	if not blob.get('Window'):
		blob['Window'] = 'either'

	if not blob.get('Direction of Travel'):
		blob['Direction of Travel'] = 'any'
	blob['Direction of Travel'] = blob.get('Direction of Travel')[-4:]

	if not blob.get("Phase of Journey"):
		blob['Phase of Journey'] = -1
	else:
		blob['Phase of Journey'] = int(blob['Phase of Journey'][6:])

	#
	if blob["Lon"] and not blob["Lat"]:
		error.append("Entry has lat but not lon")
	if blob["Lat"] and not blob["Lon"]:
		error.append("Entry has lon but not lat")
	if not ((blob['Phase of Journey']!=-1) or (blob['Lat'] and blob['Lon'])):
		error.append("Entry has neither lat&lon nor phase")

	return error



def check_unique_chapters(blobs):
	known = collections.defaultdict(list)
	for blob in blobs:
		known[blob['Position']].append(blob['Name'])
	for pos,titles in known.items():
		if len(titles)>1:
			print 'Position %s used more than once: %s' % (pos, ', '.join(titles))

def csv_to_json(csv_filename, json_filename, ignore_position_missing):
	blobs = list(csv.DictReader(open(csv_filename)))
	print 'Looking at %d database entries in file' % len(blobs)
	valid_blobs = []
	for b in blobs:
		error = transform(b, ignore_position_missing)
		if not error:
			valid_blobs.append(b)
			# for k,v in b.items():
			# 	print '% 20s: %s' % (k,v)
			# print
			# print
		else:
			print b['Name']
			for e in error:
				print '    - ' , e
	check_unique_chapters(valid_blobs)
	json.dump(valid_blobs,open(json_filename,'w'), indent=4)
	print 
	print 'Number valid = ', len(valid_blobs)


if __name__ == '__main__':
	i_hate_writers = len(sys.argv)>3 and ('--i-hate-writers' in sys.argv)
	csv_to_json(sys.argv[1],sys.argv[2], i_hate_writers)
