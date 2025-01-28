FROM golang:bookworm AS app
RUN mkdir -p /yopass
WORKDIR /yopass
COPY . .
RUN go build ./cmd/yopass && go build ./cmd/yopass-server

FROM node:22 AS website
COPY website /website
WORKDIR /website
RUN yarn install --network-timeout 600000 && yarn build

FROM alpine:latest AS words
ADD https://github.com/dwyl/english-words/raw/refs/heads/master/words.txt /
RUN awk 'length($0) >= 3 && length($0) <= 5' /words.txt > /selected_words.txt

FROM gcr.io/distroless/base
COPY --from=app /yopass/yopass /yopass/yopass-server /
COPY --from=website /website/build /public
COPY --from=words /selected_words.txt /words.txt
ENTRYPOINT ["/yopass-server"]
