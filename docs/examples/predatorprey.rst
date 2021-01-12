Predator-Prey Model
===================

In this tutorial, we will step by step build solutions to the Lotka-Volterra equations.

Metabolic rate for predator
---------------------------

The predator will have intrinsic maintenance metabolic rate. The first step is to create a node called predator, with biomass as dynamical variable 
and maintenance as a parameter. Further on, we define the differential equation for the maintenance :math:`\frac{dB}{dt}=-\alpha B`.

.. code::

    NodeDef Predator      // Define a new node called Predator
    {                     // Begin the spesification section of the node
       dynamic B;         // Define an uninitialized dynamical variable
       parameter alpha=1; // Define an initialized parameter
       .B = -alpha*B;     // The differential equation for the node
    };                    // Nodedef needs to ends with semicolon

This is now our model. The next step is to deploy the model into use. We write

.. code::

    deploy Predator 
    {
       B = 230;           // We need to initialize the dynamical variable
       alpha = 0.171;     // We can also override the previous value on alpha parameter.
    };

Now we have both defined the model, and spesified all required parametrizations of the model. Next step is to run the simulation. In simulate 
section, one can spesify all parameters for the numerical simulation. However, there are some reasonable defaults, so for the first demo, we will 
just run with those.

.. image:: metabolicrate.png

Producer with exponential growth
--------------------------------

We can now create the model with both predator and prey, but without interaction. If we give the
ATNIntrinsicGrowthModel an infinite basal capacity, the model becomes just exponential growth model.

.. code:: matlab

    model = ATNModel();
    preys = [ ATNProducer('label',  'prey', ...
                          'name',   'Prey', ...
                          'binit',  10.0, ...
                          's',      0.0, ...
                          'igr',    log(2)) ]; % Doubles in one time-unit
    predators = [ ATNSimplePredator('label',  'pred', ...
                                    'name',   'Predator', ...
                                    'binit',  1.0, ...
                                    'mbr',      0.1) ];
    model.add([ predators preys])
    model.add(ATNMetabolicRate(predators));
    model.add(ATNIntrinsicGrowthModel(preys,'K', inf));
    model.compile.simulate(100).summary();

.. image:: predprey.png

Predator-Prey interaction
-------------------------

We may further add predator-prey interaction term utilizing the :code:`ATNPredPreyInteraction`.

.. code:: matlab

    model = ATNModel();
    preys = [ ATNProducer('label',  'prey', ...
                          'name',   'Prey', ...
                          'binit',  10.0, ...
                          's',      0.0, ...
                          'igr',    log(2)) ]; % Doubles in one time-unit
    predators = [ ATNSimplePredator('label',  'pred', ...
                                    'name',   'Predator', ...
                                    'binit',  1.0, ...
                                    'mbr',      0.1) ];
    model.add([ predators preys])
    model.add(ATNMetabolicRate(predators));
    model.add(ATNIntrinsicGrowthModel(preys,'K', inf));
    model.add(ATNPredPreyInteraction(preys, predators, [ 0.1 ]));
    model.compile.simulate(1000).summary();

.. image:: lotkavolterra.png

It is also instructive to see variation on parameters. Here we use :code:`ATNLogNormal`-distribution instead, to guarantee positivity of the ensemble variables.

.. code:: matlab

    model = ATNModel();
    preys = [ ATNProducer('label',  'prey', ...
                          'name',   'Prey', ...
                          'binit',  ATNLogNormal(1.0,'30%'), ...
                          's',      0.0, ...
                          'igr',    log(2)) ]; % Doubles in one time-unit
    predators = [ ATNSimplePredator('label',  'pred', ...
                                    'name',   'Predator', ...
                                    'binit',  ATNLogNormal(1.0,'30%'), ...
                                    'mbr',    ATNLogNormal(0.1,'10%')) ];
    model.add([ predators preys])
    model.add(ATNMetabolicRate(predators));
    model.add(ATNIntrinsicGrowthModel(preys,'K', inf));
    model.add(ATNPredPreyInteraction(preys, predators, ATNLogNormal(0.2,'40%')));
    ATNEnsemble(model, 500,50).summary()

.. image:: predpreyensemble.png

Multi predator-multi prey interaction
-------------------------------------

In this example we create multiple predators and preys. Now, the interaction becomes a (number of predators) x (number of preys matrix).

.. code:: matlab

    model = ATNModel();
    for i=1:5
        preys(i) = [ ATNProducer('label',  sprintf('prey%d', i), ...
                                 'name',   sprintf('Prey %d', i), ...
                                 'binit',  ATNGaussian(1.0,'10%'), ...
                                 's',      0.0, ...
                                 'igr',    ATNGaussian(log(2), '20%')) ]; % Doubles in one time-unit
    end
    for i=1:3
       predators(i) = [ ATNSimplePredator('label',  sprintf('pred%d',i), ...
                                          'name',   sprintf('Predator %d',i), ...
                                          'binit',  ATNGaussian(1.0,'10%'), ...
                                          'mbr',    ATNGaussian(0.1,'10%')) ];
    end
    model.add([ predators preys])
    model.add(ATNMetabolicRate(predators));
    model.add(ATNIntrinsicGrowthModel(preys,'K', inf));
    model.add(ATNPredPreyInteraction(preys, predators, rand(3,5)*0.1));
    results = model.compile.simulate(100);
    results.summary('loglimits',[-6 2])

.. image:: multipredatorprey.png

Flexibility of ATNModel
-----------------------

To illustrate the flexible structure, we perform a hard optimization task requiring complex real time modification of model.
To start with, we create a food chain with a single producer and 4 consecutive consumers eating each other.
We then subsequently create a random model with metabolic rate parameters close, but different from the previous model. If we find
increase in the biodiversity function (arbitrarily defined as sum of logarithmic biomassess), we accept the modification.
If the biodiversity decreases, we reject the modification and try again.

.. literalinclude:: evo.m
    :language: matlab
    :linenos:

We note that the metabolic rate values decrease as the trophic level increases as expected.

.. image:: evosim.png



.. code::

    simulate
    {
           // Using the default parameters
    };


Next step is to visualize the results

.. code::

    visualize
    {
           // Using the default visualization
    };

In fact. If the cod

The solution yields a exponential decay of initial predator biomass.

