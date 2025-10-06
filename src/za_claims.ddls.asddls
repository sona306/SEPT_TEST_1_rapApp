@EndUserText.label: 'abstract'
define abstract entity ZA_CLAIMS
{
@Consumption.valueHelpDefinition: [{ entity:{ name: 'ZR_FILL_REJ', element: 'Value' } }]
  @EndUserText.label: 'Rejection Reason'
    rejectionreason : abap.char(20);
    
}
