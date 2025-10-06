CLASS zcl_fill_expense DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FILL_EXPENSE IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
    DATA lt_boolean TYPE STANDARD TABLE OF zdb_fill_expense.
    lt_boolean = VALUE #( ( type = 'ACCO' value = 'Accommodation' )
    ( type = 'TRVL' value = 'Travel' )
    ( type = 'FOOD' value = 'Meals & Food' )
    ( type = 'TRAN' value = 'Local Transport' )
     ( type = 'FUEL' value = 'Fuel / Mileage' )
     ( type = 'AIRF' value = 'Airfare' )
     ( type = 'VISA' value = 'Visa / Immigration' )
     ( type = 'INS' value = 'Travel Insurance' )
     ( type = 'COMM' value = 'Communication' )
     ( type = 'OTHR' value = 'Other Expenses' )
     ).
    insert zdb_fill_expense from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.
    ENDMETHOD.
ENDCLASS.
