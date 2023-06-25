FROM golang:1.20-alpine3.18@sha256:e7cc33118f807c67d9f2dfc811cc2cc8b79b3687d0b4ac891dd59bb2a5e4a8d3 AS builder
WORKDIR /build

COPY go.* ./
RUN go mod tidy && go mod download

COPY . .
RUN CGO_ENABLED=0 go build -buildvcs=false -a -installsuffix cgo -ldflags="-w -s" -o bin/web ./cmd/web

FROM alpine:3.18@sha256:25fad2a32ad1f6f510e528448ae1ec69a28ef81916a004d3629874104f8a7f70 AS runner
WORKDIR /opt/app

RUN apk --no-cache add ca-certificates
COPY --from=builder /build/bin/web .

EXPOSE 8080
CMD ["./web"]