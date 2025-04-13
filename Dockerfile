# Stage 1: Builder – installiert benötigte Tools
FROM alpine:3.18 AS builder

RUN apk add --no-cache bash curl jq pup

WORKDIR /app
COPY script.sh .

RUN chmod +x script.sh

# Stage 2: Finale Image – minimales System mit nur dem, was nötig ist
FROM alpine:3.18

# bash + Tools übernehmen
COPY --from=builder /bin/bash /bin/bash
COPY --from=builder /usr /usr
COPY --from=builder /app/script.sh /app/script.sh

ENTRYPOINT ["/bin/bash", "/app/script.sh"]
