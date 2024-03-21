$py3 $(which ragtag.py) scaffold \
	ragtag_input/reference.fasta \
	ragtag_input/query.fasta \
	-u \
	-t 1 \
	--aligner /root/mummer4/bin/nucmer
