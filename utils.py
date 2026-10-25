import sys
from string import Template


# Commands and their descriptions
commands = {
    "svg2qml": "convert an svg to qml with configurable color",
}


def print_help():
    t = Template("""
   Usage: python3 ${app_name} <command> [arguments]
   Commands:
   $command_list
   """)

    cl = "\n".join(map(lambda x: "\t" + x, map(" - ".join, commands.items())))
    print(t.substitute(app_name=sys.argv[0], command_list=cl))


def main():
    if len(sys.argv) < 2:
        print_help()


if __name__ == "__main__":
    main()
