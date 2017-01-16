#include "worker.h"

Worker::Worker(QObject *parent) : QObject(parent)
{

}

QStringList Worker::parseCSV(QString str) {

    QVector<QStringList> arr;
    QStringList retArr;
    bool quote = false;
    int row, col, c;
    QChar cc, nc;

    for( row = col = c = 0; c < str.length(); c++ ) {

        cc = str[c], nc = str[c+1];        // current character, next character

        if (arr.size() < row + 1) arr.push_back(QStringList()); //arr[row] = arr[row] || []; // create a new row if necessary

        if (arr[row].size() < col + 1) arr[row].push_back(QString()); //arr[row][col] = arr[row][col] || ''; // create a new column (start with empty string) if necessary


        // If the current character is a quotation mark, and we're inside a
        // quoted field, and the next character is also a quotation mark,
        // add a quotation mark to the current column and skip the next character
        if (cc == '"' && quote && nc == '"') { arr[row][col] += cc; ++c; continue; };

        // If it's just one quotation mark, begin/end quoted field
        if (cc == '"') { quote = !quote; continue; };

        // If it's a comma and we're not in a quoted field, move on to the next column
        if (cc == ';' && !quote) { ++col; continue; };

        // If it's a newline and we're not in a quoted field, move on to the next
        // row and move to column 0 of that new row
        if (cc == '\n' && !quote) { ++row; col = 0; continue; };

        // Otherwise, append the current character to the current column
        arr[row][col] += cc;
    }

    for (int i = 0; i < arr.length(); i++) {

        QStringList row = arr[i];

        for (int j = 0; j < row.length(); j++) {
            QString item = row[j];
            arr[i][j] = QString(item).trimmed();
        }

        retArr.push_back(arr[i].join(csv_join_parse_delimeter_string));
    }

    return retArr;
}

const int Worker::getOffsetFromUtcSec(const QString date, const QString format) {

    return QDateTime::fromString(date, format).offsetFromUtc();
}
