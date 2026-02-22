# Convenience targets for managing the local Jekyll workflow

.PHONY: help install start stop build clean

LIVERELOAD_PORT ?= 35729
ifeq ($(NO_LIVERELOAD),1)
LIVERELOAD_FLAGS :=
else
LIVERELOAD_FLAGS := --livereload --livereload-port $(LIVERELOAD_PORT)
endif

help:
	@printf "Uso: make <comando>\n"
	@printf "Comandos:\n"
	@printf "  install  Instala as gems do Ruby via Bundler\n"
	@printf "  start    Inicia o servidor local do Jekyll na porta 4000\n"
	@printf "  stop     Para qualquer processo do Jekyll em execução\n"
	@printf "  build    Compila o site sem servi-lo\n"
	@printf "  clean    Remove o diretório _site gerado\n"

install:
	bundle install

start: stop
	bundle exec jekyll serve $(LIVERELOAD_FLAGS) --host 0.0.0.0 --port 4000

stop:
	fuser -k 4000/tcp 2>/dev/null || true
	fuser -k $(LIVERELOAD_PORT)/tcp 2>/dev/null || true

build:
	bundle exec jekyll build

clean:
	rm -rf _site
