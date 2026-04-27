#!/usr/bin/env python3
"""OmniLinux ISO Creator using pycdlib"""
import os
import sys
import pycdlib

def create_iso(source_dir, output_iso, volname="OMNILINUX"):
    iso = pycdlib.PyCdlib()
    iso.new(interchange_level=3, joliet=True)
    
    for root, dirs, files in os.walk(source_dir):
        rel_path = os.path.relpath(root, source_dir)
        
        if rel_path == '.':
            continue
        
        dirs_to_create = []
        path_parts = rel_path.split(os.sep)
        for i in range(len(path_parts)):
            partial = '/' + '/'.join(path_parts[:i+1])
            if partial != '/':
                dirs_to_create.append(partial)
        
        for d in dirs_to_create:
            try:
                iso.add_directory(d)
            except:
                pass
        
        current = '/' + rel_path.replace(os.sep, '/')
        for f in files:
            file_path = os.path.join(root, f)
            iso_file = current + '/' + f
            try:
                with open(file_path, 'rb') as f_obj:
                    iso.add_file(f_obj, iso_file)
            except:
                pass
    
    iso.write(output_iso)
    print(f"ISO created: {output_iso}")

if __name__ == '__main__':
    source = sys.argv[1] if len(sys.argv) > 1 else 'build/iso-work/bootfs'
    output = sys.argv[2] if len(sys.argv) > 2 else 'build/iso/omnilinux-1.0-alpha-x86_64.iso'
    create_iso(source, output)

if __name__ == '__main__':
    source = sys.argv[1] if len(sys.argv) > 1 else 'build/iso-work/bootfs'
    output = sys.argv[2] if len(sys.argv) > 2 else 'build/iso/omnilinux-1.0-alpha-x86_64.iso'
    create_iso(source, output)