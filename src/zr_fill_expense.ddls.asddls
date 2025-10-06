@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for currency'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define root view entity ZR_FILL_EXPENSE 
as select from zdb_fill_expense
{
@Search.defaultSearchElement: true
@EndUserText.label: 'Sensitive'
    key type as Type,
    value as Value
}
