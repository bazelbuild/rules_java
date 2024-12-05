"""The http_jar repo rule, for downloading jars over HTTP."""

load("@bazel_tools//tools/build_defs/repo:cache.bzl", "CANONICAL_ID_DOC", "DEFAULT_CANONICAL_ID_ENV", "get_default_canonical_id")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "get_auth", "update_attrs")

_URL_DOC = """A URL to the jar that will be made available to Bazel.

This must be a file, http or https URL. Redirections are followed.
Authentication is not supported.

More flexibility can be achieved by the urls parameter that allows
to specify alternative URLs to fetch from."""

_URLS_DOC = """A list of URLs to the jar that will be made available to Bazel.

Each entry must be a file, http or https URL. Redirections are followed.
Authentication is not supported.

URLs are tried in order until one succeeds, so you should list local mirrors first.
If all downloads fail, the rule will fail."""

_AUTH_PATTERN_DOC = """An optional dict mapping host names to custom authorization patterns.

If a URL's host name is present in this dict the value will be used as a pattern when
generating the authorization header for the http request. This enables the use of custom
authorization schemes used in a lot of common cloud storage providers.

The pattern currently supports 2 tokens: <code>&lt;login&gt;</code> and
<code>&lt;password&gt;</code>, which are replaced with their equivalent value
in the netrc file for the same host name. After formatting, the result is set
as the value for the <code>Authorization</code> field of the HTTP request.

Example attribute and netrc for a http download to an oauth2 enabled API using a bearer token:

<pre>
auth_patterns = {
    "storage.cloudprovider.com": "Bearer &lt;password&gt;"
}
</pre>

netrc:

<pre>
machine storage.cloudprovider.com
        password RANDOM-TOKEN
</pre>

The final HTTP request would have the following header:

<pre>
Authorization: Bearer RANDOM-TOKEN
</pre>
"""

def _get_source_urls(ctx):
    """Returns source urls provided via the url, urls attributes.

    Also checks that at least one url is provided."""
    if not ctx.attr.url and not ctx.attr.urls:
        fail("At least one of url and urls must be provided")

    source_urls = []
    if ctx.attr.urls:
        source_urls = ctx.attr.urls
    if ctx.attr.url:
        source_urls = [ctx.attr.url] + source_urls
    return source_urls

def _update_integrity_attr(ctx, attrs, download_info):
    # We don't need to override the integrity attribute if sha256 is already specified.
    integrity_override = {} if ctx.attr.sha256 else {"integrity": download_info.integrity}
    return update_attrs(ctx.attr, attrs.keys(), integrity_override)

_HTTP_JAR_BUILD = """\
load("{java_import_bzl}", "java_import")

java_import(
  name = 'jar',
  jars = ["{file_name}"],
  visibility = ['//visibility:public'],
)

filegroup(
  name = 'file',
  srcs = ["{file_name}"],
  visibility = ['//visibility:public'],
)

"""

def _http_jar_impl(ctx):
    """Implementation of the http_jar rule."""
    source_urls = _get_source_urls(ctx)
    downloaded_file_name = ctx.attr.downloaded_file_name
    download_info = ctx.download(
        source_urls,
        "jar/" + downloaded_file_name,
        ctx.attr.sha256,
        canonical_id = ctx.attr.canonical_id or get_default_canonical_id(ctx, source_urls),
        auth = get_auth(ctx, source_urls),
        integrity = ctx.attr.integrity,
    )
    ctx.file("jar/BUILD", _HTTP_JAR_BUILD.format(
        java_import_bzl = str(Label("//java:java_import.bzl")),
        file_name = downloaded_file_name,
    ))

    return _update_integrity_attr(ctx, _http_jar_attrs, download_info)

_http_jar_attrs = {
    "sha256": attr.string(
        doc = """The expected SHA-256 of the jar downloaded.

This must match the SHA-256 of the jar downloaded. _It is a security risk
to omit the SHA-256 as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `integrity` should be set before shipping.""",
    ),
    "integrity": attr.string(
        doc = """Expected checksum in Subresource Integrity format of the jar downloaded.

This must match the checksum of the file downloaded. _It is a security risk
to omit the checksum as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `sha256` should be set before shipping.""",
    ),
    "canonical_id": attr.string(
        doc = CANONICAL_ID_DOC,
    ),
    "url": attr.string(doc = _URL_DOC + "\n\nThe URL must end in `.jar`."),
    "urls": attr.string_list(doc = _URLS_DOC + "\n\nAll URLs must end in `.jar`."),
    "netrc": attr.string(
        doc = "Location of the .netrc file to use for authentication",
    ),
    "auth_patterns": attr.string_dict(
        doc = _AUTH_PATTERN_DOC,
    ),
    "downloaded_file_name": attr.string(
        default = "downloaded.jar",
        doc = "Filename assigned to the jar downloaded",
    ),
}

http_jar = repository_rule(
    implementation = _http_jar_impl,
    attrs = _http_jar_attrs,
    environ = [DEFAULT_CANONICAL_ID_ENV],
    doc =
        """Downloads a jar from a URL and makes it available as java_import

Downloaded files must have a .jar extension.

Examples:
  Suppose the current repository contains the source code for a chat program, rooted at the
  directory `~/chat-app`. It needs to depend on an SSL library which is available from
  `http://example.com/openssl-0.2.jar`.

  Targets in the `~/chat-app` repository can depend on this target if the following lines are
  added to `~/chat-app/MODULE.bazel`:

  ```python
  http_jar = use_repo_rule("@rules_java//java:http_jar.bzl", "http_jar")

  http_jar(
      name = "my_ssl",
      url = "http://example.com/openssl-0.2.jar",
      sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
  ```

  Targets would specify `@my_ssl//jar` as a dependency to depend on this jar.

  You may also reference files on the current system (localhost) by using "file:///path/to/file"
  if you are on Unix-based systems. If you're on Windows, use "file:///c:/path/to/file". In both
  examples, note the three slashes (`/`) -- the first two slashes belong to `file://` and the third
  one belongs to the absolute path to the file.
""",
)
