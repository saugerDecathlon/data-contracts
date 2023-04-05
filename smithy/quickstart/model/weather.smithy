/// File: https://github.com/data-engineering-helpers/data-contracts/blob/main/smithy/quickstart/model/weather.smithy

$version: "2"
namespace example.weather

use aws.protocols#restJson1

/// Provides weather forecasts.
@paginated(
    inputToken: "nextToken"
    outputToken: "nextToken"
    pageSize: "pageSize"
)

@restJson1
service Weather {
    version: "2006-03-01"
    resources: [City]
    operations: [GetCurrentTime]
}

resource City {
    identifiers: { cityId: CityId }
    read: GetCity
    list: ListCities
    resources: [Forecast]
}

resource Forecast {
    identifiers: { cityId: CityId }
    read: GetForecast,
}

// "pattern" is a trait.
@pattern("^[A-Za-z0-9 ]+$")
string CityId

@readonly
@http(code: 200, method: "GET", uri: "/cities/{cityId}")
operation GetCity {
    input: GetCityInput
    output: GetCityOutput
    errors: [NoSuchResource]
}

@input
structure GetCityInput {
    // "cityId" provides the identifier for the resource and
    // has to be marked as required.
    @required
	@httpLabel
    cityId: CityId
}

@output
structure GetCityOutput {
    // "required" is used on output to indicate if the service
    // will always provide a value for the member.
    @required
    name: String

    @required
    coordinates: CityCoordinates
}

// This structure is nested within GetCityOutput.
structure CityCoordinates {
    @required
    latitude: Float

    @required
    longitude: Float
}

// "error" is a trait that is used to specialize
// a structure as an error.
@error("client")
structure NoSuchResource {
    @required
    resourceType: String
}

// The paginated trait indicates that the operation may
// return truncated results.
@readonly
@paginated(items: "items")
@http(code: 200, method: "GET", uri: "/cities")
operation ListCities {
    input: ListCitiesInput
    output: ListCitiesOutput
}

@input
structure ListCitiesInput {
	@httpQuery("nextToken")
    nextToken: String
	@httpQuery("pageSize")
    pageSize: Integer
}

@output
structure ListCitiesOutput {
    nextToken: String

    @required
    items: CitySummaries
}

// CitySummaries is a list of CitySummary structures.
list CitySummaries {
    member: CitySummary
}

// CitySummary contains a reference to a City.
@references([{resource: City}])
structure CitySummary {
    @required
    cityId: CityId

    @required
    name: String
}

@readonly
@http(code: 200, method: "GET", uri: "/currentTime")
operation GetCurrentTime {
    input: GetCurrentTimeInput
    output: GetCurrentTimeOutput
}

@input
structure GetCurrentTimeInput {}

@output
structure GetCurrentTimeOutput {
    @required
    time: Timestamp
}

@readonly
@http(code: 200, method: "GET", uri: "/forecast/{cityId}")
operation GetForecast {
    input: GetForecastInput
    output: GetForecastOutput
}

// "cityId" provides the only identifier for the resource since
// a Forecast doesn't have its own.
@input
structure GetForecastInput {
    @required
	@httpLabel
    cityId: CityId
}

@output
structure GetForecastOutput {
    chanceOfRain: Float
}

