@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for claim items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_CLAIMS_ITEMS 
as select from ZI_CLAIMS_ITEMS
association to parent ZR_CLAIMS as _Claims
on $projection.Claimid = _Claims.Claimid and $projection.Fiscalyear = _Claims.Fiscalyear
association to I_BusinessUserBasic as _user on $projection.CreatedBy= _user.UserID
{
key ZI_CLAIMS_ITEMS.Claimid,
key ZI_CLAIMS_ITEMS.Fiscalyear,
key ZI_CLAIMS_ITEMS.Itemid,
ZI_CLAIMS_ITEMS.Expensetype,
@Semantics.largeObject:{
          mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE
          }
ZI_CLAIMS_ITEMS.Attachment,
ZI_CLAIMS_ITEMS.Mimetype,
ZI_CLAIMS_ITEMS.Filename,
ZI_CLAIMS_ITEMS.CukyField,
 @Semantics.amount.currencyCode : 'CukyField'
ZI_CLAIMS_ITEMS.Amount,
ZI_CLAIMS_ITEMS.Description,
 @Semantics.systemDateTime.createdAt: true
ZI_CLAIMS_ITEMS.CreatedAt,
 @Semantics.user.createdBy: true
ZI_CLAIMS_ITEMS.CreatedBy,
    _Claims,
    _user
    
    
}



