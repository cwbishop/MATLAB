GAB (Generalized Analysis Batching) is a matlab batching system I built at UC Davis for helping to automate fMRI and EEG analysis. It comes with ways to batch SPM8 and EEGLab, but is easily extensible.

In writing a analysis batching script for the lab, we first have to consider what we would want. I came up with the following goals for the scripts:

    Simple: That it is possible run a whole study from a single line of code.
    Efficient: It needs to know the steps necessary before each job, so that it won't redo things that are already done, but only if errors have occurred or parameters have changed.
    Modular: It is absolutely critical for us to be able to drop in new analysis types with very little modification. We don't want to have to rewrite this every time we come up with a new analysis.
    Branching: We want multiple steps of an analysis to depend on a single pre-processing step, and a single analysis to depend on multiple pre-processing steps.
    Clear: It needs to be very easy to understand how the data that we get was created.
    Centralized: to have one central place that we look to see all of the variables which went into processing a set of data. This makes it easy to both change a variable of your study, and easy to replicate the analysis later on.

We already are working with a pretty wonderful assortment of analysis tools and there's no sense in reinventing the wheel, so we'll center our code around:

    rocks/SGE/PBS - for parallel processing
    spm - for fmri analysis
    eeglab - for eeg analysis

GAB (generalized analysis batching) code

Using the ideas mentioned above, we have created some matlab code called gab. The aim is to be a one stop shop for all of our analysis needs that can do anything matlab can do, and keeps track of all the important bits of information about our analysis for us. Hopefully the information below will get someone up to speed on working with the code.

First, for a basic outline of the way gab works. In gab there are two main terms you need to keep in mind: Tasks and Jobs. Tasks are the real workhorses of the analysis and the most variable. They can really be anything you imagine in Matlab from saving a file to running a Source analysis model. They are basically just a function handle and some arguments. Jobs are collections of tasks that interact much more with the batching part of the scripts. They track which jobs should be run before this job, which functions will need to be called to use the tasks listed in the job (and provide a mechanism to see if those functions have been modified), tell you if/when the job has been run, and what errors were encountered.

So, if you were to try and run a task, that task would just run, no matter what. It could overwrite data files without a record of it and all sorts of other nastiness. While sometimes you need to do this for debugging, it's usually better to rely on running jobs, not tasks. In order to get comfortable working with jobs you should familiarize yourself with the basic data structure of a job.

A job is defined as a matlab data structure with certain fields:

    .jobName - (string) generally lets you know a bit of what this job will be doing, and also provides the name for the file the job will be saved under
    .jobDir - (string) this lists the full path of the directory where the job will be saved
    .parent - (cell array of strings) this lists the full path to the job file(s) that need to be run successfully before this job can be run
    .task - (cell array of structs) this is a list of the tasks that will be performed (in order) by the job when it is run, and any relevant information that needs to be passed to those task functions
    .results - (cell array) a currently barely used field. In theory, you could put data here that resulted from the output of the tasks. This was an idea left over from the Janata lab scripts that just stuck around. Mostly we save our data to files through eeglab or spm.
    .status - (string) the status of the job, usually either 'new' 'running' 'finished' or 'error'
    .jid - (number) the ID of the job as it was handled by the process that does the work of submitting the jobs to be run. If you are using a parrallel job handler such as SGE, the appropriate 'foreman' should put the SGE job ID # here.
    .runTime - (datenumer) just the time at which the job started running in the format of matlab's 'now()'
    .error - (structure) empty if everything goes well, but it will be the full matlab error structure with full stack for debuging purposes.

A job structure can be generated on the fly, or saved as a standard .mat file to maintain a record of what has been run
task structure

The task stucture is very simple, and usually just contains three fields:

    .func - (function handle) a handle of the function that should be called. functions must require only one input argument, a structure. There is a number of different task functions in the ./task/ dir in the gab dir that can do most eeg and spm processing steps.
    .args - (structure) a structure of all of the arguments that should be passed to the function called by name. What the arguments should be named exactly is completely determined by the task function. for example, you might have '.source' and '.destination' fields in .args which told you the source file to read in, then the location to save the results.
    .funcHashes - This is a structure which contains information on the contents of the main function called by this task, and all functions called by that function according to the depfun() function in matlab. Right now it uses the unix md5sum function to find a hash. If anything about the job structure changes between runs, including the hashes, the job is considered to be a new job and is rerun. This allows us to be absolutely sure that any changes we make in the code are propagated into the analysis results. In some ways it is overly conservative, as simply adding a comment will change the md5 hash, but I felt it was better to be safe than sorry.

Job flow in Gab

The basic way to run a study is to create a gab_setup file. This file is a script that builds a series of jobs based on your study's needs. Because you build all of the individual subject and group jobs within this file, all of the arguments to pass the functions are contained there, making it the first place to go when you want to change something. You can pass these jobs to gab_jobman() and it will compare them against any job saved with the same .jobName and .jobDir. If everythign goes well, this is all you ever need to do. You can use gab_check_job() with the same setup script to check on the status of all the running/finished jobs.

Troubleshooting in Gab

Ofcourse, everything won't go smoothly, and there will be some error in the processing steps. You will use gab_check_job() and see a status of 'error' for one or more of the jobs. The thing to do then is to go and actually just load the job file into the matlab workspace and check out the .error field. This is a standard matlab error structure and so can be rethrow()'n but usually you just need to look at the .stack field (often just the last entry) which will give you information on the function and line that is giving you the issue. the .message field in the error structure can also clue you in on what will make that line happy. If you are really having a hard time figuring out what's going on in the function, you can go and run the tasks by hand in matlab with gab_run_task(job.task{x}). This will allow you to enter an interactive debugger if you have 'dbstop if error' set.

potential changes/roadmap

This is a loose collection of idea to change and improve gab

    the tasks probably don't need to be a cell array of structs and could just be an array of structs. not a big deal
    the hashes for functions get computed i think twice per job right now. Obviously when we are doing a large batch of subjects who all depend upon the same functions, this is wasteful. there are probably ways of streamlining this using a global variable or something which stores hashes of checked files, but the time cost is ~15-20 seconds to rerun an entier study, so right now it's just not worth it to fix
    along these same lines, I've thought about trying to get gab integrated with a versioning system such as svn or git, so that you could actually rollback code to the code used in an old analysis, but this is would be a ton of work
    We haven't yet had any need to move job files around, but I can imagine situations where this could be useful to pass of a project to someone else. It might work seemlessly, or it might not, but it would be good to check. Worst case scenario you would just have to change the gab_setup file and rerun all of the jobs again, which might be only marginally slower than moving over all of the processed data files.
    In my dream world (which someone should help me build) Gab would be rewritten in something like python, use a library similar to Yahoo Pipes to give a graphical representation of data flow, and be connected to a subject database such as Ensemble (http://atonal.ucdavis.edu/ensemble/) and a central storehouse of raw data. So make that happen okay? Actually, there is already something a bit similar with NIPypes (http://nipy.sourceforge.net/nipype/) but it is missing the key feature for me in using function hashes. Analysis is such a hacking process that when my code, not just the parameters, stops changing I'm done. This means without function hashes I have no good idea what state the data is in.
