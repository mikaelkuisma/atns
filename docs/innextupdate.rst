Near future properties
=======================

Efficiency
------------------
ATNS will automatically produce Matlab code, increasing speed by factor of 200. Now this is not yet ready for all advanced properties, thus disabled.

Sessions
-------------------
ATNS will be usable as a session, which can contain multiple simulatenously running simulations.

fork: Flexible parallelization
------------------------------
New statement fork will be introduced. This will automatically parallelize the code.

For example, following code would automatically run 4 parallel simulations distinct B.
.. code::

    fork (parameter B=[1,2,3,4])
    {
    };

Visualization of the network
------------------------------
Right now, all the links are written with plain text. An editor where one may interactively put different kinds of links to guilds will be provided.

Web interface
------------------

Node.js/react Application for more attractive GUI.
