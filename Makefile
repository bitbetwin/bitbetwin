
all: public modules

modules:
	npm install
	bower install
    
public:
	mkdir -p public/css
	mkdir -p public/js
    
clean:
	rm -r public
