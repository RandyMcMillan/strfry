#pragma once

#include "golpe.h"


inline void verifyYesstrrequest(std::string_view msg) {
    if (!msg.starts_with("Y")) throw herr("invalid yesstr magic char");
    msg = msg.substr(1);
    auto verifier = flatbuffers::Verifier(reinterpret_cast<const uint8_t*>(msg.data()), msg.size());
    bool ok = verifier.VerifyBuffer<Yesstr::request>(nullptr);
    if (!ok) throw herr("yesstr request verification failed");
}

inline void verifyYesstrresponse(std::string_view msg) {
    if (!msg.starts_with("Y")) throw herr("invalid yesstr magic char");
    msg = msg.substr(1);
    auto verifier = flatbuffers::Verifier(reinterpret_cast<const uint8_t*>(msg.data()), msg.size());
    bool ok = verifier.VerifyBuffer<Yesstr::response>(nullptr);
    if (!ok) throw herr("yesstr response verification failed");
}


inline const Yesstr::request *parseYesstrrequest(std::string_view msg) {
    return flatbuffers::GetRoot<Yesstr::request>(msg.substr(1).data());
}

inline const Yesstr::response *parseYesstrResponse(std::string_view msg) {
    return flatbuffers::GetRoot<Yesstr::response>(msg.substr(1).data());
}
