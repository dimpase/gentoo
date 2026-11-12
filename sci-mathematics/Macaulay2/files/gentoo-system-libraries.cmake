# Fail at configuration instead of silently downloading dependency sources.
foreach(dep IN ITEMS EIGEN3 BDWGC MPFR MPFI NTL FLINT FACTORY MPSOLVE
    NORMALIZ FROBBY GLPK GIVARO FFLAS_FFPACK)
  if(NOT ${dep}_FOUND)
    message(FATAL_ERROR "Gentoo requires the system ${dep} library")
  endif()
endforeach()
if(BUILD_TESTING AND NOT GTEST_FOUND)
  message(FATAL_ERROR "Gentoo requires system GoogleTest for USE=test")
endif()
file(MAKE_DIRECTORY "${M2_HOST_PREFIX}/bin" "${M2_HOST_PREFIX}/lib"
  "${M2_HOST_PREFIX}/include" "${M2_INSTALL_PROGRAMSDIR}"
  "${M2_INSTALL_LICENSESDIR}")

if(NOT EXISTS "${GFTABLESDIR}/gftables/961")
  message(FATAL_ERROR "System Factory finite-field tables are missing")
endif()
