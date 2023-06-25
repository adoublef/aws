package http

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
)

var _ http.Handler = (*Service)(nil)

type Service struct {
	m *muxHandler
}

// ServeHTTP implements http.Handler.
func (s *Service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.m.ServeHTTP(w, r)
}

func NewService() *Service {
	s := Service{m: defaultMux}
	s.routes()

	return &s
}

func (s *Service) routes() {
	s.m.Get("/", s.handleHome())
}

func (s *Service) handleHome() http.HandlerFunc {
	type response struct {
		Message string `json:"message"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		s.m.Respond(w, r, response{Message: "Hello, World!"}, http.StatusOK)
	}
}

var defaultMux = &muxHandler{chi.NewRouter()}

var _ http.Handler = (*muxHandler)(nil)

type muxHandler struct {
	*chi.Mux
}

func (mux *muxHandler) Decode(w http.ResponseWriter, r *http.Request, v any) error {
	return json.NewDecoder(r.Body).Decode(v)
}

func (mux *muxHandler) Respond(w http.ResponseWriter, r *http.Request, v any, code int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	if v != nil {
		err := json.NewEncoder(w).Encode(v)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
}
