PROJECT_NAME := state_of_pillow

serve:
	$(MAKE) reveal-serve

install: pip-install npm-install

edit:
	vi index.html
