#!/usr/bin/env python3
"""
Filtre le dictionnaire pour enlever les verbes conjugués et les participes passés pluriels.
"""

import csv


def filter_dictionary(
    lexique_path: str = "Lexique383.tsv",
    input_words: str = "mots_lexique.txt",
    output_file: str = "assets/dictionnaire_fr.txt"
):
    """
    Filtre les mots en enlevant:
    - Les verbes conjugués (garde seulement les infinitifs)
    - Les participes passés au pluriel (garde seulement le singulier)
    """

    # 1. Charger les infos du lexique
    print("Chargement du lexique...")
    word_info = {}  # word -> {cgram, lemme, infover, nombre}

    with open(lexique_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            word = row['ortho'].strip().lower()
            if not word or ' ' in word or '-' in word or not word.isalpha():
                continue

            cgram = row['cgram']
            lemme = row['lemme'].strip().lower()
            infover = row.get('infover', '')
            nombre = row.get('nombre', '')

            # Garder la première occurrence
            if word not in word_info:
                word_info[word] = {
                    'cgram': cgram,
                    'lemme': lemme,
                    'infover': infover,
                    'nombre': nombre
                }

    print(f"  {len(word_info)} mots dans le lexique")

    # 2. Charger les mots à filtrer
    print("Chargement des mots...")
    with open(input_words, 'r', encoding='utf-8') as f:
        words = [w.strip().lower() for w in f.readlines() if w.strip()]

    print(f"  {len(words)} mots à filtrer")

    # 3. Filtrer
    print("Filtrage...")
    filtered_words = []
    removed_conjugated = 0
    removed_plural_participle = 0
    removed_participle_present = 0
    removed_plural_nouns = 0
    removed_plural_adjectives = 0
    kept_infinitives = 0

    for word in words:
        info = word_info.get(word)

        if info is None:
            # Mot pas dans le lexique, on le garde
            filtered_words.append(word)
            continue

        cgram = info['cgram']
        infover = info['infover']
        nombre = info['nombre']
        lemme = info['lemme']

        # Verbe ou auxiliaire?
        if cgram in ('VER', 'AUX'):
            # Est-ce un infinitif?
            is_infinitive = word == lemme or infover.startswith('inf')

            # Est-ce un participe passé?
            is_participle_past = 'par:pas' in infover
            # Est-ce un participe présent?
            is_participle_present = 'par:pre' in infover

            if is_infinitive:
                # Garder les infinitifs
                filtered_words.append(word)
                kept_infinitives += 1
            elif is_participle_present:
                # Participe présent: enlever
                removed_participle_present += 1
            elif is_participle_past:
                # Participe passé: garder seulement si singulier (ou pas de nombre)
                if nombre == 'p':  # pluriel
                    removed_plural_participle += 1
                else:
                    filtered_words.append(word)
            else:
                # Autre forme conjuguée: enlever
                removed_conjugated += 1
        elif cgram == 'NOM':
            # Nom: garder seulement si singulier
            if nombre == 'p':  # pluriel
                removed_plural_nouns += 1
            else:
                filtered_words.append(word)
        elif cgram == 'ADJ':
            # Adjectif: garder seulement si singulier
            if nombre == 'p':  # pluriel
                removed_plural_adjectives += 1
            else:
                filtered_words.append(word)
        else:
            # Autre catégorie, garder
            filtered_words.append(word)

    # 4. Trier et sauvegarder
    filtered_words = sorted(set(filtered_words))

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(filtered_words))

    print(f"\nRésultats:")
    print(f"  Mots originaux: {len(words)}")
    print(f"  Infinitifs gardés: {kept_infinitives}")
    print(f"  Verbes conjugués enlevés: {removed_conjugated}")
    print(f"  Participes présents enlevés: {removed_participle_present}")
    print(f"  Participes passés pluriels enlevés: {removed_plural_participle}")
    print(f"  Noms pluriels enlevés: {removed_plural_nouns}")
    print(f"  Adjectifs pluriels enlevés: {removed_plural_adjectives}")
    print(f"  Mots finaux: {len(filtered_words)}")
    print(f"\nSauvegardé dans {output_file}")

    return filtered_words


if __name__ == "__main__":
    filter_dictionary()
