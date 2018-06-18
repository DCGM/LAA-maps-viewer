
QT += qml quick widgets printsupport

CONFIG += qtquickcompiler
CONFIG += c++11

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    igc.cpp \
    filereader.cpp \
    customnetworkaccessmanager.cpp \
    networkaccessmanagerfactory.cpp \
    imagesaver.cpp \
    igcfiltered.cpp \
    sortfilterproxymodel.cpp \
    pdfwriter.cpp \
    resultscreater.cpp \
    worker.cpp \
    uploader.cpp

QML_IMPORT_PATH =

HEADERS += \
    igc.h \
    filereader.h \
    customnetworkaccessmanager.h \
    networkaccessmanagerfactory.h \
    imagesaver.h \
    igcfiltered.h \
    sortfilterproxymodel.h \
    pdfwriter.h \
    resultscreater.h \
    worker.h \
    uploader.h



LANGUAGES = cs_CZ en_US

# var, prepend, append
defineReplace(prependAll) {
    for(a,$$1):result += $$2$${a}$$3
    return($$result)
}

LRELEASE = lrelease-qt5

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/i18n/viewer_,.ts)

updateqm.input = TRANSLATIONS
updateqm.output = $$OUT_PWD/${QMAKE_FILE_BASE}.qm
updateqm.commands = $$LRELEASE -idbased -silent ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_BASE}.qm
updateqm.CONFIG += no_link target_predeps
QMAKE_EXTRA_COMPILERS += updateqm

qmfiles.files = $$prependAll(LANGUAGES, $$OUT_PWD/viewer_,.qm)
# qmfiles.path = /usr/share/$${TARGET}/i18n
qmfiles.path = /$${TARGET}/i18n
qmfiles.CONFIG += no_check_exist

INSTALLS += qmfiles

CODECFORTR = UTF-8
CODECFORSRC = UTF-8

RC_ICON = viewer64.ico

RESOURCES += \
    viewer.qrc

