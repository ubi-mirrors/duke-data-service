# Functions for checking data integrity

# Verbose output goes to file descriptor 7,
# which is directed to /dev/null by default
2>&- >&7 || exec 7>/dev/null

chunk_md5sum() {
  offset=$1
  chunk_size=$2
  input_file=$3
  echo "chunk_md5sum '${offset}' '${chunk_size}' '${input_file}'" >&7
  dd skip=${offset} count=${chunk_size} if=${input_file} of=/dev/stdout bs=1 status=none | md5sum | cut -f1 -d' '
}

test_chunks_table() {
  upload=$1
  file_location=$2
  echo '### Test chunks'
  echo
  echo "Chunk #	| Size  | Expected MD5                     | Actual MD5"
  echo "-------	| ----- | ------------                     | ----------"
  offset=0
  for chunk in $(echo "${upload}" | jq --compact-output '.chunks | sort_by(.number)[]'); do
    chunk_number=$(echo "${chunk}" | jq -r '.number')
    chunk_size=$(echo "${chunk}" | jq -r '.size')
    expected_md5=$(echo "${chunk}" | jq -r '.hash.value')
    actual_md5=$(chunk_md5sum ${offset} ${chunk_size} ${file_location})
    echo "${chunk_number}	| ${chunk_size}	| ${expected_md5} | ${actual_md5}"
    offset=$((offset + chunk_size))
  done
  echo
}

test_file_table() {
  upload=$1
  file_location=$2
  expected_file_size=$(echo "${upload}" | jq -r '.size')
  expected_file_md5=$(echo "${upload}" | jq -r '.hashes[0].value')
  downloaded_file_size=`wc -c ${file_location} | cut -f1 -d' '`
  downloaded_file_md5=`md5sum ${file_location} | cut -f1 -d' '`

  echo '### Test total file'
  echo
  echo ".        | Size	| MD5"
  echo "-------- | ----	| ---"
  echo "Expected | ${expected_file_size}	| ${expected_file_md5}"
  echo "Actual   | ${downloaded_file_size}	| ${downloaded_file_md5}"
  echo
}

show_test_results() {
  upload=$1
  file_location=$2
  echo '## Results'
  echo '### Upload status'
  echo '```'
  echo "${upload}" | jq '.status'
  echo '```'
  test_chunks_table "${upload}" "${file_location}"
  test_file_table "${upload}" "${file_location}"
  echo "### Contents of downloaded file"
  echo '```'
  cat "${file_location}"
  echo '```'
}
