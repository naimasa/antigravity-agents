import json, os, subprocess, sys, tempfile
ws = sys.argv[1]
f = os.path.join(tempfile.mkdtemp(), "t.json")
def run(*a):
    return subprocess.run([sys.executable, os.path.join(ws, "src/todo.py"), "--file", f, *a], capture_output=True, text=True)
def eq(got, want, msg):
    if got != want: print(f"FAIL {msg}: {got!r} != {want!r}"); sys.exit(1)
eq(run("list").stdout, "", "empty list")
eq(run("add", "buy milk").stdout.strip(), "1", "id1")
eq(run("add", "write code").stdout.strip(), "2", "id2")
eq(run("done", "1").returncode, 0, "done rc")
eq(run("list").stdout.splitlines(), ["1 [x] buy milk", "2 [ ] write code"], "list")
eq(run("rm", "2").returncode, 0, "rm rc")
eq(run("add", "again").stdout.strip(), "3", "no id reuse")
r = run("done", "99"); eq(r.returncode, 1, "missing id rc")
assert r.stderr.strip(), "stderr message required"
json.load(open(f))
tests = os.path.join(ws, "tests")
assert os.path.isdir(tests) and any(n.endswith(".py") for n in os.listdir(tests)), "tests/ required"
print("PASS")
