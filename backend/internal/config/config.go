package config

import "os"

// Config holds all runtime settings for the Sanad server.
type Config struct {
	Port          string
	DBPath        string
	FrontendDir   string
	JWTSecret     string
	AdminEmail    string
	AdminPassword string
}

// Load reads configuration from environment variables with sensible defaults.
func Load() Config {
	return Config{
		Port:          env("PORT", "8080"),
		DBPath:        env("DB_PATH", "sanad.db"),
		FrontendDir:   env("FRONTEND_DIR", "../frontend"),
		JWTSecret:     env("JWT_SECRET", "dev-secret-change-me"),
		AdminEmail:    env("ADMIN_EMAIL", "admin@sanad.sa"),
		AdminPassword: env("ADMIN_PASSWORD", "admin12345"),
	}
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
