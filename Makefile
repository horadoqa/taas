SHELL := /bin/bash

PROJECT := TAAS - K6

COLOR_RESET   := \033[0m
COLOR_COMMAND := \033[36m
COLOR_YELLOW  := \033[33m

SCRIPT := scripts/taas.sh

.PHONY: \
	help prepare create setup run cmd update upload infracost clean destroy

layout:
	@printf "\n$(COLOR_YELLOW)----------------------------------------------------$(COLOR_RESET)\n"
	@printf "$(COLOR_YELLOW)[$(PROJECT)] %s$(COLOR_RESET)\n" "$(MESSAGE)"
	@printf "$(COLOR_YELLOW)----------------------------------------------------$(COLOR_RESET)\n\n"


define run_taas
	@$(MAKE) layout MESSAGE="$(1)"
	@$(SHELL) $(SCRIPT) $(2)
endef


## Configura o ambiente local.
prepare:
	$(call run_taas,Configura o ambiente para execução local,-p)


## Cria a infraestrutura.
create:
	$(call run_taas,Cria os ambientes,-a create)


## Configura os ambientes.
setup:
	$(call run_taas,Configura os ambientes,-a setup)


## Executa os testes.
run:
	$(call run_taas,Executa os testes,-a run)


## Executa um comando remoto.
cmd:
	$(call run_taas,Executa comando remoto,-a cmd)


## Atualiza os arquivos do ambiente.
update:
	$(call run_taas,Atualiza os testes,-a update)


## Faz upload dos resultados.
upload:
	$(call run_taas,Upload dos resultados,-a upload)


## Calcula custo da infraestrutura.
infracost:
	$(call run_taas,Calcula custo da infraestrutura,-a infracost)


## Limpa o ambiente local.
clean:
	$(call run_taas,Limpeza do ambiente,-c)


## Remove a infraestrutura.
destroy:
	$(call run_taas,Remove a infraestrutura,-a destroy)


## Exibe esta ajuda.
help:
	@printf "\n$(COLOR_YELLOW)------------\n$(PROJECT)\n------------$(COLOR_RESET)\n\n"
	@awk '\
		BEGIN {FS=":"} \
		/^[a-zA-Z0-9_.%-]+:/ { \
			if (last ~ /^## /) { \
				printf "$(COLOR_COMMAND)%-18s$(COLOR_RESET) %s\n", $$1, substr(last,4); \
			} \
		} \
		{ last = $$0 }' $(MAKEFILE_LIST)