"""Test rule to provide TemplateVariableInfo"""

def _template_var_info_rule_impl(ctx):
    return [
        platform_common.TemplateVariableInfo(ctx.attr.vars),
    ]

template_var_info_rule = rule(
    _template_var_info_rule_impl,
    attrs = {
        "vars": attr.string_dict(default = {}),
    },
)
