package database

import (
	"encoding/json"
	"log"
	"os"

	"github.com/glebarez/sqlite"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"sanad/internal/models"
)

// Open connects to the SQLite database and runs migrations.
// Switching to PostgreSQL later is a one-line change (postgres.Open(dsn)).
func Open(path string) (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(path), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	if err := db.AutoMigrate(
		&models.Paper{}, &models.SarcomaType{}, &models.Story{},
		&models.Subscriber{}, &models.Suggestion{}, &models.Admin{},
	); err != nil {
		return nil, err
	}
	return db, nil
}

// Seed loads initial content from seed.json the first time (empty papers table).
func Seed(db *gorm.DB, seedPath string) error {
	var count int64
	db.Model(&models.Paper{}).Count(&count)
	if count > 0 {
		return nil
	}
	data, err := os.ReadFile(seedPath)
	if err != nil {
		log.Println("seed file not found, skipping seed:", err)
		return nil
	}

	var sf struct {
		Papers  []models.Paper `json:"papers"`
		Types   []struct{ Category, Tag, Name, Description string } `json:"types"`
		Stories []models.Story `json:"stories"`
	}
	if err := json.Unmarshal(data, &sf); err != nil {
		return err
	}

	for i := range sf.Papers {
		sf.Papers[i].Status = "approved"
	}
	if len(sf.Papers) > 0 {
		db.Create(&sf.Papers)
	}

	types := make([]models.SarcomaType, 0, len(sf.Types))
	for _, t := range sf.Types {
		types = append(types, models.SarcomaType{
			Category: t.Category, Tag: t.Tag, Name: t.Name, Description: t.Description,
		})
	}
	if len(types) > 0 {
		db.Create(&types)
	}

	for i := range sf.Stories {
		sf.Stories[i].Status = "approved"
	}
	if len(sf.Stories) > 0 {
		db.Create(&sf.Stories)
	}

	log.Printf("seeded: %d papers, %d types, %d stories", len(sf.Papers), len(types), len(sf.Stories))
	return nil
}

// BootstrapAdmin creates the first admin account if none exists.
func BootstrapAdmin(db *gorm.DB, email, password string) error {
	var c int64
	db.Model(&models.Admin{}).Count(&c)
	if c > 0 {
		return nil
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	return db.Create(&models.Admin{Email: email, Password: string(hash)}).Error
}
