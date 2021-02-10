FROM intel/oneapi-basekit:devel-ubuntu18.04 as bootstrap

ARG  DEBIAN_FRONTEND=noninteractive
ARG  DEBCONF_NONINTERACTIVE_SEEN=true

ARG  TZ=Etc/UTC
ENV  TZ $TZ
ARG  LANG=C.UTF-8
ENV  LANG $LANG
ARG  LC_ALL=C.UTF-8
ENV  LC_ALL $LC_ALL

ARG EXT=tgz

COPY       ./stage-0/           /tmp/stage-0
COPY       ./stage-1/           /tmp/stage-1
COPY       ./stage-2            /tmp/stage-2
COPY       ./stage-3            /tmp/stage-3
COPY       ./stage-4            /tmp/stage-4
 #&& apt install tor deb.torproject.org-keyring    \
RUN ( cd                        /tmp/stage-0      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-0      \
 && chmod -v 1777               /tmp              \
 && apt-key add < /tmp/key.asc                    \
 && rm    -v      /tmp/key.asc                    \
 && apt update && apt install apt-transport-https \
 && apt update                                    \
 && apt install tor \
 \
 && ( cd                        /tmp/stage-1      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-1      \
 && chmod -v 1777               /tmp              \
 \
 && ( cd                        /tmp/stage-2      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-2      \
 && chmod -v 1777               /tmp              \
 && sed -i 's@^ORPort@#&@'      /etc/tor/torrc    \
 && echo 'SOCKSPolicy accept 127.0.0.1' >> /etc/tor/torrc \
 && echo 'SOCKSPolicy reject *'         >> /etc/tor/torrc \
 && tor --verify-config

SHELL ["/bin/bash", "-l", "-c"]
      #intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \
      #intel-oneapi-dev-utilities \
RUN sleep 127           \
 && apt update          \
 && apt install -y      \
      autoconf          \
      automake          \
      binutils-dev      \
      build-essential   \
      clang             \
      git               \
      intel-oneapi-dpcpp-cpp-compiler \
      libgmp-dev        \
      libisl-dev        \
      libmpc-dev        \
      libmpfr-dev       \
      libtool           \
      llvm              \
      m4                \
      pbzip2            \
      pigz              \
      pixz              \
      polygen           \
      wget              \
 && update-alternatives --force --install          \
      $(command -v gzip   || echo /usr/bin/gzip)   \
      gzip   $(command -v pigz)   200              \
 && update-alternatives --force --install          \
      $(command -v gunzip || echo /usr/bin/gunzip) \
      gunzip $(command -v unpigz) 200              \
 && update-alternatives --force --install          \
      $(command -v bzip2  || echo /usr/bin/bzip2)  \
      bzip2  $(command -v pbzip2) 200              \
 && update-alternatives --force --install          \
      $(command -v xz     || echo /usr/bin/xz)     \
      xz     $(command -v pixz)   200              \
 && apt full-upgrade
# && clean.sh


##COPY          ./stage-3.$EXT    /tmp/
#RUN ( cd                        /tmp/stage-3       \
# &&   tar pcf - .                                 ) \
#  | tar pxf - -C /                                  \
# && rm -rf                      /tmp/stage-3       \
# && chmod -v 1777               /tmp               \
# && apt update                                     \
# && [ -x            /tmp/dpkg.list ]               \
# && apt install   $(/tmp/dpkg.list)                \
# && cd /usr/local/bin                              \
# && shc -rUf     support-wrapper                   \
# && rm    -v     support-wrapper.x.c            \
# && chmod -v 0555 support-wrapper.x                \
# && apt-mark auto $(/tmp/dpkg.list)                \
# && rm -v           /tmp/dpkg.list
## && clean.sh
# #&& rm    -v     support-wrapper{,.x.c}            \
#
##FROM base as base-1
## TODO
##COPY --from=support /usr/local/bin/support-wrapper.x \
##                    /usr/local/bin/support-wrapper
##COPY --from=support /usr/local/bin/support-wrapper \
##                    /usr/local/bin/support-wrapper
##SHELL ["/bin/bash", "-c"]
#
##FROM base-1 as lfs-bare
##ARG EXT=tgz
ARG LFS=/mnt/lfs
ENV LFS=$LFS

#ARG TEST=
#SHELL ["/bin/bash", "-l", "-c"]
#COPY          ./stage-4.$EXT    /tmp/
#RUN ( cd                        /tmp/stage-4       \
# &&   tar pcf - .                                 ) \
#  | tar pxf - -C /                                  \
# && rm -rf                      /tmp/stage-4       \
# && chmod -v 1777               /tmp                \
# && apt update                                      \
# && [ -x           /tmp/dpkg.list ]                 \
# && apt install  $(tail -n +2 /tmp/dpkg.list)                  \
# && rm    -v       /tmp/dpkg.list                  \
#RUN clean.sh                                       \
RUN mkdir -vp         $LFS/sources                  \
 && chmod -v a+wt     $LFS/sources                  \
 && groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -G debian-tor -m -k /dev/null lfs \
 && chown -v  lfs:lfs $LFS/sources                  \
 && chown -vR lfs:lfs /home/lfs
 #&& clean.sh \
 #&& exec true || exec false
 #&& chown  -R lfs:lfs /var/lib/tor

#RUN exit 2
#FROM lfs-bare as test
#USER lfs
#RUN sleep 31 \
# && tsocks wget -O- https://3g2upl4pq6kufc4m.onion
#
#FROM lfs-bare as final

#FROM lfs-bare as squash-tmp
#USER root
#RUN  squash.sh
#FROM scratch as squash
#ADD --from=squash-tmp /tmp/final.tar /

#FROM scratch as squash
#COPY --from=lfs-bare / /
#
#FROM squash as test
#USER lfs
#RUN tor --verify-config
#USER root
#RUN apt update
#RUN apt full-upgrade
#
#FROM squash as final

