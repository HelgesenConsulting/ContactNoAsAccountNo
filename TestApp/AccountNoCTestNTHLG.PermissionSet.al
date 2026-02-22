namespace HelgesenConsulting.Account.Permissions;

using HelgesenConsulting.Account.Customer.Test;
using HelgesenConsulting.Account.Common.Library;
using HelgesenConsulting.Account.Vendor.Test;

permissionset 73310 "AccountNoCTestNTHLG"
{
    Caption = 'Cont. No as Cust/Vend No. TEST', MaxLength = 30;
    Assignable = true;
    Permissions = codeunit "Cust From Cont Test CNTHLG" = X,
        codeunit "Library - Account No. CNTHLG" = X,
        codeunit "Vend From Cont Test CNTHLG" = X;
}