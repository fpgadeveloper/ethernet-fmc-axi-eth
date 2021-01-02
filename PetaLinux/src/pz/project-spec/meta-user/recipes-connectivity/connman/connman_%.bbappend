FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://main.conf \
"

do_install_append () {
    install -d ${D}${sysconfdir}/connman
    install -m 0755 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman/
}

FILES_${PN} += "${sysconfdir}/main.conf"
