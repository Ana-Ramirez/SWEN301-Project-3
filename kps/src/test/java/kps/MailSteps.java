package kps;
import cucumber.api.java.en.*;
import cucumber.api.PendingException;

import org.junit.Assert;

import java.util.ArrayList;
import java.util.List;


import kps.server.BusinessFigures;
import kps.server.Destination;
import kps.server.KPSServer;
import kps.server.Mail;
import kps.server.TransportRoute;
import kps.server.UserRecord;
import kps.server.UserRecord.Role;
import kps.server.logs.LogItem;
import kps.server.logs.MailDelivery;
import kps.util.MailPriority;
import kps.util.RouteType;
import kps.util.RouteNotFoundException;
import kps.util.XMLFormatException;


public class MailSteps {

    BusinessFigures figures = new BusinessFigures();
    KPSServer server = new KPSServer("/dev/null", figures);
    int weight;
    int measure;
    String fromCity;
    String fromCountry;
    String toCity;
    String toCountry;
    MailPriority priorityType;
    double cost;

    @Given("^an initial map$")
    public void anInitialMap() throws Throwable {
        server.readInitialLog("data/data.xml");
    }

    @Given("^a parcel that weighs (\\d+)kg$")
    public void aParcelThatWeighsKg(int weight) throws Throwable {
        this.weight = weight;
    }

    @Given("^a parcel that measures (\\d+) cc$")

    public void aParcelThatMeasuresCc(int measure) throws Throwable {
        this.measure = measure / 1000;
    }

    @Given("^I send the parcel from \"([^\"]*)\" \"([^\"]*)\"$")
    public void iSendTheParcelFrom(String fromCity, String fromCountry) throws Throwable {
        this.fromCity = fromCity;
        this.fromCountry = fromCountry;
    }

    @Given("^I send the parcel to \"([^\"]*)\" \"([^\"]*)\"$")
    public void iSendTheParcelTo(String toCity, String toCountry) throws Throwable {
        this.toCity = toCity;
        this.toCountry = toCountry;
    }

    @And("^I send the parcel by \"([^\"]*)\"$")
        public void iSendTheParcelBy(String priority) throws Throwable {
            MailPriority type = MailPriority.fromString(priority);
            Assert.assertNotNull("priority type = invalid", type);
            priorityType = type;
        }



    @Then("^the cost is \\$(\\d+)$")
    public void theCostIs$(int expectedCost) throws Throwable {
    Destination toDes = new Destination(toCity, toCountry);
    Destination fromDes = new Destination(fromCity, fromCountry);
    Mail mail = new Mail(toDes, fromDes, priorityType, weight, measure);
    TransportRoute route = server.getTransportMap().calculateRoute(mail).get(0);


    Double actual = route.calculateCost(mail.weight, mail.volume);
    Assert.assertTrue("Expected cost: " + expectedCost + ". Actual cost: " + actual,expectedCost == actual);
    }

    @Given("^a route for this destination exists$")
    public void thisRouteExists() throws Throwable {
        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);
        Mail mail = new Mail(toDes, fromDes, priorityType, weight, measure);
        Assert.assertTrue("A route does not exist", server.getTransportMap().calculateRoute(mail).size() != 0);
    }

    @Then("^stop off in route is \"([^\"]*)\" \"([^\"]*)\"$")
    public void stopOffInRouteIs(String city, String country) throws Throwable {
        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);
        Mail mail = new Mail(toDes, fromDes, priorityType, weight, measure);
        List<TransportRoute> foundRoutes = server.getTransportMap().calculateRoute(mail);

        boolean stopOffFound = false;
        for (TransportRoute route: foundRoutes) {
            if (route.from.city.equals(city) && route.from.country.equals(country)) {
                stopOffFound = true;
            }
        }

        String msg = "There is no stop off in " + city + " , " + country;
        Assert.assertTrue(msg, stopOffFound);
    }

    @And("^sending mail to overseas country: \"([^\"]*)\"$")
    public void sendingMailToOverseasCountry(String country) throws Throwable {
        toCountry = country;
    }

    @Then("^destination city should only be one option$")
    public void destinationCityShouldOnlyBeOneOption() throws Throwable {
        List<String> countryCities = new ArrayList<>();
        for (TransportRoute route : server.getTransportRoutes()) {
            if (route.to.country.equals(toCountry)) {

                if (!countryCities.contains(route.to.city)) {
                    countryCities.add(route.to.city);
                }
            }
        }
        if (countryCities.size() > 1) {
            Assert.fail("Mail should not be able to enter a foreign country through more than one city");
        }

    }


    @Then("^the method of shipment is international air$")
    public void theMethodOfShipmentIsByInternationalAir() throws Throwable {
        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);
        Mail mail = new Mail(toDes, fromDes, priorityType, weight, measure);

        TransportRoute route = server.getTransportMap().calculateRoute(mail).get(0);
        Assert.assertTrue("The method of shipment is not international air. Actual: " + route.getType().toString(), route.getType() == RouteType.AIR);
    }


    @Given("^land and sea options exist$")
    public void landAndSeaOptionsExist() throws Throwable {
        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);
        Mail mail = new Mail(toDes, fromDes, priorityType, weight, measure);
        List<TransportRoute> routes = server.getTransportMap().calculateRoute(mail);

        boolean landAndSea = false;

        for (TransportRoute route: routes) {
            if (route.getType() == RouteType.SEA || route.getType() == RouteType.LAND) {
                landAndSea = true;
                break;
            }
        }
        Assert.assertTrue("No land or sea options exist", landAndSea);
    }


    @Then("^the method of shipment is by land or sea$")
    public void theMethodOfShipmentIsByLandOrSea() throws Throwable {
        Destination to = new Destination(toCity, toCountry);
        Destination from = new Destination(fromCity, fromCountry);
        Mail mail = new Mail(to, from, priorityType, weight, measure);

        TransportRoute route = server.getTransportMap().calculateRoute(mail).get(0);
        Assert.assertTrue("The method of shipment is not land or sea. Actual: " + route.getType().toString(), route.getType() == RouteType.LAND || route.getType() == RouteType.SEA);
    }


}
