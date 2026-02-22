/// <summary>
/// Tests for codeunit "Cust-Init No. from Cont CNTHLG".
/// Verifies that Customer."No." is set correctly relative to Contact."No."
/// depending on whether the No. Series for Contacts and Customers are the same or different.
/// </summary>
namespace HelgesenConsulting.Account.Common.Library;

using Microsoft.Foundation.NoSeries;

codeunit 73310 "Library - Account No. CNTHLG"
{
    procedure CreateNoSeries(NoSeriesCode: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            NoSeriesLine.SetRange("Series Code", NoSeriesCode);
            NoSeriesLine.DeleteAll(false);
            NoSeries.Delete(false);
        end;

        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := 'Test No. Series ' + NoSeriesCode;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := CopyStr(NoSeriesCode + '-0001', 1, MaxStrLen(NoSeriesLine."Starting No."));
        NoSeriesLine."Ending No." := CopyStr(NoSeriesCode + '-9999', 1, MaxStrLen(NoSeriesLine."Ending No."));
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);

        exit(NoSeriesCode);
    end;
}
