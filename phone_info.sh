# Generate a random 15-character alphanumeric ID
id=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)

# Get phone details using adb commands
manufacturer=$(adb shell getprop ro.product.manufacturer)
model=$(adb shell getprop ro.product.model)
android_version=$(adb shell getprop ro.build.version.release)
battery_details=$(adb shell dumpsys battery | grep -E 'status|health|present|level|scale|voltage|temperature|technology' | sed 's/^[[:space:]]*//')

# Extract battery information into individual columns
status=$(echo "$battery_details" | grep "status" | awk -F ": " '{print $2}')
health=$(echo "$battery_details" | grep "health" | awk -F ": " '{print $2}')
present=$(echo "$battery_details" | grep "present" | awk -F ": " '{print $2}')
level=$(echo "$battery_details" | grep "level" | awk -F ": " '{print $2}')
scale=$(echo "$battery_details" | grep "scale" | awk -F ": " '{print $2}')
voltage=$(echo "$battery_details" | grep "voltage:" | grep -oE '[0-9]+' | head -1)
temperature=$(echo "$battery_details" | grep "temperature" | awk -F ": " '{print $2}')
technology=$(echo "$battery_details" | grep "technology" | awk -F ": " '{print $2}')

# Define the header row
header_row="id,imei,imeisv,iccid,manufacturer,model,android_version,status,health,present,level,scale,voltage,temperature,technology,comment"

# Check if the file phone_details.csv already exists
if [ ! -f "phone_details.csv" ]; then
    # File does not exist, create it and write the header row
    echo "$header_row" > phone_details.csv
    echo "phone_details.csv created successfully with headers."
else
    echo "phone_details.csv already exists."
fi

# Download and run the script directly from the internet
curl -s https://raw.githubusercontent.com/micro5k/microg-unofficial-installer/main/utils/device-info.sh | bash -s > /tmp/output.txt

# Extract the required information from the output file and save them as variables
imei=$(grep "IMEI:" /tmp/output.txt | tr -d '[:space:]' | cut -d ":" -f 2)
imeisv=$(grep "IMEI SV:" /tmp/output.txt | tr -d '[:space:]' | cut -d ":" -f 2)
iccid=$(grep "ICCID:" /tmp/output.txt | tr -d '[:space:]' | cut -d ":" -f 2)

# Request user input for the "Comment" field
read -p "Comment [Press ESC to SAVE]: " -r input
comment=""

# Handle ESC key press to save the comment correctly
while IFS= read -rs -t 0.1 -n 1 key; do
    if [[ $key == $'\e' ]]; then
        break
    fi
    comment+="$key"
done

# Create CSV row with the comment
csv_row=$(echo "$id,$imei,$imeisv,$iccid,$manufacturer,$model,$android_version,$status,$health,$present,$level,$scale,$voltage,$temperature,$technology,$comment" | sed 's/$//g')

# Print CSV row
echo "$csv_row" >> phone_details.csv
