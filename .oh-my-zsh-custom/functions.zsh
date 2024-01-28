# portfoward() {
#   if [ $# -lt 2 ]
#   then
#     echo "Usage: $funcstack[1] <host> <port>"
#     return
#   fi

#   ssh -NL $2:localhost:$2 $1
# }

matrix() { echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4;        letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}' }

mmv ()
{
    dry='false'
    verbose='false'

    print_usage() {
        printf "Usage: ..."
    }

    while getopts 'dv' flag; do
        case "${flag}" in
            d) dry='true' ;;
            v) verbose='true' ;;
            *) print_usage
               exit 1 ;;
        esac
    done
    if "$dry"; then
        cmd=echo
    else
        cmd=''
    fi


    OLD=/tmp/current_files
    NEW=/tmp/renamed_files

    ls -1 > $OLD
    cp $OLD $NEW
    ${EDITOR:-vi} $NEW

    # die if no changes were made
    if diff $OLD $NEW > /dev/null; then
        echo "No changes made"
        return 0
    fi

    # die if the files are not the same length
    if [ $(wc -l < $OLD) -ne $(wc -l < $NEW) ]; then
        echo "Files are not the same length"
        return 1
    fi

    count=0
    while IFS= read -r orig_fname && IFS= read -r new_fname <&3; do
        if [ -z "$new_fname" ]; then
            $cmd rm "$orig_fname"
            ((count+=1))
        elif [ "$orig_fname" != "$new_fname" ]; then
            $cmd mv "$orig_fname" "$new_fname"
            ((count+=1))
        fi
    done < $OLD 3< $NEW

    echo "Renamed $count files"

    rm $OLD $NEW
    return 0
}
