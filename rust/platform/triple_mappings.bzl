"""Helpers for constructing supported Rust platform triples"""

load("//rust/platform:triple.bzl", "triple")

# All T1 Platforms should be supported, but aren't, see inline notes.
SUPPORTED_T1_PLATFORM_TRIPLES = [
    "aarch64-unknown-linux-gnu",
    "aarch64-unknown-nixos-gnu",  # Same as `aarch64-unknown-linux-gnu` but with `@platforms//os:nixos`.
    "i686-apple-darwin",
    "i686-pc-windows-msvc",
    "i686-unknown-linux-gnu",
    "x86_64-apple-darwin",
    "x86_64-pc-windows-msvc",
    "x86_64-unknown-linux-gnu",
    "x86_64-unknown-nixos-gnu",  # Same as `x86_64-unknown-linux-gnu` but with `@platforms//os:nixos`.
    # N.B. These "alternative" envs are not supported, as bazel cannot distinguish between them
    # and others using existing @platforms// config_values
    #
    #"i686-pc-windows-gnu",
    #"x86_64-pc-windows-gnu",
]

# Some T2 Platforms are supported, provided we have mappings to @platforms// entries.
# See @rules_rust//rust/platform:triple_mappings.bzl for the complete list.
SUPPORTED_T2_PLATFORM_TRIPLES = [
    "aarch64-apple-darwin",
    "aarch64-apple-ios-sim",
    "aarch64-apple-ios",
    "aarch64-fuchsia",
    "aarch64-linux-android",
    "aarch64-pc-windows-msvc",
    "arm-unknown-linux-gnueabi",
    "armv7-linux-androideabi",
    "armv7-unknown-linux-gnueabi",
    "i686-linux-android",
    "i686-unknown-freebsd",
    "powerpc-unknown-linux-gnu",
    "riscv32imc-unknown-none-elf",
    "riscv64gc-unknown-none-elf",
    "s390x-unknown-linux-gnu",
    "thumbv7em-none-eabi",
    "thumbv8m.main-none-eabi",
    "wasm32-unknown-unknown",
    "wasm32-wasi",
    "x86_64-apple-ios",
    "x86_64-fuchsia",
    "x86_64-linux-android",
    "x86_64-unknown-freebsd",
    "x86_64-unknown-none",
]

SUPPORTED_PLATFORM_TRIPLES = SUPPORTED_T1_PLATFORM_TRIPLES + SUPPORTED_T2_PLATFORM_TRIPLES

# CPUs that map to a "@platforms//cpu entry
_CPU_ARCH_TO_BUILTIN_PLAT_SUFFIX = {
    "aarch64": "aarch64",
    "arm": "arm",
    "armv7": "armv7",
    "armv7s": None,
    "asmjs": None,
    "i386": "i386",
    "i586": None,
    "i686": "x86_32",
    "le32": None,
    "mips": None,
    "mipsel": None,
    "powerpc": "ppc",
    "powerpc64": None,
    "powerpc64le": None,
    "riscv32": "riscv32",
    "riscv32imc": "riscv32",
    "riscv64": "riscv64",
    "riscv64gc": "riscv64",
    "s390": None,
    "s390x": "s390x",
    "thumbv6m": "armv6-m",
    "thumbv7em": "armv7e-m",
    "thumbv7m": "armv7-m",
    "thumbv8m.main": "armv8-m",
    "wasm32": None,
    "x86_64": "x86_64",
}

# Systems that map to a "@platforms//os entry
_SYSTEM_TO_BUILTIN_SYS_SUFFIX = {
    "android": "android",
    "bitrig": None,
    "darwin": "osx",
    "dragonfly": None,
    "eabi": "none",
    "eabihf": "none",
    "emscripten": None,
    "freebsd": "freebsd",
    "fuchsia": "fuchsia",
    "ios": "ios",
    "linux": "linux",
    "nacl": None,
    "netbsd": None,
    "nixos": "nixos",
    "none": "none",
    "openbsd": "openbsd",
    "solaris": None,
    "unknown": None,
    "wasi": None,
    "windows": "windows",
}

_SYSTEM_TO_BINARY_EXT = {
    "android": "",
    "darwin": "",
    "eabi": "",
    "eabihf": "",
    "emscripten": ".js",
    "freebsd": "",
    "fuchsia": "",
    "ios": "",
    "linux": "",
    "nixos": "",
    "none": "",
    # This is currently a hack allowing us to have the proper
    # generated extension for the wasm target, similarly to the
    # windows target
    "unknown": ".wasm",
    "wasi": ".wasm",
    "windows": ".exe",
}

_SYSTEM_TO_STATICLIB_EXT = {
    "android": ".a",
    "darwin": ".a",
    "eabi": ".a",
    "eabihf": ".a",
    "emscripten": ".js",
    "freebsd": ".a",
    "fuchsia": ".a",
    "ios": ".a",
    "linux": ".a",
    "nixos": ".a",
    "none": ".a",
    "unknown": "",
    "wasi": "",
    "windows": ".lib",
}

_SYSTEM_TO_DYLIB_EXT = {
    "android": ".so",
    "darwin": ".dylib",
    "eabi": ".so",
    "eabihf": ".so",
    "emscripten": ".js",
    "freebsd": ".so",
    "fuchsia": ".so",
    "ios": ".dylib",
    "linux": ".so",
    "nixos": ".so",
    "none": ".so",
    "unknown": ".wasm",
    "wasi": ".wasm",
    "windows": ".dll",
}

# See https://github.com/rust-lang/rust/blob/master/src/libstd/build.rs
_SYSTEM_TO_STDLIB_LINKFLAGS = {
    # NOTE: Rust stdlib `build.rs` treats android as a subset of linux, rust rules treat android
    # as its own system.
    "android": ["-ldl", "-llog"],
    "bitrig": [],
    # TODO(gregbowyer): If rust stdlib is compiled for cloudabi with the backtrace feature it
    # includes `-lunwind` but this might not actually be required.
    # I am not sure which is the common configuration or how we encode it as a link flag.
    "cloudabi": ["-lunwind", "-lc", "-lcompiler_rt"],
    "darwin": ["-lSystem", "-lresolv"],
    "dragonfly": ["-lpthread"],
    "eabi": [],
    "eabihf": [],
    "emscripten": [],
    # TODO(bazelbuild/rules_cc#75):
    #
    # Right now bazel cc rules does not specify the exact flag setup needed for calling out system
    # libs, that is we dont know given a toolchain if it should be, for example,
    # `-lxxx` or `/Lxxx` or `xxx.lib` etc.
    #
    # We include the flag setup as they are _commonly seen_ on various platforms with a cc_rules
    # style override for people doing things like gnu-mingw on windows.
    #
    # If you are reading this ... sorry! set the env var `BAZEL_RUST_STDLIB_LINKFLAGS` to
    # what you need for your specific setup, for example like so
    # `BAZEL_RUST_STDLIB_LINKFLAGS="-ladvapi32:-lws2_32:-luserenv"`
    "freebsd": ["-lexecinfo", "-lpthread"],
    "fuchsia": ["-lzircon", "-lfdio"],
    "illumos": ["-lsocket", "-lposix4", "-lpthread", "-lresolv", "-lnsl", "-lumem"],
    "ios": ["-lSystem", "-lobjc", "-Wl,-framework,Security", "-Wl,-framework,Foundation", "-lresolv"],
    # TODO: This ignores musl. Longer term what does Bazel think about musl?
    "linux": ["-ldl", "-lpthread"],
    "nacl": [],
    "netbsd": ["-lpthread", "-lrt"],
    "nixos": ["-ldl", "-lpthread"],  # Same as `linux`.
    "none": [],
    "openbsd": ["-lpthread"],
    "solaris": ["-lsocket", "-lposix4", "-lpthread", "-lresolv"],
    "unknown": [],
    "uwp": ["ws2_32.lib"],
    "wasi": [],
    "windows": ["advapi32.lib", "ws2_32.lib", "userenv.lib", "Bcrypt.lib"],
}

def cpu_arch_to_constraints(cpu_arch, *, system = None):
    """Returns a list of contraint values which represents a triple's CPU.

    Args:
        cpu_arch (str): The architecture to match constraints for
        system (str, optional): The system for the associated ABI value.

    Returns:
        List: A list of labels to constraint values
    """
    if cpu_arch not in _CPU_ARCH_TO_BUILTIN_PLAT_SUFFIX:
        fail("CPU architecture \"{}\" is not supported by rules_rust".format(cpu_arch))

    plat_suffix = _CPU_ARCH_TO_BUILTIN_PLAT_SUFFIX[cpu_arch]

    # Patch armv7e-m to mf if hardfloat abi is selected
    if plat_suffix == "armv7e-m" and system == "eabihf":
        plat_suffix = "armv7e-mf"

    return ["@platforms//cpu:{}".format(plat_suffix)]

def vendor_to_constraints(_vendor):
    # TODO(acmcarther): Review:
    #
    # My current understanding is that vendors can't have a material impact on
    # constraint sets.
    return []

def system_to_constraints(system):
    if system not in _SYSTEM_TO_BUILTIN_SYS_SUFFIX:
        fail("System \"{}\" is not supported by rules_rust".format(system))

    sys_suffix = _SYSTEM_TO_BUILTIN_SYS_SUFFIX[system]

    return ["@platforms//os:{}".format(sys_suffix)]

def abi_to_constraints(abi, *, arch = None, system = None):
    """Return a list of constraint values which represents a triple's ABI.

    Note that some ABI values require additional info to accurately match a set of constraints.

    Args:
        abi (str): The abi value to match constraints for
        arch (str, optional): The architecture for the associated ABI value.
        system (str, optional): The system for the associated ABI value.

    Returns:
        List: A list of labels to constraint values
    """

    # add constraints for iOS + watchOS simulator and device triples
    if system in ["ios", "watchos"]:
        if arch == "x86_64" or abi == "sim":
            return ["@build_bazel_apple_support//constraints:simulator"]
        else:
            return ["@build_bazel_apple_support//constraints:device"]

    # TODO(bazelbuild/platforms#38): Implement when C++ toolchain is more mature and we
    # figure out how they're doing this
    return []

def triple_to_system(target_triple):
    """Returns a system name for a given platform triple

    **Deprecated**: Use triple() from triple.bzl directly.

    Args:
        target_triple (str): A platform triple. eg: `x86_64-unknown-linux-gnu`

    Returns:
        str: A system name
    """
    if type(target_triple) == "string":
        target_triple = triple(target_triple)
    return target_triple.system

def triple_to_arch(target_triple):
    """Returns a system architecture name for a given platform triple

    **Deprecated**: Use triple() from triple.bzl directly.

    Args:
        target_triple (str): A platform triple. eg: `x86_64-unknown-linux-gnu`

    Returns:
        str: A cpu architecture
    """
    if type(target_triple) == "string":
        target_triple = triple(target_triple)
    return target_triple.arch

def triple_to_abi(target_triple):
    """Returns a system abi name for a given platform triple

    **Deprecated**: Use triple() from triple.bzl directly.

    Args:
        target_triple (str): A platform triple. eg: `x86_64-unknown-linux-gnu`

    Returns:
        str: The triple's abi
    """
    if type(target_triple) == "string":
        target_triple = triple(target_triple)
    return target_triple.system

def system_to_dylib_ext(system):
    return _SYSTEM_TO_DYLIB_EXT[system]

def system_to_staticlib_ext(system):
    return _SYSTEM_TO_STATICLIB_EXT[system]

def system_to_binary_ext(system):
    return _SYSTEM_TO_BINARY_EXT[system]

def system_to_stdlib_linkflags(system):
    return _SYSTEM_TO_STDLIB_LINKFLAGS[system]

def triple_to_constraint_set(target_triple):
    """Returns a set of constraints for a given platform triple

    Args:
        target_triple (str): A platform triple. eg: `x86_64-unknown-linux-gnu`

    Returns:
        list: A list of constraints (each represented by a list of strings)
    """
    if target_triple == "wasm32-wasi":
        return [
            "@platforms//cpu:wasm32",
            "@platforms//os:wasi",
        ]
    if target_triple == "wasm32-unknown-unknown":
        return [
            "@platforms//cpu:wasm32",
            "@platforms//os:none",
        ]

    triple_struct = triple(target_triple)

    constraint_set = []
    constraint_set += cpu_arch_to_constraints(
        triple_struct.arch,
        system = triple_struct.system,
    )
    constraint_set += vendor_to_constraints(triple_struct.vendor)
    constraint_set += system_to_constraints(triple_struct.system)
    constraint_set += abi_to_constraints(
        triple_struct.abi,
        arch = triple_struct.arch,
        system = triple_struct.system,
    )

    return constraint_set
