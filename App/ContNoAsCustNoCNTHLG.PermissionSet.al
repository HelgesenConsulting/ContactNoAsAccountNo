/// <summary>
/// Permission Set.
/// </summary>
namespace HelgesenConsulting.Account.Permissions;

using HelgesenConsulting.Account.Customer;
using HelgesenConsulting.Account.Vendor;

permissionset 73300 "ContNoAsCustNoCNTHLG"
{
    Caption = 'Cont. No as Cust/Vend No.', MaxLength = 30;
    Assignable = true;
    Permissions =
        codeunit "Cust-Init No. from Cont CNTHLG" = X,
        codeunit "Vend-Init No. from Cont CNTHLG" = X;
}