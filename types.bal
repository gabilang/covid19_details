import ballerina/http;

public type CovidEntry record {|
    readonly string iso_code;
    string country;
    decimal cases;
    decimal deaths;
    decimal recovered;
    decimal active;
|};

public type ConflictingIsoCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidIsoCodeError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};

