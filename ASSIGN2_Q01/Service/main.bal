import ballerina/http;
import ballerina/graphql;
import ballerina/mysql;
import ballerina/auth;

// Define the User type and other relevant types
type User {
    int id;
    string username;
    // Add other user fields
}

type DepartmentObjective {
    int id;
    int departmentId;
    string description;
    float weightage;
}

type EmployeeKPI {
    int id;
    int departmentObjectiveId;
    string name;
    string unit;
    float weightage;
    // Add other fields
}

// Define the GraphQL service with additional types and operations
service /performanceManagement on new http:Service {
    // Define the GraphQL service and type mappings
    resource function performanceManagementService() returns graphql:Service {
        // Define types in the GraphQL schema
        typeDefs = `
            type User {
                id: Int!
                username: String
                // Add other user fields
            }

            type DepartmentObjective {
                id: Int!
                departmentId: Int!
                description: String
                weightage: Float
            }

            type EmployeeKPI {
                id: Int!
                departmentObjectiveId: Int!
                name: String
                unit: String
                weightage: Float
                // Add other fields
            }

            type Mutation {
                createDepartmentObjective(departmentObjective: DepartmentObjectiveInput!): DepartmentObjective
                createEmployeeKPI(employeeKPI: EmployeeKPIInput!): EmployeeKPI
                // Add resolvers for other mutations
            }

            input DepartmentObjectiveInput {
                departmentId: Int!
                description: String!
                weightage: Float!
            }

            input EmployeeKPIInput {
                departmentObjectiveId: Int!
                name: String!
                unit: String!
                weightage: Float!
                // Add other fields
            }
        `;

        // Define the resolvers
        resolvers = {
            Mutation: {
                createDepartmentObjective: createDepartmentObjective,
                createEmployeeKPI: createEmployeeKPI,
                // Add resolvers for other mutations
            }
        };

        graphql:Service performanceManagementService = new(typeDefs, resolvers);
        return performanceManagementService;
    }
}

// Define the MySQL database connection endpoint
endpoint mysql:Client dbClient {
    host: "localhost",
    port: 3306,
    name: "performance_management",
    username: "root",
    password: ""
};

// Implement resolvers for the new mutations
function createEmployeeKPI(EmployeeKPIInput employeeKPIInput) returns EmployeeKPI|error {
    // Implement authentication and role checks similar to what's done for HoDs in the provided code
    // Example: Check the user's role from the JWT token

    auth:Subject subject = check jwt:authenticate(jwt:JwtDecodingConfig {
        // Add JWT decoding configuration
    });

    if (subject.roles != "Supervisor") {
        // Unauthorized
        return check new graphql:Error("Unauthorized", "You are not authorized to create employee KPIs.");
    }

    // Insert the employee KPI into the database
    string insertQuery = "INSERT INTO kpis (department_objective_id, name, unit, weightage) VALUES (?, ?, ?, ?)";
    var insertResult = dbClient->executeUpdate(insertQuery, [employeeKPIInput.departmentObjectiveId, employeeKPIInput.name, employeeKPIInput.unit, employeeKPIInput.weightage]);

    if (insertResult is int) {
        // Successfully inserted, fetch the newly created KPI
        string selectQuery = "SELECT * FROM kpis WHERE id = ?";
        var kpi = check selectKPI(selectQuery, insertResult);
        return kpi;
    } else {
        // Error occurred while inserting
        return check new graphql:Error("Internal Server Error", "Failed to create employee KPI.");
    }
}

// Define a resolver to fetch an employee KPI from the database
function selectKPI(string query, int kpiId) returns EmployeeKPI {
    var result = dbClient->select(query, [kpiId]);
    if (result is table<record {}>) {
        record{}|error row = result.next();
        if (row is record{}) {
            EmployeeKPI employeeKPI = {
                id: kpiId,
                departmentObjectiveId: row[0].toString(),
                name: row[1].toString(),
                unit: row[2].toString(),
                weightage: row[3].toString()
                // Add other fields
            };
            return employeeKPI;
        }
    }
    // Return an empty EmployeeKPI in case of errors
    return {};
}

// Implement authentication and authorization logic as needed

public function main() {
    http:ServiceConfig serviceConfig = { port: 9090 };
    http:Listener listener = check new http:Listener(serviceConfig);
    check listener->start();
    io:println("Performance Management GraphQL Service started on port 9090");
}
