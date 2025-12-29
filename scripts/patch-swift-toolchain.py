import sys
import os

def patch_toolchain():
    file_path = 'build-system/bazel-rules/rules_swift/swift/toolchains/xcode_swift_toolchain.bzl'
    if not os.path.exists(file_path):
        print(f'Error: {file_path} not found')
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    target = 'swiftcopts.extend(ctx.attr._copts[BuildSettingInfo].value)'
    if target not in content:
        print(f'Error: Could not find target line in {file_path}')
        return False

    if 'telegram_ui_only' in content:
        print('Already patched')
        return True

    patch = '\n\n    if ctx.var.get(\"telegram_ui_only\") == \"1\":\n        swiftcopts.append(\"-DTELEGRAM_UI_ONLY\")'
    new_content = content.replace(target, target + patch)

    with open(file_path, 'w') as f:
        f.write(new_content)
    print('Successfully patched xcode_swift_toolchain.bzl')
    return True

if __name__ == '__main__':
    if not patch_toolchain():
        sys.exit(1)
