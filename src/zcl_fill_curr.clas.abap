CLASS zcl_fill_curr DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FILL_CURR IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.
    DATA lt_boolean TYPE STANDARD TABLE OF zdb_fill_curr.
    lt_boolean = VALUE #( ( type = 'INR' value = 'IndianRup' )
    ( type = 'USD' value = 'USDollar' )
    ( type = 'EUR' value = 'Euro' )
    ( type = 'GBP' value = 'Pound' )
     ( type = 'CNY' value = 'ChinYuan' )
     ( type = 'JPY' value = 'JapanYen' )
     ( type = 'AUD' value = 'AusDollar' )
     ( type = 'CAD' value = 'CanDollar' )
     ( type = 'AED' value = 'UAE Dirham' )
     ).
    insert zdb_fill_curr from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.
    ENDMETHOD.
ENDCLASS.
