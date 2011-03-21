
.PHONY: test

all:

test:
	vim -u NONE -S test/all.vim
	! grep '^\s*FAILED:' test.out

push:
	git push origin master

dist:
	git archive --format zip --prefix vim-iconv/ --output vim-iconv.zip master
