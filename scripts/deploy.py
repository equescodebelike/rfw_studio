import os
import sys

# поменять версию в константе
# поменять имя файла с версией в web
# поменять в index.html main.dart.js на main.dart.{version}.js
# flutter build web --web-renderer auto --release
# firebase deploy
def rename_js_file(file_path, version):
    os.rename(file_path, f"../build/web/main.dart.{version}.js")


def replace_start_file_in_index(file_path, version):
    with open(file_path, 'r') as file:
        content = file.read()
    updated_content = content.replace("main.dart.js", f"main.dart.{version}.js")
    with open(file_path, 'w') as file:
        file.write(updated_content)

def replace_version_in_constants(file_path, version):
    with open(file_path, 'r') as file:
        content = file.read()

    updated_content = f"String debugVersion = '{version}';"
    with open(file_path, 'w') as file:
        file.write(updated_content)



if __name__ == "__main__":
    version = sys.argv[1]
    constants_file_path = "../scripts/version.dart"
    index_file_path = "../build/web/index.html"
    js_file_path = "../build/web/main.dart.js"
    os.system("flutter clean")
    replace_version_in_constants(constants_file_path, version)
    os.system("flutter build web --release --no-tree-shake-icons")
    os.system("cp web/redirect.html build/web/redirect.html")
    replace_start_file_in_index(index_file_path, version)
    rename_js_file(js_file_path, version)
    os.system("firebase deploy")