
build: SkyLib.class

SkyLib.class: SkyLib.java
	javac -classpath /mbt/starjava/lib/pal/pal.jar SkyLib.java

run: SkyLib.class
	sh run.sh -n 100000

clean:
	rm -f SkyLib.class t1-*.fits t2-*.fits

