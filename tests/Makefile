# Tests for git-weave

test: roundtrip

roundtrip:
	@for f in *.fi; \
	do \
		echo "Testing $$f"; \
		mkdir test-repo && git init -q test-repo && \
		(cd test-repo >/dev/null; git fast-import --quiet) <$$f && \
		../git-weave test-repo unpacked && \
		../git-weave unpacked repacked && \
		(cd repacked >/dev/null; git fast-export --all) >/tmp/wvregress$$ && \
		diff -u $$f /tmp/wvregress$$; \
		make --quiet clean; \
	done
	@echo "No diff output is good news."

clean:
	rm -fr test-repo unpacked repacked
