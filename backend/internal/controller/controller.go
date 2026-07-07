package controller

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"

	"sanad/internal/models"
	"sanad/internal/repository"
	"sanad/internal/service"
)

// Controller wires HTTP handlers to the service layer.
type Controller struct {
	svc       *service.Service
	jwtSecret []byte
}

func New(svc *service.Service, secret string) *Controller {
	return &Controller{svc: svc, jwtSecret: []byte(secret)}
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
func writeErr(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}

// ----- public endpoints -----

func (c *Controller) Papers(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	f := repository.PaperFilter{
		Region: q.Get("region"), Topic: q.Get("topic"),
		Type: q.Get("type"), Sort: q.Get("sort"), Q: q.Get("q"),
	}
	list, err := c.svc.ListPapers(f)
	if err != nil {
		writeErr(w, 500, "database error")
		return
	}
	writeJSON(w, 200, list)
}

func (c *Controller) Types(w http.ResponseWriter, r *http.Request) {
	m, err := c.svc.ListTypes()
	if err != nil {
		writeErr(w, 500, "database error")
		return
	}
	writeJSON(w, 200, m)
}

func (c *Controller) Stories(w http.ResponseWriter, r *http.Request) {
	l, err := c.svc.ListStories()
	if err != nil {
		writeErr(w, 500, "database error")
		return
	}
	writeJSON(w, 200, l)
}

func (c *Controller) SubmitStory(w http.ResponseWriter, r *http.Request) {
	var b struct{ Body, Who, Initial string }
	if json.NewDecoder(r.Body).Decode(&b) != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	if err := c.svc.SubmitStory(b.Body, b.Who, b.Initial); err != nil {
		writeErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"message": "تم استلام قصتك وسيتم مراجعتها قبل النشر"})
}

func (c *Controller) Subscribe(w http.ResponseWriter, r *http.Request) {
	var b struct{ Email string }
	if json.NewDecoder(r.Body).Decode(&b) != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	if err := c.svc.Subscribe(b.Email); err != nil {
		writeErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"message": "تم اشتراكك بنجاح"})
}

func (c *Controller) Suggest(w http.ResponseWriter, r *http.Request) {
	var b struct{ Title, URL, Note, Email string }
	if json.NewDecoder(r.Body).Decode(&b) != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	if err := c.svc.SuggestPaper(b.Title, b.URL, b.Note, b.Email); err != nil {
		writeErr(w, 400, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"message": "تم استلام اقتراحك، شكرًا لك"})
}

// ----- admin auth -----

type adminClaims struct {
	AdminID uint `json:"aid"`
	jwt.RegisteredClaims
}

func (c *Controller) Login(w http.ResponseWriter, r *http.Request) {
	var b struct{ Email, Password string }
	if json.NewDecoder(r.Body).Decode(&b) != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	a, err := c.svc.AdminByEmail(b.Email)
	if err != nil || bcrypt.CompareHashAndPassword([]byte(a.Password), []byte(b.Password)) != nil {
		writeErr(w, 401, "بيانات الدخول غير صحيحة")
		return
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, adminClaims{
		AdminID:          a.ID,
		RegisteredClaims: jwt.RegisteredClaims{ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour))},
	})
	s, _ := tok.SignedString(c.jwtSecret)
	writeJSON(w, 200, map[string]string{"token": s})
}

// RequireAdmin protects admin routes with a Bearer JWT.
func (c *Controller) RequireAdmin(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		parts := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			writeErr(w, 401, "unauthorized")
			return
		}
		_, err := jwt.ParseWithClaims(parts[1], &adminClaims{}, func(t *jwt.Token) (any, error) {
			return c.jwtSecret, nil
		})
		if err != nil {
			writeErr(w, 401, "invalid or expired token")
			return
		}
		next(w, r)
	}
}

// ----- admin endpoints -----

func (c *Controller) PendingStories(w http.ResponseWriter, r *http.Request) {
	l, _ := c.svc.PendingStories()
	writeJSON(w, 200, l)
}
func (c *Controller) ApproveStory(w http.ResponseWriter, r *http.Request) {
	if err := c.svc.SetStoryStatus(idFrom(r), "approved"); err != nil {
		writeErr(w, 500, "error")
		return
	}
	writeJSON(w, 200, map[string]string{"message": "approved"})
}
func (c *Controller) RejectStory(w http.ResponseWriter, r *http.Request) {
	c.svc.SetStoryStatus(idFrom(r), "rejected")
	writeJSON(w, 200, map[string]string{"message": "rejected"})
}
func (c *Controller) CreatePaper(w http.ResponseWriter, r *http.Request) {
	var p models.Paper
	if json.NewDecoder(r.Body).Decode(&p) != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	if err := c.svc.CreatePaper(&p); err != nil {
		writeErr(w, 500, "error")
		return
	}
	writeJSON(w, 201, p)
}
func (c *Controller) DeletePaper(w http.ResponseWriter, r *http.Request) {
	if err := c.svc.DeletePaper(idFrom(r)); err != nil {
		writeErr(w, 500, "error")
		return
	}
	writeJSON(w, 200, map[string]string{"message": "deleted"})
}
func (c *Controller) Suggestions(w http.ResponseWriter, r *http.Request) {
	l, _ := c.svc.Suggestions()
	writeJSON(w, 200, l)
}
func (c *Controller) Subscribers(w http.ResponseWriter, r *http.Request) {
	l, _ := c.svc.Subscribers()
	writeJSON(w, 200, l)
}

func idFrom(r *http.Request) uint {
	id, _ := strconv.Atoi(r.PathValue("id"))
	return uint(id)
}
