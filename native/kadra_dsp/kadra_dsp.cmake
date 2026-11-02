# Builds the Rust DSP library (native/kadra_dsp) with cargo and installs it
# next to the app. Optional: without cargo the app uses the Dart DSP.
#   include(".../kadra_dsp.cmake")
#   kadra_dsp_install("<install dir>")
set(KADRA_DSP_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(kadra_dsp_install DEST)
  find_program(KADRA_CARGO cargo
    HINTS "$ENV{CARGO_HOME}/bin" "$ENV{HOME}/.cargo/bin" "$ENV{USERPROFILE}/.cargo/bin")
  if(NOT KADRA_CARGO)
    message(WARNING "cargo not found: kadra_dsp (Rust) is not built; the audio editor uses the slower Dart DSP")
    return()
  endif()
  if(WIN32)
    set(name "kadra_dsp.dll")
  else()
    set(name "libkadra_dsp.so")
  endif()
  set(target_dir "${CMAKE_BINARY_DIR}/kadra_dsp")
  set(lib "${target_dir}/release/${name}")
  add_custom_target(kadra_dsp ALL
    COMMAND "${KADRA_CARGO}" build --release --manifest-path "${KADRA_DSP_DIR}/Cargo.toml" --target-dir "${target_dir}"
    BYPRODUCTS "${lib}"
    COMMENT "Building kadra_dsp (Rust)"
    USES_TERMINAL VERBATIM)
  install(FILES "${lib}" DESTINATION "${DEST}" COMPONENT Runtime)
endfunction()
