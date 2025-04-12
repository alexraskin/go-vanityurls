FROM golang:1.24-alpine AS build

RUN apk add --no-cache curl

RUN curl -sSL https://github.com/leighmcculloch/vangen/releases/download/v1.4.0/vangen_1.4.0_linux_amd64.tar.gz | tar xz -C /usr/local/bin vangen

WORKDIR /build

COPY vangen.json ./

RUN vangen -out ./public

COPY go.mod ./

RUN go mod download

COPY . .

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 \
    go build -o go-vanityurls go.twizy.sh/go-vanityurls

FROM alpine

COPY --from=build /build/go-vanityurls /bin/go-vanityurls

EXPOSE 8080

ENTRYPOINT ["/bin/go-vanityurls"]

CMD ["-port", "8080"]