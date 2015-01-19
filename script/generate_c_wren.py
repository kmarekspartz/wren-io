#!/usr/bin/env python

import glob
import os.path
import re
import string

PATTERN = re.compile(r'libSource =\n("(.|[\n])*?);')

loaders = ""
loader_includes = ""

with open("src/c.wren.template", "r") as f:
  c_template = f.read()

with open("src/h.wren.template", "r") as f:
  h_template = f.read()

with open("src/loader.wren.template", "r") as f:
  loader_template = f.read()

with open("src/loader_include_item.wren.template", "r") as f:
  loader_include_item_template = f.read()

with open("src/loader_item.wren.template", "r") as f:
  loader_item_template = f.read()

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

  camelname = snake_to_camel(name)
  libname = string.upper(name)

  c_source = c_template.format(
    basename=basename,
    name=name,
    camelname=camelname,
    libname=libname,
    source=wren_source
  )

  h_source = h_template.format(
    basename=basename,
    name=name,
    camelname=camelname,
    libname=libname
  )
  c_filename = "src/wren_io_" + name + ".c"
  c_basename = os.path.basename(c_filename)
  h_filename = "src/wren_io_" + name + ".h"

  with open(c_filename, "w") as f:
    f.write(c_source)
  with open(h_filename, "w") as f:
    f.write(h_source)
  global loaders
  global loader_includes
  loader_includes += loader_include_item_template.format(
    libname=libname,
    name=name
  )
  loaders += loader_item_template.format(
    libname=libname,
    camelname=camelname
  )

  print(basename + " generated " + c_basename)


for f in glob.iglob("src/*.c.wren"):
  build_c_wren_file(f)
loader_source = loader_template.format(
  loader_includes=loader_includes,
  loaders=loaders
)
with open("src/wren_io_loader.c", "w") as f:
  f.write(loader_source)
