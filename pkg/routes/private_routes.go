package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/riipandi/fibergo/app/handlers"
	"github.com/riipandi/fibergo/pkg/middleware"
)

// PrivateRoutes func for describe group of private routes.
func PrivateRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/v1")

	// Routes for POST method:
	route.Post("/book", middleware.JWTProtected(), handlers.CreateBook)           // create a new book
	route.Post("/user/sign/out", middleware.JWTProtected(), handlers.UserSignOut) // de-authorization user
	route.Post("/token/renew", middleware.JWTProtected(), handlers.RenewTokens)   // renew Access & Refresh tokens

	// Routes for PUT method:
	route.Put("/book", middleware.JWTProtected(), handlers.UpdateBook) // update one book by ID

	// Routes for DELETE method:
	route.Delete("/book", middleware.JWTProtected(), handlers.DeleteBook) // delete one book by ID
}
