#!/bin/bash
#title           :ats_parser.sh
#description     :This script will extract iccid and profile type and cast it into json, it supports xml and bz2 extensions
#author          :Angel Gutierrez | Deployment
#date            :20180405
#version         :0.1
#usage           :./ats_parser.sh


if [[ -f .files_processed ]]; then
    files=(`ls processed | grep -v -f .files_processed | egrep "_ATS_"| grep xml`)
else
    files=(`ls processed | grep "_ATS_" | grep xml`)
    mkdir output
fi

if [[ ${#files[@]} -gt 0 ]]; then
    for ((f=0; f<${#files[@]}; ++f)); do
      fileName=output/`echo ${files[$f]} | cut -d '.' -f2`.json
      echo { '"provision": [' >> ${fileName}
      iccid=(`bzgrep -oP "(?<=<gsepml:Iccid>)[^<]+" processed/${files[$f]}`)
      profileType=(`bzgrep -oP "(?<=<gsepml:ID>)[^<]+" processed/${files[$f]}`)
      for ((i=0; i<${#iccid[@]}; ++i)); do
        if [ ${i} -eq $((${#iccid[@]}-1)) ]; then
          echo -e '\t'{'"'iccid'"':'"'${iccid[$i]}'"', '"'profileType'"':'"'${profileType}'"'} >> ${fileName}
        else
          echo -e '\t'{'"'iccid'"':'"'${iccid[$i]}'"', '"'profileType'"':'"'${profileType}'"'}, >> ${fileName}
        fi
      done
      echo "]}" >> ${fileName}
      echo ${files[$f]} >> .files_processed
      echo "["$(date +%Y/%m/%d' '%H:%M:%S)"]|"${files[$f]}"|"${fileName}"|PROCESSED" >> ats_parser.log

    done
else
    echo "["$(date +%Y/%m/%d' '%H:%M:%S)"]""|THERE ARE NO FILES TO BE PROCESSED" >> ats_parser.log
fi
