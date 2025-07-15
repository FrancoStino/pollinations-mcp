#!/bin/bash

# Script per aggiornare la versione del progetto Pollinations MCP
# Uso: ./update-version.sh <nuova_versione>
# Esempio: ./update-version.sh 0.0.2

set -e

# Controllo che sia stato fornito un parametro
if [ $# -eq 0 ]; then
    echo "Errore: Devi fornire una versione"
    echo "Uso: $0 <nuova_versione>"
    echo "Esempio: $0 0.0.2"
    exit 1
fi

NEW_VERSION=$1

# Verifica che la versione sia nel formato corretto (x.x.x)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Errore: La versione deve essere nel formato x.x.x (es: 0.0.2)"
    exit 1
fi

echo "Aggiornamento alla versione $NEW_VERSION..."

# Verifica che siamo nella directory corretta
if [ ! -f "Cargo.toml" ] || [ ! -f "extension.toml" ]; then
    echo "Errore: Non trovo i file Cargo.toml o extension.toml"
    echo "Assicurati di essere nella directory root del progetto"
    exit 1
fi

# Backup dei file originali
cp Cargo.toml Cargo.toml.backup
cp extension.toml extension.toml.backup

# Aggiorna la versione in Cargo.toml
sed -i.tmp "s/^version = \".*\"/version = \"$NEW_VERSION\"/" Cargo.toml
rm -f Cargo.toml.tmp

# Aggiorna la versione in extension.toml
sed -i.tmp "s/^version = \".*\"/version = \"$NEW_VERSION\"/" extension.toml
rm -f extension.toml.tmp

echo "Versioni aggiornate nei file:"
echo "- Cargo.toml: $(grep '^version = ' Cargo.toml)"
echo "- extension.toml: $(grep '^version = ' extension.toml)"

# Verifica che git sia configurato
if ! git config user.name >/dev/null 2>&1; then
    echo "Errore: Git non è configurato. Configura prima nome e email:"
    echo "git config user.name 'Il Tuo Nome'"
    echo "git config user.email 'tua.email@example.com'"
    exit 1
fi

# Verifica che non ci siano cambiamenti non committati (eccetto i nostri file)
if git diff --name-only | grep -v -E '^(Cargo\.toml|extension\.toml)$' >/dev/null 2>&1; then
    echo "Attenzione: Ci sono cambiamenti non committati in altri file."
    echo "Vuoi continuare comunque? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Operazione annullata"
        # Ripristina i backup
        mv Cargo.toml.backup Cargo.toml
        mv extension.toml.backup extension.toml
        exit 1
    fi
fi

# Rimuovi i backup
rm -f Cargo.toml.backup extension.toml.backup

# Aggiungi i file modificati
git add Cargo.toml extension.toml

# Crea il commit
git commit -m "Bump version to $NEW_VERSION"

# Crea il tag
TAG_NAME="v$NEW_VERSION"
git tag -a "$TAG_NAME" -m "Release $NEW_VERSION"

echo "Commit e tag creati con successo!"
echo "Commit: $(git log --oneline -1)"
echo "Tag: $TAG_NAME"

# Chiedi se fare il push
echo ""
echo "Vuoi fare il push del commit e del tag su GitHub? (y/n)"
echo "Questo attiverà il workflow di release automaticamente."
read -r push_response

if [ "$push_response" = "y" ]; then
    echo "Pushing commit e tag..."
    git push origin main
    git push origin "$TAG_NAME"
    echo ""
    echo "✅ Push completato!"
    echo "Il workflow di release dovrebbe attivarsi automaticamente."
    echo "Controlla su GitHub Actions: https://github.com/FrancoStino/pollinations_mpc/actions"
else
    echo ""
    echo "📝 Commit e tag creati localmente ma non ancora pushati."
    echo "Per fare il push manualmente più tardi:"
    echo "git push origin main"
    echo "git push origin $TAG_NAME"
fi

echo ""
echo "✅ Versione aggiornata con successo da $(git describe --tags --abbrev=0 HEAD^) a $TAG_NAME"
