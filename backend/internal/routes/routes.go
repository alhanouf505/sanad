package routes

import (
	"net/http"

	"sanad/internal/controller"
)

// Register wires every API route to its handler.
func Register(mux *http.ServeMux, c *controller.Controller) {
	// public
	mux.HandleFunc("GET /api/papers", c.Papers)
	mux.HandleFunc("GET /api/types", c.Types)
	mux.HandleFunc("GET /api/stories", c.Stories)
	mux.HandleFunc("POST /api/stories", c.SubmitStory)
	mux.HandleFunc("POST /api/subscribe", c.Subscribe)
	mux.HandleFunc("POST /api/papers/suggest", c.Suggest)

	// admin auth
	mux.HandleFunc("POST /api/admin/login", c.Login)

	// admin (protected)
	mux.HandleFunc("GET /api/admin/stories/pending", c.RequireAdmin(c.PendingStories))
	mux.HandleFunc("POST /api/admin/stories/{id}/approve", c.RequireAdmin(c.ApproveStory))
	mux.HandleFunc("POST /api/admin/stories/{id}/reject", c.RequireAdmin(c.RejectStory))
	mux.HandleFunc("POST /api/admin/papers", c.RequireAdmin(c.CreatePaper))
	mux.HandleFunc("DELETE /api/admin/papers/{id}", c.RequireAdmin(c.DeletePaper))
	mux.HandleFunc("GET /api/admin/suggestions", c.RequireAdmin(c.Suggestions))
	mux.HandleFunc("GET /api/admin/subscribers", c.RequireAdmin(c.Subscribers))
}
