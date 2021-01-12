.. _session:

Using ATNS via session in Matlab
==========================================

In this tutorial, you will learn how to set up an ATNS session. Session help keep track of files, as it stores the input scripts for each run in separate directory along with the 
results. 

To use any ATNS functionality, you need to create an ATNS session. This is done easily just by writing

.. code::

    atn = session('mySession');

This creates a variable atn to Matlab workspace, you may use to access the session. The mySession is the name of the directory where all files will be stored. Letters 'a'-'z','A'-'Z' 
and '0'-'9' are supported.

You may get topical information about the session by typing the variable name :code:`atn`.

.. code::

    >> atn
    No source file. Write
      atn.source('mysource.model');
    to add a source file.


Sample code
---------------------------

We will build a simple Lotka--Volterra model, and save it to a file :code:`lv.model`. You may also download it directly :download:`here <lv.model>`.

.. literalinclude:: lv.model

Let's now add the code, by writing :code:`atn.source('lv.model');`.

.. code::

   >> atn.source('lv.model');
   Copying file lv.model to mySession\lv.model.
   Current source file is now: lv.model
   Reading source lv.model...
   Parsing...
   Compiling...
   Written 214 bytes to mySession\main.code.

Running the model
---------------------------
We may now again type :code:`atn` and see that a source file has been added.

.. code::

   >> atn
   Source file: lv.model

   Write
        atn.run('myRunDir');
   to run the model.


By executing the given statement :code:`atn.run('lvrun')`, where lvrun is identifier for the run.

.. code::

   >> atn.run('lvrun');
   Source file lv.model is up to date.
   Running at directory mySession\run_lvrun.
   ODE-parameters: Timestep: 0.1 Steps: 320.
   DONE.
   Stored results to mySession\run_lvrun\results.mat.


Displaying the results
---------------------------
Again typing :code:`atn`, we obtain information about runs.

.. code::

    >> atn
    Source file: producer.model

    Stored results by id:
        * lvrun               Created: 11-Jan-2021 08:22:46 SELECTED



Same session may contain results of multiple runs, and thus it is relevant to look which run is selected for analysis. Type :code:`atn.select('otherrun');` to select a different result set to analyze.

