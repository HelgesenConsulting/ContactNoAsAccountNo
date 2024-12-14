/// <summary>
/// Subscriber Codeunit that sets the `Vendor."No."` to the `Contact."No."` if the No. Series for `Contacts` and `Vendors` is the same when
/// using the `Create As Vendor` action on the Contact Card.
/// Subscriber Codeunit that sets the `Contact."No."` to the `Vendor."No."` if the No. Series for `Contacts` and `Vendors` is the same when
/// using the `Create Contacts from Vendors` Report.
/// </summary>
/// 
namespace HelgesenConsulting.Account.Vendor;

using Microsoft.CRM.Setup;
using Microsoft.CRM.Contact;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

codeunit 73301 "Vend-Init No. from Cont CNTHLG"
{
    //#region Permissions
    Permissions =
        tabledata "Purchases & Payables Setup" = r,
        tabledata "Marketing Setup" = r;

    //#endregion

    [EventSubscriber(ObjectType::Table, Database::Contact, OnCreateVendorFromTemplateOnBeforeInitVendorNo, '', true, true)]
    local procedure InitVendorNoFromContact(var Vendor: Record Vendor; var Contact: Record Contact; VendorTempl: Record "Vendor Templ."; var IsHandled: Boolean)
    begin
        if not ContactNoSeriesAndVendorNoSeriesIsTheSame() then
            exit;

        Vendor."No." := Contact."No.";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Conts. from Vendors", OnBeforeContactInsert, '', true, true)]
    local procedure OnBeforeContactInsert(Vendor: Record Vendor; var Contact: Record Contact)
    begin
        if not ContactNoSeriesAndVendorNoSeriesIsTheSame() then
            exit;

        Contact."No." := Vendor."No.";
    end;

    local procedure ContactNoSeriesAndVendorNoSeriesIsTheSame(): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        MarketingSetup: Record "Marketing Setup";

    begin
        PurchSetup.SetLoadFields("Vendor Nos.");
        if not PurchSetup.Get() then
            exit(false);
        if PurchSetup."Vendor Nos." = '' then
            exit(false);

        MarketingSetup.SetLoadFields("Contact Nos.");
        if not MarketingSetup.Get() then
            exit(false);
        if MarketingSetup."Contact Nos." = '' then
            exit(false);

        exit(PurchSetup."Vendor Nos." = MarketingSetup."Contact Nos.");
    end;
}
