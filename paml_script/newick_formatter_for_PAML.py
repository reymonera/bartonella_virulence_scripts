import argparse
import re

def round_number(match):
    """Round the matched number to 4 decimal places."""
    number = float(match.group(0))
    return f"{number:.4f}"

def format_newick(newick_str):
    indent_level = 0
    formatted_str = ""
    in_string = False
    
    # Regular expression to find numbers in the Newick string
    number_pattern = re.compile(r'\d+\.\d+')

    for char in newick_str:
        if char == ',' and not in_string:
            formatted_str += ",\n" + "  " * indent_level
        elif char == '(':
            formatted_str += char + "\n" + "  " * (indent_level + 1)
            indent_level += 1
        elif char == ')':
            indent_level -= 1
            formatted_str += "\n" + "  " * indent_level + char
        elif char == ';':
            formatted_str += char
        else:
            formatted_str += char

    # Round numbers to 4 decimal places
    formatted_str = number_pattern.sub(round_number, formatted_str)
    
    return formatted_str

def number_lines(formatted_str):
    lines = formatted_str.splitlines()
    numbered_lines = [f"{i + 1}: {line}" for i, line in enumerate(lines) if line.strip()]
    return numbered_lines

def mark_line(formatted_str, line_number):
    lines = formatted_str.splitlines()
    if 1 <= line_number <= len(lines):
        target_line = lines[line_number - 1]
        
        # Remove trailing whitespace
        target_line = target_line.rstrip()
        
        if target_line.endswith('),'):
            # Case: Ends with "),"
            target_line = target_line[:-1] + ' #1,'  # Remove the last comma, add "#1", then add the comma
        elif target_line.endswith(','):
            # Case: Ends with ","
            target_line = target_line.rstrip(',') + ' #1,'  # Remove the last comma, add "#1", then add the comma
        else:
            # Case: All other cases
            target_line += ' #1'
        
        lines[line_number - 1] = target_line
    
    return "\n".join(lines)

def unformat_newick(formatted_str):
    lines = formatted_str.splitlines()
    newick_str = ""
    for line in lines:
        if line.strip():
            newick_str += line.strip()
    return newick_str

def main(input_filename, output_filename):
    print("This script only marks branches and not terminal nodes!!")
    
    # Read the Newick file
    with open(input_filename, 'r') as file:
        newick_str = file.read()
    
    # Format the Newick string
    formatted_str = format_newick(newick_str)
    
    while True:
        # Display the formatted Newick tree with line numbers
        numbered_str = "\n".join(number_lines(formatted_str))
        print("Formatted Newick Tree with Line Numbers:")
        print(numbered_str)
        
        # Ask the user if they want to add a mark
        add_mark = input("\nDo you want to add a mark? (yes/no) ").strip().lower()
        
        if add_mark == 'yes':
            try:
                # Get the line number where the user wants to add the mark
                line_number = int(input("In which line do you wish to put the mark? "))
                formatted_str = mark_line(formatted_str, line_number)
            except ValueError:
                print("Invalid input. Please enter a valid line number.")
        elif add_mark == 'no':
            break
        else:
            print("Invalid choice. Please enter 'yes' or 'no'.")
    
    # Convert formatted Newick back to a single-line Newick string
    final_newick_str = unformat_newick(formatted_str)
    
    # Write the final Newick string to a new file
    with open(output_filename, 'w') as file:
        file.write(final_newick_str)
    
    print(f"\nFinal Modified Newick Tree written to {output_filename}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Format and mark a Newick tree file.')
    parser.add_argument('input_filename', type=str, help='The Newick file to process.')
    parser.add_argument('output_filename', type=str, help='The file to write the modified Newick tree.')
    args = parser.parse_args()
    
    main(args.input_filename, args.output_filename)

