#!/usr/bin/env bash
ex="example"
pv="private"
base_path="/etc/nginx/snippets"

# file_list="$(cat /usr/local/share/xfl/check_file_list.txt | grep -v '^$')"
raw_file_list="$(cd $base_path/$ex && grep -r --include="*.conf" "include snippets/private" . )"
generate_file_list="$(echo -e "$raw_file_list" | sed '/\*\.conf/d' | cut -d':' -f1 | sort | uniq)"
mkdir_file_list="$(echo -e "$raw_file_list" | grep '*.conf;' | grep -oE 'include .*$' | sed 's#include ##g' | sed 's#\*\.conf;##g' | cut -d':' -f2 | sort | uniq)"

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][xfl_init] $1"
}

just_log "Current ID[$(id)]"

for rel_path in $mkdir_file_list; do
    curr_private_dir_path="$(realpath -Pm /etc/nginx/${rel_path})"
    just_log "Checking dir[${curr_private_dir_path}]..."
    if [ ! -e $curr_private_dir_path ]; then
        just_log "Creating dir[${curr_private_dir_path}]..."
        mkdir -p $curr_private_dir_path
    fi
done

for rel_path in $generate_file_list; do
    curr_example_file_path="$(realpath -Pm ${base_path}/${ex}/${rel_path})"
    curr_private_file_path="$(realpath -Pm ${base_path}/${pv}/${rel_path})"
    just_log "Checking file[${curr_example_file_path}]..."
    if [ ! -e $curr_private_file_path -a -e $curr_example_file_path  ]; then
        file_content="include ${curr_example_file_path};"
        just_log "Generating file[${curr_private_file_path}] with content[${file_content}]..."
        just_log "${file_content}" >> $curr_private_file_path
    fi
done

just_log "All done!"
