# Add more folders to ship with the application, here
folder_01.source = qml/viewer
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

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
    worker.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

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
    worker.h

QT += qml quick widgets printsupport


LANGUAGES = cs_CZ en_US

# var, prepend, append
defineReplace(prependAll) {
    for(a,$$1):result += $$2$${a}$$3
    return($$result)
}

LRELEASE = lrelease

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

OTHER_FILES += \
    qml/viewer/csv.js \
    qml/viewer/functions.js \
    qml/viewer/md5.js \
    qml/viewer/AltChart.qml

# CONFIG += qtquickcompiler

DISTFILES += \
    ImportDialog.qml \
    HorizontalDelimeter.qml

