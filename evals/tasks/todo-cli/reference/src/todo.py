import argparse, json, os, sys
def load(p):
    return json.load(open(p)) if os.path.exists(p) else {"next": 1, "items": []}
def main(argv=None):
    ap = argparse.ArgumentParser(); ap.add_argument("--file", required=True)
    sp = ap.add_subparsers(dest="cmd", required=True)
    sp.add_parser("add").add_argument("text"); sp.add_parser("list")
    sp.add_parser("done").add_argument("id", type=int); sp.add_parser("rm").add_argument("id", type=int)
    a = ap.parse_args(argv); d = load(a.file)
    if a.cmd == "add":
        d["items"].append({"id": d["next"], "text": a.text, "done": False}); print(d["next"]); d["next"] += 1
    elif a.cmd == "list":
        for i in sorted(d["items"], key=lambda x: x["id"]): print(f'{i["id"]} [{"x" if i["done"] else " "}] {i["text"]}')
    else:
        t = [i for i in d["items"] if i["id"] == a.id]
        if not t: print(f"no such id: {a.id}", file=sys.stderr); return 1
        if a.cmd == "done": t[0]["done"] = True
        else: d["items"].remove(t[0])
    json.dump(d, open(a.file, "w")); return 0
if __name__ == "__main__": sys.exit(main())
