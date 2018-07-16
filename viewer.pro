
QT += qml quick charts

CONFIG += qtquickcompiler
CONFIG += c++11

TARGET = viewer
TEMPLATE = app

QML_IMPORT_PATH =


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

unix: {
    LRELEASE = lrelease-qt5
}
win32: {
    LRELEASE = lrelease
}

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/i18n/viewer_,.ts)

updateqm.input = TRANSLATIONS
updateqm.output = $$OUT_PWD/${QMAKE_FILE_BASE}.qm
updateqm.commands = $$LRELEASE -idbased -silent ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_BASE}.qm
updateqm.CONFIG += no_link target_predeps
QMAKE_EXTRA_COMPILERS += updateqm

qmfiles.files = $$prependAll(LANGUAGES, $$OUT_PWD/viewer_,.qm)
qmfiles.path = $$PREFIX/share/$${TARGET}/i18n
qmfiles.CONFIG += no_check_exist

INSTALLS += qmfiles

CODECFORTR = UTF-8
CODECFORSRC = UTF-8

RESOURCES += viewer.qrc

RC_ICONS = viewer64.ico

unix: !andorid: {
    isEmpty(PREFIX) {
        PREFIX = /usr/local
    }
    BINDIR = $$PREFIX/bin
    INSTALLS += target
    target.path = $$BINDIR

    icons.files = ./viewer64.png
    icons.path = $$PREFIX/share/icons/hicolor/64x64/apps/
    icons.CONFIG += no_check_exist
    INSTALLS += icons

    desktop.files = viewer.desktop
    desktop.path = $$PREFIX/share/applications
    desktop.CONFIG += no_check_exist
    INSTALLS += desktop

}



