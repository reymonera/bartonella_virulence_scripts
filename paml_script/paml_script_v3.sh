#!/bin/bash

# Create an array of all files in the current directory
files=(*)
echo "Created an array"

echo "Activando conda mediante conda run..."

# Loop through the files
for file in "${files[@]}"; do
    # Check if the file is a phy file (ends with .phy)
    if [[ $file == *.phy ]]; then
        # Extract the base name (without extension) from the phy file
        base_name="${file%.phy}"
        echo "Este es $base_name"
        # Check if there is a corresponding newick file
        newick_file="${base_name}.newick"
        if [[ -e $newick_file ]]; then
            # Create a directory with the base name (if it doesn't exist)
            # Here we also cut out the 'nt_' shit with sed
            #base_name=$(echo "$file" | sed 's/nt_\(.*\)\.phy/\1/')
            mkdir -p "$base_name"
            
            # Move both files to the directory
            mv "$file" "$newick_file" "$base_name/"
            
            # Output a message indicating the move
            echo "Moved $file and $newick_file to $base_name/"
            
            # Create Hypothesis directories
            # H0 H1 H2 H3
            for i in 0_1 1 0_2 2; do
				mkdir -p "$base_name/H$i"
				cp "$base_name/$file" "$base_name/$newick_file" "$base_name/H$i" ##
			done
            
            echo "Created Hypothesis subdirectories"
           
        fi
    fi
done

echo "Ahora para el otro tipo de análisis"
echo "=== EMPIEZA PAML ==="

# Get the current directory
parent_directory="$(pwd)"
echo "Parent directory: $parent_directory"

# Loop through directories in the parent directory
for directory in "$parent_directory"/bart_*/; do
    # Check if the item is a directory
    if [ -d "$directory" ]; then
        # Echo the directory's name
        echo "Estamos en: $directory"
        
        # Loop through subdirectories H0, H1, H2, H3 in the current directory
        for subdirectory in H0_1 H1 H0_2 H2; do
            # Define the subdirectory path
            subdirectory_path="$directory$subdirectory"
            
            # Copy the "codeml" file to the subdirectory
            cp "$parent_directory/codeml.ctl" "$subdirectory_path"
            echo "Copied codeml to $subdirectory_path"
            
            # Get the name of the phy file in the subdirectory
            phy_file=$(find "$subdirectory_path" -maxdepth 1 -type f -name "*.phy")
            phy_file=$(basename "$phy_file")
            
            newick_file=$(find "$subdirectory_path" -maxdepth 1 -type f -name "*.newick")
            newick_file=$(basename "$newick_file")
            
            #for value in 1 0; do
                # Reemplazo para distintos outputs
                #sed -i "s|{{omega_value}}|$value|" "${subdirectory_path}/codeml.ctl"
            ########
                # Determine the value based on the subdirectory name
			if [[ "$subdirectory" == "H0" ]]; then
			    value=1
			    sed -i "s|((omega))|$value|" "${subdirectory_path}/codeml.ctl"
			    sed -i "s|((fix_omega))|1|" "${subdirectory_path}/codeml.ctl"
			else
			    value=0
			    sed -i "s|((omega))|10|" "${subdirectory_path}/codeml.ctl"
			    sed -i "s|((fix_omega))|$value|" "${subdirectory_path}/codeml.ctl"
			fi
			
			sed -i "s|((output name))|$subdirectory|" "${subdirectory_path}/codeml.ctl"
				
			# Reemplazo para distintos outputs
			echo "Updated codeml.ctl in $subdirectory_path"
            ########
            # Replace ((phy file)) with the phy file name in the "codeml" file
            if [ -n "$phy_file" ]; then
                sed -i "s|((phy file))|$phy_file|" "${subdirectory_path}/codeml.ctl"
                echo "Replaced phy file name in codeml file"
            else
                echo "Phy file not found in $subdirectory_path"
            fi
                
            # Replace ((newick file)) with the newick file name in the "codeml" file
            if [ -n "$newick_file" ]; then
                sed -i "s|((newick file))|$newick_file|" "${subdirectory_path}/codeml.ctl"
                echo "Replaced newick file name in codeml file"
            else
                echo "Newick file not found in $subdirectory_path"
            fi
            #echo "Haciendo uso de fixed_omega: $value"
                # Replace ((1 or 0)) with the current value in the "codeml" file
                #sed -i "s|((omega))|$value|g" "${subdirectory_path}/codeml.ctl"
                #echo "Replaced!"

                # Activate the conda environment
                #conda activate paml
            #Which ones is working?
            echo "Now executing $subdirectory"
            grep 'fix_omega =' ${subdirectory_path}/codeml.ctl
            grep 'omega =' ${subdirectory_path}/codeml.ctl
            echo "Please modify newick file in $subdirectory according to your needs:"
            
            #Executing interactive modifier for newick in python
            python newick_formatter_for_PAML.py ${subdirectory_path}/$newick_file ${subdirectory_path}/$newick_file

            # Execute "codeml" in the subdirectory
            cd "$subdirectory_path"
            codeml
            cd "$parent_directory"

            # Revert changes to the "codeml" file for the next iteration
            cp "codeml.ctl" "$subdirectory_path"
            echo "Revertido!"
            #done
        done
    fi
done

# Define the CSV file where the results will be stored
csv_file="paml_results.csv"
echo "Directory,File,Value" > "$csv_file"

# Get the current directory
parent_directory="$(pwd)"
echo "Parent directory: $parent_directory"

echo "Ahora para el otro tipo de análisis"
echo "=== EMPIEZA EXTRACCION DE RESULTADOS DE PAML ==="

# Loop through subdirectories in the current directory
for directory in "$parent_directory"/bart_*/; do #######
    # Check if the item is a directory
    if [ -d "$directory" ]; then
    echo "Directory: $directory"
    directory_name=$(echo "$directory" | awk -F'/' '{split($(NF-1),a,"_"); gsub(/\.[^.]*$/, "", a[2]); print a[2]}')
        # Loop through subdirectories in the current subdirectory
        for subdirectory in "$directory"*/; do #######
            if [ -d "$subdirectory" ]; then
                # Extract the parent directory name
                parent_name=$(echo "$subdirectory" | rev | cut -d'/' -f2 | rev)
                # Search for {{subdirectory}}-mlc files in the subdirectory
                subdirectory_name=$(echo "$subdirectory" | awk -F'/' '{print $(NF-1)}')
                echo "THIS IS $subdirectory_name"
                
                mlc_file="${subdirectory}${subdirectory_name}-mlc"

                # Check if mlc files exist
                if [ -f "$mlc_file" ]; then
                    # Search for the line containing "lnL(ntime: 20  np: 25):  -6210.965357      +0.000000" file
                    value_line=$(grep "lnL(ntime:" "$mlc_file")
                    #echo "$value_line"
                    
                    # Search for the line containing "w (dN/dS) for branches:" in the "1-mlc" file
                    #value_line_1=$(grep "w (dN/dS) for branches:" "$one_mlc_file")
                    #echo "$value_line_1"

                    if [ -n "$value_line" ]; then
                        # Extract the value from the line
                        value=$(echo "$value_line" | awk -F':  ' '{print $2}' | awk '{print $1}')
                        
                        # Store the results in the CSV file
                        parent_mlc_file=$(echo "mlc_file" | rev | cut -d'/' -f1 | rev)
                        echo "${directory_name},${parent_name},${parent_mlc_file},${value}" >> "$csv_file"
                        echo "Found and recorded value in $mlc_file: $value"
                        
                        # Extract the value from the line
                        #value_1=$(echo "$value_line_1" | awk '{print $5}')
                        
                        # Store the results in the CSV file
                        #parent_one_mlc_file=$(echo "$one_mlc_file" | rev | cut -d'/' -f1 | rev)
                        #echo "${parent_name},${parent_one_mlc_file},${value_1}" >> "$csv_file"
                        #echo "Found and recorded value in $one_mlc_file: $value_1"
                    else
                        echo "Value not found in '${subdirectory_name}-mlc' file in $subdirectory_name"
                    fi
                else
                    echo "${subdirectory_name}-mlc file missing in $subdirectory"
                fi
            fi
        done
    fi
done


echo "Terminamos"



