cat heap20111116.log | awk -F '[,]' '{print $1 "," $3 "," $6}' > heap.log

sed - if its starts with x delete it
cat heap.log | sed '/^[T|E|V]/d'
sed '/time=//g'
-- eg. lines starting w/ Target or Elapsed or VM
:%s/^Target/d  -- delete line
:%s/^Elapsed/d  -- delete line
:%s/^VM/d  -- delete line

cat heap.log | sed '/^[T|E|V]/d' # delete first three header lines starting w/ Target or Elapsed or VM args
| sed -e 's/time=//g' -e 's/used=//g' -e 's/max=//g' # do series of substitute deletes
-e 's/K//g' -e 's/, /,/g'   # del Cap K, del space
-e 's/[()]/,/g'             # rplc parans w/ comma
| awk -F '[,]' '{print $1 "," $3 "," $6}' # specify comma as field separator
> final.log

cat heap.log | sed '/^[T|E|V]/d' | sed 's/time=//g'
