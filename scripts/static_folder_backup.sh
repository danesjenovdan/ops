#!/bin/bash
set -euo pipefail

if [ -z "$SOURCE_BASE_DIR" ]; then
  echo "Napaka: SOURCE_BASE_DIR ni nastavljen (npr. /var/www/html)."
  exit 1
fi

if [ -z "$SUB_DIRS_TO_BACKUP" ]; then
  echo "Napaka: SUB_DIRS_TO_BACKUP ni nastavljen (npr. media,logs,config)."
  exit 1
fi

if [ -z "$PROJECT" ]; then
  echo "Napaka: PROJECT ni nastavljen."
  exit 1
fi

if [ -z "$AGE_RECIPIENT" ]; then
  echo "Napaka: AGE_RECIPIENT ni nastavljen. Potrebna je za šifriranje."
  exit 1
fi

if [ -z "$PROJECT" ]; then
  echo "Napaka: PROJECT ni nastavljen. Potrebna je za šifriranje."
  exit 1
fi

if [ -z "$AGE_RECIPIENT" ]; then
  echo "Napaka: AGE_RECIPIENT ni nastavljen. Potrebna je za šifriranje."
  exit 1
fi

if  [ -z "$S3_BACKUP_PATH" ]; then
  echo "Napaka: S3_BACKUP_PATH ni nastavljen. Potrebna je za nalaganje na S3."
  exit 1
fi

if [ -z "$S3_ENDPOINT_URL" ]; then
  echo "Napaka: S3_ENDPOINT_URL ni nastavljen. Potrebna je za nalaganje na S3."
  exit 1
fi

if [ -z "$S3_REGION" ]; then
  echo "Napaka: S3_REGION ni nastavljen. Potrebna je za nalaganje na S3."
  exit 1
fi

# Privzeta pot za začasne varnostne kopije
BACKUP_DIR="${BACKUP_DIR:-/tmp/backups}"

# Ustvari backup imenik, če ne obstaja
mkdir -p "$BACKUP_DIR"

# Določi imena datotek
TIMESTAMP=$(date +%Y-%m-%d) # Uporabimo samo datum za enostavnost
ARCHIVE_BASE_NAME="${PROJECT}_STATIC_${TIMESTAMP}"
ARCHIVE_UNENCRYPTED_PATH="${BACKUP_DIR}/${ARCHIVE_BASE_NAME}.tar.bz2"
ARCHIVE_ENCRYPTED_PATH="${BACKUP_DIR}/${ARCHIVE_BASE_NAME}.tar.bz2.age"
ARCHIVE_LATEST_PATH="${BACKUP_DIR}/${PROJECT}_STATIC_latest.tar.bz2.age" # Pot za 'latest' kopijo

# --- Ustvarjanje README datoteke ---
# Pot do README datoteke
README_FILE="${BACKUP_DIR}/README_${ARCHIVE_BASE_NAME}.txt" 

echo "Ustvarjam README datoteko: $README_FILE"
cat << EOF > "$README_FILE"
# Datoteka varnostne kopije
-------------------------

**Projekt:** $PROJECT
**Tip varnostne kopije:** Statične datoteke
**Datum ustvarjanja:** $(date +"%Y-%m-%d %H:%M:%S %Z")
**Osnovni imenik varnostne kopije (znotraj arhiva):**
  - / (oz. koren volumna, iz katerega so bile kopirane podmape)

**Varnostno kopirane podmape (relativno na '$SOURCE_BASE_DIR'):**
  $(echo "$SUB_DIRS_TO_BACKUP" | tr ',' '\n' | sed 's/^/  - /')


-------------------------
**Vsebina arhiva:**
Arhiv vsebuje zgoraj navedene podmape, spakirane relativno na osnovni imenik '$SOURCE_BASE_DIR'.
To pomeni, da so podmape, kot je 'docroot/media', shranjene kot 'docroot/media/' znotraj arhiva,
ne celotne absolutne poti.

**Primer dostopa do datoteke po razpakiranju:**
Če razpakirate arhiv v imenik '/restore_data', boste vsebino mape 'docroot/media' našli na '/restore_data/docroot/media'.
EOF

echo "Arhiviranje podmap iz '$SOURCE_BASE_DIR'..."

# --- Arhiviranje map z tar ---
# Pretvorimo vejice v presledke za tar ukaz
IFS=',' read -r -a DIRS_ARRAY <<< "$SUB_DIRS_TO_BACKUP"

TAR_INCLUDE_PATHS=()
for dir in "${DIRS_ARRAY[@]}"; do
    # Dodamo pot do vsake podmape glede na SOURCE_BASE_DIR
    TAR_INCLUDE_PATHS+=("./$dir")
done

# Uporabimo -C za spremembo imenika in nato navedemo relativne poti do map
# Dodamo še README datoteko v arhiv
tar -cjf "$ARCHIVE_UNENCRYPTED_PATH" -C "$SOURCE_BASE_DIR" "${TAR_INCLUDE_PATHS[@]}" -C "$BACKUP_DIR" "$(basename "$README_FILE")"

if [ $? -ne 0 ]; then
  echo "Napaka pri ustvarjanju nešifrirane varnostne kopije."
  # Očistimo README, če je prišlo do napake pri arhiviranju
  rm -f "$README_FILE"
  exit 1
fi
echo "Nešifrirana varnostna kopija uspešno ustvarjena: $ARCHIVE_UNENCRYPTED_PATH"

rm -f "$README_FILE"

# --- Šifriranje arhiva z age ---
age -r "$AGE_RECIPIENT" "$ARCHIVE_UNENCRYPTED_PATH" > "$ARCHIVE_ENCRYPTED_PATH"

if [ $? -ne 0 ]; then
  echo "Napaka pri šifriranju arhivske datoteke."
  exit 1
fi
echo "Arhivska datoteka uspešno šifrirana: $ARCHIVE_ENCRYPTED_PATH"

rm "$ARCHIVE_UNENCRYPTED_PATH"

# --- Nalaganje na S3 ---

# AWS CLI samodejno prebere AWS_ACCESS_KEY_ID in AWS_SECRET_ACCESS_KEY iz okolja,
# zato ukaz 'aws configure' ni potreben. Preverimo pa, ali sta nastavljeni.
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Opozorilo: Okoljski spremenljivki AWS_ACCESS_KEY_ID in/ali AWS_SECRET_ACCESS_KEY nista nastavljeni."
  echo "Preverite, ali je IAM Role for Service Account pravilno konfiguriran ali nastavite spremenljivki."
fi

# Prvo nalaganje: Arhiv z časovnim žigom
echo "Nalaganje šifrirane varnostne kopije '$ARCHIVE_ENCRYPTED_PATH' na S3 pot '$S3_BACKUP_PATH'..."
aws s3 cp "$ARCHIVE_ENCRYPTED_PATH" "$S3_BACKUP_PATH/$ARCHIVE_BASE_NAME.tar.bz2.age" \
    --endpoint-url="$S3_ENDPOINT_URL" \
    --region="$S3_REGION" \
    --checksum-algorithm=CRC32

if [ $? -ne 0 ]; then
  echo "Napaka pri nalaganju arhivske datoteke z časovnim žigom na S3."
  exit 1
fi
echo "Šifrirana varnostna kopija z časovnim žigom uspešno naložena na S3."

# Drugo nalaganje: "latest" kopija
echo "Ustvarjanje in nalaganje 'latest' kopije '$ARCHIVE_ENCRYPTED_PATH' na S3..."
# Kopiramo šifrirano datoteko v 'latest' datoteko v isti lokalni mapi
cp "$ARCHIVE_ENCRYPTED_PATH" "$ARCHIVE_LATEST_PATH"

# Naložemo 'latest' kopijo na S3
aws s3 cp "$ARCHIVE_LATEST_PATH" "$S3_BACKUP_PATH/${PROJECT}_STATIC_latest.tar.bz2.age" \
    --endpoint-url="$S3_ENDPOINT_URL" \
    --region="$S3_REGION" \
    --checksum-algorithm=CRC32

if [ $? -ne 0 ]; then
  echo "Napaka pri nalaganju 'latest' kopije na S3."
  exit 1
fi
echo "'Latest' kopija uspešno naložena na S3."
