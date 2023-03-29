#include "./set_wallpaper.hpp"
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>

extern "C" int change_wallpaper(const wchar_t *input)
{
    int result = SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, (PVOID)input, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
    return result;
}