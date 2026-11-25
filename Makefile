.PHONY: api mobile api-build mobile-analyze mobile-build

api:
	./scripts/dev-api.sh

mobile:
	./scripts/dev-mobile.sh

api-build:
	cd services/api && JAVA_HOME="$(CURDIR)/.tools/jdk/Contents/Home" ./gradlew build

mobile-analyze:
	cd apps/mobile && ../../.tools/flutter/bin/flutter analyze

mobile-build:
	cd apps/mobile && ../../.tools/flutter/bin/flutter build web --release
