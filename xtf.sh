#!/bin/bash

list_flag=false
list_currency_flag=false
status_flag=false
profit_flag=false

after=""
before=""
currency=0

help_printer(){
        echo "PŘÍKAZ může být jeden z:
list – výpis záznamů pro daného uživatele.
list-currency – výpis seřazeného seznamu vyskytujících se měn.
status – výpis skutečného stavu účtu seskupeného a seřazeného dle jednotlivých měn.
profit – výpis stavu účtu zákazníka se započítaným fiktivním výnosem.
FILTR může být kombinace následujících:
-a DATETIME – after: jsou uvažovány pouze záznamy PO tomto datu a čase (bez něj). DATETIME je formátu YYYY-MM-DD HH:MM:SS.
-b DATETIME – before: jsou uvažovány pouze záznamy PŘED tímto datem a časem (bez něj).
-c CURRENCY – jsou uvažovány pouze záznamy odpovídající dané měně.
-h a --help vypíšou nápovědu s krátkým popisem každého příkazu a přepínače."
}

ARGS=( "$@" )
# Initialize an empty array to store logs
logs=()

for i in "${!ARGS[@]}"; do
    case "${ARGS[i]}" in
        '') # Skip if element is empty
            continue
            ;;
        -h|--help)
                help_printer
            ;;
        list) 
            list_flag=true
            ;;
        list-currency)
            list_currency_flag=true
            ;;
        status)
            status_flag=true
            ;;
        profit)
            profit_flag=true
            ;;
        -a)
            after="${ARGS[i+1]}"
            i=$((i+1)) # Skip next two arguments as they are processed with -a
            ;;
        -b)
            before="${ARGS[i+1]}"
            i=$((i+1)) # Skip next two arguments as they are processed with -b
            ;;
        -c)
            currency="${ARGS[i+1]}"
            i=$((i+1)) # Skip next two arguments as they are processed with -c
            ;;
         *)
            # Check if the last 4 characters of ARGS[i] are ".log"
            if [[ "${ARGS[i]: -4}" == ".log" ]]; then
                log_file="${ARGS[i]}"
                logs+=("$log_file") # Append trader to traders array
            else
                trader="${ARGS[i]}"
            fi
            ;;
    esac
    # No longer unsetting ARGS[i] here to allow processing all elements
done
if [[ "$list_flag" == false && "$list_currency_flag" == false && "$status_flag" == false && "$profit_flag" == false && "$currency" = "" ]]; then
    list_flag=true
# else
#     echo "At least one flag is true."
#     echo "$list_flag"
#     echo "$list_currency_flag"
#     echo "$status_flag"
#     echo "$profit_flag"
fi

# Decide what to do with collected traders. For example, print them
# for log in "${logs[@]}"; do
#     echo "Log found:: $log"
# done
# Function to read file line by line and append strings to the global array
read_file_to_array() {
    local filename="$1" # The first argument to the function is the filename
    local trader=$2
    while IFS= read -r line; do # IFS= prevents leading/trailing whitespace from being trimmed.
        IFS=';' read -ra ADDR <<< "$line" # Split line into an array based on ';'

        if [ "$list_flag" = true ]; then
                if [ "$trader" = "${ADDR[0]}" ]; then
                        for i in "${ADDR[@]}"; do
                                echo -n "$i;"
                        done
                        echo ""
                fi
        fi

        if [ "$list_currency_flag" = true ]; then
                if [ "$trader" = "${ADDR[0]}" ]; then
                        echo "${ADDR[2]}"
                fi
        fi

        if [ "$currency" = "${ADDR[2]}" ]; then
            if [ "$trader" = "${ADDR[0]}" ]; then
                        for i in "${ADDR[@]}"; do
                                echo -n "$i;"
                        done
                        echo ""
                fi
        fi

        if [[ "$after" != "" && "$after" > "${ADDR[1]}" ]]; then
                if [ "$trader" = "${ADDR[0]}" ]; then
                        for i in "${ADDR[@]}"; do
                                echo -n "$i;"
                        done
                        echo ""
                fi
        fi

        if [ "$status_flag" = true ]; then
                i=${i^^} # Convert to uppercase
        fi

        if [ "$profit_flag" = true ]; then
                i=${i^^} # Convert to uppercase
        fi

        # for element in ${ADDR[0]}; do
        #     echo "$element"
        # done
        
    done < "$filename" # Read from the file specified as the first argument
}

# Call the function with the filename
read_file_to_array "cryptoexchange-1.log" "$trader"


