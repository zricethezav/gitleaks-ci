import json

def open_file(filename):
    with open(filename) as json_file:
        data = json.load(json_file)
        for i in data:
            print("\"" + data[i]+ "\"")
        

def main():
    open_file("regexes.json")

if __name__ == "__main__":
    main()