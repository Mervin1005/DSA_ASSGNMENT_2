import ballerina/http;
import ballerina/jwt;
import ballerina/io;

public function main() {
    // Replace the following with your JWT token for authentication
    string jwtToken = "your_jwt_token_here";

    // Define the HTTP client endpoint for the GraphQL service
    http:Client client = new("http://localhost:9090/performanceManagement");

    // Perform operations based on user roles (HoD, Supervisor, Employee)

    // Sample operation for HoD (Creating a department objective)
   // Sample operation for HoD (Creating a department objective)
if (isHod(jwtToken)) {
    var createDepartmentObjectiveQuery = `
        mutation {
            createDepartmentObjective(departmentObjective: {
                departmentId: 1,
                description: "Sample Objective",
                weightage: 0.5
            }) {
                id
                departmentId
                description
                weightage
            }
        `;
    createDepartmentObjectiveQuery = createDepartmentObjectiveQuery + "\n}"; // Closing backtick

    var hodResponse = sendGraphQLRequest(client, createDepartmentObjectiveQuery, jwtToken);
    io:println("HoD Response: " + hodResponse);
}

// Sample operation for Supervisor (Creating an employee KPI)
if (isSupervisor(jwtToken)) {
    var createEmployeeKPIQuery = `
        mutation {
            createEmployeeKPI(employeeKPI: {
                departmentObjectiveId: 1,
                name: "Sample KPI",
                unit: "Unit",
                weightage: 0.5
            }) {
                id
                departmentObjectiveId
                name
                unit
                weightage
            }
        `;
    createEmployeeKPIQuery = createEmployeeKPIQuery + <object:RawTemplate>"\n}"; // Closing backtick

    var supervisorResponse = sendGraphQLRequest(client, createEmployeeKPIQuery, jwtToken);
    io:println("Supervisor Response: " + supervisorResponse);
}

// Sample operation for Employee (Viewing their scores)
if (isEmployee(jwtToken)) {
    var viewEmployeeScoresQuery = `
        query {
            viewEmployeeScores(employeeId: 1) {
                kpiName
                score
            }
        `;
    viewEmployeeScoresQuery = viewEmployeeScoresQuery + "\n}"; // Closing backtick

    var employeeResponse = sendGraphQLRequest(client, viewEmployeeScoresQuery, jwtToken);
    io:println("Employee Response: " + employeeResponse);
}

}

function isHod(jwtToken string) returns boolean {
    // Replace 'your_jwt_token_claim_key' with the actual key used to store user roles in the JWT
    var jwt = check jwt:decode(jwtToken);
    var roles = jwt.claims.your_jwt_token_claim_key;

    // Check if 'HoD' is one of the roles in the JWT
    return "HoD" in roles;
}

function isSupervisor(jwtToken string) returns boolean {
    // Replace 'your_jwt_token_claim_key' with the actual key used to store user roles in the JWT
    var jwt = check jwt:decode(jwtToken);
    var roles = jwt.claims.your_jwt_token_claim_key;

    // Check if 'Supervisor' is one of the roles in the JWT
    return "Supervisor" in roles;
}

function isEmployee(jwtToken string) returns boolean {
    // Replace 'your_jwt_token_claim_key' with the actual key used to store user roles in the JWT
    var jwt = check jwt:decode(jwtToken);
    var roles = jwt.claims.your_jwt_token_claim_key;

    // Check if 'Employee' is one of the roles in the JWT
    return "Employee" in roles;
}

function sendGraphQLRequest(http:Client client, string query, string jwtToken) returns string {
    // Define HTTP headers with the JWT token
    http:Headers headers = [
        { name: "Authorization", value: "Bearer " + jwtToken }
    ];

    // Send the GraphQL query with the JWT token
    var response = client->post("/graphql", query, headers);

    if (response is http:Response) {
        return response.getTextPayload();
    } else {
        return "Failed to send the request: " + response.toString();
    }
}
