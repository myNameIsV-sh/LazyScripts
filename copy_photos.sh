 #!/bin/bash

declare SOURCE_PATH=""
declare DESTINATION_PATH=""

list_connected_devices() {
    echo "Dispositivos disponíveis:"
    lsblk -lp | grep " /"
    echo "--------------------------"
}

define_data_paths() {
    read -e -p "Digite o caminho de ORIGEM (Source): " SOURCE_PATH
    read -e -p "Digite o caminho de DESTINO (Destination): " DESTINATION_PATH
    
    # Expansão de parâmetros %/ 
    # Remove a barra final "/" do diretório 
    SOURCE_PATH="${SOURCE_PATH%/}"
    DESTINATION_PATH="${DESTINATION_PATH%/}"
    
    [[ -z "$SOURCE_PATH" || -z "$DESTINATION_PATH" ]] && { echo "Caminhos vazios!"; exit 1; }
}

auto_copy_files() {
    echo -e "\nAnalisando arquivos na origem... Aguarde."
    local total_origem=$(find "$SOURCE_PATH" -maxdepth 1 -type f | wc -l)
    
    echo "------------------------------------------"
    echo "Arquivos detectados na origem: $total_origem"
    echo "Destino Base: $DESTINATION_PATH"
    echo "------------------------------------------"
    
    read -p "Deseja iniciar a sincronização com preservação total de atributos? (s/n): " confirmacao
    [[ "$confirmacao" =~ ^[sS]$ ]] || { echo "Operação cancelada."; return 0; }

    echo -e "\n--- Iniciando Transferência de Alta Fidelidade ---"

    # Captura os anos YYYY
    local anos=$(ls "$SOURCE_PATH" | grep -E '^[0-9]{4}' | cut -c1-4 | sort -u)

    for ano in $anos; do
        echo -e "\n>>> Processando pasta: $ano/"
        mkdir -p "$DESTINATION_PATH/$ano"
        
        # AJUSTE: rsync -aXv --times
        # -a (archive): Preserva permissões, dono, grupo e symlinks.
        # -X (extended attributes): Preserva metadados extras se o sistema de arquivos suportar.
        # --times: Garante a preservação rigorosa das datas de modificação.
        rsync -aXv --ignore-existing --progress \
              --include="${ano}*" --exclude="*" \
              "$SOURCE_PATH/" "$DESTINATION_PATH/$ano/"
    done

    # Arquivos que não seguem o padrão YYYY
    echo -e "\n>>> Verificando arquivos restantes (Outros)..."
    rsync -aXv --ignore-existing --progress \
          --exclude="[0-9][0-9][0-9][0-9]*" \
          "$SOURCE_PATH/" "$DESTINATION_PATH/"

    echo -e "\n--- Auditoria Final ---"
    local total_destino=$(find "$DESTINATION_PATH" -type f ! -name "$(basename "$0")" | wc -l)
    
    echo "Total na Origem: $total_origem"
    echo "Total no Destino: $total_destino"
    
    sync
    echo "Concluído! Atributos preservados."
}

main() {
  echo "Iniciando processo de backup seguro..."
  list_connected_devices
  define_data_paths
  auto_copy_files
}

main