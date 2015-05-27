Geoinfra Dataprocessing
=======================

Scripts and Drake workflows to process data for prototype geo-temporal store

Diverse input datasets need to be mapped to a single internal model. The transformations should be broken down into as small steps as possible. Any dependencies should be handled automatically (by using Drake).

Ideally the development process should be testable. How will we do that?

Testing data processing is difficult. It's hard to get small, quick test results when you're processing potentially huge datasets.


Data and script setup
---------------------

Make it as easy as possible to manage data and scripts.


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



Unified logging and error handling
----------------------------------

If I understand correctly, we need to do something with the exit status to detect error methods. The reason my workflows are continuing after errors is because my scripts are not producing non-zero exit status. What seems -- at the moment -- the best way to set this up is to use the shell protocol, call our script (node, sql, what have you) with the input and output arguments, and let the script a) decide whether it will write to the output file, b) exit with an error. This way we can write something to the log and then still exit with error; or we can exit with error without writing to the log if we prefer.

It would be cool to call test functions from the update scripts as well. This way we can use the output of those to determine exit status, esp. during development.


TopoJSON
--------

We need to create topojson. Either pre-cached or on-the-fly. We need a separate endpoint for it. Everything prefixed with `topojson`.

Then we need to create on-the-fly request handlers. But, if we start doing that, then we might as well ditch apache entirely and run our api with nodejs. So, let's say we can only request 'countries' as topojson for now, with time parameters. No entity filtering. Then we can create files for those, and redirect straight to them.
