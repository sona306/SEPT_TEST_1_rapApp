CLASS lhc_zr_claims_items DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validate_amount FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_claims_items~validate_amount.
    METHODS CalcualteTotalAmount FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_claims_items~CalcualteTotalAmount.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zr_claims_items.

ENDCLASS.

CLASS lhc_zr_claims_items IMPLEMENTATION.

  METHOD validate_amount.

    READ ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims_items
        FIELDS ( Amount )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_amt).

    LOOP AT lt_amt ASSIGNING FIELD-SYMBOL(<fs_amt>).

      IF <fs_amt>-Amount < 0.

        APPEND VALUE #(
          %tky             = <fs_amt>-%tky
          %msg             = new_message(
                               id       = 'ZMSG2'
                               number   = '004'
                               severity = if_abap_behv_message=>severity-error )
                               %update = if_abap_behv=>mk-on
          %element-Amount  = if_abap_behv=>mk-on
        ) TO reported-zr_claims_items.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CalcualteTotalAmount.
    READ ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims BY \_Item
       ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_data).

    DATA totalval TYPE zr_claims-Totalamount.
    totalval = 0.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      totalval = totalval + <fs_data>-%data-Amount.
    ENDLOOP.

    READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims_items BY \_Claims
    FIELDS ( Totalamount )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data1).

    LOOP AT lt_data1 ASSIGNING FIELD-SYMBOL(<ft_data>).

      MODIFY ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims
      UPDATE FIELDS ( Totalamount )
      WITH VALUE #( (
                    %tky = <ft_data>-%tky
                    Totalamount = totalval
                    %control-Totalamount = if_abap_behv=>mk-on ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_amt>).

      IF <fs_amt>-Amount < 0.
        APPEND VALUE #(
          %key    = <fs_amt>-%key
          %update = if_abap_behv=>mk-on
        ) TO failed-zr_claims_items.

        APPEND VALUE #(
          %key             = <fs_amt>-%key
          %msg             = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = |Amount must be greater than zero. Entered: { <fs_amt>-Amount }|
                             )
          %update          = if_abap_behv=>mk-on
          %element-Amount  = if_abap_behv=>mk-on
        ) TO reported-zr_claims_items.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_claims DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zr_claims IMPLEMENTATION.

  METHOD adjust_numbers.
    IF mapped-zr_claims IS NOT INITIAL.
      LOOP AT mapped-zr_claims ASSIGNING FIELD-SYMBOL(<fs_sal>).
        TRY.
            CALL METHOD cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = '01'
                object            = '/DMO/TRV_M'
*               quantity          = CONV #( lines( mapped-jounryheader ) )
              IMPORTING
                number            = DATA(number_range_key)
                returncode        = DATA(number_range_return_code)
                returned_quantity = DATA(number_range_returned_quantity) ).
          CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error).
            lo_uuid_error->get_text(  RECEIVING  result = DATA(lv_errortext) ).
          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
            lx_number_ranges->get_text(  RECEIVING  result = lv_errortext ).
        ENDTRY.
      ENDLOOP.
      <fs_sal>-Claimid = number_range_key.
      DATA(lv_year) = cl_abap_context_info=>get_system_date(  ).
      <fs_sal>-Fiscalyear = lv_year+0(4).
    ELSEIF mapped-zr_claims_items IS NOT INITIAL.
      LOOP AT mapped-zr_claims_items ASSIGNING FIELD-SYMBOL(<fs_temp>).
        TRY.
            CALL METHOD cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = '01'
                object            = '/DMO/TRV_M'
*               quantity          = CONV #( lines( mapped-jounryheader ) )
              IMPORTING
                number            = DATA(number_range_key2)
                returncode        = DATA(number_range_return_code1)
                returned_quantity = DATA(number_range_returned_quantit) ).
          CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error1).
            lo_uuid_error->get_text(  RECEIVING  result = DATA(lv_errortext1) ).
          CATCH cx_number_ranges INTO DATA(lx_number_ranges1).
            lx_number_ranges->get_text(  RECEIVING  result = lv_errortext1 ).
        ENDTRY.
      ENDLOOP.
      <fs_temp>-Itemid = number_range_key2.
      <fs_temp>-Claimid = <fs_temp>-%tmp-Claimid.
      <fs_temp>-FiscalYear = <fs_temp>-%tmp-FiscalYear.
    ENDIF.
  ENDMETHOD.

*METHOD adjust_numbers.
*
*  DATA: lv_fiscyear TYPE gjahr,
*        lv_period   TYPE monat.
*
*  IF mapped-zr_claims IS NOT INITIAL.
*    LOOP AT mapped-zr_claims ASSIGNING FIELD-SYMBOL(<fs_sal>).
*      TRY.
*          CALL METHOD cl_numberrange_runtime=>number_get
*            EXPORTING
*              nr_range_nr       = '01'
*              object            = '/DMO/TRV_M'
*            IMPORTING
*              number            = DATA(number_range_key)
*              returncode        = DATA(number_range_return_code)
*              returned_quantity = DATA(number_range_returned_quantity).
*        CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error).
*          lo_uuid_error->get_text( RECEIVING result = DATA(lv_errortext) ).
*        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
*          lx_number_ranges->get_text( RECEIVING result = lv_errortext ).
*      ENDTRY.
*
*      " ✅ Convert system date into fiscal year
*      CALL FUNCTION 'DATE_TO_FISCAL_YEAR'
*        EXPORTING
*          i_date   = cl_abap_context_info=>get_system_date( )
*          i_periv  = 'K4'          " <-- replace with your company’s fiscal variant
*        IMPORTING
*          e_gjahr  = lv_fiscyear
*          e_perio  = lv_period.
*
*      <fs_sal>-Claimid    = number_range_key.
*      <fs_sal>-Fiscalyear = lv_fiscyear.
*
*    ENDLOOP.
*
*  ELSEIF mapped-zr_claims_items IS NOT INITIAL.
*    LOOP AT mapped-zr_claims_items ASSIGNING FIELD-SYMBOL(<fs_temp>).
*      TRY.
*          CALL METHOD cl_numberrange_runtime=>number_get
*            EXPORTING
*              nr_range_nr       = '01'
*              object            = '/DMO/TRV_M'
*            IMPORTING
*              number            = DATA(number_range_key2)
*              returncode        = DATA(number_range_return_code1)
*              returned_quantity = DATA(number_range_returned_quantit).
*        CATCH cx_nr_object_not_found INTO DATA(lo_uuid_error1).
*          lo_uuid_error1->get_text( RECEIVING result = DATA(lv_errortext1) ).
*        CATCH cx_number_ranges INTO DATA(lx_number_ranges1).
*          lx_number_ranges1->get_text( RECEIVING result = lv_errortext1 ).
*      ENDTRY.
*
*      " ✅ Fiscal year for items also
*      CALL FUNCTION 'DATE_TO_FISCAL_YEAR'
*        EXPORTING
*          i_date   = cl_abap_context_info=>get_system_date( )
*          i_periv  = 'K4'
*        IMPORTING
*          e_gjahr  = lv_fiscyear
*          e_perio  = lv_period.
*
*      <fs_temp>-Itemid     = number_range_key2.
*      <fs_temp>-Claimid    = <fs_temp>-%tmp-Claimid.
*      <fs_temp>-Fiscalyear = lv_fiscyear.
*
*    ENDLOOP.
*  ENDIF.

*ENDMETHOD.



ENDCLASS.

CLASS lhc_ZR_CLAIMS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_claims RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_claims RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_claims RESULT result.

    METHODS approveclaim FOR MODIFY
      IMPORTING keys FOR ACTION zr_claims~approveclaim RESULT result.

    METHODS rejectclaim FOR MODIFY
      IMPORTING keys FOR ACTION zr_claims~rejectclaim RESULT result.

    METHODS submitclaim FOR MODIFY
      IMPORTING keys FOR ACTION zr_claims~submitclaim RESULT result.

    METHODS withdrawclaim FOR MODIFY
      IMPORTING keys FOR ACTION zr_claims~withdrawclaim RESULT result.
    METHODS validate_total FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_claims~validate_total.


ENDCLASS.

CLASS lhc_ZR_CLAIMS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

METHOD ApproveClaim.

  READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
    FIELDS ( Claimstatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky ) )
    RESULT DATA(lt_claims).

  LOOP AT lt_claims ASSIGNING FIELD-SYMBOL(<fs_claim>).

    IF <fs_claim>-Claimstatus = 'Approved'.
      INSERT VALUE #(
        %tky = <fs_claim>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '008'
                 severity = if_abap_behv_message=>severity-error )
      ) INTO TABLE reported-zr_claims.

      CONTINUE.
    ENDIF.

    MODIFY ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims
      UPDATE FROM VALUE #(
        ( %tky                 = <fs_claim>-%tky
          Claimstatus          = 'Approved'
          %control-Claimstatus = if_abap_behv=>mk-on )
      )
      FAILED failed
      REPORTED reported.

  ENDLOOP.

  READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
    ALL FIELDS
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky ) )
    RESULT DATA(lt_project).

  result = VALUE #(
    FOR lw_project IN lt_project
      ( %tky   = lw_project-%tky
        %param = lw_project )
  ).

ENDMETHOD.

METHOD RejectClaim.

  READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
    FIELDS ( Claimstatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky ) )
    RESULT DATA(lt_claims).

  LOOP AT lt_claims ASSIGNING FIELD-SYMBOL(<fs_claim>).
    IF <fs_claim>-Claimstatus = 'Rejected'.
      INSERT VALUE #(
        %tky = <fs_claim>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '009'
                 severity = if_abap_behv_message=>severity-error )
      ) INTO TABLE reported-zr_claims.
    ENDIF.
  ENDLOOP.

  MODIFY ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
    UPDATE FIELDS ( Claimstatus Rejectionreason )
    WITH VALUE #(
      FOR key IN keys
        ( %tky            = key-%tky
          Claimstatus     = 'Rejected'
          Rejectionreason = key-%param-rejectionreason )
    ).

  READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
    ALL FIELDS
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky ) )
    RESULT DATA(lt_data).

  result = VALUE #(
    FOR wa_data IN lt_data
      ( %tky   = wa_data-%tky
        %param = wa_data )
  ).

ENDMETHOD.



METHOD SubmitClaim.
  READ ENTITIES OF zr_claims IN LOCAL MODE
    ENTITY zr_claims
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

    IF <fs_data>-Claimstatus = 'Submitted'.
      INSERT VALUE #(
        %tky = <fs_data>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '010'
                 severity = if_abap_behv_message=>severity-warning )
      ) INTO TABLE reported-zr_claims.
    ENDIF.

    IF <fs_data>-%is_draft IS INITIAL.
      APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-zr_claims.
      INSERT VALUE #(
        %tky = <fs_data>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '006'
                 severity = if_abap_behv_message=>severity-error )
      ) INTO TABLE reported-zr_claims.
      CONTINUE.
    ENDIF.

    READ ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims BY \_Item
      ALL FIELDS
      WITH VALUE #( ( %tky = <fs_data>-%tky ) )
      RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-zr_claims.
      INSERT VALUE #(
        %tky = <fs_data>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '001'
                 severity = if_abap_behv_message=>severity-error )
      ) INTO TABLE reported-zr_claims.
      CONTINUE.
    ENDIF.

    IF <fs_data>-Claimstatus = ''.

      MODIFY ENTITIES OF zr_claims IN LOCAL MODE
        ENTITY zr_claims UPDATE
          FIELDS ( Claimstatus )
          WITH VALUE #(
            FOR key IN keys ( %tky = key-%tky Claimstatus = 'Submitted' )
          ).

      READ ENTITIES OF zr_claims IN LOCAL MODE
        ENTITY zr_claims
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(claims).

      result = VALUE #(
                 FOR claim IN claims
                   ( %tky   = claim-%tky
                     %param = claim )
               ).
    ENDIF.
  ENDLOOP.
ENDMETHOD.



METHOD WithdrawClaim.

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
    READ ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims
      FIELDS ( Claimstatus )
      WITH VALUE #( ( %tky = <fs_key>-%tky ) )
      RESULT DATA(lt_pr).

    DATA(lv_status) = VALUE #( lt_pr[ 1 ]-Claimstatus OPTIONAL ).
    IF lv_status = 'Approved'.
      APPEND VALUE #(
        %tky = <fs_key>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '003'
                 severity = if_abap_behv_message=>severity-error )
      ) TO reported-zr_claims.

      APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-zr_claims.
      CONTINUE.
    ENDIF.

    IF lv_status = 'Withdraw'.
      APPEND VALUE #(
        %tky = <fs_key>-%tky
        %msg = new_message(
                 id       = 'ZMSG2'
                 number   = '011'
                 severity = if_abap_behv_message=>severity-warning )
      ) TO reported-zr_claims.
      CONTINUE.
    ENDIF.

    MODIFY ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims
      UPDATE FROM VALUE #(
        ( %tky                 = <fs_key>-%tky
          Claimstatus          = 'Withdraw'
          %control-Claimstatus = if_abap_behv=>mk-on )
      )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zr_claims IN LOCAL MODE
      ENTITY zr_claims
      ALL FIELDS
      WITH VALUE #( ( %tky = <fs_key>-%tky ) )
      RESULT DATA(lt_project).

    result = VALUE #(
      FOR lw_project IN lt_project
        ( %tky = lw_project-%tky
          %param = lw_project )
    ).

  ENDLOOP.

ENDMETHOD.


  METHOD validate_total.
    READ ENTITIES OF zr_claims IN LOCAL MODE
            ENTITY zr_claims
              FIELDS ( Totalamount )
              WITH CORRESPONDING #( keys )
              RESULT DATA(lt_tot).

    LOOP AT lt_tot ASSIGNING FIELD-SYMBOL(<fs_tot>).
      IF <fs_tot>-Totalamount > 10000.
        APPEND VALUE #(
          %tky = <fs_tot>-%tky
          %msg = new_message(
                   id       = 'ZMSG2'
                   number   = '005'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_claims.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
