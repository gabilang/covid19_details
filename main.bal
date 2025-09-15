import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /covid/status on httpDefaultListener {
    resource function get greeting() returns error|json|http:InternalServerError {
        do {
            return "Hello, World";
        } on fail error err {
            // handle error
            return error("Not implemented", err);
        }
    }

    resource function get countries() returns CovidEntry[] {
        return covidTable.toArray();
    }

    resource function post countries(@http:Payload CovidEntry[] covidEntries)
                                    returns CovidEntry[]|ConflictingIsoCodesError {

        string[] conflictingISOs = from CovidEntry covidEntry in covidEntries
            where covidTable.hasKey(covidEntry.iso_code)
            select covidEntry.iso_code;

        if conflictingISOs.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting ISO Codes:", ...conflictingISOs)
                }
            };
        } else {
            covidEntries.forEach(covdiEntry => covidTable.add(covdiEntry));
            return covidEntries;
        }
    }

    resource function get countries/[string iso_code]() returns CovidEntry|InvalidIsoCodeError {
        CovidEntry? covidEntry = covidTable[iso_code];
        if covidEntry is () {
            return {
                body: {
                    errmsg: string `Invalid ISO Code: ${iso_code}`
                }
            };
        }
        return covidEntry;
    }
}

public final table<CovidEntry> key(iso_code) covidTable = table [
    {iso_code: "AFG", country: "Afghanistan", cases: 159303, deaths: 7386, recovered: 146084, active: 5833},
    {iso_code: "SL", country: "Sri Lanka", cases: 598536, deaths: 15243, recovered: 568637, active: 14656},
    {iso_code: "US", country: "USA", cases: 69808350, deaths: 880976, recovered: 43892277, active: 25035097}
];
