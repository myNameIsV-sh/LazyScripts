#!/bin/bash

define_data_path() {
    read -e -p "Digite o caminho da pasta para organizar: " TARGET_PATH
   
    TARGET_PATH="${TARGET_PATH%/}"

    if [[ -z "$TARGET_PATH" ]]; then
        echo "Erro: Forneça algum diretório"
        exit 1
    fi

    if [[ ! -d "$TARGET_PATH" ]]; then
        echo "Erro: "$TARGET_PATH" não é um diretório válido"
        exit 1
    fi

}

process_rename() {
    echo "Iniciando a renomeação local..." 

    # 'find -depth' processa arquivos antes das pastas pai
    find "$TARGET_PATH" -depth -mindepth 1 | while read -r full_path; do
        
        dir_name=$(dirname "$full_path")
        old_name=$(basename "$full_path")

        new_name=$(echo "$old_name" | iconv -f UTF-8 -t ASCII//TRANSLIT | tr -cd '[:alnum:]._ -')

        if [ "$old_name" != "$new_name" ]; then
            mv "$dir_name/$old_name" "$dir_name/$new_name"
            echo "Renomeado: $old_name -> $new_name"
        fi
    done
}

define_data_path
process_rename
echo "Tudo certo!"