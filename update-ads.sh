#!/bin/sh

set -e

sleep "$(jot -r 1 1 600)"

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
umask 22

extr1="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml"
extr2="https://hostfiles.frogeye.fr/firstparty-trackers.txt"
extr3="https://hosts.oisd.nl/basic"
_disconad="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
_discontrack="https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
_stevenblack="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
_smarttv="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt"
_android="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt"
_adaway="https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt"
_e1="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/EasyPrivacySpecific.txt"
_e2="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/EasyPrivacy3rdParty.txt"
_e3="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileSpyware.txt"
_e4="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileAds.txt"
_e5="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardDNS.txt"
_e6="https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardApps.txt"
_sp1="https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt"
_sp2="https://raw.githubusercontent.com/notracking/hosts-blocklists/master/dnscrypt-proxy/dnscrypt-proxy.blacklist.txt"
_spt="https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/spotifyads.txt"
_x1="https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
_x3="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt"
_x4="https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
_x5="https://phishing.army/download/phishing_army_blocklist_extended.txt"
_x6="https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
_hm1="https://raw.githubusercontent.com/hectorm/hmirror/master/data/antipopads/list.txt"
_hm2="https://raw.githubusercontent.com/hectorm/hmirror/master/data/digitalside-threat-intel/list.txt"
_hm3="https://raw.githubusercontent.com/hectorm/hmirror/master/data/fanboy-annoyance/list.txt"
_hm4="https://raw.githubusercontent.com/hectorm/hmirror/master/data/ublock-abuse/list.txt"
_hm5="https://raw.githubusercontent.com/hectorm/hmirror/master/data/ublock-privacy/list.txt"
_hm6="https://raw.githubusercontent.com/hectorm/hmirror/master/data/ublock/list.txt"
_hm7="https://raw.githubusercontent.com/hectorm/hmirror/master/data/urlhaus/list.txt"
_doh="https://raw.githubusercontent.com/oneoffdallas/dohservers/master/list.txt"

_tmpfile="$(mktemp)" && touch $_tmpfile
_parsed="$(mktemp)"  && touch $_parsed
_unboundconf="/home/_dl/combined.txt"

getcmd="ftp -S noverifytime -V -M -U '' -o"

parsehost()
{
  $getcmd - $1 | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' > $_parsed
  cat $_parsed >> $_tmpfile
}

parsehost0000() {
  $getcmd - $1 | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | \
  awk '/^0.0.0.0/ { print $2 }' > $_parsed
  cat $_parsed >> $_tmpfile
}

parsehost $_android
parsehost $_smarttv
parsehost $_discontrack
parsehost $_disconad
parsehost $_sp1
parsehost $_spt
parsehost0000 $_e1
parsehost0000 $_e2
parsehost0000 $_e3
parsehost0000 $_e4
parsehost0000 $_e5
parsehost0000 $_e6
parsehost $_sp2
parsehost0000 $_x1
parsehost $_x3
parsehost $_x4
parsehost $_x5
parsehost $_x6
parsehost $_hm1
parsehost $_hm2
parsehost $_hm3
parsehost $_hm4
parsehost $_hm5
parsehost $_hm6
parsehost $_hm7
parsehost $extr1
parsehost $extr2
parsehost $extr3
parsehost0000 $_doh

  $getcmd - $_stevenblack | \
  sed -n '/Start/,$p' | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | \
  awk '/^0.0.0.0/ { print $2 }' > $_parsed
  cat $_parsed >> $_tmpfile

  $getcmd - $_adaway | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | \
  awk '/^127.0.0.1/ { print $2 }' > $_parsed
  cat $_parsed >> $_tmpfile

sync
sort -fu $_tmpfile | grep -v "^[[:space:]]*$" | \
awk '{
  print $1
}' | uniq > $_unboundconf

rm -f $_tmpfile

cd /home/_dl
git add combined.txt
git commit -m update
git push

exit 0
