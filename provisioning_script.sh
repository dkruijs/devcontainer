start=`date +%s`

# load environment variables
source ./.env

echo "[status:] get and install ubuntu packages"
apt-get update
apt-get upgrade
apt-get install -y git-core wget snapd # TODO consider making optional what isn't used (snapd in case of no VS code)

# TODO modularize this script into separate shell scripts
# TODO perhaps separate python package installation into data science packages (conda) 
    # and py package production packages (pip/venv?)

if [ $INSTALL_PYTHON_PACKAGES = 1 ]; then

    echo "[status:] get and install miniconda"
    wget https://repo.anaconda.com/miniconda/$MINICONDA_VERSION
    chmod +x ./$MINICONDA_VERSION
    ./$MINICONDA_VERSION -b # -b is for Batch mode, no prompts
    export PATH=/root/miniconda3/bin:$PATH

    # TODO freeze all versions (conda freeze command?)
    # TODO I definitely want to use cookiecutter... which requires python. Consider making python non-optional.
    conda config --append channels conda-forge

    # TODO consolidate all conda commands into one for efficiency
    # TODO install sphinx package (python or ubuntu?)
    conda install cookiecutter=1.7.0
    conda install tox
    conda install click
    conda install joblib
    conda install -c anaconda pytest
    # conda install python-dotenv # TODO: required?
    conda install virtualenv # TODO: virtualenv benefits over venv? 
    conda install jupyter
    conda install pandas
    conda install scikit-learn
    conda install -c anaconda scipy
    conda install -c conda-forge pandas-profiling=2.3.0
    conda install -c conda-forge voila
    conda install -c conda-forge matplotlib
    conda install -c anaconda seaborn 
    conda install -c anaconda flask
    conda install -c conda-forge flask-restful

    conda clean -ya

fi

if [ $BUILD_COOKIECUTTER_DATA_SCIENCE = 1 ]; then

    echo "[status:] build cookiecutter template for data science"

    # collect the 'cookiecutter-data-science' project template from github
    git clone https://github.com/drivendata/cookiecutter-data-science

    # insert custom values from env into cookiecutter.json
    # TODO: create my own cookiecutter template based on this, which doesn't require the s3 bucket and AWS profile.
    cat > ./cookiecutter-data-science/cookiecutter.json <<- EOM
        {
            "author_name": "$DS_AUTHOR_NAME",
            "email": "$DS_EMAIL",
            "project_name": "$DS_PROJECT_NAME",
            "repo_name": "{{ cookiecutter.project_name.lower().replace(' ', '_') }}",
            "description": "$DS_DESCRIPTION",
            "release_date": "$DS_RELEASE_DATE",
            "year": "$DS_YEAR",
            "version": "$DS_VERSION",
            "s3_bucket": "$DS_S3_BUCKET",
            "aws_profile": "$DS_AWS_PROFILE",
            "open_source_license": [$DS_OPEN_SOURCE_LICENSE_LIST],
            "python_interpreter": [$DS_PYTHON_INTERPRETER_LIST]
        }
        
EOM

    # create project folder from template
    cookiecutter ./cookiecutter-data-science/ --no-input

    # delete no longer required template
    # rm -rf ./cookiecutter-data-science

fi

# TODO: maybe, consider if this should be deployed _inside_ the 'prod' folder of the data science template
if [ $BUILD_COOKIECUTTER_PYTHON_PACKAGE = 1 ]; then

    echo "[status:] build cookiecutter template for python package development"

    # collect the 'cookiecutter-data-science' project template from github
    git clone https://github.com/audreyr/cookiecutter-pypackage

    # insert custom values from env into cookiecutter.json
    # TODO: create my own cookiecutter template based on this, which doesn't require the s3 bucket and AWS profile.
    cat > ./cookiecutter-pypackage/cookiecutter.json <<- EOM
        {
            "full_name": "$PY_FULL_NAME",
            "email": "$PY_EMAIL",
            "github_username": "$PY_GITHUB_USERNAME",
            "project_name": "$PY_PROJECT_NAME",
            "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '_').replace('-', '_') }}",
            "project_short_description": "$PY_PROJECT_SHORT_DESCRIPTION",
            "pypi_username": "{{ cookiecutter.github_username }}",
            "version": "$PY_VERSION",
            "use_pytest": "$PY_USE_PYTEST",
            "use_pypi_deployment_with_travis": "$PY_USE_PYPI_DEPLOYMENT_WITH_TRAVIS",
            "add_pyup_badge": "$PY_ADD_PYUP_BADGE",
            "command_line_interface": [$PY_COMMAND_LINE_INTERFACE_LIST],
            "create_author_file": "$PY_CREATE_AUTHOR_FILE",
            "open_source_license": [$PY_OPEN_SOURCE_LICENSE_LIST]
        }
        
EOM

    # create project folder from template
    cookiecutter ./cookiecutter-pypackage/ --no-input

    # delete no longer required template
    # rm -rf ./cookiecutter-pypackage

fi

if [ $INSTALL_VS_CODE = 1 ]; then
    
    echo "[status:] install VS Code"
    
    # dependencies for VS code and add-apt-repository
    apt-get install --assume-yes libx11-xcb1 libasound2 software-properties-common 

    wget -q https://packages.microsoft.com/keys/microsoft.asc -O - | apt-key add -
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    apt-get update
    apt-get install -y code

fi

end=`date +%s`

runtime=$(( end-start ))
runtime=$(( runtime/60 ))
echo "[status:COMPLETED] provisioning script execution time was: $runtime minute(s)"