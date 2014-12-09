#!/bin/sh

exists=0
if [ -f messages.po ]; then
  exists=1
  cp -f messages.po old.po # stary preklad zazalohujeme
fi

xgettext ../*.php --from-code UTF-8 # vygenerujeme novy messages.po

sed -i "s|Content-Type: text/plain; charset=CHARSET|Content-Type: text/plain; charset=UTF-8|" messages.po


if [ $exists -eq 1 ]; then
  msgmerge --lang=cs_CZ -N old.po messages.po > new.po # spojime
  mv new.po messages.po # prepisme spojene
fi


msgfmt messages.po # prekompilujeme do .mo
mkdir -p ./cs_CZ/LC_MESSAGES/
mv ./messages.mo ./cs_CZ/LC_MESSAGES/messages.mo # dame na misto