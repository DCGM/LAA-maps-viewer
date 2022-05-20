#ifndef WORKER_H
#define WORKER_H

#include <QStringList>
#include <QString>
#include <QVector>
#include <QObject>
#include <QDateTime>

class Worker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString csv_join_parse_delimeter_property READ CsvJoinDelimeterReadFunc)

public:
    explicit Worker(QObject *parent = 0);

    QString CsvJoinDelimeterReadFunc() const { return csv_join_parse_delimeter_string; }

    Q_INVOKABLE QStringList parseCSV(QString str);
    Q_INVOKABLE int getOffsetFromUtcSec(const QString date, const QString format);

private:

    QString csv_join_parse_delimeter_string = "#";

signals:

public slots:
};

#endif // WORKER_H
