git-hook:
	@for hook in .config/git/*.hook; do \
		echo "==> Linking hook: $${hook}"; \
		ln -sf "../../$${hook}" ".git/hooks/$$(basename $${hook%.hook})"; \
	done
