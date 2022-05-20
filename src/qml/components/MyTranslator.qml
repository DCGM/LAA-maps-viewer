import QtQuick 2.9

Item {
    // used for is C++ class for translation
    function myTranslate(key) {
        var retVal;
        switch (key) {
        case ("track-list-delegate-ob-short"):
            //% "TP"
            retVal = qsTrId("track-list-delegate-ob-short");
            break;
        case ("track-list-delegate-tg-short"):
            //% "TG"
            retVal = qsTrId("track-list-delegate-tg-short");
            break;
        case ("track-list-delegate-sg-short"):
            //% "SG"
            retVal = qsTrId("track-list-delegate-sg-short");
            break;
        case ("track-list-delegate-alt_min-short"):
            //% "ALT_MIN"
            retVal = qsTrId("track-list-delegate-alt_min-short");
            break;
        case ("track-list-delegate-alt_max-short"):
            //% "ALT_MAX"
            retVal = qsTrId("track-list-delegate-alt_max-short");
            break;
        case ("track-list-delegate-speed_min-short"):
            //% "SPD_MIN"
            retVal = qsTrId("track-list-delegate-speed_min-short");
            break;
        case ("track-list-delegate-speed_max-short"):
            //% "SPD_MAX"
            retVal = qsTrId("track-list-delegate-speed_max-short");
            break;
        case ("track-list-delegate-section_speed_start-short"):
            //% "sss"
            retVal = qsTrId("track-list-delegate-section_speed_start-short");
            break;
        case ("track-list-delegate-section_speed_end-short"):
            //% "sse"
            retVal = qsTrId("track-list-delegate-section_speed_end-short");
            break;
        case ("track-list-delegate-section_alt_start-short"):
            //% "sas"
            retVal = qsTrId("track-list-delegate-section_alt_start-short");
            break;
        case ("track-list-delegate-section_alt_end-short"):
            //% "sae"
            retVal = qsTrId("track-list-delegate-section_alt_end-short");
            break;
        case ("track-list-delegate-section_space_start-short"):
            //% "sws"
            retVal = qsTrId("track-list-delegate-section_space_start-short");
            break;
        case ("track-list-delegate-section_space_end-short"):
            //% "swe"
            retVal = qsTrId("track-list-delegate-section_space_end-short");
            break;
        case ("track-list-delegate-secret-turn-point-short"):
            //% "sec_tp"
            retVal = qsTrId("track-list-delegate-secret-turn-point-short");
            break;
        case ("track-list-delegate-secret-time-gate-short"):
            //% "sec_tg"
            retVal = qsTrId("track-list-delegate-secret-time-gate-short");
            break;
        case ("track-list-delegate-secret-space-gate-short"):
            //% "sec_sg"
            retVal = qsTrId("track-list-delegate-secret-space-gate-short");
            break;
        case ("html-continuous-results"):
            //% "continuous results"
            retVal = qsTrId("html-continuous-results");
            break;
        case ("hit-no"):
            //% "hit no"
            retVal = qsTrId("track-list-delegate-hit-no");
            break;
        case ("hit-yes"):
            //% "hit yes"
            retVal = qsTrId("track-list-delegate-hit-yes");
            break;
        case ("html-results-altitude-sections"):
            //% "altitude sections"
            retVal = qsTrId("html-results-altitude-sections");
            break;
        case ("html-results-circling"):
            //% "circling on track"
            retVal = qsTrId("html-results-circling");
            break;
        case ("html-results-competition-arbitr"):
            //% "competition referee"
            retVal = qsTrId("html-results-competition-arbitr");
            break;
        case ("html-results-take-off-legend"):
            //% "[S / E / D]"
            retVal = qsTrId("html-results-take-off-legend");
            break;
        case ("html-results-markers-legend"):
            //% "[O / N / F]"
            retVal = qsTrId("html-results-markers-legend");
            break;
        case ("html-results-point-legend"):
            //% "[P]"
            retVal = qsTrId("html-results-point-legend");
            break;
        case ("html-results-count-legend"):
            //% "[C]"
            retVal = qsTrId("html-results-count-legend");
            break;
        case ("html-results-ctnt-tg-shortcut"):
            //% "TG"
            retVal = qsTrId("html-results-ctnt-tg-shortcut");
            break;
        case ("html-results-ctnt-tp-shortcut"):
            //% "TP"
            retVal = qsTrId("html-results-ctnt-tp-shortcut");
            break;
        case ("html-results-ctnt-sg-shortcut"):
            //% "SG"
            retVal = qsTrId("html-results-ctnt-sg-shortcut");
            break;
        case ("html-results-ctnt-altLimits-shortcut"):
            //% "AltP"
            retVal = qsTrId("html-results-ctnt-altLimits-shortcut");
            break;
        case ("html-results-ctnt-speedSec-shortcut"):
            //% "SpdS"
            retVal = qsTrId("html-results-ctnt-speedSec-shortcut");
            break;
        case ("html-results-ctnt-altSec-shortcut"):
            //% "AltS"
            retVal = qsTrId("html-results-ctnt-altSec-shortcut");
            break;
        case ("html-results-ctnt-spaceSec-shortcut"):
            //% "SpcS"
            retVal = qsTrId("html-results-ctnt-spaceSec-shortcut");
            break;
        case ("html-results-ctnt-markersOk-shortcut"):
            //% "M"
            retVal = qsTrId("html-results-ctnt-markersOk-shortcut");
            break;
        case ("html-results-ctnt-markersNok-shortcut"):
            //% "BM"
            retVal = qsTrId("html-results-ctnt-markersNok-shortcut");
            break;
        case ("html-results-ctnt-markersFalse-shortcut"):
            //% "FM"
            retVal = qsTrId("html-results-ctnt-markersFalse-shortcut");
            break;
        case ("html-results-ctnt-photosOk-shortcut"):
            //% "P"
            retVal = qsTrId("html-results-ctnt-photosOk-shortcut");
            break;
        case ("html-results-ctnt-photosNok-shortcut"):
            //% "BP"
            retVal = qsTrId("html-results-ctnt-photosNok-shortcut");
            break;
        case ("html-results-ctnt-photosFalse-shortcut"):
            //% "FP"
            retVal = qsTrId("html-results-ctnt-photosFalse-shortcut");
            break;
        case ("html-results-ctnt-landing-shortcut"):
            //% "Lnd"
            retVal = qsTrId("html-results-ctnt-landing-shortcut");
            break;
        case ("html-results-ctnt-takeOfF-shortcut"):
            //% "TW"
            retVal = qsTrId("html-results-ctnt-takeOfF-shortcut");
            break;
        case ("html-results-ctnt-circling-shortcut"):
            //% "GP"
            retVal = qsTrId("html-results-ctnt-circling-shortcut");
            break;
        case ("html-results-ctnt-opposite-shortcut"):
            //% "OP"
            retVal = qsTrId("html-results-ctnt-opposite-shortcut");
            break;
        case ("html-results-ctnt-otherPoints-shortcut"):
            //% "+p"
            retVal = qsTrId("html-results-ctnt-otherPoints-shortcut");
            break;
        case ("html-results-ctnt-otherPenalty-shortcut"):
            //% "-p"
            retVal = qsTrId("html-results-ctnt-otherPenalty-shortcut");
            break;
        case ("html-results-ctnt-points-shortcut"):
            //% "Sum"
            retVal = qsTrId("html-results-ctnt-points-shortcut");
            break;
        case ("html-results-ctnt-points1000-shortcut"):
            //% "Sum1000"
            retVal = qsTrId("html-results-ctnt-points1000-shortcut");
            break;
        case ("html-results-ctnt-tg-shortcut-legend"):
            //% "TG legend"
            retVal = qsTrId("html-results-ctnt-tg-shortcut-legend");
            break;
        case ("html-results-ctnt-tp-shortcut-legend"):
            //% "TP legend"
            retVal = qsTrId("html-results-ctnt-tp-shortcut-legend");
            break;
        case ("html-results-ctnt-sg-shortcut-legend"):
            //% "SG legend"
            retVal = qsTrId("html-results-ctnt-sg-shortcut-legend");
            break;
        case ("html-results-ctnt-altLimits-shortcut-legend"):
            //% "AltP legend"
            retVal = qsTrId("html-results-ctnt-altLimits-shortcut-legend");
            break;
        case ("html-results-ctnt-speedSec-shortcut-legend"):
            //% "SpdS legend"
            retVal = qsTrId("html-results-ctnt-speedSec-shortcut-legend");
            break;
        case ("html-results-ctnt-altSec-shortcut-legend"):
            //% "AltS legend"
            retVal = qsTrId("html-results-ctnt-altSec-shortcut-legend");
            break;
        case ("html-results-ctnt-spaceSec-shortcut-legend"):
            //% "SpcS legend"
            retVal = qsTrId("html-results-ctnt-spaceSec-shortcut-legend");
            break;
        case ("html-results-ctnt-markersOk-shortcut-legend"):
            //% "M legend"
            retVal = qsTrId("html-results-ctnt-markersOk-shortcut-legend");
            break;
        case ("html-results-ctnt-markersNok-shortcut-legend"):
            //% "BM legend"
            retVal = qsTrId("html-results-ctnt-markersNok-shortcut-legend");
            break;
        case ("html-results-ctnt-markersFalse-shortcut-legend"):
            //% "FM legend"
            retVal = qsTrId("html-results-ctnt-markersFalse-shortcut-legend");
            break;
        case ("html-results-ctnt-photosOk-shortcut-legend"):
            //% "P legend"
            retVal = qsTrId("html-results-ctnt-photosOk-shortcut-legend");
            break;
        case ("html-results-ctnt-photosNok-shortcut-legend"):
            //% "BP legend"
            retVal = qsTrId("html-results-ctnt-photosNok-shortcut-legend");
            break;
        case ("html-results-ctnt-photosFalse-shortcut-legend"):
            //% "FP legend"
            retVal = qsTrId("html-results-ctnt-photosFalse-shortcut-legend");
            break;
        case ("html-results-ctnt-landing-shortcut-legend"):
            //% "Lnd legend"
            retVal = qsTrId("html-results-ctnt-landing-shortcut-legend");
            break;
        case ("html-results-ctnt-takeOfF-shortcut-legend"):
            //% "TW legend"
            retVal = qsTrId("html-results-ctnt-takeOfF-shortcut-legend");
            break;
        case ("html-results-ctnt-circling-shortcut-legend"):
            //% "GP legend"
            retVal = qsTrId("html-results-ctnt-circling-shortcut-legend");
            break;
        case ("html-results-ctnt-opposite-shortcut-legend"):
            //% "OP legend"
            retVal = qsTrId("html-results-ctnt-opposite-shortcut-legend");
            break;
        case ("html-results-ctnt-otherPoints-shortcut-legend"):
            //% "+p legend"
            retVal = qsTrId("html-results-ctnt-otherPoints-shortcut-legend");
            break;
        case ("html-points-shortcut"):
            //% "p"
            retVal = qsTrId("html-points-shortcut");
            break;
        case ("html-results-ctnt-otherPenalty-shortcut-legend"):
            //% "-p legend"
            retVal = qsTrId("html-results-ctnt-otherPenalty-shortcut-legend");
            break;
        case ("html-results-ctnt-points-shortcut-legend"):
            //% "Sum legend"
            retVal = qsTrId("html-results-ctnt-points-shortcut-legend");
            break;
        case ("html-results-ctnt-points1000-shortcut-legend"):
            //% "Sum1000 legend"
            retVal = qsTrId("html-results-ctnt-points1000-shortcut-legend");
            break;
        case ("html-results-competition-date"):
            //% "competition date"
            retVal = qsTrId("html-results-competition-date");
            break;
        case ("html-results-competition-director"):
            //% "competition director"
            retVal = qsTrId("html-results-competition-director");
            break;
        case ("html-results-competition-type"):
            //% "competition type"
            retVal = qsTrId("html-results-competition-type");
            break;
        case ("html-results-manual-values"):
            //% "manual values"
            retVal = qsTrId("html-results-manual-values");
            break;
        case ("html-results-competition-group-name"):
            //% "competition group name"
            retVal = qsTrId("html-results-competition-group-name");
            break;
        case ("html-results-inserted-value"):
            //% "inserted value"
            retVal = qsTrId("html-results-inserted-value");
            break;
        case ("html-results-competition-round"):
            //% "competition round"
            retVal = qsTrId("html-results-competition-round");
            break;
        case ("html-results-count"):
            //% "count"
            retVal = qsTrId("html-results-count");
            break;
        case ("html-results-crew-title"):
            //% "crew details"
            retVal = qsTrId("html-results-crew-title");
            break;
        case ("html-results-ctnt-aircraft-registration"):
            //% "aircraft registration"
            retVal = qsTrId("html-results-ctnt-aircraft-registration");
            break;
        case ("html-results-ctnt-aircraft-type"):
            //% "aircraft type"
            retVal = qsTrId("html-results-ctnt-aircraft-type");
            break;
        case ("html-results-ctnt-category"):
            //% "category"
            retVal = qsTrId("html-results-ctnt-category");
            break;
        case ("html-results-ctnt-classify"):
            //% "classify"
            retVal = qsTrId("html-results-ctnt-classify");
            break;
        case ("html-results-ctnt-class-order"):
            //% "class order"
            retVal = qsTrId("html-results-ctnt-class-order");
            break;
        case ("html-results-ctnt-copilot"):
            //% "copilot"
            retVal = qsTrId("html-results-ctnt-copilot");
            break;
        case ("html-results-ctnt-pilot"):
            //% "pilot"
            retVal = qsTrId("html-results-ctnt-pilot");
            break;
        case ("html-results-ctnt-classify"):
            //% "classify"
            retVal = qsTrId("html-results-ctnt-classify");
            break;
        case ("html-results-ctnt-score-points"):
            //% "score points"
            retVal = qsTrId("html-results-ctnt-score-points");
            break;
        case ("html-results-ctnt-score-points1000"):
            //% "score points1000"
            retVal = qsTrId("html-results-ctnt-score-points1000");
            break;
        case ("html-results-ctnt-speed"):
            //% "speed"
            retVal = qsTrId("html-results-ctnt-speed");
            break;
        case ("html-results-ctnt-startTime"):
            //% "startTime"
            retVal = qsTrId("html-results-ctnt-startTime");
            break;
        case ("html-results-false"):
            //% "false"
            retVal = qsTrId("html-results-false");
            break;
        case ("html-results-landing-accurancy"):
            //% "landing accurancy"
            retVal = qsTrId("html-results-landing-accurancy");
            break;
        case ("html-results-markers"):
            //% "markers"
            retVal = qsTrId("html-results-markers");
            break;
        case ("html-results-nok"):
            //% "nok"
            retVal = qsTrId("html-results-nok");
            break;
        case ("html-results-note"):
            //% "note"
            retVal = qsTrId("html-results-note");
            break;
        case ("html-results-ok"):
            //% "ok"
            retVal = qsTrId("html-results-ok");
            break;
        case ("html-results-opposite"):
            //% "opposite"
            retVal = qsTrId("html-results-opposite");
            break;
        case ("html-results-other-penalty"):
            //% "other penalty"
            retVal = qsTrId("html-results-other-penalty");
            break;
        case ("html-results-other-points"):
            //% "other points"
            retVal = qsTrId("html-results-other-points");
            break;
        case ("html-results-penalty"):
            //% "penalty"
            retVal = qsTrId("html-results-penalty");
            break;
        case ("html-results-photos"):
            //% "photos"
            retVal = qsTrId("html-results-photos");
            break;
        case ("html-results-point-alt-max"):
            //% "alt max"
            retVal = qsTrId("html-results-point-alt-max");
            break;
        case ("html-results-point-alt-measured"):
            //% "alt measured"
            retVal = qsTrId("html-results-point-alt-measured");
            break;
        case ("html-results-point-alt-min"):
            //% "alt min"
            retVal = qsTrId("html-results-point-alt-min");
            break;
        case ("html-results-point-alt-type"):
            //% "alt type"
            retVal = qsTrId("html-results-point-alt-type");
            break;
        case ("html-results-point-alt-limit"):
            //% "alt limit"
            retVal = qsTrId("html-results-point-alt-limit");
            break;
        case ("html-results-point-distance"):
            //% "point distance"
            retVal = qsTrId("html-results-point-distance");
            break;
        case ("html-results-point-name"):
            //% "point name"
            retVal = qsTrId("html-results-point-name");
            break;
        case ("html-results-point-sg-hit"):
            //% "sg hit"
            retVal = qsTrId("html-results-point-sg-hit");
            break;
        case ("html-results-point-tg-difference"):
            //% "tg difference"
            retVal = qsTrId("html-results-point-tg-difference");
            break;
        case ("html-results-point-tg-expected"):
            //% "tg expected"
            retVal = qsTrId("html-results-point-tg-expected");
            break;
        case ("html-results-point-tg-measured"):
            //% "tg measured"
            retVal = qsTrId("html-results-point-tg-measured");
            break;
        case ("html-results-point-tp-hit"):
            //% "tp hit"
            retVal = qsTrId("html-results-point-tp-hit");
            break;
        case ("html-results-point-type"):
            //% "point-type"
            retVal = qsTrId("html-results-point-type");
            break;
        case ("html-results-tg-score"):
            //% "tg results score"
            retVal = qsTrId("html-results-tg-score");
            break;
        case ("html-results-tp-score"):
            //% "tp results score"
            retVal = qsTrId("html-results-tp-score");
            break;
        case ("html-results-sg-score"):
            //% "sg results score"
            retVal = qsTrId("html-results-sg-score");
            break;
        case ("html-results-alt-score"):
            //% "alt results score"
            retVal = qsTrId("html-results-alt-score");
            break;
        case ("html-results-score"):
            //% "results score"
            retVal = qsTrId("html-results-score");
            break;
        case ("html-start-list-title"):
            //% "crews"
            retVal = qsTrId("html-start-list-title");
            break;
        case ("html-start-list"):
            //% "start list"
            retVal = qsTrId("html-start-list");
            break;
        case ("html-results-space-sections"):
            //% "space sections"
            retVal = qsTrId("html-results-space-sections");
            break;
        case ("html-results-space-sec-start-point"):
        case ("html-results-alt-sec-start-point"):
        case ("html-results-speed-sec-start-point"):
            //% "space sec start point"
            retVal = qsTrId("html-results-speed-sec-start-point");
            break;
        case ("html-results-speed-sec-measured"):
            //% "speed sec measured"
            retVal = qsTrId("html-results-speed-sec-measured");
            break;
        case ("html-results-speed-sec-expected"):
            //% "speed sec expected"
            retVal = qsTrId("html-results-speed-sec-expected");
            break;
        case ("html-results-space-sec-end-point"):
        case ("html-results-alt-sec-end-point"):
        case ("html-results-speed-sec-end-point"):
            //% "speed sec end point"
            retVal = qsTrId("html-results-speed-sec-end-point");
            break;
        case ("html-results-speed-sec-difference"):
            //% "speed sec difference"
            retVal = qsTrId("html-results-speed-sec-difference");
            break;
        case ("html-results-speed-sections"):
            //% "speed sections"
            retVal = qsTrId("html-results-speed-sections");
            break;
        case ("html-results-take-off"):
            //% "take off"
            retVal = qsTrId("html-results-take-off");
            break;
        case ("html-results-takeoff-calculated"):
            //% "take off calculated"
            retVal = qsTrId("html-results-takeoff-calculated");
            break;
        case ("html-results-takeoff-difference"):
            //% "take off difference"
            retVal = qsTrId("html-results-takeoff-difference");
            break;
        case ("html-results-takeoff-measured"):
            //% "take off measured"
            retVal = qsTrId("html-results-takeoff-measured");
            break;
        case ("html-results-track-points"):
            //% "track points"
            retVal = qsTrId("html-results-track-points");
            break;
        case ("html-continuous-results-name"):
            //% "crew name"
            retVal = qsTrId("html-continuous-results-name");
            break;
        case ("html-continuous-results-order"):
            //% "results order"
            retVal = qsTrId("html-continuous-results-order");
            break;
        case ("html-results-alt-sec-min-count"):
            //% "altitude sections min entries count"
            retVal = qsTrId("html-results-alt-sec-min-count");
            break;
        case ("html-results-alt-sec-min-time"):
            //% "altitude sections min entries time"
            retVal = qsTrId("html-results-alt-sec-min-time");
            break;
        case ("html-results-alt-sec-max-count"):
            //% "altitude sections max entries count"
            retVal = qsTrId("html-results-alt-sec-max-count");
            break;
        case ("html-results-alt-sec-max-time"):
            //% "altitude sections max entries time"
            retVal = qsTrId("html-results-alt-sec-max-time");
            break;
        case ("html-results-space-sec-entries-count"):
            //% "space sections entries count"
            retVal = qsTrId("html-results-space-sec-entries-count");
            break;
        case ("html-results-space-sec-entries-time"):
            //% "space sections entries time"
            retVal = qsTrId("html-results-space-sec-entries-time");
            break;
        case ("html-startList-order"):
            //% "Starting number"
            retVal = qsTrId("html-startList-order");
            break;
        case ("html-startList-startTimePrepTime"):
            //% "Preparation time"
            retVal = qsTrId("html-startList-startTimePrepTime");
            break;
        case ("html-startList-startTimeVBT"):
            //% "VBT time"
            retVal = qsTrId("html-startList-startTimeVBT");
            break;
        case ("html-startList-blank"):
            //% "Others"
            retVal = qsTrId("html-startList-blank");
            break;
        default:
            //retVal = "tr error: " + String(key);
            retVal = "";
        }
        return retVal;
    }

}
