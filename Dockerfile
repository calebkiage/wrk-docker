# Build:
# docker build --tag=wrk --target=wrk .
# docker build --tag=wrk2 --target=wrk2 .
# Run Interactive:
# docker run -rm -it wrk sh
# docker run -rm -it wrk2 sh
#
# Run:
# docker run -rm -it wrk wrk -t5 -c55 -d5 --latency http://host.docker.internal:8000

FROM alpine:3 AS base_build
WORKDIR /src
RUN apk add --no-cache git gcc openssl-dev make linux-headers musl-dev perl


FROM base_build AS build-wrk
RUN git clone https://github.com/wg/wrk.git --depth=1 && cd wrk && make

FROM base_build AS build-wrk2
RUN apk add --no-cache zlib-dev
RUN git clone https://github.com/giltene/wrk2.git --depth=1 && cd wrk2 && make && mv wrk wrk2


FROM alpine:3 AS wrk
RUN apk add --no-cache libgcc
COPY --from=build-wrk /src/wrk/wrk /bin
RUN adduser -H -D wrk
USER wrk
CMD [ "/bin/wrk", "--help" ]


FROM alpine:3 AS wrk2
RUN apk add --no-cache libgcc
COPY --from=build-wrk2 /src/wrk2/wrk2 /bin
RUN adduser -H -D wrk2
USER wrk2
ENTRYPOINT [ "/bin/wrk2" ]
CMD [ "--help" ]

