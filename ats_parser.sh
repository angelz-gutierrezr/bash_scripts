#!/bin/bash
#title           :ats_parser.sh
#description     :This script will extract iccid and profile type and cast it into json, it supports xml and bz2 extensions
#author          :Angel Gutierrez | Deployment
#date            :20180405
#version         :0.1
#usage           :./ats_parser.sh

#Define PROXY
export https_proxy=https://proxy-fr-croissy.gemalto.com:8080/
export http_proxy=http://proxy-fr-croissy.gemalto.com:8080/


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
      #Send POST command to AMDOCS API
      #curl --silent -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d @${fileName} -k https://52.35.52.112:20501/HandleProvisioningInfo
      # EXECUTE THIS FROM GWAF
      #curl --verbose -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d @5365C03EC6086509D1673A6C615052C63E6DAC9F_ATS_SUBS_SO59132.001_82953100_IUSB006L_1-1_20180306104900.xml -k https://10.9.93.116:443/HandleProvisioningInfo
      echo "["$(date +%Y/%m/%d' '%H:%M:%S)"]|"${files[$f]}"|"${fileName}"|PROCESSED" >> ats_parser.log

    done
else
    echo "["$(date +%Y/%m/%d' '%H:%M:%S)"]""|THERE ARE NO FILES TO BE PROCESSED" >> ats_parser.log
fi
