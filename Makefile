site:
	stack build
	stack exec -- homepage rebuild

upload:
	cp -r _site/* docs/ 
	cp -r static/code/src docs/code/
	cd docs/ && git add . && git commit -a -m "update page" && git push origin main 

clean:
	rm -rf *.hi *.o .*.swp .*.swo website _site/ _cache/

server:
	stack exec -- homepage watch

