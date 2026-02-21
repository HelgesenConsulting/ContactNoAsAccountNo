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
using Microsoft.Foundation.NoSeries;

codeunit 73310 "Cust-Init No. from Cont Test CNTHLG"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure DifferentNoSeries_CustomerNoIsDifferentFromContactNo()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] When "Contact Nos." in Marketing Setup and "Customer Nos." in
        //            Sales & Receivables Setup use different No. Series, creating a
        //            new Customer from a Contact results in a different No. on each.

        // [GIVEN] "Contact Nos." and "Customer Nos." point to different No. Series
        SetupNoSeries(CreateNoSeries('TC-CONT'), CreateNoSeries('TC-CUST'));

        // [GIVEN] A new Contact with common name and address data
        CreateContact(Contact);

        // [WHEN] A new Customer is created from the Contact
        CustomerNo := Contact.CreateCustomerFromTemplate(GetCustomerTemplate());
        Customer.Get(CustomerNo);

        // [THEN] The Customer "No." is different from the Contact "No."
        if Contact."No." = Customer."No." then
            Error(
                'Customer No. should differ from Contact No. (%1) when using different No. Series, but they were the same.',
                Contact."No.");
    end;

    [Test]
    procedure SameNoSeries_CustomerNoEqualsContactNo()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerNo: Code[20];
        SharedNoSeriesCode: Code[20];
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
        CustomerNo := Contact.CreateCustomerFromTemplate(GetCustomerTemplate());
        Customer.Get(CustomerNo);

        // [THEN] The Customer "No." equals the Contact "No."
        if Contact."No." <> Customer."No." then
            Error(
                'Customer No. (%1) should equal Contact No. (%2) when using the same No. Series.',
                Customer."No.", Contact."No.");
    end;

    // Helpers

    local procedure SetupNoSeries(ContactNoSeriesCode: Code[20]; CustomerNoSeriesCode: Code[20])
    var
        MarketingSetup: Record "Marketing Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        MarketingSetup.Get();
        MarketingSetup."Contact Nos." := ContactNoSeriesCode;
        MarketingSetup.Modify();

        SalesSetup.Get();
        SalesSetup."Customer Nos." := CustomerNoSeriesCode;
        SalesSetup.Modify();
    end;

    local procedure CreateNoSeries(NoSeriesCode: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            NoSeriesLine.SetRange("Series Code", NoSeriesCode);
            NoSeriesLine.DeleteAll();
            NoSeries.Delete();
        end;

        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := 'Test No. Series ' + NoSeriesCode;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := CopyStr(NoSeriesCode + '-0001', 1, MaxStrLen(NoSeriesLine."Starting No."));
        NoSeriesLine."Ending No." := CopyStr(NoSeriesCode + '-9999', 1, MaxStrLen(NoSeriesLine."Ending No."));
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert();

        exit(NoSeriesCode);
    end;

    local procedure CreateContact(var Contact: Record Contact)
    begin
        Contact.Init();
        Contact.Type := Contact.Type::Company;
        Contact.Name := 'Test Company A/S';
        Contact.Address := '1 Test Street';
        Contact.City := 'Testville';
        Contact.Insert(true);
    end;

    local procedure GetCustomerTemplate(): Record "Customer Templ."
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        CustomerTempl.FindFirst();
        exit(CustomerTempl);
    end;
}
