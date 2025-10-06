CLASS lhc_ZC_CLAIMS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_claims RESULT result.

    METHODS addNewRow FOR MODIFY
      IMPORTING keys FOR ACTION zc_claims~addNewRow RESULT result.

ENDCLASS.

CLASS lhc_ZC_CLAIMS IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD addNewRow.
    READ ENTITIES OF zr_claims
      ENTITY zr_claims
        FIELDS ( Claimid Fiscalyear Currency )
        WITH CORRESPONDING #( keys )
        RESULT DATA(parents)
      FAILED DATA(read_failed).

    MODIFY ENTITIES OF zr_claims
      ENTITY zr_claims
        CREATE BY \_Item
          AUTO FILL CID
          WITH VALUE #(
            FOR parent IN parents
            ( %tky = parent-%tky
  %target = VALUE #(
    ( %is_draft   = parent-%is_draft
      Claimid     = parent-Claimid
      Fiscalyear  = parent-Fiscalyear
      CukyField   = parent-Currency
      Amount      = ''
      Expensetype = ''
      Description = ''
      Attachment  = ''
      Filename    = ''
      Mimetype    = ''

      %control-Amount      = if_abap_behv=>mk-on
      %control-Expensetype = if_abap_behv=>mk-on
      %control-Description = if_abap_behv=>mk-on
      %control-Attachment  = if_abap_behv=>mk-on
      %control-Filename    = if_abap_behv=>mk-on
      %control-Mimetype    = if_abap_behv=>mk-on
    )
  )
            )
          )
      REPORTED DATA(rep)
      FAILED DATA(fail).

    result = VALUE #(
      FOR parent IN parents
        ( %tky   = parent-%tky )
    ).

    LOOP AT parents ASSIGNING FIELD-SYMBOL(<parent>).
      APPEND VALUE #( %tky  = <parent>-%tky
                      %msg  = new_message(
                                  id       = 'ZMSG2'
                                  number   = '007'
                                  severity = if_abap_behv_message=>severity-success ) )
        TO reported-zc_claims.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
