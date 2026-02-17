module example.com/monorepo/services/paymentsvc
go 1.22

require (
  example.com/monorepo/libs/platform v0.0.0
  example.com/monorepo/gen/go v0.0.0
)

replace example.com/monorepo/libs/platform => ../../libs/platform
replace example.com/monorepo/gen/go => ../../gen/go
