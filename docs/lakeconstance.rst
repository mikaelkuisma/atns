.. _lakeconstance:


Lake Constance as Black Box
============================

In this tutorial, we run a sophisticated simulation. The details of the model-code used will be addressed later, here we focus in running and analyzing its results.


First run
------------------------------------

Begin downloading :download:`lakeconstance.inc<lakeconstance.inc>`-file, which specifyes all necessary nodes and links in Lake Constance in a single file.
Thus, for first run, it sufficies to create a following simple file :code:`lc.model`.

.. code::

    include "lakeconstance.inc";
    

We may now run the code, again, by writing :code:`results = atns('lc.model')`. Plotting the results, 


.. code::
    
    results.overview();

we find that they are much more structure. However, the variables do not follow any 
periodic patterns, since we do not have any periodic interference affecting the system. This will be addressed later.

Simulation parameter with Matlab
--------------------------------

Sometimes it will be easier to configure system at Matlab script-level. To that end, the :code:`atns`-function takes also simulation parameters after. 
These will override any parameters set in the simulation.

.. code::

   >> results = atns('lv.model','SolverParameters',SolverParameterSet('steps_per_day', 10,
                                                                      'day_length', 1,
                                                                      'days_per_year', 90,
                                                                      'day_name', 'day',
                                                                      'year_name', 'year'));

Next step
----------------

You may now simulate a first real system, Lake Constance in section :ref:`lakeconstance`.

