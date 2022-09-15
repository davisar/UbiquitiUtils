if [ "$EUID" -ne 0 ]
    then echo "Please Run as root or use sudo."
    exit
fi

if openvpn --version | grep -q "OpenVPN 2.5.5";
    then echo "OpenVPN is already on version 2.5.5"
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

echo "$outputTag Gathering required binaries in order to compile OpenVPN 2.5.5"

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
"apt-get install liblzo2-dev -y"
"apt-get install libpam0g-dev -y"
)

for i in ${!aptGetCmds[@]}; do
    echo "$outputTag Running '${aptGetCmds[$i]}'"
    eval ${aptGetCmds[$i]}
done

echo "$outputTag Apt-get Commands Complete"

cd /tmp

echo "$outputTag ########################################"

echo "$outputTag Getting libssl 1.1.1m from openssl.org..."
wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz

echo "$outputTag Extracting libssl 1.1.1m tarball..."
tar -xzf openssl-1.1.1m.tar.gz
cd openssl-1.1.1m/

echo "$outputTag Configuring libssl options..."
./Configure --prefix=/usr linux-mips32

echo "$outputTag Make..."
make

echo "$outputTag Make test..."
make test

# TODO: Should check make output and fail install if tests fails. There probably is some return code to check.

echo "$outputTag Make install..."
make install

echo "$outputTag ########################################"

echo "$outputTag Getting OpenVPN 2.5.5 from openvpn.org..."
wget https://swupdate.openvpn.org/community/releases/openvpn-2.5.5.tar.gz

echo "$outputTag Extracting OpenVPN 2.5.5 tarball..."
tar -xzf openvpn-2.5.5.tar.gz

cd openvpn-2.5.5/

echo "$outputTag Configuring OpenVPN options..."
./configure --prefix=/usr --disable-plugins

echo "$outputTag Make..."
make

echo "$outputTag Make install..."
make install

echo "$outputTag Dumping new openvpn version:"
openvpn --version

cd $cwd
