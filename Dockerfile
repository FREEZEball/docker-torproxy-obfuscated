FROM alpine:3.22.1
#USER tor
CMD ["tor"]

EXPOSE 9050

RUN apk add --no-cache \
                    tor \
                    lyrebird \
                    curl

HEALTHCHECK --interval=120s --timeout=30s --start-period=60s --retries=5 \
            CMD curl --silent --location --socks5-hostname localhost:9050 https://check.torproject.org/?lang=en_US | \
            grep -qm1 Congratulations
            #Thanks to https://github.com/FriendlyAdmin for the healthcheck code
