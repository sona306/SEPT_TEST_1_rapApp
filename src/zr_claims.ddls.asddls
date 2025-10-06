@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for claims'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_CLAIMS
as select from ZI_CLAIMS
composition[0..*] of ZR_CLAIMS_ITEMS as _Item 
association to I_BusinessUserBasic as _user on $projection.CreatedBy= _user.UserID
{
    key Claimid,
    key Fiscalyear,
    cast(case Claimstatus
      when 'Approved' then 3
      when 'Withdraw' then 2
      when 'Rejected' then 1
      when 'Submitted' then 3
      else 0
      end as abap.int4) as Statuscriticality,
    Claimstatus,
    Rejectionreason,
    Currency,
    @Semantics.amount.currencyCode : 'Currency'
    Totalamount,
    @Semantics.systemDateTime.createdAt: true
    CreatedAt,
    @Semantics.user.createdBy: true
    CreatedBy,
   _Item,
   _user
}



