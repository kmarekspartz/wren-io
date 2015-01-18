#!/usr/bin/env python

import glob
import os.path
import re
import string

PATTERN = re.compile(r'libSource =\n("(.|[\n])*?);')

def snake_to_camel(snake):
  return ''.join(string.capitalize(w) for w in snake.split('_'))

def build_c_wren_file(filename):
  basename = os.path.basename(filename)
  name = basename.split('.')[0]

  with open(filename, "r") as f:
    lines = f.readlines()

  wren_source = ""
  for line in lines:
    line = line.replace('"', "\\\"")
    line = line.replace("\n", "\\n\"")
    if wren_source: wren_source += "\n"
    wren_source += '"' + line

  # re.sub() will unescape escape sequences, but we want them to stay escapes
  # in the C string literal.
  wren_source = wren_source.replace('\\', '\\\\')

  with open("src/c.wren.template", "r") as f:
    template = f.read()

  c_source = template.format(
    basename=basename,
    name=snake_to_camel(name),
    libname=string.upper(name),
    source=wren_source
  )
  c_filename = "src/wren_" + name + ".c"
  c_basename = os.path.basename(c_filename)

  with open(c_filename, "w") as f:
    f.write(c_source)

  print(basename + " generated " + c_basename)


for f in glob.iglob("src/*.c.wren"):
  build_c_wren_file(f)
