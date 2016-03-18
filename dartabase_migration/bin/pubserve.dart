import "dart:async";
import "dart:io";
import "package:path/path.dart" as pathos;

Future main(List<String> args) async {
    String app;
    String file;
    switch (args.length) {
        case 1:
            app = args[0];
            break;
        case 2:
            app = args[0];
            file = args[1];
            break;
        default:
            print("Usage: pubserve.dart app_path [file_name]");
            exit(0);
    }

    if (!new Directory(app).existsSync()) {
        print("Directory not exists: $app");
        exit(-1);
    }

    await pubServe(app, file);
    exit(exitCode);
}

Future<int> pubServe(String app, String file) async {
    var sdk = Platform.environment["DART_SDK"];
    if (sdk == null) {
        print("Dart SDK not found");
        return new Future(() => -1);
    }

    var executable = pathos.join(sdk, "bin", "pub");
    var pattern = r"^Serving (?:.*) web on (.*)$";
    var regexp = new RegExp(pattern);
    var process = await Process.start(
            executable, ["serve"], runInShell: true, workingDirectory: app);
    process.stdout.listen((data) {
        var string = new String.fromCharCodes(data);
        for (var c in data) {
            stdout.writeCharCode(c);
        }

        var match = regexp.matchAsPrefix(string);
        if (match != null) {
            var url = match.group(1);
            if (file != null) {
                url += "/$file";
            }

            Timer.run(() => runBrowser(url));
        }
    });

    process.stderr.pipe(stderr);
    stdin.pipe(process.stdin);
    var exitCode = await process.exitCode;
    return exitCode;
}

void runBrowser(String url) {
    var fail = false;
    switch (Platform.operatingSystem) {
        case "linux":
            Process.run("x-www-browser", [url]);
            break;
        case "macos":
            Process.run("open", [url]);
            break;
        case "windows":
            Process.run("explorer", [url]);
            break;
        default:
            fail = true;
            break;
    }

    if (!fail) {
        //print("Start browsing...");
    }
}