#include <a_samp>
#include "../include/player_name_ru"

enum server_type_e {
     server_sa = 0
    ,server_anderius
    ,server_united
    ,server_gostown6
    ,server_cr
    ,server_openvice
    ,server_united2
}

stock server_type_e:get_server_type() {
    new ver[64];
    GetServerVarAsString("version", ver, sizeof(ver));
    
    if (0 == strcmp(ver, "a1", false, 2)) {
        return server_anderius;
    }
    if (0 == strcmp(ver, "cr", false, 2)) {
        return server_cr;
    }
    if (0 == strcmp(ver, "g6", false, 2)) {
        return server_gostown6;
    }
    if (0 == strcmp(ver, "ov", false, 2)) {
        return server_openvice;
    }
    if (0 == strcmp(ver, "u1", false, 2)) {
        return server_united;
    }
    if (0 == strcmp(ver, "u2", false, 2)) {
        return server_united2;
    }
    return server_sa;
}

stock get_server_desc(server_type_e:t) {
    new rezult[64];
    if (server_anderius == t) {
        strcat(rezult, "Anderius");
    }
    else if (server_united == t) {
        strcat(rezult, "United v1.1");
    }
    else if (server_gostown6 == t) {
        strcat(rezult, "Gostown6");
    }
    else if (server_cr == t) {
        strcat(rezult, "Criminal Russia");
    }
    else if (server_openvice == t) {
        strcat(rezult, "Open Vice");
    }
    else if (server_united2 == t) {
        strcat(rezult, "United v1.2");
    }
    else {
        strcat(rezult, "San Andreas");
    }
    return rezult;
}

stock get_server_name(server_type_e:t) {
    new rezult[64];
    if (server_anderius == t) {
        strcat(rezult, "anderius");
    }
    else if (server_united == t) {
        strcat(rezult, "united");
    }
    else if (server_gostown6 == t) {
        strcat(rezult, "gostown6");
    }
    else if (server_cr == t) {
        strcat(rezult, "cr");
    }
    else if (server_openvice == t) {
        strcat(rezult, "openvice");
    }
    else if (server_united2 == t) {
        strcat(rezult, "united2");
    }
    else {
        strcat(rezult, "sa");
    }
    return rezult;
}
