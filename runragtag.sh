#!/usr/bin/bash

echo running ragtag

# run ragtag
/root/venv/bin/python3 /root/venv/bin/ragtag.py scaffold /root/ragtag_input/reference.fasta /root/ragtag_input/query.fasta -u -t 1 --aligner /root/mummer4/bin/nucmer

echo ragtag done, printing some debug information

echo tree -f /root/ragtag_output
tree -f /root/ragtag_output
echo ls -l /root/ragtag_output/*
ls -l /root/ragtag_output/*
echo cat /root/ragtag_output/*
cat /root/ragtag_output/*

echo debug info printing done
