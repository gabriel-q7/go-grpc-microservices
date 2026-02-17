FROM golang:1.22 AS build
WORKDIR /src
COPY . .
WORKDIR /src/services/usersvc
RUN go build -o app ./cmd/usersvc

FROM gcr.io/distroless/base-debian12
COPY --from=build /src/services/usersvc/app /app
CMD ["/app"]
