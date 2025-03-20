"""Helper rules to test errors in JavaInfo instantiation"""

load("//java/common:java_info.bzl", "JavaInfo")

def _make_file(ctx):
    f = ctx.actions.declare_file(ctx.label.name + ".out")
    ctx.actions.write(f, "out")
    return f

def _deps_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f, compile_jar = f, deps = [f])

def _runtime_deps_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f, compile_jar = f, runtime_deps = [f])

def _exports_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f, compile_jar = f, exports = [f])

def _nativelibs_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f, compile_jar = f, native_libraries = [f])

def _compile_jar_not_set_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f)

def _compile_jar_set_to_none_impl(ctx):
    f = _make_file(ctx)
    return JavaInfo(output_jar = f, compile_jar = None)

bad_deps = rule(_deps_impl)
bad_runtime_deps = rule(_runtime_deps_impl)
bad_exports = rule(_exports_impl)
bad_libs = rule(_nativelibs_impl)
compile_jar_not_set = rule(_compile_jar_not_set_impl)
compile_jar_set_to_none = rule(_compile_jar_set_to_none_impl)
