Feature: Delivery

  Scenario: Send some mail
     Given an initial map
     Given a parcel that weighs 1kg
     Given a parcel that measures 1000 cc
     And I send the parcel from "Wellington" "New Zealand" 
     And I send the parcel to "Palmerston North" "New Zealand" 
     And I send the parcel by "domestic standard"
     Then the cost is $5


  Scenario: Send some mail from Wellington to Singapore

     Testing something simple (slight extension of initial provided test)

     Given an initial map
     Given a parcel that weighs 2kg
     Given a parcel that measures 150 cc
     And I send the parcel from "Wellington" "New Zealand"
     And I send the parcel to "Singapore City" "Singapore"
     And I send the parcel by "international air"
     Given a route for this destination exists
     Then stop off in route is "Auckland" "New Zealand"


  Scenario Outline: Price of mail coming from overseas should be $0 for KPS

     In this scenario outline, I'm assuming that "no cost" is meaning that it costs $0 for KPS, not the customer

     Given an initial map
     Given a parcel that weighs <Weight>kg
     Given a parcel that measures <Measurement> cc
     And I send the parcel from "<FromCity>" "<FromCountry>"
     And I send the parcel to "<ToCity>" "<ToCountry>"
     And I send the parcel by "<MailPriority>"
     Given a route for this destination exists
     Then the cost is $<ExpectedCost>

     Examples:
     | Weight  | Measurement  | FromCity        | FromCountry     | ToCity       | ToCountry    | MailPriority             | ExpectedCost |
     | 1       | 10           | Singapore City  | Singapore       | Wellington   | New Zealand  | international standard   | 0            |
     | 1       | 10           | Singapore City  | Singapore       | Auckland     | New Zealand  | international standard   | 0            |
     | 1       | 10           | Place           | Martin Island   | Auckland     | New Zealand  | international standard   | 0            |
     | 1       | 10           | Montreal        | Canada          | Auckland     | New Zealand  | international air        | 0            |
     | 1       | 10           | Sydney          | Australia       | Auckland     | New Zealand  | international air        | 0            |


  Scenario Outline: Mail can only enter foreign country through a single city

     According to the specification, all mail going to an overseas country goes through the same port
     This means that for each foreign country (a non-New Zealand country), there should only be ONE city that the mails enters the foreign country through

     Given an initial map
     And sending mail to overseas country: "<Country>"
     Then destination city should only be one option

     Examples:
     | Country       |
     | Australia     |
     | Canada        |
     | Martin Island |
     | Singapore     |


  Scenario Outline: Air priority is always followed

     According to the specification, if the mailPriority is international air, international air must always be the method of shipment
     I am testing pairs of to and from destinations multiple times because there seems to be inconsistency issues in the data.

     NOTE: For each pair (e.g. Auckland to Singapore), if not all the tests pass or not all the tests fail (i.e. some fail and some pass), there is inconsistency in the data.

     Given an initial map
     Given a parcel that weighs <Weight>kg
     Given a parcel that measures <Measurement> cc
     And I send the parcel from "<FromCity>" "<FromCountry>"
     And I send the parcel to "<ToCity>" "<ToCountry>"
     And I send the parcel by "<MailPriority>"
     Given a route for this destination exists
     Then the method of shipment is international air

     Examples:
        | Weight | Measurement | FromCity   | FromCountry | ToCity          | ToCountry     | MailPriority        |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international air   |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international air   |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international air   |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international air   |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international air   |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international air   |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international air   |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international air   |


  Scenario Outline: Mail travels by ground or sea unless the only option available is air

     The specification states that land or sea always take preference to air (unless air is the only option available)

     NOTE: For each pair (e.g. Auckland to Singapore), if not all the tests pass or not all the tests fail (i.e. some fail and some pass), there is inconsistency in the data.

     Given an initial map
     Given a parcel that weighs <Weight>kg
     Given a parcel that measures <Measurement> cc
     And I send the parcel from "<FromCity>" "<FromCountry>"
     And I send the parcel to "<ToCity>" "<ToCountry>"
     And I send the parcel by "<MailPriority>"
     Given a route for this destination exists
     Given land and sea options exist
     Then the method of shipment is by land or sea

     Examples:
        | Weight | Measurement | FromCity   | FromCountry | ToCity          | ToCountry     | MailPriority           |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international standard |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international standard |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international standard |
        | 1      | 10          | Auckland   | New Zealand | Singapore City  | Singapore     | international standard |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international standard |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international standard |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international standard |
        | 2      | 20          | Wellington | New Zealand | Singapore City  | Singapore     | international standard |
        | 3      | 30          | Auckland   | New Zealand | Place           | Martin Island | international standard |
        | 3      | 30          | Auckland   | New Zealand | Place           | Martin Island | international standard |
        | 3      | 30          | Auckland   | New Zealand | Place           | Martin Island | international standard |
        | 3      | 30          | Auckland   | New Zealand | Place           | Martin Island | international standard |


  Scenario Outline: Auckland can send mail to at least one other place in NZ

     My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
     Therefore, Auckland must be able to send mail to at least one other city in NZ

     Given an initial map
     Given a parcel that weighs <Weight>kg
     Given a parcel that measures <Measurement> cc
     And I send the parcel from "<FromCity>" "<FromCountry>"
     And I send the parcel to "<ToCity>" "<ToCountry>"
     And I send the parcel by "<MailPriority>"
     Then a route for this destination exists

     Examples:
        | Weight  | Measurement    | FromCity       | FromCountry   | ToCity          | ToCountry   | MailPriority      |
        | 1       | 10             | Auckland       | New Zealand   | Christchurch    | New Zealand | domestic standard |
        | 1       | 10             | Auckland       | New Zealand   | Dunedin         | New Zealand | domestic standard |
        | 1       | 10             | Auckland       | New Zealand   | Hamilton        | New Zealand | domestic standard |
        | 1       | 10             | Auckland       | New Zealand   | Palmerston North| New Zealand | domestic standard |
        | 1       | 10             | Auckland       | New Zealand   | Rotorua         | New Zealand | domestic standard |
        | 1       | 10             | Auckland       | New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Christchurch can send mail to at least one other place in NZ

      My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
      Therefore, Christchurch must be able to send mail to at least one other city in NZ

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity       | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Christchurch   | New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Christchurch   | New Zealand   | Dunedin         | New Zealand | domestic standard |
         | 1       | 10             | Christchurch   | New Zealand   | Hamilton        | New Zealand | domestic standard |
         | 1       | 10             | Christchurch   | New Zealand   | Palmerston North| New Zealand | domestic standard |
         | 1       | 10             | Christchurch   | New Zealand   | Rotorua         | New Zealand | domestic standard |
         | 1       | 10             | Christchurch   | New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Dunedin can send mail to at least one other place in NZ

   My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
   Therefore, Dunedin must be able to send mail to at least one other city in NZ

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity       | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Dunedin        | New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Dunedin        | New Zealand   | Christchurch    | New Zealand | domestic standard |
         | 1       | 10             | Dunedin        | New Zealand   | Hamilton        | New Zealand | domestic standard |
         | 1       | 10             | Dunedin        | New Zealand   | Palmerston North| New Zealand | domestic standard |
         | 1       | 10             | Dunedin        | New Zealand   | Rotorua         | New Zealand | domestic standard |
         | 1       | 10             | Dunedin        | New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Hamilton can send mail to at least one other place in NZ

      My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
      Therefore, Hamilton must be able to send mail to at least one other city in NZ

      This test fails since Hamilton cannot send to any other city according to the data.xml

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity       | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Hamilton       | New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Hamilton       | New Zealand   | Christchurch    | New Zealand | domestic standard |
         | 1       | 10             | Hamilton       | New Zealand   | Dunedin         | New Zealand | domestic standard |
         | 1       | 10             | Hamilton       | New Zealand   | Palmerston North| New Zealand | domestic standard |
         | 1       | 10             | Hamilton       | New Zealand   | Rotorua         | New Zealand | domestic standard |
         | 1       | 10             | Hamilton       | New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Palmerston North can send mail to at least one other place in NZ

      My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
      Therefore, Palmerston North must be able to send mail to at least one other city in NZ

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity        | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Palmerston North| New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Palmerston North| New Zealand   | Christchurch    | New Zealand | domestic standard |
         | 1       | 10             | Palmerston North| New Zealand   | Dunedin         | New Zealand | domestic standard |
         | 1       | 10             | Palmerston North| New Zealand   | Hamilton        | New Zealand | domestic standard |
         | 1       | 10             | Palmerston North| New Zealand   | Rotorua         | New Zealand | domestic standard |
         | 1       | 10             | Palmerston North| New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Rotorua can send mail to at least one other place in NZ

      My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
      Therefore, Rotorua must be able to send mail to at least one other city in NZ

      This test fails since Rotorua cannot send to any other city according to the data.xml

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity        | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Rotorua         | New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Rotorua         | New Zealand   | Christchurch    | New Zealand | domestic standard |
         | 1       | 10             | Rotorua         | New Zealand   | Dunedin         | New Zealand | domestic standard |
         | 1       | 10             | Rotorua         | New Zealand   | Hamilton        | New Zealand | domestic standard |
         | 1       | 10             | Rotorua         | New Zealand   | Palmerston North| New Zealand | domestic standard |
         | 1       | 10             | Rotorua         | New Zealand   | Wellington      | New Zealand | domestic standard |


   Scenario Outline: Wellington can send mail to at least one other place in NZ

   My interpretation of the specification is that mail must be able to be sent from each city in NZ to AT LEAST ONE OTHER city in NZ
   Therefore, Wellington must be able to send mail to at least one other city in NZ

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then a route for this destination exists

      Examples:
         | Weight  | Measurement    | FromCity        | FromCountry   | ToCity          | ToCountry   | MailPriority      |
         | 1       | 10             | Wellington      | New Zealand   | Auckland        | New Zealand | domestic standard |
         | 1       | 10             | Wellington      | New Zealand   | Christchurch    | New Zealand | domestic standard |
         | 1       | 10             | Wellington      | New Zealand   | Dunedin         | New Zealand | domestic standard |
         | 1       | 10             | Wellington      | New Zealand   | Hamilton        | New Zealand | domestic standard |
         | 1       | 10             | Wellington      | New Zealand   | Palmerston North| New Zealand | domestic standard |
         | 1       | 10             | Wellington      | New Zealand   | Rotorua         | New Zealand | domestic standard |


   Scenario Outline: Send a weight and measurement of 0

      Outcome should be $0

      Given an initial map
      Given a parcel that weighs <Weight>kg
      Given a parcel that measures <Measurement> cc
      And I send the parcel from "<FromCity>" "<FromCountry>"
      And I send the parcel to "<ToCity>" "<ToCountry>"
      And I send the parcel by "<MailPriority>"
      Then the cost is $<ExpectedCost>

      Examples:
         | Weight  | Measurement    | FromCity        | FromCountry   | ToCity          | ToCountry   | MailPriority      | ExpectedCost  |
         | 0       | 0              | Auckland        | New Zealand   | Dunedin         | New Zealand | domestic standard | 0             |
         | 0       | 0              | Wellington      | New Zealand   | Palmerston North| New Zealand | domestic standard | 0             |
