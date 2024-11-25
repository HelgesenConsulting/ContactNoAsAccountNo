codeunit 73300 "Cust-Init No. from Cont CNTHLG"
{
    //#region Permissions
    Permissions =
        tabledata "Sales & Receivables Setup" = r,
        tabledata "Marketing Setup" = r;

    //#endregion

    //#region EventSubscriber Codeunit Object No. Trigger
    [EventSubscriber(ObjectType::Table, Database::Contact, OnCreateCustomerFromTemplateOnBeforeInitCustomerNo, '', true, true)]
    local procedure InitCustomerNoFromContact(var Customer: Record Customer; var Contact: Record Contact; CustomerTempl: Record "Customer Templ."; var IsHandled: Boolean)
    begin
        if not ContactNoSeriesAndCustomerNoSeriesIsTheSame() then
            exit;

        Customer."No." := Contact."No.";
        IsHandled := true;
    end;
    //#endregion EventSubscriber Codeunit Object No. Trigger

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
