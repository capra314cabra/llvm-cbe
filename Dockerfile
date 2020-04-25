FROM alpine

RUN \
  set -e; \
  apk update; \
  apk upgrade; \
  apk add --no-cache \
    curl \
    clang \
    ninja \
    cmake \
    build-base \
    llvm-static \
    llvm-dev \
    clang-static \
    clang-dev \
    python; \
  rm -rf /var/cache/apk/*;

WORKDIR /root

RUN \
  curl -fL http://releases.llvm.org/8.0.0/llvm-8.0.0.src.tar.xz \
    | tar xJf -; \
  mv /root/llvm-8.0.0.src /root/llvm; \
  mkdir -p /root/llvm/build;

COPY . /root/llvm/projects/llvm-cbe/

WORKDIR /root/llvm/build

RUN \
  cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..; \
  ninja llvm-cbe; \
  ninja lli; \
  ninja CBEUnitTests; \
  /root/llvm/build/projects/llvm-cbe/unittests/CWriterTest; \
  ln -s /root/llvm/build/bin/llvm-cbe /bin/llvm-cbe;

WORKDIR /root

RUN \
  rm -rf `ls | grep -v 'build'`; \
  cd /root/llvm/build; \
  rm -rf `ls | grep -v -E '(bin|lib|tool)'`;
