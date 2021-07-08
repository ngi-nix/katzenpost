# katzenpost

upsteam: https://katzenpost.mixnetworks.org/
ngi-nix: https://github.com/ngi-nix/ngi/issues/97

Is a something something chat network, which could also handle crypto and email. It consists of
two server components, katzenpost-authority and katzenpost-server and a client application like catchat.

## katzenpost-server

upsteam: https://github.com/katzenpost/server/

Server compnent for katzenpost, builds and works, I think.

## katzenpost-authority

upsteam: https://github.com/katzenpost/authority/

Authority compnent for katzenpost, builds and works, I think.

## catchat

upstream: https://github.com/katzenpost/catchat

Client application for katzenpost, fails to build since a Qt app written in Go and I have zero
clue how to build it. It uses [qt](https://github.com/therecipe/qt/) (go bindings for Qt), which takes over the build process so I don't think the normal Go infrastruture will work. The last commit is from September last year, so I don't think we'll get any help from upstream either.
