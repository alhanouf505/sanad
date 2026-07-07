// أداة صغيرة: تنشئ/تحدّث حساب أدمن بإيميل وكلمة مرور محدّدين.
// الاستخدام: go run ./tools/mkadmin <email> <password>
package main

import (
	"fmt"
	"log"
	"os"

	"golang.org/x/crypto/bcrypt"

	"sanad/internal/config"
	"sanad/internal/database"
	"sanad/internal/models"
)

func main() {
	if len(os.Args) < 3 {
		log.Fatal("usage: go run ./tools/mkadmin <email> <password>")
	}
	email, password := os.Args[1], os.Args[2]

	cfg := config.Load()
	db, err := database.Open(cfg.DBPath)
	if err != nil {
		log.Fatal(err)
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}

	var admin models.Admin
	db.Where("email = ?", email).First(&admin)
	admin.Email = email
	admin.Password = string(hash)
	if err := db.Save(&admin).Error; err != nil {
		log.Fatal(err)
	}
	fmt.Printf("✓ admin ready → %s\n", email)
}
