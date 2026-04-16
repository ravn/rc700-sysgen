bin/zmac: download/src/zmac.y
	mkdir -p bin
	cd download/src ; make; cp zmac ../../bin

download/src/zmac.y: download/zmac.zip zmac_dri_fixes.patch
	cd download ; unzip -D zmac.zip ; touch *
	# Apply DRI-compat fixes (see README.md).  Guard with patch's
	# --dry-run so a re-run after the patch is already applied is a no-op.
	cd download/src && \
		(patch -p2 --dry-run --silent < ../../zmac_dri_fixes.patch 2>/dev/null && \
		 patch -p2 < ../../zmac_dri_fixes.patch || \
		 echo "zmac_dri_fixes.patch already applied (or declined); continuing")


download/zmac.zip:
	mkdir -p download
	curl --output-dir download -O http://48k.ca/zmac.zip


clean:
	rm -rf bin download
