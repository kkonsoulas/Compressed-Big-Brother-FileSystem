compile:
	mkdir -p mountdir
	mkdir -p rootdir
	echo "========================================" ;\
	cd build/ ;\
	aclocal ;\
	autoreconf -i ;\
	automake --add-missing ;\
	./configure ;\
	make ;\
	echo -e "\e[42mFinished, you can now mount the FS by running make mount\e[0m" ;\
	echo "========================================" 

mount:
	echo "========================================" ;\
	echo -e "\e[43m> Unmounting old cbbfs...\e[0m" ;\
	fusermount -u mountdir ;\
	echo -e "\e[43m> Mounting cbbfs...\e[0m" ;\
	build/src/bbfs rootdir/ mountdir/ ;\
	echo -e "\e[42mFinished, you can find tests in the tests directory\e[0m" ;\
	echo "========================================" 
	
unmount:
	echo "========================================" ;\
	echo "\e[43m> Unmounting old cbbfs...\e[0m" ;\
	fusermount -u mountdir ;\
	echo "========================================" 
	
tests: test1 test2 test3 test4

test1:
	cp -r testfiles/a* mountdir/
	diff -ur testfiles/a4kB mountdir/a4kB
	diff -ur testfiles/a8kB mountdir/a8kB
	diff -ur testfiles/a64kB mountdir/a64kB
		
test2:
	cp testfiles/fileGen.py.txt mountdir/fileGen.py.txt
	diff -ur testfiles/fileGen.py.txt mountdir/fileGen.py.txt

test3:
	cp testfiles/lorem8kb_with_suffix mountdir/lorem8kb_with_suffix
	diff -ur testfiles/lorem8kb_with_suffix mountdir/lorem8kb_with_suffix

test4:
	mkdir -p mountdir/testdir
	cp testfiles/lorem8kb_with_suffix mountdir/testdir/lorem8kb_with_suffix
	diff -ur testfiles/lorem8kb_with_suffix mountdir/testdir/lorem8kb_with_suffix
	
distdir:
	cp Makefile $(distdir)

mostlyclean clean distclean mainainer-clean:
	rm -r mountdir rootdir bbfs.log
	cd build ;\
	make clen
