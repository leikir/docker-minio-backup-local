#! /bin/sh

set -e

if [ "${MINIO_BUCKET}" = "**None**" ]; then
  echo "You need to set the MINIO_BUCKET environment variable."
  exit 1
fi

if [ "${MINIO_DIR}" = "**None**" ]; then
  echo "You need to set the MINIO_DIR environment variable."
  exit 1
fi

KEEP_DAYS=$BACKUP_KEEP_DAYS
KEEP_WEEKS=`expr $((($BACKUP_KEEP_WEEKS * 7) + 1))`
KEEP_MONTHS=`expr $((($BACKUP_KEEP_MONTHS * 31) + 1))`

# Initialize dirs
mkdir -p "$BACKUP_DIR/daily/" "$BACKUP_DIR/weekly/" "$BACKUP_DIR/monthly/"

# Loop all buckets
for BUCKET in $(echo $MINIO_BUCKET | tr , " "); do
  # Initialize filename vars
  DFILE="$BACKUP_DIR/daily/$BUCKET-`date +%Y%m%d-%H%M%S`.tgz"
  WFILE="$BACKUP_DIR/weekly/$BUCKET-`date +%G%V`.tgz"
  MFILE="$BACKUP_DIR/monthly/$BUCKET-`date +%Y%m`.tgz"

  # Create dump
  echo "Creating dump of ${BUCKET} bucket..."
  cd "$MINIO_DIR"
  tar -cvzf "$DFILE" $BUCKET
  cd -

  # Copy (hardlink) for each entry
  ln -vf "$DFILE" "$WFILE"
  ln -vf "$DFILE" "$MFILE"

  # Clean old files
  find "$BACKUP_DIR/daily" -maxdepth 1 -mtime +$KEEP_DAYS -name "$BUCKET-*.tgz" -exec rm -rf '{}' ';'
  find "$BACKUP_DIR/weekly" -maxdepth 1 -mtime +$KEEP_WEEKS -name "$BUCKET-*.tgz" -exec rm -rf '{}' ';'
  find "$BACKUP_DIR/monthly" -maxdepth 1 -mtime +$KEEP_MONTHS -name "$BUCKET-*.tgz" -exec rm -rf '{}' ';'
done

echo "Minio backup created successfully"
