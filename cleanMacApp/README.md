## CleanMacApp
- Remove unused Proofing Tools from Office

```sh
find /Applications/Microsoft*/Contents/SharedSupport/Proofing\ Tools \
  -type d -name "*.proofingtool" \
  -not -name "French*" -not -name "English*" \
  -not -name "Generic*" -not -name "CssFrench*" -not -name "CssEnglish*" \
| awk '{print "sudo rm -Rf \""$0"\""}'
```

- Remove unused Fonts

```sh
find /Applications/Microsoft*/Contents/Resources/DFonts \
    -size +2M | awk '{print "sudo rm -Rf \""$0"\""}'
```

- Remove unused languages (attention, pas OneDrive)

```sh
find /Applications/Microsoft*/Contents/Resources \
  -type d -name "*.lproj" -not -name "Base.lproj" \
  -not -name "fr.lproj" -not -name "en.lproj" -not -name "en[_-][A-Z]*.lproj" \
| awk '{print "sudo rm -Rf \""$0"\""}' 
```
