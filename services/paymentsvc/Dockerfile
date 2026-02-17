FROM golang:1.22 AS build
WORKDIR /src
COPY . .
WORKDIR /src/services/paymentsvc
RUN go build -o app ./cmd/paymentsvc

FROM gcr.io/distroless/base-debian12
COPY --from=build /src/services/paymentsvc/app /app
CMD ["/app"]
