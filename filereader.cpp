#include <QFile>
#include <QUrl>
#include <QDebug>
#include "filereader.h"

FileReader::FileReader(QObject *parent) :
    QObject(parent)
{
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
    return QFile(filename).exists();
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
