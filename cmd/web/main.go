package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	s1 "github.com/adoublef/aws/internal/home/http"
	"github.com/go-chi/chi/v5"
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
	mux := chi.NewMux()
	// rate limiter
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
