#!/usr/bin/bash

sudo singularity build ragtag.sif ragtag.def
sudo singularity run --bind ragtag_output:/root/ragtag_output ragtag.sif
