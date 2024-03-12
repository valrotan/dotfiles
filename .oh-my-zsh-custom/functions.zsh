lfcd () {
    'cd' "$('lf' -print-last-dir "$@")"
}

# portfoward() {
#   if [ $# -lt 2 ]
#   then
#     echo "Usage: $funcstack[1] <host> <port>"
#     return
#   fi

#   ssh -NL $2:localhost:$2 $1
# }

matrix() { echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4;        letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}' }

mmv()
{
    OLD=/tmp/current_files
    NEW=/tmp/rename_files

    # get options
    dry='false'
    verbose='false'
    while getopts 'dvh' flag; do
        case "${flag}" in
            d) dry='true' ;;
            v) verbose='true' ;;
            h | *) echo "Usage: $0 [-d  dryrun] [-v  verbose] [file or folder]" 1>&2
                   return 0;;
        esac
    done

    if "$dry"; then
        echo "Dry run:"
        cmd=echo
        NEW=${NEW}_dry_run
    else
        cmd=''
    fi

    # get the directory argument
    DIR="${@: -1}"
    if [ $DIR ] && [ -d $DIR ]; then
        DIR="${DIR%/}/"
    else
        DIR=""
    fi
    echo "DIR: $DIR"

    # get the files and open the editor
    ls -1p $DIR | sed "s|^|$DIR|" > $OLD
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

    # rename or delete the files
    mv_count=0
    rm_count=0
    while IFS= read -r orig_fname && IFS= read -r new_fname <&3; do
        if [ -z "$new_fname" ]; then
            $cmd rm "$orig_fname"
            ((rm_count+=1))
        elif [ "$orig_fname" != "$new_fname" ]; then
            # check if new_fname exists and don't overwrite
            if [ -e "$new_fname" ]; then
                echo "Cannot mv $orig_fname $new_fname, new filename already exists. Skipping"
            else
                $cmd mv "$orig_fname" "$new_fname"
                ((mv_count+=1))
            fi
        fi
    done < $OLD 3< $NEW

    [ $mv_count -gt 0 ] && echo "Renamed $mv_count files"
    [ $rm_count -gt 0 ] && echo "Removed $rm_count files"

    rm $OLD $NEW
    return 0
}
