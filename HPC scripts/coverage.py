from optparse import OptionParser
import sys
usage = '''
contigs_length_coverage.py : calculate the percentage of the contigs length covered by certain depth
contigs_length_coverage.py [-h] [-i <input file>] [-d <depth>]
*SAMPLE : python contigs_length_coverage.py -i sample.bam -d 1
*NOTICE : '''
parser = OptionParser(usage = usage)
parser.add_option('-i','--infile', dest="infile", help="sorted bamfile")
parser.add_option('-d','--depth', dest="depth", help="specify the depth coverage you want, the default depth is 1")
(options, args) = parser.parse_args()


if options.infile != None:
	sorted_bamfile  = options.infile
else:
	sys.exit("Please specify input bam file!\n")

if options.infile != None:
	depth_want = int(options.depth)
else:
	depth_want = 1


import os 
samtools_depth_outfile = os.path.splitext(sorted_bamfile)[0]+".per_base_depth.txt"
samtools_depth_cmd = "samtools depth -aa " + sorted_bamfile + " > " + samtools_depth_outfile
print(samtools_depth_cmd)
os.system(samtools_depth_cmd)

a = "ls -sh "+samtools_depth_outfile
print(os.system(a))


from collections import defaultdict
d = defaultdict(list)
with open(samtools_depth_outfile) as f:
    for n in f:
    	key = n.rstrip("\n").split("\t")[0]
    	value = n.rstrip("\n").split("\t")[2]
    	d[key].append(value)

def Get_percentage(l, depth):
	l = list(map(int, l))
	contig_len = len(l)+0.0
	certain_depth_len = sum(i >= depth for i in l)+0.0
	cov = (certain_depth_len/contig_len)*100
	return cov

list1 = list([])
for i in sorted(d.keys()):
	rec = i +"\t"+str(Get_percentage(d[i], depth_want))
	list1.append(rec)

outfile_name = os.path.splitext(sorted_bamfile)[0]+"."+str(depth_want)+"depth_percent.txt"
outfile = open(outfile_name,"w")
outfile.write("#contigs\t"+str(sorted_bamfile)+"\n")
outfile.write("\n".join(list1) + "\n")
outfile.close()

print("save to"+outfile_name)
os.system("rm "+samtools_depth_outfile)
print("rm "+samtools_depth_outfile)





