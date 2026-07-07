package main

import (
	"log"
	"net/http"
	"time"

	"sanad/internal/config"
	"sanad/internal/controller"
	"sanad/internal/database"
	"sanad/internal/middleware"
	"sanad/internal/repository"
	"sanad/internal/routes"
	"sanad/internal/service"
)

func main() {
	cfg := config.Load()

	db, err := database.Open(cfg.DBPath)
	if err != nil {
		log.Fatal("database: ", err)
	}
	if err := database.Seed(db, "seed.json"); err != nil {
		log.Fatal("seed: ", err)
	}
	if err := database.BootstrapAdmin(db, cfg.AdminEmail, cfg.AdminPassword); err != nil {
		log.Fatal("admin bootstrap: ", err)
	}

	// wire layers: repository -> service -> controller
	repo := repository.New(db)
	svc := service.New(repo)
	ctl := controller.New(svc, cfg.JWTSecret)

	mux := http.NewServeMux()
	routes.Register(mux, ctl)
	// serve the static frontend for everything else
	mux.Handle("/", http.FileServer(http.Dir(cfg.FrontendDir)))

	handler := middleware.Logger(middleware.CORS(mux))
	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}

	log.Printf("Sanad running → http://localhost:%s", cfg.Port)
	log.Printf("Admin login: %s / (ADMIN_PASSWORD env, default admin12345)", cfg.AdminEmail)
	log.Fatal(srv.ListenAndServe())
}
