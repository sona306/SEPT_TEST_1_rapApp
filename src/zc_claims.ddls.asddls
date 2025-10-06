@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for claims'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_CLAIMS
  provider contract transactional_query as projection on ZR_CLAIMS
{
    key Claimid,
    key Fiscalyear,
    Claimstatus,
    Statuscriticality,
    Rejectionreason,
    Currency,
    @Semantics.amount.currencyCode : 'Currency'
    Totalamount,
    CreatedAt,
    /* Associations */
   _user.PersonFullName as CreatedBy,
    _Item : redirected to composition child ZC_CLAIMS_ITEMS
}
