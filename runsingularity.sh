sudo singularity build ragtag.sif ragtag.def
sudo singularity run --bind ragtag_input:/ragtag_input ragtag.sif
