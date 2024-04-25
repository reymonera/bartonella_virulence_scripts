#!/usr/bin/env python3

import sys
import glob
import re
import pickle

def get_unique_names(file, regex):
    with open(file, 'r') as f:
        content = f.read()
    names = re.findall(regex, content)
    return list(set(names))  # remove duplicates

def ask_for_replacement(name):
    while True:
        answer = input(f"Do you want to replace {name}? (y/n) ")
        if answer.lower() == 'y':
            new_name = input(f"What should {name} be replaced with? ")
            return new_name
        elif answer.lower() == 'n':
            return name
        else:
            print("Invalid input. Please enter 'y' or 'n'.")

def replace_names_in_file(filename, replacements):
    with open(filename, 'r') as f:
        content = f.read()
    for old_name, new_name in replacements.items():
        content = content.replace(old_name, new_name)
    with open(filename, 'w') as f:
        f.write(content)

def main():
    # The last argument is the regex
    regex = sys.argv[-1]

    # The rest of the arguments are the file names
    files = sys.argv[1:-1]

    all_unique_names = set()
    for arg in sys.argv[1:]:
        files = glob.glob(arg)
        for filename in files:
            unique_names = get_unique_names(filename, regex)
            all_unique_names.update(unique_names)

    print(f"Found {len(all_unique_names)} unique names in all files: {all_unique_names}")

    # Load previous replacements if exists
    try:
        with open('replacements.pkl', 'rb') as f:
            replacements = pickle.load(f)
    except FileNotFoundError:
        replacements = {}

    # Ask user if they want to use previous replacements
    use_previous = input("Do you want to use previous replacements? (y/n) ")
    if use_previous.lower() != 'y':
        for name in all_unique_names:
            new_name = ask_for_replacement(name)
            if new_name != name:
                replacements[name] = new_name

    # Save replacements
    save_replacements = input("Do you want to save these replacements for future use? (y/n) ")
    if save_replacements.lower() == 'y':
        with open('replacements.pkl', 'wb') as f:
            pickle.dump(replacements, f)

    # Replace names in all files
    for arg in sys.argv[1:]:
        files = glob.glob(arg)
        for filename in files:
            replace_names_in_file(filename, replacements)

if __name__ == "__main__":
    main()
