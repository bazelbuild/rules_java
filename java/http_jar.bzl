"""The http_jar repo rule, for downloading jars over HTTP.

### Setup

To use this rule in a module extension, load it in your .bzl file and then call it from your
extension's implementation function. For example:

```python
load("@rules_java//java:http_jar.bzl", "http_jar")

def _my_extension_impl(mctx):
  http_jar(name = "foo", urls = [...])

my_extension = module_extension(implementation = _my_extension_impl)
```

Alternatively, you can directly call it your MODULE.bazel file with `use_repo_rule`:

```python
http_jar = use_repo_rule("@rules_java//java:http_jar.bzl", "http_jar")
http_jar(name = "foo", urls = [...])
```
"""

load("@compatibility_proxy//:proxy.bzl", _http_jar = "http_jar")

http_jar = _http_jar
