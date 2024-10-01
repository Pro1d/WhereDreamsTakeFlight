name=where-dreams-take-flight

godot4 --quiet --headless --export-release Web build/web/index.html ../project.godot
rm $name-web.zip 2> /dev/null
zip -j $name-web.zip web/* > /dev/null

butler push $name-web.zip proyd/where-dreams-take-flight:web


godot4 --quiet --headless --export-release Windows build/windows/$name.exe ../project.godot
rm $name"_"windows.zip 2> /dev/null
zip -j $name"_"windows.zip windows/* > /dev/null

butler push $name"_"windows.zip proyd/where-dreams-take-flight:windows


godot4 --quiet --headless --export-release Linux build/linux/$name.x86_64 ../project.godot
rm $name"_"linux.zip 2> /dev/null
zip -j $name"_"linux.zip linux/* > /dev/null

butler push $name"_"linux.zip proyd/where-dreams-take-flight:linux
