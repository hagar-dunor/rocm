# Copyright
#

EAPI=7

inherit cmake-utils flag-o-matic

DESCRIPTION=""
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocFFT"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocFFT/archive/rocm-$(ver_cut 1-2).tar.gz -> rocFFT-${PV}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE="+gfx803 gfx900 gfx906"
REQUIRED_USE="^^ ( gfx803 gfx900 gfx906 )"

RDEPEND="=sys-devel/hip-$(ver_cut 1-2)*"
DEPEND="${RDEPEND}
	dev-util/cmake"

S="${WORKDIR}/rocFFT-rocm-$(ver_cut 1-2)"

src_prepare() {
	cd ${S}

	eapply "${FILESDIR}/rocFFT-library_src_CMakeListstxt.patch"
	eapply "${FILESDIR}/rocFFT-library_src_device_CMakeListstxt.patch"

	sed -e "s: PREFIX rocfft:# PREFIX rocfft:" -i ${S}/library/src/CMakeLists.txt
	sed -e "s:rocm_install_symlink_subdir( rocfft ):#rocm_install_symlink_subdir( rocfft ):" -i ${S}/library/src/CMakeLists.txt
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/rocFFT:" -i ${S}/library/src/CMakeLists.txt

	sed -e "s: PREFIX rocfft:# PREFIX rocfft:" -i ${S}/library/src/device/CMakeLists.txt
	sed -e "s:rocm_install_symlink_subdir( rocfft ):#rocm_install_symlink_subdir( rocfft ):" -i ${S}/library/src/device/CMakeLists.txt

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	# if the ISA is not set previous to the autodetection,
	# /opt/rocm/bin/rocm_agent_enumerator is executed,
	# this leads to a sandbox violation
	if use gfx803; then
		CurrentISA="gfx803"
	fi
	if use gfx900; then
		CurrentISA="gfx900"
	fi
	if use gfx906; then
		CurrentISA="gfx906"
	fi
	strip-flags

	export HCC_ROOT=/usr/lib/hcc/$(ver_cut 1-2)
	export CXX=${HCC_ROOT}/bin/hcc
	export PATH=$PATH:${HCC_ROOT}/bin
	export hcc_DIR=${HCC_ROOT}/lib/cmake/

	local mycmakeargs=(
		-Wno-dev
		-DHIP_PLATFORM=hcc
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocFFT/"
		-DAMDGPU_TARGETS="${CurrentISA}"
	)

	cmake-utils_src_configure
}
