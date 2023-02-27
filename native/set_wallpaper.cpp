#include "./set_wallpaper.hpp"
#include <windows.h>

extern "C"
int set_wallpaper(int a, int b) {
    return a + b;
}

extern "C"
int change_wallpaper(const char *input) {
    int result = SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, (PVOID*)input, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
    return result;
}