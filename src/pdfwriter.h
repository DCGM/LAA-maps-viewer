#ifndef PDFWRITER_H
#define PDFWRITER_H

#include <QObject>
#include <QPainter>
#include <QPdfWriter>
#include <QString>

class PdfWriter : public QObject {
    Q_OBJECT

public:
    explicit PdfWriter(QObject* parent = 0);

    Q_INVOKABLE void createPDF(const QString a_strFilename);
};

#endif // PDFWRITER_H
