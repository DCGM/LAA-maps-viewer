#include <QDebug>
#include "igcfiltered.h"
#include "igc.h"

IgcFiltered::IgcFiltered(QObject *parent) :  QAbstractListModel(parent) {

    igcFile = new IgcFile();
    m_invalid_count = 0;
    m_trimmed_count = 0;
}

IgcFiltered::~IgcFiltered() {
    delete igcFile;

}


bool IgcFiltered::load(const QString &path, const QTime after) {
    igcFile->load(path);


    QList<IgcEvent*> events = igcFile->events();
    filtered_events.clear();
    m_invalid_count = 0;
    m_trimmed_count = 0;
    QList<IgcEvent*>::iterator it;
    for (it = events.begin(); it != events.end(); ++it) {
        int type = (*it)->getEventType();
        if (type != IgcEvent::FIX) {
            continue;
        }
        QTime fixTime = (*it)->getTimestamp();
        if (fixTime < after) {
            m_trimmed_count++;
            continue;
        }
        Fix const* igcFix = static_cast<Fix const *>(*it);

        if (!igcFix->getValid()) {
            m_invalid_count++;
            continue;
        }

        filtered_events.append((*it));

    }


    emit eventsChanged();

    return false;
}

void IgcFiltered::clear() {
    filtered_events.clear();

}

int IgcFiltered::getCount() {
    return filtered_events.count();
}


QVariant IgcFiltered::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() > filtered_events.count()) {
        return QVariant();
    }

    const IgcEvent* item = filtered_events[index.row()];

    if (item->getEventType() != IgcEvent::FIX)  {
        switch(role) {
        case typeRole:
            return item->getEventType();
            break;
        case timeRole:
            return item->getTimestamp();
            break;
        default:
            return QVariant();
        }

    }

    Fix const* igcFix = static_cast<Fix const *>(item);

    if (!igcFix->getValid()) {
        if (role == validRole) {
            return QVariant(false);
        } else {
            return QVariant();
        }
    }

    switch (role) {
    case typeRole: return igcFix->getEventType();
    case timeRole: return igcFix->getTimestamp();
    case latRole: return igcFix->getLat();
    case lonRole: return igcFix->getLon();
    case altRole: return igcFix->getAlt();
    case pressureAltRole: return igcFix->getPressureAlt();
    case validRole: return igcFix->getValid();
    }


    return QVariant();
}

int IgcFiltered::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return filtered_events.count();

}

QVariant IgcFiltered::get(int row) {
    QModelIndex myidx = index(row);

    QMap<QString, QVariant> itemData;
    QHashIterator<int, QByteArray> hashItr(roleNames());
    while(hashItr.hasNext()){
        hashItr.next();
        itemData.insert(hashItr.value(),myidx.data(hashItr.key()).toString());

    }
    // Edit:
    // My C++ is sometimes a bit rusty, I was deleting item...
    // DO NOT delete item... otherwise you remove the item from the ListModel
    // delete item;
    return QVariant(itemData);
}


QHash<int,QByteArray> IgcFiltered::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[typeRole] = "type";
    roles[timeRole] = "time";
    roles[latRole] = "lat";
    roles[lonRole] = "lon";
    roles[altRole] = "alt";
    roles[pressureAltRole] = "pressureAlt";
    roles[validRole] = "valid";
    return roles;
}
