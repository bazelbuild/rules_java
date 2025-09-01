"""Module extensions for local and remote java repositories"""

load(":local_java_repository.bzl", "local_java_repository")
load(":remote_java_repository.bzl", "remote_java_repository")

visibility(["//java"])

def _java_repository_impl(mctx):
    for mod in mctx.modules:
        if not mod.is_root:
            fail(
                """This module extension may only be used in the root module. {name}
                must set `dev_dependency` = True on it's usage of this extension,
                if {name} can be dependency of other modules.""".format(name = mod.name),
            )
        for local in mod.tags.local:
            local_java_repository(
                local.name,
                java_home = local.java_home,
                version = local.version,
                build_file = local.build_file,
                build_file_content = local.build_file_content,
            )
        for remote in mod.tags.remote:
            remote_java_repository(
                remote.name,
                remote.version,
                target_compatible_with = remote.target_compatible_with,
                prefix = remote.prefix,
                remote_file_urls = remote.remote_file_urls,
                remote_file_integrity = remote.remote_file_integrity,
                sha256 = remote.sha256,
                strip_prefix = remote.strip_prefix,
                urls = remote.urls,
            )

_local = tag_class(attrs = {
    "name": attr.string(mandatory = True),
    "build_file": attr.label(default = None),
    "build_file_content": attr.string(default = ""),
    "java_home": attr.string(default = ""),
    "version": attr.string(default = ""),
})

_remote = tag_class(attrs = {
    "name": attr.string(mandatory = True),
    "version": attr.string(mandatory = True),
    "urls": attr.string_list(mandatory = True),
    "prefix": attr.string(default = ""),
    "remote_file_urls": attr.string_list_dict(default = {}),
    "remote_file_integrity": attr.string_dict(default = {}),
    "sha256": attr.string(default = ""),
    "strip_prefix": attr.string(default = ""),
    "target_compatible_with": attr.string_list(default = []),
})

java_repository = module_extension(
    _java_repository_impl,
    tag_classes = {
        "local": _local,
        "remote": _remote,
    },
)
