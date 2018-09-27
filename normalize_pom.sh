#!/bin/bash

set -euo pipefail

# sed -e '1,7 d' \
# -e '/\W*<dependency>/d' \
# -e '/\W*<\/dependency>/d' \
# -e 's/<\/groupId>\W*<artifactId>//g' \
# shadow_bonita-server.xml

if [ "$#" -ne 1 ]; then
    echo "Usage: `basename ${0}` <FILE_TO_NORMALIZE>"
    exit 1
fi

source_file=$1

output_file=${source_file%%.xml}_normalized.txt
echo "Writing output to file ${output_file}"

tmp_file=${output_file}_tr

cat ${source_file} | sed -e '1,7 d' > ${output_file} # remove all carriage returns
sed -i 's/[ ]*//g' ${output_file}
sed -i '/<dependency>/d' ${output_file}
sed -i 's/<groupId>//g' ${output_file}
sed -i 's/<\/groupId>/:/g' ${output_file}
sed -i 's/<artifactId>//g' ${output_file}
sed -i 's/<version>/:/g' ${output_file}
sed -i 's/<\/version>//g' ${output_file}
sed -i 's/<exclusions>/ - EXCLUSIONS /g' ${output_file}
sed -i 's/<\/artifactId>//g' ${output_file}
sed -i 's/<\/exclusions>//g' ${output_file}
cat ${output_file} | tr -d '\n' > ${tmp_file}
sed -e 's/<\/groupId><artifactId>//g' ${tmp_file} > $output_file
sed -i 's/<\/artifactId><\/exclusion>//g' ${output_file}
sed -i 's@</exclusion><exclusion>@, @g' ${output_file}
sed -i 's/<[\/]*exclusion>//g' ${output_file}

sed -i 's/<\/dependency>/\n/g' ${output_file}
sed -e '/<\/dependencies>/d' ${output_file} > ${tmp_file}
# read unused
sort ${tmp_file} | uniq > ${output_file}

rm ${tmp_file}

cat $output_file





# head -20 shadow_bonita-server.xml | sed -e '1,7 d' | tr -d '\n' | sed -e '/\W*<dependency>/d'