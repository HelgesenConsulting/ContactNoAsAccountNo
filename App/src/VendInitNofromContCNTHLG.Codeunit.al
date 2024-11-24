codeunit 73301 "Vend-Init No. from Cont CNTHLG"
{
    //#region Permissions
    Permissions =
        tabledata "Purchases & Payables Setup" = r,
        tabledata "Marketing Setup" = r;

    //#endregion

    //#region EventSubscriber Codeunit Object No. Trigger
    [EventSubscriber(ObjectType::Table, Database::Contact, OnCreateVendorFromTemplateOnBeforeInitVendorNo, '', true, true)]
    local procedure InitVendorNoFromContact(var Vendor: Record Vendor; var Contact: Record Contact; VendorTempl: Record "Vendor Templ."; var IsHandled: Boolean)
    begin
        if not ContactNoSeriesAndVendorNoSeriesIsTheSame() then
            exit;

        Vendor."No." := Contact."No.";
        IsHandled := true;
    end;
    //#endregion EventSubscriber Codeunit Object No. Trigger

    local procedure ContactNoSeriesAndVendorNoSeriesIsTheSame(): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        MarketingSetup: Record "Marketing Setup";

    begin
        if not PurchSetup.Get() then
            exit(false);
        if PurchSetup."Vendor Nos." = '' then
            exit(false);

        if not MarketingSetup.Get() then
            exit(false);
        if MarketingSetup."Contact Nos." = '' then
            exit(false);

        exit(PurchSetup."Vendor Nos." = MarketingSetup."Contact Nos.");
    end;
}
