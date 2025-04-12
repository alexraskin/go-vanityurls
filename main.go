package main

import (
	"embed"
	"errors"
	"flag"
	"io/fs"
	"log"
	"net/http"
)

//go:embed public
var public embed.FS

func main() {
	port := flag.String("port", "8080", "port to listen on")
	flag.Parse()

	sub, err := fs.Sub(public, "public")
	if err != nil {
		log.Fatalf("failed to get sub filesystem: %v", err)
	}

	log.Printf("listening on :%s", *port)
	if err = http.ListenAndServe(":"+*port, http.FileServer(http.FS(sub))); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Printf("failed to listen and serve: %v", err)
	}
}
