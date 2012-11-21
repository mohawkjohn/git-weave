PYLINTOPTS = --rcfile=/dev/null --reports=n --include-ids=y --disable="C0103,C0111,C0301,E1103,R0912,R0914,R0915,W0141,W0621,W0631"
pylint:
	@pylint --output-format=parseable $(PYLINTOPTS) git-weave
