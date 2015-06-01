Geoinfra Dataprocessing
=======================

Scripts and Drake workflows to process data for prototype geo-temporal store

Quickstart
----------

    git clone https://github.com/IISH/geoinfra-dataprocess
    cd geoinfra-dataprocess


make a file called `config` and put in it:

    * relative path to input data directory
    * relative path to working directory
    * postgres user
    * postgres password

e.g.:

    ../../inputdata
    ../process
    username
    password

run drake:

    drake


Data and script setup
---------------------

This repository contains the Drake workflow file and all scripts used by its steps. Think of the Drakefile as an executable Readme/TOC of the scripts.

Proposed structure, where `control` is this git repo:

    control/
        config          #specify working dir locations
        master.drake    #master drakefile `include`ing all subfiles
        cshapes/
            Drakefile
            script1.py
            script2.sql
            ...
            test/       #tests specific to cshapes
        geacron/
            ...
        gemges/
            ...
        test/           #universal/master tests
        design/         #design documents (or should this be outside this repo?)

The scripts expect a working dir and input data dir elsewhere. Probably in the same parent directory as this repo. e.g.:

    work/
        input/
            cshapes/
            ...
        process/        #working dir for all step outputs, logs.
        control/        #this repo
        design/         #alternatively, design docs in own repo?

The location of these other directories could be specified with a config file which Drakefiles can read.

This avoids storing data in the repo (size and licensing issues).

We also need some connection parameters including passwords. At the very least we shouldn't store these in our git repos. So we put these in a config file too, and read that in our Drakefile.

The scripts contain variables which are interpolated with the config values. Note that this doesn't make the scripts unuseable on their own; you can pass them arguments on the command line.
