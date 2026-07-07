package service

import (
	"errors"
	"strings"

	"sanad/internal/models"
	"sanad/internal/repository"
)

// Service holds the business logic (validation + rules) on top of the repository.
type Service struct{ repo *repository.Repo }

func New(r *repository.Repo) *Service { return &Service{repo: r} }

// ----- public -----

func (s *Service) ListPapers(f repository.PaperFilter) ([]models.Paper, error) {
	return s.repo.Papers(f)
}
func (s *Service) ListTypes() (map[string][]models.SarcomaType, error) { return s.repo.Types() }
func (s *Service) ListStories() ([]models.Story, error)                { return s.repo.Stories("approved") }

func (s *Service) SubmitStory(body, who, initial string) error {
	body = strings.TrimSpace(body)
	if len([]rune(body)) < 10 {
		return errors.New("النص قصير جدًا")
	}
	who = strings.TrimSpace(who)
	if initial == "" && who != "" {
		initial = string([]rune(who)[:1])
	}
	return s.repo.CreateStory(&models.Story{Body: body, Who: who, Initial: initial, Status: "pending"})
}

func (s *Service) Subscribe(email string) error {
	email = strings.ToLower(strings.TrimSpace(email))
	if !strings.Contains(email, "@") || len(email) < 5 {
		return errors.New("بريد إلكتروني غير صالح")
	}
	return s.repo.Subscribe(email)
}

func (s *Service) SuggestPaper(title, url, note, email string) error {
	title = strings.TrimSpace(title)
	if title == "" {
		return errors.New("العنوان مطلوب")
	}
	return s.repo.CreateSuggestion(&models.Suggestion{
		Title: title, URL: strings.TrimSpace(url),
		Note: strings.TrimSpace(note), Email: strings.TrimSpace(email),
	})
}

// ----- admin -----

func (s *Service) AdminByEmail(email string) (*models.Admin, error) {
	return s.repo.AdminByEmail(strings.ToLower(strings.TrimSpace(email)))
}
func (s *Service) PendingStories() ([]models.Story, error)   { return s.repo.Stories("pending") }
func (s *Service) SetStoryStatus(id uint, st string) error   { return s.repo.SetStoryStatus(id, st) }
func (s *Service) CreatePaper(p *models.Paper) error         { p.Status = "approved"; return s.repo.CreatePaper(p) }
func (s *Service) DeletePaper(id uint) error                 { return s.repo.DeletePaper(id) }
func (s *Service) Suggestions() ([]models.Suggestion, error) { return s.repo.Suggestions() }
func (s *Service) Subscribers() ([]models.Subscriber, error) { return s.repo.Subscribers() }
