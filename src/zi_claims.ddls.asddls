@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for claim'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CLAIMS as select from zdb_claim
{
    key claimid as Claimid,
    key fiscalyear as Fiscalyear,
    claimstatus as Claimstatus,
    rejectionreason as Rejectionreason,
    currency as Currency,
    @Semantics.amount.currencyCode : 'Currency'
    totalamount as Totalamount,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.createdBy: true
    created_by as CreatedBy
}

    
