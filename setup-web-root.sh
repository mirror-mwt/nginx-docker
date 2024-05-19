#!/bin/sh

# Exit on first error
set -e

# Create a directory to hold the web server files
mkdir -p /srv/www

# Change to the web root directory
cd /srv/www

#####################################################################
# Create all of the directories and simlinks
#####################################################################

# Loop through a list of directories to create
while read -r dir; do
	mkdir -p "$dir"
done <<-EOF
	internal
	rclone
	zoom
	rstudio
	shiftkey-desktop
	termux
	zotero
EOF

# Loop through a list of simlinks to create
# shellcheck disable=SC2086
while read -r link; do
	ln -s $link
done <<-EOF
	/mirror/tex-archive ./ctan
	/mirror/rclone/deb ./rclone/deb
	/mirror/rclone/rpm ./rclone/rpm
	/mirror/zoom/deb ./zoom/deb
	/mirror/zoom/rpm ./zoom/rpm
	/mirror/rstudio/deb ./rstudio/deb
	/mirror/rstudio/rpm ./rstudio/rpm
	/mirror/apt-mirror/mirror/apt.packages.shiftkey.dev/ubuntu ./shiftkey-desktop/deb
	/mirror/dnf-reposync/shiftkey ./shiftkey-desktop/rpm
	/mirror/termux/termux-main ./termux/main
	/mirror/termux/termux-root ./termux/root
	/mirror/termux/termux-x11 ./termux/x11
	/mirror/apt-mirror/mirror/zotero.retorque.re/file/apt-package-archive ./zotero/deb
EOF

#####################################################################
# Install all of the universal installation stubs
#####################################################################

# Define a function that returns the stub for a given package
get_stub() {
	# Header of the stub should generally be the same
	cat <<-'EOF'
		#!/bin/sh
		<!--#set var="repo_base_url" value="https://$host/$inc_foldername" -->
		APP_NAME="<!--# echo var='inc_foldername' -->"
		BASE_URL="<!--# echo var='repo_base_url' -->"
		GPG_KEY="<!--# include file='./gpgkey' -->"
	EOF

	# If the first argument is nonempty, define DEB_REPO
	if [ -n "$1" ]; then
		echo "DEB_REPO=\"$1\""
	fi

	# If the second argument is nonempty, define RPM_REPO
	if [ -n "$2" ]; then
		echo "RPM_REPO=\"$2\""
	fi

	# Footer of the stub should generally be the same
	cat <<-'EOF'
		<!--# include file="/internal/universal-install.sh" -->
	EOF
}

# Generate the stub for rclone
# shellcheck disable=SC2016
get_stub '$BASE_URL/deb any main' '[$APP_NAME]
name=$APP_NAME
baseurl=$BASE_URL/rpm/\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/$APP_NAME.asc' >./rclone/install.sh

# Generate the stub for zoom
# shellcheck disable=SC2016
get_stub '$BASE_URL/deb any main' '[$APP_NAME]
name=$APP_NAME
baseurl=$BASE_URL/rpm/\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/$APP_NAME.asc' >./zoom/install.sh

# Generate the stub for rstudio
# shellcheck disable=SC2016
get_stub '$BASE_URL/deb/jammy jammy main' '[$APP_NAME]
name=$APP_NAME
baseurl=$BASE_URL/rpm/el9/\$basearch
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/$APP_NAME.asc' >./rstudio/install.sh

# Generate the stub for shiftkey-desktop
# shellcheck disable=SC2016
get_stub '$BASE_URL/deb any main' '[$APP_NAME]
name=GitHub Desktop
baseurl=$BASE_URL/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/$APP_NAME.asc' >./shiftkey-desktop/install.sh

# Generate the stub for zotero
# shellcheck disable=SC2016
get_stub '$BASE_URL/deb/ ./' >./zotero/install.sh

#####################################################################
# Create all of the keyfiles
#####################################################################

# Create the keyfiles for my self-signed repositories
tee ./rclone/gpgkey ./zoom/gpgkey ./rstudio/gpgkey >/dev/null <<-'EOF'
	-----BEGIN PGP PUBLIC KEY BLOCK-----

	mQINBGISxKwBEAC+EyYLsKTvF63M+y5YGdSjwo5CWQMaTXMGIXcTuIiWi2qN8um5
	J1eQ8V8EpDPWWBya2/gxfsW21sjIBrTqdWlY7efEqoy0R7Tj/2H05mbfaigOZ0zJ
	6umVDzsHegvWxAwoHX6HjPgk9YhPLrTeE7vsukWczIABJjHCeHT7k3H9fDQgSsfN
	t4mL8vbdtkHhJ0ShhvLFZRjKtZgtoqisJ+DtfR+ga0c4U+x0YYnfBshGi8la2WQO
	ZDtdD3uIbSlj8gKKV+M33RPYkY0fy6b+7c+BoHSLWpxPNiVUSUrKATLmUnjernzM
	SND6sBIiLh7tAlpZxdCmv4k4s2lztVDbQzLOU/N0/46qnMP0eoiyq8zgjng+vFE/
	5g391M1m5jPA0WpQdy6TgVTuDf/6usbOkYfMBYHfcCp+64qc5gEuypvV+eEj8uw2
	XnH8L9Qlrb+jVYdtd9t35vgGlqknzzwWDOMBxF3XlH+/s+y6NZwgLnklTS6swhAL
	lvuwPn9g/9Gb/vzYePp7jawE3Naqpcx7DwLu9U3XiSxO/GNM+5z886e0pmzzjNba
	10g0KVQCESFUoMPY3xzgZXNTanvlnPQoVb5F5dsYgqnAu3i/TN58ZomFp3VwD11N
	xeXJqiQnwMkh24Ynl5jrkB+61REnNxDo3Jo+EB64gZh/2GRUGN4hLy3eAQARAQAB
	tC5NYXR0aGV3IFdpbGRyaWNrIFRob21hcyAocmVwbykgPG1pcnJvckBtd3QubWU+
	iQJOBBMBCgA4FiEEGIZ+I4kzXcYUee2DTfavmLe+WsIFAmISxKwCGwMFCwkIBwIG
	FQoJCAsCBBYCAwECHgECF4AACgkQTfavmLe+WsIw9xAAguHmx+jll8y9OhoVDVLu
	Pls+dQ0aoEjMXl9UTx6Nx9X1l9Z0HTSXvAZc7ouKKfln1sUs0HAZeZC8xtqzdmr8
	yv2tfag9XqsJJIUYRV+JftKW+E3siY5+OWFZfODezMjX2ebnPQgpUNg42lJWQ0vl
	8y1dInl+s9UZGXWA70ZgoKx4iFABp49D4b/Jta5TLyeDCoqbmoIuEchu8IeVaG6c
	0zmkGEO7VzykUKlLl1ghtfTpMByBl6OX9ieKEdv5vdSvuZ/rhzX7FR+EwJE8tWSt
	zsjlXChTlAoywoj9SgeIg4wqssisAMHdbcza8749ZmVYP66notRV+hVdIajsEGG7
	Rwwj46cHN/SDqkNZOYAFcCGpuClVBKjMzAjGleuakr7cElRWHOMcLdd59g0U5znV
	VDKrYx87we5s7JBkGjLEW3mcinbIfJ/MZxhh1FKo5zks8P+oMVyyIx6ZXXgt3xTD
	MTjfo0aGge1LRLl+/SY57k5mGtLF2byXUPEivGCULp0mJ2FPnVUCaRqR2UeO9ScC
	Dy/O9m4CM+O3eDgB9mXlnXHS++TCB2AzZzE1htNO2KyBPAf3f50nWGOInsEf95Dk
	gM28sJrDheTxFyhilzRIGiw/KwaiDKtzwCxIFBmaY/QDa53ZzezAUbnTlvT6iDiP
	64xkC/DBNhnZVB1UL5ClM/a5Ag0EYhLErAEQAKwsbsjyhdnoY7wbxMovexhT0juK
	lHuZFYRsNVe5R3nB6UDNYRQyhdhcY61hZcLgeYHPgxGlYHPxIDxF4HVuB4DdEQXB
	AH2Mfg3m+iu9PQyU28BwUXKe0PGgif9+BulGjA6U3D6jsIg1ndqlEflGmHr4HIjt
	sFpeQKLUxoOa0uiEwibahD/QUErkLH2kcAg+xf9fv6sz6RjBKKQqvmrbIYn/pe7f
	Q7KdHtydUDDYjpfPYofqRA8VBUvMftX0HEnRstPbJOLxi5mx5djbSFVW5w18Zw1D
	2EVLG3w5w4BlGrwjsGL7gcnjcJyzr216V81B21/jmZF7GSwmSX9BuX+XJaXbXkro
	UHFECkQ6w2MsKGHek6YOYfiZaDSxNX8IFbLlkVJc8rs3gSqD6705BF/1zLPcVwg0
	K2YCWkY4N3wLzw6FZ0i2ma42pzHIRFGO0ebPHXJL5Tj+qgbz0KJUEdqOnmVgu2Zj
	dW6g6yTi+1aja4UTGmORbv4GZv/wfaYGgKFiqV04YQy50waMYSMDaI3WaNtpi0UZ
	mv+Jkzw+neBHJj1pbu8LgJtSMmBgj4EWV93f1Wu8wBUFtb2ymAgRNVFU8LYluY0z
	4VCK9VhupDDeB2UbfitBamEwXwzMLq0l2Hh2GU0DO7FAkbt61EBcuPg3cfJGRvcS
	H3InOEarIFxdbo0HABEBAAGJAjYEGAEKACAWIQQYhn4jiTNdxhR57YNN9q+Yt75a
	wgUCYhLErAIbDAAKCRBN9q+Yt75awhDsD/92zbK71SmGau1X0i/clBTL6YJLGx3O
	8aT9FWs2eRPa5FIUh7ooWOxAdbhvlDSFZoTdoPyeIHizYJHZd8g3y/kjZqLkXof1
	aYc+pRG+lajVrc91ocSGzOeLvYTKO/d2d5lfqTxVp/DnzGgIoSz/oIGJ96qseQot
	zbkxhFOKgjyeE8SCEG4urNuDHhdGk2/hoDj2qZkMspsG6nCvCuvhqdNPia5bByLX
	fn4LV6Nz6LuGE7tDXV8kbpLsxe+MS/0qPMPScsGuXXDncr9A5Ij7sfBvE0i6f+3J
	sSJxL0aJI/WeMzPv4J4N3dsy/PTJe/ZNpe2vH3EamJ1DB0dnpCZ1epsrYBgaiGzl
	oUvxF3eDR2Iu/YqXsQG4SixOmkFRL3E7vbSf8mL7rDu20D6a8wPynZyIq3rYiwem
	9LERNeme+4ezJsKWuwYPyeiVxi3xbGd766hffR/v7ol9OvCZ7gsdmkQAmMxkiROv
	AVmJQKJ+fB+LEdOKc1Cjlb5ZKJjx73cv6V3Ny7+he9j2xbFGTk1vrFGjyxiNe35w
	1FxsCEiWUrxgTqxKhld7Eu7VtAmjWYFWNnPkc3IW4hzXogE9lsn7HNlaadJXJdT+
	gQo+UmLTZRwcf4Uy1DsK5VvMaR5WLVtdAOBj/yeXkLMpLxIs32lW85DpYO8vYW9i
	6NgcvtS2QJSTKA==
	=GSyU
	-----END PGP PUBLIC KEY BLOCK-----
EOF

# Create the keyfiles for shiftkey-desktop
tee ./shiftkey-desktop/gpgkey >/dev/null <<-'EOF'
	-----BEGIN PGP PUBLIC KEY BLOCK-----

	mDMEY/JlqBYJKwYBBAHaRw8BAQdAVplbujSODiiIcIxhg+xK7YGyK4nIpY/ZdnqL
	yi8SHVO0LUJyZW5kYW4gRm9yc3RlciA8cGFja2FnZXNAYnJlbmRhbmZvcnN0ZXIu
	Y29tPoiWBBMWCgA+FiEETgKjVqGDFLAKSB8Gf8l5AosZl8EFAmPyZagCGwMFCQlm
	AYAFCwkIBwMFFQoJCAsFFgMCAQACHgECF4AACgkQf8l5AosZl8EbYAEAouvPKHOb
	zmvBIC9ONp3Zu69+Tx8JoKrfKm+zIfuTCXsBAMKEIXP9UyxF191LLU7aOrXVRJ2y
	8uqXsG/vu4BpKy8DuDgEY/JlqBIKKwYBBAGXVQEFAQEHQFbHIiBMgeWt9/3UlhAE
	IZS+aVIRCS73Nr+Io8mDjZUkAwEIB4h+BBgWCgAmFiEETgKjVqGDFLAKSB8Gf8l5
	AosZl8EFAmPyZagCGwwFCQlmAYAACgkQf8l5AosZl8HHogEArWvwl3DRFr9NiPL1
	wv/zC0KaZ2Rg0heEwACmGtg0e9cBAJhm7kV0Cvg7CU4w8sfabNXiXWelOyRnLPR1
	pX8lwGQE
	=Hv1H
	-----END PGP PUBLIC KEY BLOCK-----
EOF

# Create the keyfiles for zotero
tee ./zotero/gpgkey >/dev/null <<-'EOF'
	-----BEGIN PGP PUBLIC KEY BLOCK-----

	mQINBFvK3/gBEACv/NhVuY9Ozwb5/vytXR4fzaJgZB/lmWF0A8mZocYiGHcRoXbT
	6dPs923hjuESdVSIA8YmU7HIgWHml3HwqwOOGp+PiATX1wXeCUjsgWTvFXD5IBMF
	MQxO5jz/XqFimV5z0YjPks8a1bIicFIuDhzH/qsAjaWuTP1b71s4x0glaO8w5cko
	gM8pamyXFLLejY4TkDLjVJF4WJWvuXT+8W3zrKGNn2/MqE/I51pThwLfUZv+zU06
	iOFuLDB8lyaN6vV+kHp6SCxM2hkBgyoxJ3/DDademVVaiTncDt+zazoyljxiMjZP
	qmdu+KoFADvUOyMjdZieN+XK6Xrc4PIp/wcB7f0IgG5r66OTYWe0VtqpQ7e8jfHR
	ETbDqIn/B2PVLsPZ5dgCr7iFmTxC91mdPt1FYHgBIz8QOfJTmmbsmcJZ938EG/RS
	fa46BM7T4rkt55iqz1xwiCpyQO1Fa2A4sbsnRzSOB5n2FID3D6jUKSAi9N3vvhO6
	sAcIqvuHXrvS7o0TrytCRCj5hAU7kqlN+bspCUrpsxJknX8A8UoQW+zifVpxQfcP
	Z2K8UDsNxpt1PhxJTsqp55wYygRXHaNkojCgNHK9GpKCG+HuMKtAeSZslyXGx5BC
	67Yt57mixKmTZ0htDfTa8h90LySTXHwL7gxQ8SLAVY66zm62TkpIe2XxAQARAQAB
	tBtkcGtnIDxkcGtnQGlyaXMtYWR2aWVzLmNvbT6JAk4EEwEIADgWIQRrCKiCKzlb
	ygZ8iKrrm1d6HDSb/AUCW8rf+AIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAK
	CRDrm1d6HDSb/F0zD/0aOtz6z9kvJ/wowZvk1U8JV4VUQ9XzhvGXCJvHhUsx4xpV
	h81hbcTUUWotxYwqmH42wBs/f9T9LN2xLCAw7Bl+4E5LoAg7eDCohG4zbWu8KHlM
	WMa0hv2yHEmjNgo2r3VDg8h0xBuLaPcK2mPLo196XXINRLLL0McKmR4pejRRxmJ2
	8v9fViDfJztl8JywWqkVgIP94j81eCXFivNw2gts6HW77PBHT/MirUXaDBINeSj0
	4YbJCBqz6XV9sUvL0dhUgClwcVrwGZKZv03oTxWncZd3EyJUyvEadyZlDA5g7DVe
	DYymlZT/OUDAJrmzcXZM5ll2wXEIF/dqAHesztujGWtDQ/2XvjSUNfiFWZ48ULnt
	UFucNTCLN4XQcx60GoNt1k17T0FrxdgT9dlW74wxzaJrfog5/AE76VToOTLuqO/4
	oyANETYZZr5+TpAipUo7c+yFbz9FHXx0EF+gbFtvdl57QyFU2UiUL317MVrn39I9
	gQSPrVqzlwpplu/RKqT6Sy6Hq3YMXRuOf/Fke+aXu6rIgC94joFby8/AFQ2blGNF
	lskY7JuBznxYVHqyILCFonpYeba3TVJ5Bf3PJ/Z97JV3my+kq75DI5/gY6NYFApz
	Vh5jXckxwLXbKxzXLDPul5Znuhk+a3765cU52aB9AJUwl4OUjuZW16YQLrFSyQ==
	=Toat
	-----END PGP PUBLIC KEY BLOCK-----
EOF

# Delete this script
rm "/setup-web-root.sh"
