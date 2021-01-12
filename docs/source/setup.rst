.. _setup:
Setting up ATNS
=============================

In this tutorial, you will download ATNS zip-file (or the latest git version from the repository, and set up the environment).

Download and unzip the ANTS code
------------------------------------

Unzip the code some well defined location. For example :code:`C:\users\username\atns`. Copy the path to folder to clipboard.

Matlab environment
---------------------------

Start Matlab, and create a new working directory (not the same as the ATNS code). The basic principle is, that users modifications and the main code are not mixed at any stage.

Create a :code:`init.m` file, with following content

.. code::

    run('C:\users\username\atns\atnsinit.m');

Every time you begin to use the code, you may now type :code:`startup`, and the code search directories are automatically set up.

.. code::

    init

You may test that the paths have been correctly set up, by typing :code:`atnsdemo`.

.. code::

   >> atnsdemo
   ATNS is set up in your search path.


It is also strongly recommended that test suite is run after every update. You may run tests by typing :code:`dotests`.

.. code::

   >> dotests
   ...
   ...
   Totals:
      27 Passed, 5 Failed (rerun), 5 Incomplete.
      39.9772 seconds testing time.

All tests should pass. In the code above the test suite has failed with 5 tests.

Next step
------------------

You may proceed to run your first example :ref:`atnssimple`.

