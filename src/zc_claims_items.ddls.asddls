@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for claim items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_CLAIMS_ITEMS
  as projection on ZR_CLAIMS_ITEMS
{
  key Claimid,
  key Fiscalyear,
  key Itemid,
      Expensetype,
      @Semantics.largeObject: {
          mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE
        }

      Attachment,
      Filename,
      Mimetype,
      CukyField,
      @Semantics.amount.currencyCode : 'CukyField'
      Amount,
      Description,
      CreatedAt,
      _user.PersonFullName as CreatedBy,
      /* Associations */
      _Claims : redirected to parent ZC_CLAIMS
}
