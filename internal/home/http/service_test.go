package http_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	s1 "github.com/adoublef/aws/internal/home/http"
	is "github.com/stretchr/testify/require"
)

func TestHome(t *testing.T) {
	t.Parallel()

	s := newTestServer(t)
	t.Cleanup(func() { s.Close() })

	testRequest(t, s, http.MethodGet, "/", http.StatusOK)
}

func newTestServer(t *testing.T) *httptest.Server {
	t.Helper()

	s := s1.NewService()
	return httptest.NewServer(s)
}

func testRequest(t *testing.T, s *httptest.Server, method string, path string, code int) {
	t.Helper()

	req, err := http.NewRequest(method, s.URL+path, nil)
	is.NoError(t, err)

	res, err := s.Client().Do(req)
	is.NoError(t, err)

	defer res.Body.Close()

	is.Equal(t, code, res.StatusCode)
}