#!/bin/bash

# Script per aggiornare la versione del progetto Pollinations MCP
# Uso: ./update-version.sh <versione_o_tipo>
# Esempi:
#   ./update-version.sh 0.0.2        # Versione specifica
#   ./update-version.sh patch         # Incrementa patch (0.0.1 -> 0.0.2)
#   ./update-version.sh minor         # Incrementa minor (0.0.1 -> 0.1.0)
#   ./update-version.sh major         # Incrementa major (0.0.1 -> 1.0.0)

set -e

# Controllo che sia stato fornito un parametro
if [ $# -eq 0 ]; then
    echo "Errore: Devi fornire una versione o un tipo di increment"
    echo "Uso: $0 <versione_o_tipo>"
    echo "Esempi:"
    echo "  $0 0.0.2        # Versione specifica"
    echo "  $0 patch         # Incrementa patch (0.0.1 -> 0.0.2)"
    echo "  $0 minor         # Incrementa minor (0.0.1 -> 0.1.0)"
    echo "  $0 major         # Incrementa major (0.0.1 -> 1.0.0)"
    exit 1
fi

VERSION_INPUT=$1

# Funzione per ottenere la versione attuale da Cargo.toml
get_current_version() {
    grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'
}

# Funzione per incrementare la versione
increment_version() {
    local current_version=$1
    local increment_type=$2

    # Estrai le componenti della versione
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)

    case $increment_type in
        "patch")
            patch=$((patch + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            echo "Errore: Tipo di increment non valido: $increment_type"
            exit 1
            ;;
    esac

    echo "$major.$minor.$patch"
}

# Determina la nuova versione
if [[ $VERSION_INPUT =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Versione specifica fornita
    NEW_VERSION=$VERSION_INPUT
elif [[ $VERSION_INPUT =~ ^(patch|minor|major)$ ]]; then
    # Incremento semantico
    CURRENT_VERSION=$(get_current_version)
    if [ -z "$CURRENT_VERSION" ]; then
        echo "Errore: Non riesco a trovare la versione attuale in Cargo.toml"
        exit 1
    fi
    NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$VERSION_INPUT")
    echo "Versione attuale: $CURRENT_VERSION"
    echo "Incremento $VERSION_INPUT -> Nuova versione: $NEW_VERSION"
else
    echo "Errore: Parametro non valido: $VERSION_INPUT"
    echo "Usa una versione nel formato x.x.x oppure patch/minor/major"
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
    echo "Controlla su GitHub Actions: https://github.com/FrancoStino/pollinations_mcp/actions"
else
    echo ""
    echo "📝 Commit e tag creati localmente ma non ancora pushati."
    echo "Per fare il push manualmente più tardi:"
    echo "git push origin main"
    echo "git push origin $TAG_NAME"
fi

echo ""
echo "✅ Versione aggiornata con successo da $(git describe --tags --abbrev=0 HEAD^) a $TAG_NAME"
