FROM golang:1.22 AS build
WORKDIR /src
COPY . .
WORKDIR /src/services/authsvc
RUN go build -o app ./cmd/authsvc

FROM gcr.io/distroless/base-debian12
COPY --from=build /src/services/authsvc/app /app
CMD ["/app"]
