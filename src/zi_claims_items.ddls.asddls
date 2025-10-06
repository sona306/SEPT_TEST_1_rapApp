@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for claim items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CLAIMS_ITEMS as select from zdb_claim_item
{
key claimid as Claimid,
key fiscalyear as Fiscalyear,
key itemid as Itemid,
expensetype as Expensetype,
@Semantics.largeObject:{
          mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE
          }
      zdb_claim_item.attachment         as Attachment,
      zdb_claim_item.mimetype           as Mimetype,
      @EndUserText.label: 'Filename'
      zdb_claim_item.filename           as Filename,
cuky_field as CukyField,
 @Semantics.amount.currencyCode : 'CukyField'
amount as Amount,
description as Description,
@Semantics.systemDateTime.createdAt: true
created_at as CreatedAt,
@Semantics.user.createdBy: true
created_by as CreatedBy
}
    
