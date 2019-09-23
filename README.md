---
layout: lesson
root: ../..
title: Scaling Up
---
<!-- <div class="objectives" markdown="1">

#### Objectives
*   Learn how to write an HTCondor submit script.
*   Learn how to submit multiple jobs at once with HTCondor.
*   Visualize how jobs distribute on OSG.

-->

### Overview

In this section, we will learn how to quickly submit multiple jobs simultaneously using HTCondor and we will visualize where these jobs run so we can get an idea of where and jobs are distributed on the Open Science Grid.

### Gathering network information from the OSG

Now to create a submit file and that will run in the OSG!

1.  Use the command `cd ..` to move out of the `tutorial-quickstart` folder
2.  Change into the `scaling-up` directory with `cd scaling-up`

### Hostname fetching code

The following Python script finds the ClassAd of the machine it's running on and finds a network identity that can be used to perform lookups:

``` file
#!/bin/env python

import re
import os
import socket

machine_ad_file_name = os.getenv('_CONDOR_MACHINE_AD')
try:
    machine_ad_file = open(machine_ad_file_name, 'r')
    machine_ad = machine_ad_file.read()
    machine_ad_file.close()
except TypeError:
    print socket.getfqdn()
    exit(1)

try:
    print re.search(r'GLIDEIN_Gatekeeper = "(.*):\d*/jobmanager-\w*"', machine_ad, re.MULTILINE).group(1)
except AttributeError:
    try:
        print re.search(r'GLIDEIN_Gatekeeper = "(\S+) \S+:9619"', machine_ad, re.MULTILINE).group(1)
    except AttributeError:
        exit(1)
```

You will be using `location-wrapper.sh` as your executable and `wn-geoip.tar.gz` as an input file.

The submit file for this job, `scalingup.submit`, is setup to specify these files and
submit **fifty** jobs simultaneously. It also uses the job's `process` value to create unique output, error and log files for each of the job.

``` console
$ cat scalingup.submit
# We need the job to run our executable script, with the
#  input.txt filename as an argument, and to transfer the
#  relevant input and output files:
executable = location_wrapper.sh
transfer_input_files = wn-geoip.tar.gz

# We can specify unique filenames for each job by using
#  the job's 'process' value.
error = job.$(Process).error
output = job.$(Process).output
log = job.$(Process).log

# The below are good base requirements for first testing jobs on OSG, 
#  if you don't have a good idea of memory and disk usage.
request_cpus = 1
request_memory = 1 GB
request_disk = 1 GB

# Queue fifty jobs with the above specifications.
queue 50
```

Submit this job using the `condor_submit` command:

``` console
$ condor_submit scalingup.submit
```

Wait for the results. Remember, you can use `watch condor_q` to monitor the status of your jobs.

### Collating your results

Now that you have your results, it's time to summarize them.
Rather than inspecting each output file individually, you can use the `cat` command 
to print the results from all of your output files at once. If all of your output 
files have the format `job.#.output` (e.g., `job.10.output`), your command will 
look something like this:

``` console
$ cat job.*.output
```

The `*` is a wildcard so the above cat command runs on all files that start with `location-` and end in `.out`.
Additionally, you can use `cat` in combination with the `sort` and `uniq` commands to print only the unique results:

``` console
$ cat job.*.output | sort | uniq
```

### Mapping your results

To visualize the locations of the machines that your jobs ran on, you will be using http://www.mapcustomizer.com/. Copy and paste the collated results into the text box that pops up when clicking on the 'Bulk Entry' button on the right-hand side. Where did your jobs run?
