SHELL := /bin/bash

################################################################################
# TaaS - Testing as a Service
# Automação de provisionamento e execução de testes k6
################################################################################

PROJECT := TaaS - K6
VERSION := 2.0.0

SCRIPT := scripts/taas.sh


################################################################################
# Cores
################################################################################

RESET        := \033[0m
CYAN         := \033[36m
YELLOW       := \033[33m
GREEN        := \033[32m
RED          := \033[31m
BOLD         := \033[1m


################################################################################
# Targets
################################################################################

.PHONY: help \
	prepare create setup run cmd update upload infracost clean destroy


################################################################################
# Helpers
################################################################################

define banner

	@printf "\n"
	@printf "$(YELLOW)====================================================$(RESET)\n"
	@printf "$(BOLD)$(PROJECT)$(RESET)\n"
	@printf "Versão: $(VERSION)\n"
	@printf "$(YELLOW)====================================================$(RESET)\n"
	@printf "$(CYAN)%s$(RESET)\n\n" "$(1)"

endef


define run_taas
	$(call banner,$(1))
	@$(SHELL) $(SCRIPT) $(2)
endef


################################################################################
# Ambiente
################################################################################

## Prepara o ambiente local e gera configurações.
prepare:
	$(call run_taas,Preparando ambiente local,-p)


## Cria a infraestrutura utilizando Terraform e Ansible.
create:
	$(call run_taas,Criando infraestrutura,-a create)


## Configura os servidores para execução dos testes.
setup:
	$(call run_taas,Configurando ambientes,-a setup)


################################################################################
# Testes k6
################################################################################

## Executa uma bateria de testes k6.
run:
	$(call run_taas,Executando testes de performance,-a run)


## Executa comandos diretamente nos geradores de carga.
cmd:
	$(call run_taas,Executando comando remoto,-a cmd)


## Atualiza os testes nos geradores de carga.
update:
	$(call run_taas,Atualizando testes,-a update)


## Envia resultados para o Report.
upload:
	$(call run_taas,Enviando resultados,-a upload)


################################################################################
# Infraestrutura
################################################################################

## Calcula o custo estimado da infraestrutura.
infracost:
	$(call run_taas,Calculando custo da infraestrutura,-a infracost)


## Remove a infraestrutura criada.
destroy:
	$(call run_taas,Removendo infraestrutura,-a destroy)


################################################################################
# Manutenção
################################################################################

## Remove configurações e arquivos temporários.
clean:
	$(call run_taas,Limpando ambiente local,-c)


################################################################################
# Help
################################################################################

## Exibe esta ajuda.
help:
	@printf "\n"
	@printf "$(YELLOW)====================================================$(RESET)\n"
	@printf "$(BOLD)$(PROJECT) - Comandos disponíveis$(RESET)\n"
	@printf "$(YELLOW)====================================================$(RESET)\n\n"

	@awk '\
		BEGIN {FS=":"} \
		/^##/ {desc=substr($$0,4); next} \
		/^[a-zA-Z0-9_-]+:/ { \
			printf "$(CYAN)%-15s$(RESET) %s\n", $$1, desc \
		}' $(MAKEFILE_LIST)

	@printf "\n"
	@printf "$(GREEN)Exemplo:$(RESET)\n"
	@printf "  make prepare\n"
	@printf "  make create\n"
	@printf "  make run\n\n"