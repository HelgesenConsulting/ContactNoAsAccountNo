/// <summary>
/// Subscriber Codeunit that sets the `Customer."No."` to the `Contact."No."` if the No. Series for `Contacts` and `Customers` is the same when
/// using the `Create As Customer` action on the Contact Card.
/// Subscriber Codeunit that sets the `Contact."No."` to the `Customer."No."` if the No. Series for `Contacts` and `Vendors` is the same when
/// using the `Create Contacts from Customers` Report.
/// </summary>
/// 
namespace HelgesenConsulting.Account.Customer;

using Microsoft.CRM.Setup;
using Microsoft.CRM.Contact;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;

/// <summary>
/// Unknown HelgesenConsulting.
/// </summary>
codeunit 73300 "Cust-Init No. from Cont CNTHLG"
{
    //#region Permissions
    Permissions =
        tabledata "Sales & Receivables Setup" = r,
        tabledata "Marketing Setup" = r;

    //#endregion

    [EventSubscriber(ObjectType::Table, Database::Contact, OnCreateCustomerFromTemplateOnBeforeInitCustomerNo, '', true, true)]
    local procedure InitCustomerNoFromContact(var Customer: Record Customer; var Contact: Record Contact; CustomerTempl: Record "Customer Templ."; var IsHandled: Boolean)
    begin
        if not ContactNoSeriesAndCustomerNoSeriesIsTheSame() then
            exit;

        Customer."No." := Contact."No.";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Conts. from Customers", OnBeforeContactInsert, '', true, true)]
    local procedure OnBeforeContactInsert(Customer: Record Customer; var Contact: Record Contact)
    begin
        if not ContactNoSeriesAndCustomerNoSeriesIsTheSame() then
            exit;

        Contact."No." := Customer."No.";
    end;

    local procedure ContactNoSeriesAndCustomerNoSeriesIsTheSame(): Boolean
    var
        SalesSetup: Record "Sales & Receivables Setup";
        MarketingSetup: Record "Marketing Setup";

    begin
        SalesSetup.SetLoadFields("Customer Nos.");
        if not SalesSetup.Get() then
            exit(false);
        if SalesSetup."Customer Nos." = '' then
            exit(false);

        MarketingSetup.SetLoadFields("Contact Nos.");
        if not MarketingSetup.Get() then
            exit(false);
        if MarketingSetup."Contact Nos." = '' then
            exit(false);

        exit(SalesSetup."Customer Nos." = MarketingSetup."Contact Nos.");
    end;
}
