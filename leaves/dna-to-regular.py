import gflags
import os
import sys
import numpy as np
FLAGS = gflags.FLAGS

gflags.DEFINE_string('input_dir', "", "Input dir")
gflags.DEFINE_string('output_dir', "", "Output dir")
gflags.DEFINE_bool("is_grouped", False, "Whether distance is grouped")

def write_output(output_filename, distance, fun):
  with open(output_filename,'w') as f:
    for key in distance:
      f.write("%s,%s\n"%(key,fun(distance[key])))
  

def group_distances(filename):
  distance = dict()
  with open(filename) as f:
    lines =  map(lambda line: line[:-1], f.readlines())
    heading = map(lambda x: x.split("_")[0], lines[1].split(","))
    for i in xrange(2,len(lines)):
      fields = lines[i].split(",")
      class_name = fields[1].split("_")[0]
      for j in xrange(2,len(fields)):
        key = "%s,%s"%(class_name,heading[j])
        if key not in distance:
          distance[key] = []
        distance[key].append(float(fields[j]))
  basename = os.path.basename(filename).split(".")[0]
  #write mean
  output_filename=os.path.join(FLAGS.output_dir, basename + "-mean.csv") 
  write_output(output_filename, distance, np.mean)
  #write median
  output_filename=os.path.join(FLAGS.output_dir, basename + "-median.csv") 
  write_output(output_filename, distance, np.median)
  #write min
  output_filename=os.path.join(FLAGS.output_dir, basename + "-min.csv") 
  write_output(output_filename, distance, np.min)
  #write max
  output_filename=os.path.join(FLAGS.output_dir, basename + "-max.csv") 
  write_output(output_filename, distance, np.max)

def pair_distances(filename):
  distance = dict()
  with open(filename) as f:
    lines = map(lambda line: line[:-1], f.readlines())
    heading = lines[0].split(",")
    for i in xrange(1,len(lines)):
      fields = lines[i].split(",")
      class_name = fields[0]
      for j in xrange(1,len(fields)):
        key = "%s,%s"%(class_name, heading[j])
        distance[key] = float(fields[j])
  # write output file
  basename = os.path.basename(filename)
  output_filename=os.path.join(FLAGS.output_dir, basename) 
  with open(output_filename,'w') as f:
    for key in distance:
      f.write("%s,%s\n"%(key,distance[key]))

def main(argv):
  FLAGS(argv)
  if not FLAGS.input_dir or not FLAGS.output_dir:
    print "invalid usage"
    sys.exit(1)
  for filename in os.listdir(FLAGS.input_dir):
    if FLAGS.is_grouped:
      group_distances(os.path.join(FLAGS.input_dir,filename))
    else:
      pair_distances(os.path.join(FLAGS.input_dir,filename))

if __name__=="__main__":
  main(sys.argv)
  
