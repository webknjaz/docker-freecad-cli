FROM izone/freecad:nvidia
MAINTAINER Leonardo Loures <luvres@hotmail.com>

#RUN apt update \
#    && apt install -y --no-install-recommends software-properties-common \    
#    && add-apt-repository -y ppa:freecad-maintainers/freecad-daily

# pivy is a binding for Coin3D
# Coin3D is used for displaying 3D models
# So it should be safe to remove it
# Ref: https://www.freecadweb.org/wiki/Scenegraph

# pyside is used for GUI, and since we build CLI only it's not needed:
# - libpyside-dev
# - pyside-tools
# - python-pyside
# - python3-pyside

# pivy build depends on:
# - swig3.0
# - libcoin80
# - libcoin80-dev
# - libsoqt4-dev
# - libsimage-dev
# - libshiboken-dev
# - python3-pyside
# - python-pyside
# So it should be safe to remove them as well
# Ref: https://github.com/FreeCAD/pivy/blob/master/.travis.yml#L9-L19
# Also rm:
# - python-pivy
# - python3-pivy

##############################################################################
# Unsure:
# - python-matplotlib
# - python-dev
# - python

RUN apt-get update

RUN \
    pack_build="git \
                build-essential \
                cmake \
                libtool \
                libxerces-c-dev \
                libboost-dev \
                libboost-filesystem-dev \
                libboost-regex-dev \
                libboost-program-options-dev \
                libboost-signals-dev \
                libboost-thread-dev \
                libboost-python-dev \
                libqt4-dev \
                libqt4-opengl-dev \
                qt4-dev-tools \
                liboce-modeling-dev \
                liboce-visualization-dev \
                liboce-foundation-dev \
                liboce-ocaf-lite-dev \
                liboce-ocaf-dev \
                oce-draw \
                libeigen3-dev \
                libqtwebkit-dev \
                libode-dev \
                libzipios++-dev \
                libfreetype6 \
                libfreetype6-dev \
                netgen-headers \
                libmedc-dev \
                libvtk6-dev \
                libproj-dev " \
#    && apt-get update \
    && apt install -y \
                $pack_build \
                gmsh

RUN \
  # get FreeCAD Git
    cd \
    && git clone https://github.com/FreeCAD/FreeCAD.git \
    && mkdir freecad-build

RUN apt update \
    && apt install -y --no-install-recommends software-properties-common \    
    && add-apt-repository -y ppa:jonathonf/python-3.6 \

  # Install

    && pack_build=" \
                python3.6 \
                python3.6-dev \
    " \
    && apt-get update \
    && apt install -y \
                $pack_build

RUN \
  # Uninstall

    pack_remove=" \
                python-dev \
    " \
    && apt remove -y \
                $pack_remove
                #python \
                # \
    #&& apt autoremove -y

ENV PYTHON_EXECUTABLE=/usr/bin/python3.6m
ENV PYTHON_INCLUDE_DIR=/usr/include/python3.6m
ENV PYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
ENV PYTHON_BASENAME=.cpython-36m
ENV PYTHON_SUFFIX=.cpython-36m
RUN cd ~/freecad-build \
  # Build
    && export PYTHON_EXECUTABLE=/usr/bin/python3.6m \
    && export PYTHON_INCLUDE_DIR=/usr/include/python3.6m \
    && export PYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
    && export PYTHON_BASENAME=.cpython-36m \
    && export PYTHON_SUFFIX=.cpython-36m \
    && cmake \
        -DBUILD_GUI=OFF \
        -DBUILD_QT5=OFF \
        -DPYTHON_EXECUTABLE=/usr/bin/python3.6m \
        -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
        -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
        -DPYTHON_BASENAME=.cpython-36m \
        -DPYTHON_SUFFIX=.cpython-36m \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_FEM_NETGEN=ON ../FreeCAD \
  \
    && make -j$(nproc) \
    && make install \
    && cd \
              \
              # Clean
#                 && rm FreeCAD/ freecad-build/ -fR \
                && ln -s /usr/local/bin/FreeCAD /usr/bin/freecad-git

# # Calculix
# ENV CCX_VERSION=2.12
# RUN apt-get install -y gfortran xorg-dev wget cpio \
#     && cd \
#     && git clone https://github.com/luvres/graphics.git \
#     && cd graphics/calculix-$CCX_VERSION/ \
#     && ./install \
#     && cp $HOME/CalculiX-$CCX_VERSION/bin/ccx_$CCX_VERSION /usr/bin/ccx \
#     && cp $HOME/CalculiX-$CCX_VERSION/bin/cgx /usr/bin/cgx \
#     && cd && rm CalculiX-$CCX_VERSION graphics -fR

# # Clean
# RUN apt-get clean \
#     && rm /var/lib/apt/lists/* \
#           /usr/share/doc/* \
#           /usr/share/locale/* \
#           /usr/share/man/* \
#           /usr/share/info/* -fR    
