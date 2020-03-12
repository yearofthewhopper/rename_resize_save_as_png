#!/usr/bin/env bash

# Update this if there are changes to the arguments passed.
# shellcheck disable=SC2059
printf "Usage: \n* 'bash $0 dir_arg'\n* 'bash $0 percentage_arg dir_arg'\n* 'bash $0 width_arg height_arg dir_arg'\nAnything else will not work properly.\n"

execute_script() {
    while [[ $prefix = '' ]];
    do
        printf '\nEnter chosen prefix: '
        # shellcheck disable=SC2162
        read prefix
    done

    # downloads/combined was the placeholder
    # shellcheck disable=SC2016
    printf "Target directory: $dir\n"
    # shellcheck disable=SC2164
    # shellcheck disable=SC2016
    cd "$dir"

    readonly LOG="chronicle.log"

    now=$(date '+%d/%m/%Y | %r')
    echo '-> New renaming started:' >> $LOG

    # Declaring an array variable.
    # shellcheck disable=SC2207
    declare -a files=(`ls`)

    printf 'Print read files in this folder (Y/n): '
    # shellcheck disable=SC2162
    read read_files

    if [[ "$read_files" = 'Y' || "$read_files" = 'y' ]]
    then
      # shellcheck disable=SC2145
      echo "Files here: ${files[@]}"
    fi

    printf 'Loader: \n'
    echo '*'

    # for loading the renaming and/or size conversion
    loader=1
    sp='/-\|'
    echo -n ' '

    id=0
    for file in *.*
    do
        if [[ "$file" =~ \.(jpeg|png|jpg)$ ]]; then
            id=$((id+1))
            echo -ne "\b${sp:loader++%${#sp}:1}"
            mv "$file" "$prefix-$id".jpg

            if [[ "$percentage" != "" ]]; then
                convert "$prefix-$id".jpg -resize "$percentage"% "$prefix-$id".png | tr '-' '_' # standardize to a png
            fi

            if [[ "$width" != "" && "$height" != "" ]]; then
                convert "$prefix-$id".jpg -resize "$width"x"$height" "$prefix-$id".png | tr '-' '_'

            fi

            echo "$prefix-$id.png was $file" >> $LOG
            

        fi
    done

    printf '\n*'

    if [[ "$id" -ne 0 ]]; then
        echo "-> Renaming the date of these thingies: $now" >> $LOG
        printf "\nRenaming totally don. Check your renamed images in this file, kiddo: $LOG\n"
    else
        printf '\nNo .jpeg, .png or .jpg files present in this dir.\n'
        echo 'Yikes quit early i didnt find anything!' >> $LOG
    fi
}

# echo "Arguments count: $#"
# Arguments passed.
if [[ "$#" -eq 1 ]]; then
    dir="$1"
    execute_script
elif [[ "$#" -eq 2 ]]; then
    percentage="$1"
    dir="$2"
    execute_script
elif [[ "$#" -eq 3 ]]; then
    width="$1"
    height="$2"
    # shellcheck disable=SC2034
    dir="$3"
    execute_script
else
    printf 'Invalid argument size.\n'
fi
