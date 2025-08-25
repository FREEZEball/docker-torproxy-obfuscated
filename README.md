# docker-torproxy-obfuscated

Tor proxy with obfuscation layer by lyrebird. Based on alpine-linux.

> [!IMPORTANT] 
> This image is mainly for users who have a need for an obfuscation using tor (such as people in countries where the government is blocking entry nodes) and who have obtained [bridges](https://bridges.torproject.org/) to use with this container. For anyone else there is a plethora of tor containers without obfuscation, more lightweight and with less setup required. 

Or, I guess, you could still use this image after removing all lines about obfuscation in the torrc file, then it is just a slightly bigger "vanilla" tor proxy container.

# torrc example:
> [!CAUTION] 
> First of all, be sure to understand [this](https://support.torproject.org/tbb/tbb-editing-torrc/), do not trust random torrc configs found on the internet, not even this one.

torrc.sample
```ini
SOCKSPort 0.0.0.0::9050
SOCKSPolicy accept *

Log notice syslog

DataDirectory /var/lib/tor

UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/lyrebird

#Change bridge placeholders to the ones you got from torproject:
Bridge obfs4 AAA.BBB.CCC.DDD:EEEEE 0000000000000000000000000000000000000000 cert=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa iat-mode=X
Bridge obfs4 FFF.GGG.HHH.III:KKKKK 0000000000000000000000000000000000000000 cert=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb iat-mode=Y
```

> [!NOTE] 
> Note that binding SOCKS port to 0.0.0.0 exposes it to every IPv4 address in the world... inside of the container. So it is as safe as binding it to only one address. Logs will complain "[warn] You specified a public address '0.0.0.0:9050' for SocksPort. Other people on the Internet might find your computer and use it as an open proxy. Please don't allow this unless you have a good reason.", and if you are worried about that, you could use the internal IP that docker assigns in the virtual network, and bind SOCKS to it instead.

> [!NOTE] 
> Alternatively, if using host network mode, you can bind SOCKS to "localhost:9050" (if all connections to the proxy are from the same machine) or to your LAN IP range. Do not forget to use a firewall.

Refer to the [official sample configuration file](https://gitlab.torproject.org/tpo/core/tor/-/blob/HEAD/src/config/torrc.sample.in).

# docker-compose.yml example:

docker-compose.yml.sample
``` yaml
services:
  torproxy:
    image: freezeball/docker-torproxy-obfuscated:latest
    container_name: torproxy
    ports:
      - 9050:9050
    volumes:
      - /your/torrc/configuration/location:/etc/tor
      - /your/persistent/data/location:/var/lib/tor
    restart: always
```

I usually use /opt

``` yaml
    volumes:
      - /opt/torproxy/torrc:/etc/tor/torrc # note that this is a file, not a directory
      - /opt/torproxy/data:/var/lib/tor
```

# Usage

The container **will not** connect to the tor network immediately, it should take a couple of minutes to connect for the first time. If there are no errors in the logs, just let lyrebird do it's thing.

Check if you are connected to tor with `docker exec -it torproxy curl --proxy socks5://localhost:9050 https://check.torproject.org/`

Check if you can access proxy from outside with `curl --proxy socks5://<ip_of_the_machine_running_the_container>:9050 https://check.torproject.org/`
