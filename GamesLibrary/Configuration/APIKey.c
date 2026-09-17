#include "APIKey.h"

#ifndef GAMESLIBRARY_API_KEY
#error "GAMESLIBRARY_API_KEY must be set via OTHER_CFLAGS from Config.xcconfig"
#endif

const char *GamesLibraryAPIKey(void) {
	return GAMESLIBRARY_API_KEY;
}
