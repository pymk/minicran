#!/bin/bash

# Working dir that is linked to GitHub repo
# Include the trailing slash
working_dir=$HOME/Code/minicran/

# For version numbers, see:
# https://cran.r-project.org/bin/macosx/big-sur-arm64/contrib/
# https://cran.r-project.org/bin/windows/contrib/
r_ver_mac=4.2
r_ver_win=4.3

# For version names for ARM64-based macOS chips (like M1), see:
# https://cran.r-project.org/bin/macosx/
macos_ver_name=big-sur-arm64

# Should not need to change anything below this line ---------------------------
docs_dir="${working_dir}docs/"
r_packages_csv="${working_dir}packages.csv"

# Working directory and required sub-directories
cd ${docs_dir}

mkdir -p "src"
mkdir -p "bin"

dir_src="${docs_dir}src/"
dir_bin="${docs_dir}bin/"

cran_src="https://cran.r-project.org/src/contrib/"
cran_arm="https://cran.r-project.org/bin/macosx/${macos_ver_name}-arm64/contrib/${r_ver_mac}/"
cran_x86="https://cran.r-project.org/bin/macosx/contrib/${r_ver_mac}/"
cran_win="https://cran.r-project.org/bin/windows/contrib/${r_ver_win}/"

# Sort the CSV file
sort -k1 -n -t, ${r_packages_csv} -o ${r_packages_csv}

cd ${working_dir}

# Loop through the CSV file
while IFS=, read -r package_name package_version
do
    pkg_id="${package_name}_${package_version}"
    pkg_src_filename="${pkg_id}.tar.gz"
    pkg_arm_filename="${pkg_id}.tgz"
    pkg_x86_filename="${pkg_id}.tgz"
    pkg_win_filename="${pkg_id}.zip"

    pkg_src_url="${cran_src}${pkg_src_filename}"
    pkg_arm_url="${cran_arm}${pkg_arm_filename}"
    pkg_x86_url="${cran_x86}${pkg_x86_filename}"
    pkg_win_url="${cran_win}${pkg_win_filename}"

    pkg_src_dir="${dir_src}${pkg_src_filename}"
    pkg_arm_dir="${dir_bin}macosx/${macos_ver_name}/contrib/${r_ver_mac}/${pkg_arm_filename}"
    pkg_x86_dir="${dir_bin}macosx/contrib/${r_ver_mac}/${pkg_x86_filename}"
    pkg_win_dir="${dir_bin}windows/contrib/${r_ver_win}/${pkg_win_filename}"

    # Run only if package source file does not already exist in the src dir
    if ! [ -f "${dir_src}${pkg_src_filename}" ]; then
        echo "# Downloading ${package_name} v${package_version} --------------------------------------------------"
        # Download and to staging
        curl -L ${pkg_src_url} -o ${pkg_src_dir} --create-dirs
        Rscript ${working_dir}/add_to_github.R ${pkg_src_dir}
        
        curl -L ${pkg_arm_url} -o ${pkg_arm_dir} --create-dirs
        Rscript ${working_dir}/add_to_github.R ${pkg_arm_dir}

        curl -L ${pkg_x86_url} -o ${pkg_x86_dir} --create-dirs
        Rscript ${working_dir}/add_to_github.R ${pkg_x86_dir}

        curl -L ${pkg_win_url} -o ${pkg_win_dir} --create-dirs
        Rscript ${working_dir}/add_to_github.R ${pkg_win_dir}
    fi
done < ${r_packages_csv}

# Push commits to git
git push
