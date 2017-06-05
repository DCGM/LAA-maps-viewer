#include <QFile>
#include <QFileInfo>
#include <QUrl>
#include <QDebug>
#include "filereader.h"

#include <QTextStream>
#include <QTextCodec>
#include <QString>

FileReader::FileReader(QObject *parent) :
    QObject(parent)
{
}

/**
 * @brief FileReader::toLocal wrapper over QUrl.toLocalFile() function
 * @param filename
 * @return
 */

QString FileReader::toLocal(const QUrl &filename) {
    return filename.toLocalFile();
}


QByteArray FileReader::read(const QUrl &filename) {
//    qDebug() << "read " << filename.toLocalFile();
    return read_local(filename.toLocalFile());
}


QByteArray FileReader::read_local(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QByteArray();

    return file.readAll();
}

void FileReader::write(const QUrl &filename, QByteArray data) {
    write_local(filename.toLocalFile(), data);
}

void FileReader::copy_file(const QUrl &filename, const QUrl &newFilename) {

    remove_if_exists(newFilename); // remove file with dst name if exist

    QFile::copy(filename.toLocalFile(), newFilename.toLocalFile());
}

void FileReader::remove_if_exists(const QUrl &filename) {

    if (file_exists(filename)) {
        QFile::remove(filename.toLocalFile());
    }
}

void FileReader::writeUTF8(const QUrl &filename, QByteArray data) {

    QFile file (filename.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        return;
    }

    QTextStream streamFileOut(&file);
    streamFileOut.setCodec(QTextCodec::codecForName("UTF-8"));
    streamFileOut << QString::fromUtf8(data);
    streamFileOut.flush();

    file.close();
}

void FileReader::write_local(const QString &filename, QByteArray data) {
    QFile file (filename);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        return;
    }

    file.write(data);
}

bool FileReader::file_exists(const QUrl &filename) {
    return file_exists_local(filename.toLocalFile());
}

bool FileReader::file_exists_local(const QString &filename) {
    return QFileInfo(filename).isFile() && QFile(filename).exists();
}

bool FileReader::is_local_file(const QUrl &filename) {
    return filename.isLocalFile();
}

bool FileReader::delete_file(const QUrl &filename) {
    return delete_file_local(filename.toLocalFile());
}

bool FileReader::delete_file_local(const QString &filename) {
    return QFile(filename).remove();
}
