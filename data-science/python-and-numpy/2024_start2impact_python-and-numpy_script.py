#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 20:48:59 2024

@author: stevenmariani
"""

#Importazione delle librerie necessarie al corretto funzionamento dello script

import os
import mimetypes
import csv
import argparse

#Definizione delle funzioni che mi serviranno per eseguire lo script
#Ho scelto di affrontare in questo modo lo script in modo da avere
#un approccio modulare.

#Definisco il dizionario in cui associo la chiave (il tipo di file)
#con il valore (il nome che avranno le cartelle di destinazione)

def carica_dizionario():
    return {
        'audio': 'audio',
        'image': 'image',
        'text': 'docs'
    }

#Definisco la funzione prepara_ambiente che mi occorrà per ordinare
#i file dentro il percorso e gestire il percorso del file recap csv

def prepara_ambiente(files_path, recap_input):
    files_list = sorted(os.listdir(files_path))
    csv_file_path = os.path.join(files_path, recap_input)
    return files_list, csv_file_path

#Definisco la funzione per creare le cartelle per ogni chiave
#del dizionario nel caso in cui ancora non esista la cartella

def crea_cartelle_destinazione(files_path, dictionary):
    for key in dictionary.values():
        full_path = os.path.join(files_path, key)
        if not os.path.exists(full_path):
            os.mkdir(full_path)  
            
#Definisco una funzione che si occupa di riconoscere il file sulla base
#della sua estensione, grazie alla libreria mimetypes
            
def riconosci_tipo_file(file, dictionary):
    tipo_mime, _ = mimetypes.guess_type(file)
    for key, _ in dictionary.items():
        if tipo_mime and key in tipo_mime:
            return key
    return None

#Definisco la funzione che si occupa di spostare il file e stampa il recap,
#per operare lo spostamento utilizzo la funzione riconosci_tipo_file precedentemente
#definita. Una volta spostato il file la funzione scrive nel recap.csv (che deve esistere)
#le informazioni del file spostato

def sposta_file(file, files_path, dictionary, csv_writer):
    if file == 'recap.csv':
        return
    
    tipo_file = riconosci_tipo_file(file, dictionary)
    if tipo_file:
        dest_folder_path = os.path.join(files_path, dictionary[tipo_file])
        dest_file_path = os.path.join(dest_folder_path, file)
        src_file_path = os.path.join(files_path, file)
        
        os.rename(src_file_path, dest_file_path)
        
        name, extension = os.path.splitext(file)
        size = os.path.getsize(dest_file_path)
        
        csv_writer.writerow([name, tipo_file, size])
        
#Definisco la funzione principale sfruttando argparse per permettere la compilazione tramite
#CLI. Il nome del file che viene passato nella funzione viene poi passato dentro la funzione
#sposta file.

def main():
    parser = argparse.ArgumentParser(description="Script di categorizzazione automatica di un file specifico")
    parser.add_argument('file', type=str, help='Il nome del file da categorizzare presente nella cartella "files".')
    args = parser.parse_args()
    
    files_path = os.path.join('files')
    recap_input = os.path.join('recap.csv')
    dictionary = carica_dizionario()
    
    csv_file_path = os.path.join(files_path, recap_input)
    file_exists = os.path.exists(csv_file_path)
    
    crea_cartelle_destinazione(files_path, dictionary)

    with open(csv_file_path, mode='a' if file_exists else 'w', newline='') as csv_file:
            csv_writer = csv.writer(csv_file)
            file_to_process = args.file
            
            if not file_exists:
                csv_writer.writerow(['name', 'tipo_file', 'size'])
            
            if file_to_process in os.listdir(files_path):
                sposta_file(file_to_process, files_path, dictionary, csv_writer)
            else:
                print(f"Il file '{file_to_process}' non è stato trovato nella directory'.")

                     
if __name__ == "__main__":
    main()