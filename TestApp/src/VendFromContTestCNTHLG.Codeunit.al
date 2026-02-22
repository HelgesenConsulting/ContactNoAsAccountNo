/// <summary>
/// Tests for codeunit "Cust-Init No. from Cont CNTHLG".
/// Verifies that VendorCustomer."No." is set correctly relative to Contact."No."
/// depending on whether the No. Series for Contacts and VendorCustomers are the same or different.
/// </summary>
namespace HelgesenConsulting.Account.Vendor.Test;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Setup;
using HelgesenConsulting.Account.Common.Library;

codeunit 73312 "Vend From Cont Test CNTHLG"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryMarketing: Codeunit "Library - Marketing";

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DifferentNoSeries_VendorNoIsDifferentFromContactNo()
    var
        Contact: Record Contact;
        Vendor: Record Vendor;
        VendorNo: Code[20];
        ContactNoAndVendorNoShouldBeDifferentLbl: Label 'Vendor No. should not match the Contact No.';

    begin
        // [SCENARIO] When "Contact Nos." in Marketing Setup and "Vendor Nos." in
        //            Purchase & Payables Setup use different No. Series, creating a
        //            new Vendor from a Contact results in a different No. on each.

        // [GIVEN] "Contact Nos." and "Vendot Nos." point to different No. Series
        SetupNoSeries(CreateNoSeries('TC-CONT'), CreateNoSeries('TC-VEND'));

        // [GIVEN] A new Contact with common name and address data
        CreateContact(Contact);

        // [WHEN] A new Vendor is created from the Contact
        VendorNo := Contact.CreateVendorFromTemplate(GetVendorTemplateCode());
        Vendor.Get(VendorNo);

        // [THEN] The Vendor "No." is different from the Contact "No."
        Assert.AreNotEqual(Contact."No.", Vendor."No.", ContactNoAndVendorNoShouldBeDifferentLbl);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SameNoSeries_VendorNoEqualsContactNo()
    var
        Contact: Record Contact;
        Vendor: Record Vendor;
        VendorNo: Code[20];
        SharedNoSeriesCode: Code[20];
        VendorNoShouldBeTheSameLbl: Label 'Vendor No. should be equal to the Contact No.';
    begin
        // [SCENARIO] When "Contact Nos." in Marketing Setup and "Vendor Nos." in
        //            Sales & Receivables Setup use the same No. Series, creating a
        //            new Vendor from a Contact results in the same No. on each.

        // [GIVEN] "Contact Nos." and "Vendor Nos." point to the same No. Series
        SharedNoSeriesCode := CreateNoSeries('TC-SHARED');
        SetupNoSeries(SharedNoSeriesCode, SharedNoSeriesCode);

        // [GIVEN] A new Contact with common name and address data
        CreateContact(Contact);

        // [WHEN] A new VendorCustomer is created from the Contact
        VendorNo := Contact.CreateVendorFromTemplate(GetVendorTemplateCode());
        Vendor.Get(VendorNo);

        // [THEN] The Vendor "No." equals the Contact "No."
        Assert.AreEqual(Contact."No.", Vendor."No.", VendorNoShouldBeTheSameLbl);
    end;

    // Helpers

    local procedure SetupNoSeries(ContactNoSeriesCode: Code[20]; VendorNoSeriesCode: Code[20])
    var
        MarketingSetup: Record "Marketing Setup";
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        MarketingSetup.Get();
        MarketingSetup."Contact Nos." := ContactNoSeriesCode;
        MarketingSetup.Modify(false);

        PurchSetup.Get();
        PurchSetup."Vendor Nos." := VendorNoSeriesCode;
        PurchSetup.Modify(false);
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

    local procedure GetVendorTemplateCode(): Code[20]
    var
        VendorTempl: Record "Vendor Templ.";
    begin
        VendorTempl.FindFirst();
        exit(VendorTempl.Code);
    end;

    // Handlers

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin

    end;
}
