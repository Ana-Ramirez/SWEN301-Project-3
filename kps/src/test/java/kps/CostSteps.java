package kps;
import cucumber.api.java.en.*;
import cucumber.api.PendingException;

import org.junit.Assert;

import java.util.ArrayList;
import java.util.List;


import kps.server.BusinessFigures;
import kps.server.Destination;
import kps.server.KPSServer;
import kps.server.*;


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
import java.time.DayOfWeek;


public class CostSteps {

    BusinessFigures figures = new BusinessFigures();
    KPSServer server = new KPSServer("/dev/null", figures);
    int weight;
    int measure;
    String fromCity;
    String fromCountry;
    String toCity;
    String toCountry;
    MailPriority priorityType;
    MailDelivery domesticStandard;
    MailDelivery domesticAir;

    double cost;

    @Given("^an initial cost map$")
    public void anInitialCostMap() throws Throwable {
        server.readInitialLog("data/data.xml");
    }

    @Given("^a cost parcel that weighs (\\d+)kg$")
    public void aCostParcelThatWeighsKg(int weight) throws Throwable {
        this.weight = weight;
    }

    @Given("^a cost parcel that measures (\\d+) cc$")
    public void aCostParcelThatMeasuresCc(int measure) throws Throwable {
        this.measure = measure / 1000;
    }

    @Given("^I send the cost parcel from \"([^\"]*)\" \"([^\"]*)\"$")
    public void iSendTheCostParcelFrom(String fromCity, String fromCountry) throws Throwable {
        this.fromCity = fromCity;
        this.fromCountry = fromCountry;
    }

    @Given("^I send the cost parcel to \"([^\"]*)\" \"([^\"]*)\"$")
    public void iSendTheCostParcelTo(String toCity, String toCountry) throws Throwable {
        this.toCity = toCity;
        this.toCountry = toCountry;
    }

    @And("^I send the cost parcel by \"([^\"]*)\"$")
    public void iSendTheCostParcelBy(String priority) throws Throwable {
        MailPriority type = MailPriority.fromString(priority);
        Assert.assertNotNull("priority type = invalid", type);
        priorityType = type;
    }

    @Given("^a cost route exists for domestic air$")
    public void aCostRouteExistsForDomesticAir() throws Throwable {

        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);

        MailDelivery domesticAir = new MailDelivery(fromDes, toDes, weight, measure, MailPriority.DOMESTIC_AIR, DayOfWeek.MONDAY);
        double domesticAirCost = server.getTransportMap().getCustomerPrice(domesticAir);

        if(domesticAirCost == -1){
            Assert.fail("data file does not have entries for this path");
        }

    }

    @Given("^a cost route exists for domestic standard$")
    public void aCostRouteExistsForDomesticStandard() throws Throwable {

        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);

        MailDelivery domesticstandard = new MailDelivery(fromDes, toDes, weight, measure, MailPriority.DOMESTIC_STANDARD, DayOfWeek.MONDAY);
        double domesticstandardCost = server.getTransportMap().getCustomerPrice(domesticstandard);

        if(domesticstandardCost == -1){
            Assert.fail("data file does not have entries for this path");
        }

    }

    @Then("^sending domestic air should cost more than domestic standard$")
    public void sendingDomesticAirShouldCostMoreThanDomesticStandard() throws Throwable {

        Destination toDes = new Destination(toCity, toCountry);
        Destination fromDes = new Destination(fromCity, fromCountry);

        MailPriority air = MailPriority.DOMESTIC_AIR;
        MailPriority standard = MailPriority.DOMESTIC_STANDARD;

        this.domesticStandard = new MailDelivery(fromDes, toDes, weight, measure, standard, DayOfWeek.MONDAY);
        this.domesticAir = new MailDelivery(fromDes, toDes, weight, measure, air, DayOfWeek.MONDAY);

        double domesticstandardCost = server.getTransportMap().getCustomerPrice(domesticStandard);
        double domesticairCost = server.getTransportMap().getCustomerPrice(domesticAir);

        Assert.assertTrue("Cost of air should have been greater than standard. domesticAir cost= " + domesticairCost + " domesticStandard cost= " + domesticstandardCost, domesticairCost > domesticstandardCost);
    }


    @Then("^the parcel costs \\$(\\d+)")
    public void theParcelCosts(int cost) {
        Destination to = new Destination(toCity, toCountry);
        Destination from = new Destination(fromCity, fromCountry);

        MailDelivery delivery = new MailDelivery(from, to, weight, measure, priorityType, DayOfWeek.MONDAY);
        double price = server.getTransportMap().getCustomerPrice(delivery);

        if(price == -1){
            Assert.assertTrue("No price available", price == cost);
        }

        else{
            Assert.assertTrue("actual cost: $" + price + ". expected cost: $" + cost + ". ", price == cost);
        }

    }


}
