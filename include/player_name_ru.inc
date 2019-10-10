#include <a_samp>
// Данный иклюд исправляет проблемы с чтением русских имен игроков
// Желательно подключить в файл как можно раньше

stock GetPlayerNameFixRu(player_id, name[], len) {
    GetPlayerName(player_id, name, len);
    for (new i = 0; i < len; ++i) {
        if (!name[i]) {
            break;
        }
        name[i] &= 0xff;
    }
}
#define GetPlayerName GetPlayerNameFixRu
