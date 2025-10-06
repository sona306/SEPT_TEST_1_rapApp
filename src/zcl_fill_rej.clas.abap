CLASS zcl_fill_rej DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FILL_REJ IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
    DATA lt_boolean TYPE STANDARD TABLE OF zdb_fill_rej.
    lt_boolean = VALUE #( ( type = 'INCO' value = 'Incorrect Amount' )
    ( type = 'MISS' value = 'Missing Receipt' )
    ( type = 'EXCE' value = 'Exceeds Policy Limit' )
    ( type = 'NELEG' value = 'Not Eligible' )
     ( type = 'DUP' value = 'Duplicate Claim' )
     ( type = 'OTH' value = 'Other' )
     ).
    insert zdb_fill_rej from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.
    ENDMETHOD.
ENDCLASS.
