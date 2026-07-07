package models

import "time"

// Paper is one research paper in the library.
// JSON keys are chosen to match what the existing frontend expects.
type Paper struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Title     string    `gorm:"not null" json:"title"`
	Authors   string    `json:"authors"`
	Abstract  string    `gorm:"type:text" json:"abs"`
	Journal   string    `json:"journal"`
	URL       string    `json:"url"`
	Region    string    `gorm:"index;size:16" json:"region"` // saudi | arab | global
	Topic     string    `gorm:"index;size:20" json:"topic"`  // genetic | clinical | treatment | diagnosis
	Type      string    `gorm:"index;size:16" json:"type"`   // rms | sts | bone
	Year      int       `gorm:"index" json:"year"`
	Status    string    `gorm:"index;size:12;default:approved" json:"-"`
	CreatedAt time.Time `json:"-"`
}

// SarcomaType is one card under a category (soft / bone / child).
type SarcomaType struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Category    string `gorm:"index;size:16" json:"category"`
	Tag         string `json:"tag"`
	Name        string `json:"h"`
	Description string `gorm:"type:text" json:"p"`
}

// Story is a patient/supporter story. Submitted ones start as pending.
type Story struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Initial   string    `gorm:"size:8" json:"initial"`
	Body      string    `gorm:"type:text" json:"body"`
	Who       string    `json:"who"`
	Status    string    `gorm:"index;size:12;default:pending" json:"-"`
	CreatedAt time.Time `json:"-"`
}

// Subscriber is a newsletter/contact email.
type Subscriber struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Email     string    `gorm:"uniqueIndex;size:160" json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

// Suggestion is a paper suggested by a visitor for review.
type Suggestion struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Title     string    `json:"title"`
	URL       string    `json:"url"`
	Note      string    `gorm:"type:text" json:"note"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

// Admin is a dashboard user.
type Admin struct {
	ID       uint   `gorm:"primaryKey" json:"id"`
	Email    string `gorm:"uniqueIndex;size:160" json:"email"`
	Password string `json:"-"`
}
