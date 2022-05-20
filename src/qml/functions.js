.pragma library

var base_url_default = 'https://ppt.laacr.cz'

var alt_hysteresis = 20; // meters
var alt_max_init = -100000;
var alt_min_init = 100000;
var space_hysteresis = 25; // meters
var space_mindistance_init = 100000000;


/*
// function has been moved into resultscreater.cpp
function arrayFromMask (nMask) {
    // nMask must be between -2147483648 and 2147483647
    if (nMask > 0x7fffffff || nMask < -0x80000000) { throw new TypeError("arrayFromMask - out of range"); }
    for (var nShifted = nMask, aFromMask = []; nShifted; aFromMask.push(Boolean(nShifted & 1)), nShifted >>>= 1);
    return aFromMask;
}
*/

function basename(path) {
    return String(path).replace(/.*\/|\.[^.]*$/g, '');
}

function addSlashes(input) {
    return String(input).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function removeSlashes(input) {
    return String(input).replace(/\\\\/g, '\\').replace(/\\"/g, '"');
}

function replaceDoubleQuotes(input) {
    return String(input).replace(/"/g, '\\\'');
}

function replaceSingleQuotes(input) {
    return String(input).replace(/\\\'/g, '\"');
}






function getContestantResultFileName(name, category) {
    return name + "_" + category;
}

function nameValidator(string) {

    var nameRegexp = /^.+ .+$/; // two words with space

    return nameRegexp.exec(string);
}

function addUtcToTime(timeSec, utcOffsetSec) {

    if (timeSec === 0) {
        return 0;
    }
    else {
        return timeSec + utcOffsetSec;
    }
}

function subUtcFromTime(timeSec, utcOffsetSec) {

    if (timeSec === 0) {
        return 0;
    } else {
        return timeSec - utcOffsetSec;
    }
}

function addTimeStrFormat(str) {
    var t = parseInt(str, 10);
    if (isNaN(t)) {
        return "";
    }
    var ta = Math.abs(t)
    var hours = Math.floor(ta/3600)
    var minutes = Math.floor((ta%3600)/60)
    var seconds = Math.floor(ta%60);

    if (t >= 0) {
        return pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds)
    } else {

        return "-"+pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds)
    }
}

function test_addTimeStrFormat() {

    var t = [
                {
                    "input": 0,
                    "expected" : "00:00:00"
                },
                {
                    "input": 1,
                    "expected" : "00:00:01"
                },
                {
                    "input": 60,
                    "expected" : "00:01:00"
                },
                {
                    "input": 61,
                    "expected" : "00:01:01"
                },
                {
                    "input": 3600,
                    "expected" : "01:00:00"
                },
                {
                    "input": 3661,
                    "expected" : "01:01:01"
                },
                {
                    "input": 3600,
                    "expected" : "01:00:00"
                },
                {
                    "input": -1,
                    "expected" : "-00:00:01"
                },
                {
                    "input": -60,
                    "expected" : "-00:01:00"
                },
                {
                    "input": -3600,
                    "expected" : "-01:00:00"
                },
                {
                    "input": -3661,
                    "expected" : "-01:01:01"
                },
            ]
    for (var i = 0; i < t.length; i++) {
        var item = t[i]
        if (item.expected !== addTimeStrFormat(item.input)) {
            console.error(item.input + " " + item.expected + " "  + addTimeStrFormat(item.input));
        }
    }

}

function pad2(i) {
    if (i < 10) {
        return "0" + i;
    }
    return i;
}

function getFlagsByIndex(flag_index, value) {
    var mask = (0x1 << flag_index);
    return ((value & mask) == mask);
}


function timeToUnix(str) {
    var result = /^(-?)(\d+):(-?\d+):?(-?\d*\.?\d*)$/.exec(str);
    if (result) {
        if (isNaN(parseInt(result[4],10))) {
            result[4] = 0;
        }
        var h = parseInt(result[2], 10);
        var m = parseInt(result[3], 10);
        var s = parseInt(result[4], 10);
        var positive = ((result[1] !== "-") && (m >= 0) && (s >= 0)) ? 1 : -1;
        return positive * (h * 3600 +  m * 60 + s);
    } else if ((str === '') || (str === null) || (str === "null")) {
        return 0;
    }
    console.warn("timeToUnix regexp doesn't match \"" +str+"\"" + typeof str)
    return 0;
}

function test_timeToUnix() {
    var t = [
                {
                    "input": "00:00:00",
                    "expected" : 0
                },
                {
                    "input": "00:00:01",
                    "expected" : 1
                },
                {
                    "input": "00:01:00",
                    "expected" : 60
                },
                {
                    "input": "00:01:01",
                    "expected" : 61
                },
                {
                    "input": "01:00:00",
                    "expected" : 3600
                },
                {
                    "input": "01:01:01",
                    "expected" : 3661
                },
                {
                    "input": "01:00:00",
                    "expected" : 3600,
                },
                {
                    "input": "-00:00:01",
                    "expected" : -1,
                },
                {
                    "input": "-00:01:00",
                    "expected" : -60,
                },
                {
                    "input": "-01:00:00",
                    "expected" : -3600,
                },
                {
                    "input": "-01:01:01",
                    "expected" : -3661,
                },
                {
                    "input": "6:00",
                    "expected" : 21600,
                },
            ]
    for (var i = 0; i < t.length; i++) {
        var item = t[i]

        if (item.expected !== timeToUnix(item.input)) {
            console.error(item.input + ": " + item.expected + " != "  + timeToUnix(item.input) + " Doesn't match with expected value");
        }
    }

}

