#!/bin/sh
xgettext ../*.php --from-code UTF-8
# msgmerge -N existing.po messages.po > new.po
#msgfmt messages.po