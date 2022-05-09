package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/riipandi/fibergo/app/handlers"
)

// PublicRoutes func for describe group of public routes.
func PublicRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/v1")

	// Routes for GET method:
	route.Get("/books", handlers.GetBooks)   // get list of all books
	route.Get("/book/:id", handlers.GetBook) // get one book by ID

	// Routes for POST method:
	route.Post("/user/sign/up", handlers.UserSignUp) // register a new user
	route.Post("/user/sign/in", handlers.UserSignIn) // auth, return Access & Refresh tokens
}
