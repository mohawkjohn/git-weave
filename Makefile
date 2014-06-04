# Test and validation productions for git-weave

PYLINTOPTS = --rcfile=/dev/null --reports=n \
	--msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" \
	--dummy-variables-rgx='^_'
SUPPRESSIONS = "C0103,C0111,C0301,C0326,C1001,E1103,R0912,R0914,R0915,W0110,W0141,W0621,W0631"
pylint:
	@pylint $(PYLINTOPTS) --disable=$(SUPPRESSIONS) git-weave

check:
	cd test; $(MAKE) --quiet

