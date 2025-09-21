bin/zmac: download/src/zmac.y
	mkdir -p bin
	cd download/src ; make; cp zmac ../../bin

download/src/zmac.y: download/zmac.zip
	cd download ; unzip -D zmac.zip ; touch *


download/zmac.zip:
	mkdir -p download
	curl --output-dir download -O http://48k.ca/zmac.zip


clean:
	rm -rf bin download
