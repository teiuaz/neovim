set(LUV_CMAKE_ARGS
  -D LUA_BUILD_TYPE=System
  -D LUA_COMPAT53_DIR=${DEPS_BUILD_DIR}/src/lua-compat-5.3
  -D WITH_SHARED_LIBUV=ON
  -D BUILD_SHARED_LIBS=OFF
  -D BUILD_STATIC_LIBS=ON
  -D BUILD_MODULE=OFF)

if(USE_BUNDLED_LUAJIT)
  list(APPEND LUV_CMAKE_ARGS -D WITH_LUA_ENGINE=LuaJit)
elseif(USE_BUNDLED_LUA)
  list(APPEND LUV_CMAKE_ARGS -D WITH_LUA_ENGINE=Lua)
else()
  find_package(Luajit)
  if(LUAJIT_FOUND)
    list(APPEND LUV_CMAKE_ARGS -D WITH_LUA_ENGINE=LuaJit)
  else()
    list(APPEND LUV_CMAKE_ARGS -D WITH_LUA_ENGINE=Lua)
  endif()
endif()

if(USE_BUNDLED_LIBUV)
  list(APPEND LUV_CMAKE_ARGS -D CMAKE_PREFIX_PATH=${DEPS_INSTALL_DIR})
endif()

list(APPEND LUV_CMAKE_ARGS "-DCMAKE_C_FLAGS:STRING=${DEPS_INCLUDE_FLAGS}")
if(CMAKE_GENERATOR MATCHES "Unix Makefiles" AND
    (CMAKE_SYSTEM_NAME MATCHES ".*BSD" OR CMAKE_SYSTEM_NAME MATCHES "DragonFly"))
    list(APPEND LUV_CMAKE_ARGS -D CMAKE_MAKE_PROGRAM=gmake)
endif()

ExternalProject_Add(lua-compat-5.3
  URL ${LUA_COMPAT53_URL}
  URL_HASH SHA256=${LUA_COMPAT53_SHA256}
  DOWNLOAD_NO_PROGRESS TRUE
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/lua-compat-5.3
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND "")

ExternalProject_Add(luv-static
  DEPENDS lua-compat-5.3
  URL ${LUV_URL}
  URL_HASH SHA256=${LUV_SHA256}
  DOWNLOAD_NO_PROGRESS TRUE
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/luv
  SOURCE_DIR ${DEPS_BUILD_DIR}/src/luv
  CMAKE_ARGS ${DEPS_CMAKE_ARGS} ${LUV_CMAKE_ARGS}
  CMAKE_CACHE_ARGS ${DEPS_CMAKE_CACHE_ARGS})

if(USE_BUNDLED_LUAJIT)
  add_dependencies(luv-static luajit)
elseif(USE_BUNDLED_LUA)
  add_dependencies(luv-static lua)
endif()
if(USE_BUNDLED_LIBUV)
  add_dependencies(luv-static libuv)
endif()
