mkdir -p tools

# Auto exit on any failed command
set -e

ADD_PATH=''

NODEJS_VER=node-v8.9.4-linux-x64
if [ ! -f tools/$NODEJS_VER/bin/node ]; then
  echo "Installing tools/$NODEJS_VER"
  curl -Ls https://nodejs.org/dist/v8.9.4/$NODEJS_VER.tar.xz | tar -xJC tools
fi
ADD_PATH=$(pwd)/tools/$NODEJS_VER/bin

HAXE_VER=haxe-3.4.7-linux64
if [ ! -f tools/$HAXE_VER/haxe ]; then
  echo "Installing tools/$HAXE_VER"
  curl -Ls https://github.com/HaxeFoundation/haxe/releases/download/3.4.7/haxe-3.4.7-linux64.tar.gz | tar -xzC tools
  # Haxe is compressed with commit hash :P
  mv tools/haxe_201* tools/$HAXE_VER
fi
ADD_PATH=$ADD_PATH:$(pwd)/tools/$HAXE_VER

NEKO_VER=neko-2.2.0-linux64
if [ ! -f tools/$NEKO_VER/neko ]; then
  echo "Installing tools/$NEKO_VER"
  curl -Ls https://github.com/HaxeFoundation/neko/releases/download/v2-2-0/neko-2.2.0-linux64.tar.gz | tar -xzC tools
fi
ADD_PATH=$ADD_PATH:$(pwd)/tools/$NEKO_VER

MONGO_VER=mongodb-linux-x86_64-3.6.3
if [ ! -f tools/$MONGO_VER/bin/mongod ]; then
  echo "Installing tools/$MONGO_VER"
  curl -Ls https://fastdl.mongodb.org/linux/$MONGO_VER.tgz | tar -xzC tools
fi
ADD_PATH=$ADD_PATH:$(pwd)/tools/$MONGO_VER/bin

# Jeff's handy scripts
if [ ! -f tools/watch.rb ]; then
  echo "Installing tools/watch.rb"
  curl -Ls http://onetacoshort.com/temp/watch.rb > tools/watch.rb
  chmod a+x tools/watch.rb
fi

# Jeff's handy ff script
if [ ! -f tools/ff ]; then
  echo "Installing tools/ff"
  curl -Ls http://onetacoshort.com/temp/ff > tools/ff
  chmod a+x tools/ff
fi

# Precompiled https://github.com/sass/libsass + https://github.com/sass/sassc
if [ ! -f tools/sassc ]; then
  echo "Installing tools/sassc"
  curl -Ls http://onetacoshort.com/temp/sassc.gz | gunzip > tools/sassc
  chmod a+x tools/sassc
fi
ADD_PATH=$ADD_PATH:$(pwd)/tools/

ENV_FILE=tools/env.source
echo "Writing $ENV_FILE"
echo "export PATH=$ADD_PATH:\$PATH" > $ENV_FILE
echo "export NEKOPATH=$(pwd)/tools/$NEKO_VER" >> $ENV_FILE
echo "export HAXELIB_PATH=$(pwd)/tools/haxelib" >> $ENV_FILE
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/tools/$NEKO_VER" >> $ENV_FILE
echo "export HAXE_STD_PATH=$(pwd)/tools/$HAXE_VER/std" >> $ENV_FILE
