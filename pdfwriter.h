#ifndef PDFWRITER_H
#define PDFWRITER_H

#include <QPdfWriter>
#include <QString>
#include <QObject>
#include <QPainter>

class PdfWriter : public QObject
{
    Q_OBJECT

public:
    explicit PdfWriter(QObject *parent = 0);

    Q_INVOKABLE void createPDF(const QString a_strFilename);
};

#endif // PDFWRITER_H
