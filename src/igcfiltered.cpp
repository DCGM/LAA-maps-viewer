#include <QDebug>
#include "igcfiltered.h"
#include "igc.h"

IgcFiltered::IgcFiltered(QObject *parent) :  QAbstractListModel(parent) {

    igcFile = new IgcFile();
    m_invalid_count = 0;
    m_trimmed_count = 0;
    m_trimmed_end_count = 0;
}

IgcFiltered::~IgcFiltered() {
    delete igcFile;

}

qreal IgcFiltered::getDistanceTo(qreal lat, qreal lon, qreal tlat, qreal tlon) {

    qreal dlat = pow(sin((tlat-lat) * (M_PI/180.0) / 2), 2);
    qreal dlon = pow(sin((tlon-lon) * (M_PI/180.0) / 2), 2);
    qreal a = dlat + cos(lat * (M_PI/180.0)) * cos(tlat * (M_PI/180.0)) * dlon;
    qreal c = 2 * atan2(sqrt(a), sqrt(1-a));
    return 6371000.0 * c;
}

qreal IgcFiltered::getBearingTo(qreal lat, qreal lon, qreal tlat, qreal tlon) {
    qreal lat1 = lat * (M_PI/180.0);
    qreal lat2 = tlat * (M_PI/180.0);

    qreal dlon = (tlon - lon) * (M_PI/180.0);
    qreal y = sin(dlon) * cos(lat2);
    qreal x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    return fmod((360 + (atan2(y, x)) * (180.0/M_PI)), 360.0);
}



bool IgcFiltered::load(const QString &path, const QTime after, const bool removeAfterLanding) {
    igcFile->load(path);


    QList<IgcEvent*> events = igcFile->events();
    filtered_events.clear();
    m_invalid_count = 0;
    m_trimmed_count = 0;
    m_trimmed_end_count = 0;
    QList<IgcEvent*>::iterator it;

    qreal prevLat = 0;
    qreal prevLon = 0;
    qreal lat = 0;
    qreal lon = 0;
    qreal speed_m_s = 0;
    int m_fixes_after = 60;
    int m_valid_count = 0;
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

        m_valid_count++;

        prevLat = lat;
        prevLon = lon;
        lat = igcFix->getLat();
        lon = igcFix->getLon();
        speed_m_s = getDistanceTo(lat, lon, prevLat, prevLon);

        if (removeAfterLanding && (speed_m_s < 10) && (m_valid_count > 3000)) { // speed lower than 10 m/s (36 km/h) and 50 minutes of valid fixes before
            if (m_fixes_after > 0) {
                filtered_events.append((*it));
                m_fixes_after--;
            } else {
                m_trimmed_end_count++;
            }

        } else {
            filtered_events.append((*it));
        }

    }


    emit eventsChanged();

    return false;
}

void IgcFiltered::clear() {
    filtered_events.clear();
    m_invalid_count = 0;
    m_trimmed_count = 0;
    m_trimmed_end_count = 0;
    emit eventsChanged();
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
