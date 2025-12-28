package main

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"math/rand/v2"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

func listenAndServe(servers ...*http.Server) {
	for _, server := range servers {
		go func() {
			slog.Info("Starting http server", "addr", server.Addr)
			err := server.ListenAndServe()
			if err != nil {
				log.Fatal(err)
			}
		}()
	}

	sigChannel := make(chan os.Signal, 1)
	signal.Notify(sigChannel, os.Interrupt, syscall.SIGTERM)
	<-sigChannel

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*4)
	defer cancel()

	var wg sync.WaitGroup
	wg.Add(len(servers))
	for _, server := range servers {
		go func() {
			defer wg.Done()
			err := server.Shutdown(ctx)
			if err != nil {
				log.Fatal(err)
			}
		}()
	}
	wg.Wait()
}

func mainHandler(w http.ResponseWriter, r *http.Request) {
	randomInt := rand.IntN(500)
	hostname, err := os.Hostname()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
	time.Sleep(time.Duration(randomInt) * time.Millisecond)
	w.WriteHeader(http.StatusAccepted)
	fmt.Fprintf(w, "Hello from %s\n", hostname)
	slog.Info("Handling request for", "path", r.RequestURI, "after_ms", randomInt)
}

func healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusAccepted)
	fmt.Fprintf(w, "%s\n", "success")
	slog.Info("Handling request for", "path", r.RequestURI)
}

func main() {
	mainMux := http.NewServeMux()
	mainMux.HandleFunc("/home", mainHandler)

	mainServer := &http.Server{
		Addr:    ":80",
		Handler: mainMux,
	}

	healthcheckMux := http.NewServeMux()
	healthcheckMux.HandleFunc("/healthcheck", healthcheckHandler)

	healthcheckServer := &http.Server{
		Addr:    ":8080",
		Handler: healthcheckMux,
	}

	listenAndServe(mainServer, healthcheckServer)
}
