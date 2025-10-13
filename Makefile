LAZBUILD = $(shell command -v lazbuild)
OPTS = -B --bm=Release
OPTSQT = --ws=qt5
LPI = heidisql.lpi

# VERSION = 12.12.1.3
BIN = out/heidisql
BINGTK = out/gtk2/heidisql
BINQT = out/qt5/heidisql

.PHONY: all clean run-tx heidisql-gtk2 heidisql-qt5 deb-package tar-gtk2 tar-qt5

all: clean run-tx heidisql-gtk2 heidisql-qt5 deb-package tar-gtk2 tar-qt5

clean:
	@echo "=== Cleaning"
	@rm -rf bin/lib/x86_64-linux/*
	@rm -f out/gtk2/* out/qt5/*
	@rm -rf deb rpm tar dist

run-tx:
	@echo "=== Running tx"
# Need to run tx here!!

heidisql-gtk2:
	@echo "=== Building GTK2"
	$(LAZBUILD) $(OPTS) $(LPI)
	mv -v $(BIN) $(BINGTK)

heidisql-qt5:
	@echo "=== Building QT5"
	$(LAZBUILD) $(OPTS) $(OPTSQT) $(LPI)
	mv -v $(BIN) $(BINQT)

deb-package: run-tx
	@echo "=== Creating debian package"
	rm -vrf deb
	cp -R package-skeleton deb
	find deb -iname ".gitkeep" -exec rm -v {} +
	cp -vR extra/locale/*.mo deb/usr/share/heidisql/locale
	cp -v extra/ini/*.ini  deb/usr/share/heidisql
	cp -v res/deb-package-icon.png deb/usr/share/pixmaps/heidisql.png
	cp -v $(BINGTK) deb/usr/share/heidisql/heidisql
	cp -v README.md LICENSE deb/usr/share/doc/heidisql
	mkdir -p dist
	rm -vf dist/*.deb
	fpm -s dir -t deb -n heidisql -v ${VERSION} \
	  -p dist \
	  --verbose \
	  --deb-custom-control deb-control.txt \
	  --deb-no-default-config-files \
	  ./deb/=/

tar-gtk2: run-tx
	@echo "=== Creating GTK2 archive"
	rm -vrf tar
	mkdir -p tar/locale dist
	cp -v README.md LICENSE tar
	cp -v res/deb-package-icon.png tar/heidisql.png
	cp -v extra/locale/*.mo tar/locale
	cp -v extra/ini/*.ini tar
	cp -v out/gtk2/heidisql tar
	chmod +x tar/heidisql
	cd tar && tar -zcvf ../dist/heidisql-gtk2-$(VERSION).tgz *

tar-qt5: run-tx
	@echo "=== Creating QT5 archive"
	rm -vrf tar
	mkdir -p tar/locale dist
	cp -v README.md LICENSE tar
	cp -v res/deb-package-icon.png tar/heidisql.png
	cp -v extra/locale/*.mo tar/locale
	cp -v extra/ini/*.ini tar
	cp -v out/qt5/heidisql tar
	chmod +x tar/heidisql
	cd tar && tar -zcvf ../dist/heidisql-qt5-$(VERSION).tgz *
