if ! gem spec xcodeproj > /dev/null 2>&1; then
	echo "Gem xcodeproj is not installed."
	echo "Please login as administrator."
	read -p 'Administrator username: ' admin
	su $admin -c "sudo gem install xcodeproj"
fi

swift package generate-xcodeproj
ruby xcodeproj/firefly.rb
