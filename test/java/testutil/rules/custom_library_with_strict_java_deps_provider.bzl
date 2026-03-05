"""Custom libraty that reads --strict_java_deps and returns it from a provider."""

StrictJavaDepsInfo = provider(
    doc = "Provides args.strict_java_deps for testing",
    fields = ["strict_java_deps"],
)

def _impl(ctx):
    return [StrictJavaDepsInfo(strict_java_deps = ctx.fragments.java.strict_java_deps)]

custom_library_with_strict_java_deps_provider = rule(
    implementation = _impl,
    attrs = {},
    fragments = ["java"],
)
