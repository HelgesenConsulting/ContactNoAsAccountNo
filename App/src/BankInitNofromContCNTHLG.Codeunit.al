/// <summary>
/// Subscriber Codeunit that sets the `BankAccount."No."` to the `Contact."No."` if the No. Series for `Contacts` and `Bank Accounts` is the same when
/// using the `Create As Vendor` action on the Contact Card.
/// Subscriber Codeunit that sets the `Contact."No."` to the `Vendor."No."` if the No. Series for `Contacts` and `Bank Account` is the same when
/// using the `Create Contacts from Bank Accounts` Report.
/// </summary>
/// 
namespace HelgesenConsulting.Account.Bank;

using Microsoft.CRM.Setup;
using Microsoft.CRM.Contact;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Bank.BankAccount;

codeunit 73302 "Bank-Init No. from Cont CNTHLG"
{
    //#region Permissions
    Permissions =
        tabledata "General Ledger Setup" = r,
        tabledata "Marketing Setup" = r;

    //#endregion

    [EventSubscriber(ObjectType::Table, Database::Contact, OnCreateBankAccountOnBeforeContBusRelInsert, '', true, true)]
    local procedure OnBeforeBankAccountInsert(var BankAccount: Record "Bank Account"; var Contact: Record Contact)
    begin
        if not ContactNoSeriesAndBankAccountNoSeriesIsTheSame() then
            exit;

        BankAccount."No." := Contact."No.";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Conts. from Bank Accs.", OnBeforeSetSkipDefaults, '', true, true)]
    local procedure OnBeforeSetSkipDefaults(var BankAccount: Record "Bank Account"; var Contact: Record Contact)
    begin
        if not ContactNoSeriesAndBankAccountNoSeriesIsTheSame() then
            exit;

        Contact."No." := BankAccount."No.";
    end;

    local procedure ContactNoSeriesAndBankAccountNoSeriesIsTheSame(): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        MarketingSetup: Record "Marketing Setup";

    begin
        GeneralLedgerSetup.SetLoadFields("Bank Account Nos.");
        if not GeneralLedgerSetup.Get() then
            exit(false);
        if GeneralLedgerSetup."Bank Account Nos." = '' then
            exit(false);

        MarketingSetup.SetLoadFields("Contact Nos.");
        if not MarketingSetup.Get() then
            exit(false);
        if MarketingSetup."Contact Nos." = '' then
            exit(false);

        exit(GeneralLedgerSetup."Bank Account Nos." = MarketingSetup."Contact Nos.");
    end;
}
