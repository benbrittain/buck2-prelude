# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

load("@prelude//apple:apple_bundle_attrs.bzl", "get_apple_info_plist_build_system_identification_attrs")
load("@prelude//apple:apple_bundle_resources.bzl", "get_apple_bundle_resource_part_list")
load("@prelude//apple:apple_bundle_types.bzl", "AppleBundleResourceInfo")
load("@prelude//apple:apple_toolchain_types.bzl", "AppleToolchainInfo", "AppleToolsInfo")
load("@prelude//apple:resource_groups.bzl", "RESOURCE_GROUP_MAP_ATTR")
load("@prelude//user:rule_spec.bzl", "RuleRegistrationSpec")
load("@prelude//decls/ios_rules.bzl", "AppleBundleExtension")

def _get_apple_resources_toolchain_attr():
    # FIXME: prelude// should be standalone (not refer to fbcode//)
    return attrs.toolchain_dep(default = "fbcode//buck2/platform/toolchain:apple-resources", providers = [AppleToolchainInfo])

def _impl(ctx: AnalysisContext) -> list[Provider]:
    resource_output = get_apple_bundle_resource_part_list(ctx)
    return [
        DefaultInfo(),
        AppleBundleResourceInfo(
            resource_output = resource_output,
        ),
    ]

def _apple_resource_bundle_attrs():
    attribs = {
        "asset_catalogs_compilation_options": attrs.dict(key = attrs.string(), value = attrs.any(), default = {}),
        "binary": attrs.option(attrs.dep(), default = None),
        "copy_public_framework_headers": attrs.option(attrs.bool(), default = None),
        "deps": attrs.list(attrs.dep(), default = []),
        "extension": attrs.one_of(attrs.enum(AppleBundleExtension), attrs.string()),
        "ibtool_flags": attrs.option(attrs.list(attrs.string()), default = None),
        "ibtool_module_flag": attrs.option(attrs.bool(), default = None),
        "info_plist": attrs.source(),
        "info_plist_substitutions": attrs.dict(key = attrs.string(), value = attrs.string(), sorted = False, default = {}),
        "labels": attrs.list(attrs.string(), default = []),
        "privacy_manifest": attrs.option(attrs.source(), default = None),
        "product_name": attrs.option(attrs.string(), default = None),
        "resource_group": attrs.option(attrs.string(), default = None),
        "resource_group_map": RESOURCE_GROUP_MAP_ATTR,
        # Only include macOS hosted toolchains, so we compile resources directly on Mac RE
        "_apple_toolchain": _get_apple_resources_toolchain_attr(),
        "_apple_tools": attrs.exec_dep(default = "prelude//apple/tools:apple-tools", providers = [AppleToolsInfo]),
        # Because `apple_resource_bundle` is a proxy for `apple_bundle`, we need to get `name`
        # field of the `apple_bundle`, as it's used as a fallback value in Info.plist.
        "_bundle_target_name": attrs.string(),
        "_compile_resources_locally_override": attrs.option(attrs.bool(), default = None),
    }
    attribs.update(get_apple_info_plist_build_system_identification_attrs())
    return attribs

registration_spec = RuleRegistrationSpec(
    name = "apple_resource_bundle",
    impl = _impl,
    attrs = _apple_resource_bundle_attrs(),
)
