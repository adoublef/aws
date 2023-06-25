package main

import "os"

type Config struct {
	addr string
}

func load() (*Config, bool) {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	return &Config{
		addr: ":" + port,
	}, true
}