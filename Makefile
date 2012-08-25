out=ld24.love
url=http://minornine.com/games/files/$(out)

all:
	zip -r $(out) *
	@echo "Wrote $(out)"

clean:
	rm -rf $(out)

upload: all
	scp $(out) m:web/games/files/
	echo $(url) | pbcopy
	@echo "Copied $(url)"
