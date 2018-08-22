build: termuxtask.nim 
	nim c -o:termux-task termuxtask.nim
	cd hooks/
	nim c -o:on-exit-termux on_exit_termux.nim
install: 
	cp ./hooks/* ~/.todo/hooks/
	install termux-task /data/data/com.termux/files/usr/bin/termux-task
all: build install
