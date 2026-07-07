package repository

import (
	"strings"

	"gorm.io/gorm"

	"sanad/internal/models"
)

// Repo is the data-access layer (the only place that talks to the DB).
type Repo struct{ db *gorm.DB }

func New(db *gorm.DB) *Repo { return &Repo{db: db} }

// PaperFilter carries the research-library query parameters.
type PaperFilter struct {
	Region, Topic, Type, Sort, Q string
}

// Papers returns approved papers matching the filter, sorted by year.
func (r *Repo) Papers(f PaperFilter) ([]models.Paper, error) {
	q := r.db.Model(&models.Paper{}).Where("status = ?", "approved")
	if f.Region != "" && f.Region != "all" {
		q = q.Where("region = ?", f.Region)
	}
	if f.Topic != "" && f.Topic != "all" {
		q = q.Where("topic = ?", f.Topic)
	}
	if f.Type != "" && f.Type != "all" {
		q = q.Where("type = ?", f.Type)
	}
	if s := strings.TrimSpace(f.Q); s != "" {
		like := "%" + s + "%"
		q = q.Where("title LIKE ? OR authors LIKE ? OR abstract LIKE ? OR journal LIKE ?",
			like, like, like, like)
	}
	order := "year DESC"
	if f.Sort == "old" {
		order = "year ASC"
	}
	var list []models.Paper
	err := q.Order(order).Find(&list).Error
	return list, err
}

func (r *Repo) CreatePaper(p *models.Paper) error { return r.db.Create(p).Error }
func (r *Repo) DeletePaper(id uint) error         { return r.db.Delete(&models.Paper{}, id).Error }

// Types returns all type cards grouped by category.
func (r *Repo) Types() (map[string][]models.SarcomaType, error) {
	var all []models.SarcomaType
	if err := r.db.Order("id asc").Find(&all).Error; err != nil {
		return nil, err
	}
	m := map[string][]models.SarcomaType{}
	for _, t := range all {
		m[t.Category] = append(m[t.Category], t)
	}
	return m, nil
}

func (r *Repo) Stories(status string) ([]models.Story, error) {
	var list []models.Story
	err := r.db.Where("status = ?", status).Order("created_at desc, id desc").Find(&list).Error
	return list, err
}
func (r *Repo) CreateStory(s *models.Story) error { return r.db.Create(s).Error }
func (r *Repo) SetStoryStatus(id uint, status string) error {
	return r.db.Model(&models.Story{}).Where("id = ?", id).Update("status", status).Error
}

func (r *Repo) Subscribe(email string) error {
	return r.db.Where(models.Subscriber{Email: email}).
		FirstOrCreate(&models.Subscriber{Email: email}).Error
}
func (r *Repo) Subscribers() ([]models.Subscriber, error) {
	var l []models.Subscriber
	err := r.db.Order("id desc").Find(&l).Error
	return l, err
}

func (r *Repo) CreateSuggestion(s *models.Suggestion) error { return r.db.Create(s).Error }
func (r *Repo) Suggestions() ([]models.Suggestion, error) {
	var l []models.Suggestion
	err := r.db.Order("id desc").Find(&l).Error
	return l, err
}

func (r *Repo) AdminByEmail(email string) (*models.Admin, error) {
	var a models.Admin
	err := r.db.Where("email = ?", email).First(&a).Error
	return &a, err
}
