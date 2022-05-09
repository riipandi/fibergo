package database

import "github.com/riipandi/fibergo/cmd/services"

// Queries struct for collect all app services.
type Queries struct {
	*services.UserQueries // load services from User model
	*services.BookQueries // load services from Book model
}

// OpenDBConnection func for opening database connection.
func OpenDBConnection() (*Queries, error) {
	// Define a new PostgreSQL connection.
	db, err := PostgreSQLConnection()
	if err != nil {
		return nil, err
	}

	return &Queries{
		// Set services from models:
		UserQueries: &services.UserQueries{DB: db}, // from User model
		BookQueries: &services.BookQueries{DB: db}, // from Book model
	}, nil
}
