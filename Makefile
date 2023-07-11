all: suc

suc: suc_wrapper.c
	gcc -o suc suc_wrapper.c
	gcc -o succ suc.c

clean:
	rm -f suc
	rm -f succ

install:
	id -u suc || useradd --home-dir=/ --gid=suc --no-create-home --shell=/usr/bin/nologin suc
	getent group suc || groupadd suc
	mkdir -p /var/lib/suc
	chown suc:suc /var/lib/suc
	chmod 775 /var/lib/suc
	install --owner=suc --group=suc --mode=u=rw,go=r ./suc.sh /usr/bin/
	install --owner=suc --group=suc --mode=u=rwx,g=rx,o=r ./usuc /usr/bin/
	install --owner=suc --group=suc --mode=u=rwsx,g=rx,o=r ./suc /usr/bin/
