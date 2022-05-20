#include "pdfwriter.h"

PdfWriter::PdfWriter(QObject *parent) : QObject(parent)
{

}


void PdfWriter::createPDF(QString a_strFilename)
{
    QPdfWriter writer(a_strFilename);
    QPainter painter(&writer);

    writer.setPageSize(QPageSize(QPageSize::A4));
    painter.drawPixmap(QRect(0,0,writer.logicalDpiX()*8.3,writer.logicalDpiY()*11.7),QPixmap("viewer.png"));

    painter.end();
    //QMessageBox::information(NULL,"Hi!","Image has been written to the pdf file!");
}
