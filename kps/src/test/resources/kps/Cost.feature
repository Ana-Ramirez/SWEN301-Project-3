Feature: Cost

   Scenario Outline: The higher the (domestic) priority, the more expensive it is for the customer

   I created a few pieces of data in the data.xml file in order to test this. Not sure if we're allowed to do that or not...


      Given an initial cost map
      Given a cost parcel that weighs <Weight>kg
      Given a cost parcel that measures <Measurement> cc
      And I send the cost parcel from "<FromCity>" "<FromCountry>"
      And I send the cost parcel to "<ToCity>" "<ToCountry>"
      Given a cost route exists for domestic air
      Given a cost route exists for domestic standard
      Then sending domestic air should cost more than domestic standard
      Examples:
         | Weight | Measurement | FromCity   | FromCountry | ToCity            | ToCountry   |
         |   2    |  1000       | Wellington | New Zealand | Auckland          | New Zealand |
         |   2    |  1000       | Wellington | New Zealand | Christchurch      | New Zealand |


    Scenario Outline: Customer is charged the same no matter where the parcel is sent from or to (domestically)

       I created a few pieces of data in the data.xml file in order to test this. Not sure if we're allowed to do that or not...
       The routes coming from Wellington have a weightcost and volumecost of 10, whereas the ones from Auckland have a weightcost and volumecost of 5

       The specification gives a few contrasting statements but I have decided to conclude the following:
       If the weight and measurement of a parcel is the same, the customer should be charged the same no matter where the parcel is being sent from or is going to (domestically)

       Given an initial cost map
       Given a cost parcel that weighs <Weight>kg
       Given a cost parcel that measures <Measurement> cc
       And I send the cost parcel from "<FromCity>" "<FromCountry>"
       And I send the cost parcel to "<ToCity>" "<ToCountry>"
       And I send the cost parcel by "<Priority>"
       Then the parcel costs $<ExpectedCost>

       Examples:
          | Weight | Measurement | FromCity   | FromCountry | ToCity            | ToCountry   | Priority           | ExpectedCost   |
          | 10     | 1000        | Wellington | New Zealand | Auckland          | New Zealand | domestic standard  | 100            |
          | 10     | 1000        | Wellington | New Zealand | Christchurch      | New Zealand | domestic standard  | 100            |
          | 10     | 1000        | Auckland   | New Zealand | Dunedin           | New Zealand | domestic standard  | 50             |
          | 10     | 1000        | Auckland   | New Zealand | Palmerston North  | New Zealand | domestic standard  | 50             |



