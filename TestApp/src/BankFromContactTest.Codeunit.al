/// <summary>
/// Tests for codeunit "Cust-Init No. from Cont CNTHLG".
/// Verifies that Customer."No." is set correctly relative to Contact."No."
/// depending on whether the No. Series for Contacts and Customers are the same or different.
/// </summary>
namespace HelgesenConsulting.Account.Customer.Test;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using HelgesenConsulting.Account.Common.Library;


codeunit 73311 "Cust From Cont Test CNTHLG"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryMarketing: Codeunit "Library - Marketing";

    [Test]
    procedure DifferentNoSeries_CustomerNoIsDifferentFromContactNo()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerNo: Code[20];
        ContactNoAndCustomerNoShouldBeDifferentLbl: Label 'Customer No. should not match the Contact No.';

    begin
        // [SCENARIO] When "Contact Nos." in Marketing Setup and "Customer Nos." in
        //            Sales & Receivables Setup use different No. Series, creating a
        //            new Customer from a Contact results in a different No. on each.

        // [GIVEN] "Contact Nos." and "Customer Nos." point to different No. Series
        SetupNoSeries(CreateNoSeries('TC-CONT'), CreateNoSeries('TC-CUST'));

        // [GIVEN] A new Contact with common name and address data
        CreateContact(Contact);

        // [WHEN] A new Customer is created from the Contact
        CustomerNo := Contact.CreateCustomerFromTemplate(GetCustomerTemplateCode());
        Customer.Get(CustomerNo);

        // [THEN] The Customer "No." is different from the Contact "No."
        Assert.AreNotEqual(Contact."No.", Customer."No.", ContactNoAndCustomerNoShouldBeDifferentLbl);
    end;

    [Test]
    procedure SameNoSeries_CustomerNoEqualsContactNo()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerNo: Code[20];
        SharedNoSeriesCode: Code[20];
        ContactNoAndCustomerNoShouldBeTheSameLbl: Label 'Customer No. should be equal to the Contact No.';
    begin
        // [SCENARIO] When "Contact Nos." in Marketing Setup and "Customer Nos." in
        //            Sales & Receivables Setup use the same No. Series, creating a
        //            new Customer from a Contact results in the same No. on each.

        // [GIVEN] "Contact Nos." and "Customer Nos." point to the same No. Series
        SharedNoSeriesCode := CreateNoSeries('TC-SHARED');
        SetupNoSeries(SharedNoSeriesCode, SharedNoSeriesCode);

        // [GIVEN] A new Contact with common name and address data
        CreateContact(Contact);

        // [WHEN] A new Customer is created from the Contact
        CustomerNo := Contact.CreateCustomerFromTemplate(GetCustomerTemplateCode());
        Customer.Get(CustomerNo);

        // [THEN] The Customer "No." equals the Contact "No."
        Assert.AreEqual(Contact."No.", Customer."No.", ContactNoAndCustomerNoShouldBeTheSameLbl);
    end;

    // Helpers

    local procedure SetupNoSeries(ContactNoSeriesCode: Code[20]; CustomerNoSeriesCode: Code[20])
    var
        MarketingSetup: Record "Marketing Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        MarketingSetup.Get();
        MarketingSetup."Contact Nos." := ContactNoSeriesCode;
        MarketingSetup.Modify(false);

        SalesSetup.Get();
        SalesSetup."Customer Nos." := CustomerNoSeriesCode;
        SalesSetup.Modify(false);
    end;

    local procedure CreateNoSeries(NoSeriesCode: Code[20]): Code[20]
    var
        LibraryAccountNo: Codeunit "Library - Account No. CNTHLG";
    begin
        exit(LibraryAccountNo.CreateNoSeries(NoSeriesCode));
    end;

    local procedure CreateContact(var Contact: Record Contact)
    begin
        LibraryMarketing.CreateCompanyContact(Contact);
    end;

    local procedure GetCustomerTemplateCode(): Code[20]
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        CustomerTempl.FindFirst();
        exit(CustomerTempl.Code);
    end;
}
