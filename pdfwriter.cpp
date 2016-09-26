#include "pdfwriter.h"

PdfWriter::PdfWriter(QObject *parent) : QObject(parent)
{

}


void PdfWriter::createPDF(QString a_strFileName)
{
    QPdfWriter writer(a_strFileName);
    QPainter painter(&writer);

    writer.setPageSize(QPagedPaintDevice::A4);
    painter.drawPixmap(QRect(0,0,writer.logicalDpiX()*8.3,writer.logicalDpiY()*11.7),QPixmap("viewer.png"));

    painter.end();
    //QMessageBox::information(NULL,"Hi!","Image has been written to the pdf file!");
}