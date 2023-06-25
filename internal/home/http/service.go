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
	s.m.Get("/panic", func(w http.ResponseWriter, r *http.Request) {
		panic("test panic")
	})
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
	// should check that the incoming request has the correct headers
	// this includes: Content-Type, Accept, and Accept-Language, etc.
	return json.NewDecoder(r.Body).Decode(v)
}

func (mux *muxHandler) Respond(w http.ResponseWriter, r *http.Request, v any, code int) {
	// should check that the outgoing response has the correct headers
	// should also set some additional headers for the API
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	if v != nil {
		err := json.NewEncoder(w).Encode(v)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
}
