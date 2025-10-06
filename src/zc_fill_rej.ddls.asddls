@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for fill rejection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_FILL_REJ as select from ZR_FILL_REJ
{
    key Type,
    Value
}
