#ifndef IGCFILTERED_H
#define IGCFILTERED_H

#include <QObject>
#include <QTime>
#include <QtCore>
#include <igc.h>

class IgcFiltered : public QAbstractListModel
{
    Q_OBJECT

public:

    enum IgcEventRoles {
        typeRole = Qt::UserRole + 1,
        timeRole,
        latRole,
        lonRole,
        altRole,
        pressureAltRole,
        validRole
    };

    explicit IgcFiltered(QObject *parent = 0);
    ~IgcFiltered();

    Q_INVOKABLE bool load(const QString &path, const QTime after);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariant get(int row);


    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QHash<int,QByteArray> roleNames() const;



    Q_PROPERTY(int count READ getCount NOTIFY eventsChanged)
    int getCount();


    Q_PROPERTY(int invalidCount READ getInvalidCount NOTIFY eventsChanged)
    Q_PROPERTY(int trimmedCount READ getTrimmedCount NOTIFY eventsChanged)

    int getInvalidCount() { return m_invalid_count; }
    int getTrimmedCount() { return m_trimmed_count; }

    Q_PROPERTY(QDate date READ date)
    QDate date() const { return igcFile->date(); }


signals:
    void eventsChanged();


public slots:


private:
    IgcFile* igcFile;
    QList<IgcEvent*> filtered_events;
    int m_invalid_count;
    int m_trimmed_count;

};

#endif // IGCFILTERED_H
