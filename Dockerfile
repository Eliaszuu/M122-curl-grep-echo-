FROM alpine:3.18 AS builder

RUN apk add --no-cache bash curl jq pup

WORKDIR /app
COPY script.sh .

RUN chmod +x script.sh

FROM alpine:3.18

COPY --from=builder /bin/bash /bin/bash
COPY --from=builder /usr /usr
COPY --from=builder /app/script.sh /app/script.sh

ENTRYPOINT ["/bin/bash", "/app/script.sh"]
