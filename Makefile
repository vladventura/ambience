CC=gcc
CPC=g++

main: create_object
	$(CC) -shared ./native/set_wallpaper.o -o set_wallpaper.so

create_object:
	$(CPC) -c ./native/set_wallpaper.cpp -o ./native/set_wallpaper.o

clean:
	rm ./native/*.o ./*.so
	