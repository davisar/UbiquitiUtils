if [ "$EUID" -ne 0 ]
    then echo "Please Run as root or use sudo."
    exit
fi

if openvpn --version | grep -q "OpenVPN 2.4.12";
    then echo "OpenVPN is already on version 2.4.12"
    exit
fi

source="deb http://archive.debian.org/debian/ wheezy main non-free contrib"
sourcesFile="/etc/apt/sources.list"
cwd=$(pwd)
outputTagColor="3"
outputTagContent="#####"
outputTag="$(tput setaf 6)${outputTagContent}$(tput setaf 7)"

echo "$outputTag Current OpenVPN Version:"
openvpn --version

echo "$outputTag Checking if the debian repository already exists in /etc/apt/sources.list ..."
echo "$outputTag Looking for '$source'"
if grep -q "$source" "$sourcesFile"; then
    echo "$outputTag Source already added to the list."
else
    echo "$outputTag Adding source to the repository list..."
    echo $source >> $sourcesFile
fi

# Next we define the set of things that we need to install using apt-get

echo "$outputTag Gathering required binaries in order to compile OpenVPN 2.4.12"

aptGetCmds=("apt-get update"
"apt-get install wget -y"
"apt-get install apt-utils -y"
"apt-get install libssl-doc -y"
"apt-get install libc6/wheezy -y"
"apt-get install libc6-dev/wheezy -y"
"apt-get install libc-dev-bin/wheezy -y"
"apt-get install libc-bin/wheezy -y"
"apt-get install locales/wheezy -y"
"apt-get install sudo/wheezy -y"
"apt-get install build-essential -y"
"apt-get install aptitude -y")

for i in ${!aptGetCmds[@]}; do
    echo "$outputTag Running '${aptGetCmds[$i]}'"
    eval ${aptGetCmds[$i]}
done

echo "$outputTag Apt-get Commands Complete"

# The printf statements automate the prompt responses.
aptitudeCmds=(
    # Automate responses: no (reject proposed solution), 2 (option 2 - install bin86), remaining prompts "Yes"
    "printf '%s\n' n 2 Y Y |aptitude install libssl-dev"
    "aptitude install liblzo2-dev -y"
    "aptitude install libpam0g-dev -y"
    "aptitude install libtool -y")

echo "$outputTag Running aptitude installation tasks"

for i in ${!aptitudeCmds[@]}; do
    echo "$outputTag Running '${aptitudeCmds[$i]}'"
    eval ${aptitudeCmds[$i]}
done

cd /tmp

echo "$outputTag Getting OpenVPN 2.4.12 from openvpn.org..."
wget https://swupdate.openvpn.org/community/releases/openvpn-2.4.12.tar.gz

echo "$outputTag Extracting OpenVPN 2.4.1 tarball..."
tar -xzf openvpn-2.4.12.tar.gz

cd openvpn-2.4.12/

echo "$outputTag Configuring OpenVPN options..."
./configure --prefix=/usr

echo "$outputTag Make..."
make

echo "$outputTag Make install..."
make install

echo "$outputTag Dumping new openvpn version:"
openvpn --version

cd $cwd