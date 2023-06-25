package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	s1 "github.com/adoublef/aws/internal/home/http"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/httplog"
	"github.com/go-chi/httprate"
)

func main() {
	cfg, ok := load()
	if !ok {
		log.Fatal("failed to load config")
	}

	ctx, cancel := context.WithCancel(context.Background())

	q := make(chan os.Signal, 1)
	signal.Notify(q, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-q
		cancel()
	}()

	if err := run(ctx, cfg); err != nil {
		log.Fatal(err)
	}
}

func run(ctx context.Context, cfg *Config) (err error) {
	logger := httplog.NewLogger("server", httplog.Options{
		Concise: true,
	})

	mux := chi.NewMux()
	mux.Use(middleware.RequestID)
	mux.Use(httplog.RequestLogger(logger))
	mux.Use(middleware.RealIP)
	// 10 req per minute until CI/CD is setup
	mux.Use(httprate.LimitByRealIP(10, 1))
	// timeout hard-coded for development, should be configurable
	mux.Use(middleware.Timeout(60 * time.Second))
	mux.Mount("/", s1.NewService())

	srv := &http.Server{
		Handler: mux,
		Addr:    cfg.addr,
		BaseContext: func(_ net.Listener) context.Context {
			return ctx
		},
	}

	e := make(chan error, 1)

	go func() {
		e <- srv.ListenAndServe()
	}()

	select {
	case <-ctx.Done():
		return srv.Shutdown(ctx)
	case err := <-e:
		return err
	}
}
