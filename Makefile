RED?=$(shell tput setaf 1)
GREEN?=$(shell tput setaf 2)
YELLOW?=$(shell tput setaf 3)
BLUE?=$(shell tput setaf 4)
BOLD?=$(shell tput bold)
RST?=$(shell tput sgr0)


git-hook:
	@for hook in .config/git/*.hook; do \
		echo "==> Linking hook: $${hook}"; \
		ln -sf "../../$${hook}" ".git/hooks/$$(basename $${hook%.hook})"; \
	done

watch:
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)searching for upstream changes...$(RST)"
	@mkdir -p .cache/urlwatch
	@urlwatch --urls=./.urlwatch -c .cache/urlwatch
	@echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)successfully finished upstream watches$(RST)"
