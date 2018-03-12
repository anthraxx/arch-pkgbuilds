REPO_CMD=svn checkout --depth=files
REPO_URL_COMMUNITY=svn+ssh://svn-community@repos.archlinux.org/srv/repos
REPO_URL_PACKAGES=svn+ssh://svn-packages@repos.archlinux.org/srv/repos

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
	@mkdir -p .cache
	@urlwatch --urls ./.urlwatch --cache .cache/urlwatch.db
	@echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)successfully finished upstream watches$(RST)"

clean:
	@echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)cleaning up...$(RST)"
	@find * -type d \( -name 'src' -o -name 'pkg' \) -print0 | xargs -0 -I {} rm -v -r '{}'|sed -e 's/removed ‘\(.*\)’/$(BOLD)$(YELLOW)  -> $(BLUE)\1$(RST)/g'
	@find * -type f \( -name "*.zip" -o -name "*.tgz" -o -name "*.jar" -o -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.bz2' -o -name '*.sig' -o -name '*.log' -o -name '*.gem' \) -print0 | xargs -0 -I {} rm -v '{}'|sed -e 's/removed ‘\(.*\)’/$(BOLD)$(YELLOW)  -> $(BLUE)\1$(RST)/g'
	@echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)successfully cleaned up$(RST)"

reverse-sync-repo:
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)reverse sync all repo files...$(RST)"
	@for PKG in `ls .repo/community|grep -v .repo`; do \
		echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)syncing community/$${PKG}...$(RST)"; \
		cp .repo/community/$${PKG}/trunk/PKGBUILD $${PKG}/PKGBUILD; \
	done
	@for PKG in `ls .repo/packages|grep -v .repo`; do \
		echo "$(BOLD)$(GREEN)[+] $(RST)$(BOLD)syncing packages/$${PKG}...$(RST)"; \
		cp .repo/packages/$${PKG}/trunk/PKGBUILD $${PKG}/PKGBUILD; \
	done

update-index-file:
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)updating community.list index file...$(RST)"
	ls .repo/community|sort > .repo/community.list
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)updating packages.list index file...$(RST)"
	ls .repo/packages|sort > .repo/packages.list

repo-checkout:
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Initialize community repo...$(RST)"
	${REPO_CMD} ${REPO_URL_COMMUNITY}/svn-community/svn .repo/community
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Initialize packages repo...$(RST)"
	${REPO_CMD} ${REPO_URL_PACKAGES}/svn-packages/svn .repo/packages

repo: repo-checkout
	@cd .repo/community; \
		for PKG in `cat ../community.list`; do \
			echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Checkout community/$${PKG}...$(RST)"; \
			svn update $${PKG} >/dev/null; \
		done
	@cd .repo/packages; \
		for PKG in `cat ../packages.list`; do \
			echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Checkout packages/$${PKG}...$(RST)"; \
			svn update $${PKG} >/dev/null; \
		done

repo-update:
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Update community...$(RST)"
	@.repo/update community
	@echo "$(BOLD)$(GREEN)[*] $(RST)$(BOLD)Update packages...$(RST)"
	@.repo/update packages
