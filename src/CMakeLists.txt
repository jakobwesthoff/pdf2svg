find_package(PkgConfig)
pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(POPPLER REQUIRED poppler-glib)
pkg_check_modules(CAIRO REQUIRED cairo)

set(CFLAGS
	${GOBJECT_CFLAGS} ${GOBJECT_CFLAGS_OTHER}
	${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
	${POPPLER_CFLAGS} ${POPPLER_CFLAGS_OTHER}
	${CAIRO_CFLAGS} ${CAIRO_CFLAGS_OTHER}
)
add_definitions(${CFLAGS})

set(LIBS
	${GOBJECT_LIBRARIES}
	${GIO_LIBRARIES}
	${POPPLER_LIBRARIES}
	${CAIRO_LIBRARIES}
)
link_libraries(${LIBS})

set(LIB_PATHS
	${GOBJECT_LIBRARY_DIRS}
	${GIO_LIBRARY_DIRS}
	${POPPLER_LIBRARY_DIRS}
	${CAIRO_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

set(VALA_SRC
	pdf2svg.vala
	transformer.vala
)

vala_precompile(VALA_C
	${VALA_SRC}
PACKAGES 
	gio-2.0
	poppler-glib
	cairo
	posix
)

add_executable(pdf2svg
  	${VALA_C}
)

# explicitly add libraries (needed e.g. for Fedora 13+)
target_link_libraries(pdf2svg -lm)

install(TARGETS 
	pdf2svg
RUNTIME
DESTINATION
	bin
)
