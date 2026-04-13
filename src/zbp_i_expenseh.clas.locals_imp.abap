*----------------------------------------------------------------------*
* Header Behavior Handler — Determinations & Validations
*----------------------------------------------------------------------*
CLASS lhc_expenseheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      determineCreatedBy
        FOR DETERMINE ON MODIFY
          IMPORTING keys FOR ExpenseHeader~determineCreatedBy,
      determineExpId
        FOR DETERMINE ON MODIFY
          IMPORTING keys FOR ExpenseHeader~determineExpId,
      determineStoreDetails
        FOR DETERMINE ON MODIFY
          IMPORTING keys FOR ExpenseHeader~determineStoreDetails,
      determineGSTAmounts
        FOR DETERMINE ON MODIFY
          IMPORTING keys FOR ExpenseHeader~determineGSTAmounts,
      validateTotalAmount
        FOR VALIDATE ON SAVE
          IMPORTING keys FOR ExpenseHeader~validateTotalAmount,
      validateVendor
        FOR VALIDATE ON SAVE
          IMPORTING keys FOR ExpenseHeader~validateVendor,
      validateBudget
        FOR VALIDATE ON SAVE
          IMPORTING keys FOR ExpenseHeader~validateBudget,
      validateDuplicate
        FOR VALIDATE ON SAVE
          IMPORTING keys FOR ExpenseHeader~validateDuplicate,
      create FOR MODIFY
            IMPORTING entities FOR CREATE ExpenseHeader.

          METHODS update FOR MODIFY
            IMPORTING entities FOR UPDATE ExpenseHeader.

          METHODS delete FOR MODIFY
            IMPORTING keys FOR DELETE ExpenseHeader.

          METHODS read FOR READ
            IMPORTING keys FOR READ ExpenseHeader RESULT result.

          METHODS rba_Items FOR READ
            IMPORTING keys_rba FOR READ ExpenseHeader\_Items FULL result_requested RESULT result LINK association_links.

          METHODS cba_Items FOR MODIFY
            IMPORTING entities_cba FOR CREATE ExpenseHeader\_Items.
ENDCLASS.

CLASS lhc_expenseheader IMPLEMENTATION.

  METHOD determineCreatedBy.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( CreatedBy CreatedOn Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseh\\ExpenseHeader.
    LOOP AT lt_expenses INTO DATA(ls_expense).
      APPEND VALUE #(
        %tky      = ls_expense-%tky
        CreatedBy = sy-uname
        CreatedOn = cl_abap_context_info=>get_system_date( )
        Currency  = 'INR'
        %control  = VALUE #(
          CreatedBy = if_abap_behv=>mk-on
          CreatedOn = if_abap_behv=>mk-on
          Currency  = if_abap_behv=>mk-on )
      ) TO lt_update.
    ENDLOOP.
    MODIFY ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        UPDATE FIELDS ( CreatedBy CreatedOn Currency )
        WITH lt_update
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD determineExpId.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( ExpId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseh\\ExpenseHeader.
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-ExpId IS INITIAL.
        SELECT SINGLE
          FROM zexp_h
          FIELDS MAX( exp_id )
          INTO @DATA(lv_max_id).
        DATA(lv_num) = 1.
        IF lv_max_id IS NOT INITIAL.
          DATA(lv_suffix) = substring(
            val = lv_max_id
            off = 4
            len = 6 ).
          lv_num = CONV i( lv_suffix ) + 1.
        ENDIF.
        DATA(lv_exp_id) = |ZEX-{ lv_num WIDTH = 6 ALIGN = RIGHT PAD = '0' }|.
        APPEND VALUE #(
          %tky     = ls_expense-%tky
          ExpId    = lv_exp_id
          %control = VALUE #( ExpId = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        UPDATE FIELDS ( ExpId )
        WITH lt_update
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD determineStoreDetails.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( StoreId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseh\\ExpenseHeader.
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-StoreId IS NOT INITIAL.
        SELECT SINGLE
          FROM zexp_config
          FIELDS addl_field1, addl_field2, addl_field3
          WHERE config_type = 'STORE'
            AND config_key  = @ls_expense-StoreId
            AND is_active   = 'X'
          INTO @DATA(ls_store).
        IF sy-subrc = 0.
          APPEND VALUE #(
            %tky       = ls_expense-%tky
            City       = ls_store-addl_field1
            Region     = ls_store-addl_field2
            CostCenter = ls_store-addl_field3
            %control   = VALUE #(
              City       = if_abap_behv=>mk-on
              Region     = if_abap_behv=>mk-on
              CostCenter = if_abap_behv=>mk-on )
          ) TO lt_update.
        ENDIF.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        UPDATE FIELDS ( City Region CostCenter )
        WITH lt_update
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD determineGSTAmounts.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( TotalAmt GstSlab )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseh\\ExpenseHeader.
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-TotalAmt > 0 AND ls_expense-GstSlab >= 0.
        DATA(lv_gst_rate)  = CONV decfloat34( ls_expense-GstSlab ).
        DATA(lv_total)     = CONV decfloat34( ls_expense-TotalAmt ).
        DATA(lv_base)      = ( lv_total * 100 ) / ( 100 + lv_gst_rate ).
        DATA(lv_gst_total) = lv_total - lv_base.
        DATA(lv_cgst)      = lv_gst_total / 2.
        DATA(lv_sgst)      = lv_gst_total / 2.
        APPEND VALUE #(
          %tky     = ls_expense-%tky
          BaseAmt  = CONV #( lv_base )
          CgstAmt  = CONV #( lv_cgst )
          SgstAmt  = CONV #( lv_sgst )
          %control = VALUE #(
            BaseAmt = if_abap_behv=>mk-on
            CgstAmt = if_abap_behv=>mk-on
            SgstAmt = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        UPDATE FIELDS ( BaseAmt CgstAmt SgstAmt )
        WITH lt_update
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD validateTotalAmount.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( TotalAmt StoreId VendorId ExpCat PayMode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-TotalAmt <= 0 OR ls_expense-TotalAmt IS INITIAL.
        APPEND VALUE #(
          %tky = ls_expense-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Total Amount must be greater than zero' )
          %element-TotalAmt = if_abap_behv=>mk-on
        ) TO reported-expenseheader.
        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
      ENDIF.
      IF ls_expense-StoreId IS INITIAL.
        APPEND VALUE #(
          %tky = ls_expense-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Store ID is mandatory' )
          %element-StoreId = if_abap_behv=>mk-on
        ) TO reported-expenseheader.
        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
      ENDIF.
      IF ls_expense-VendorId IS INITIAL.
        APPEND VALUE #(
          %tky = ls_expense-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Vendor is mandatory' )
          %element-VendorId = if_abap_behv=>mk-on
        ) TO reported-expenseheader.
        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
      ENDIF.
      IF ls_expense-ExpCat IS INITIAL.
        APPEND VALUE #(
          %tky = ls_expense-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Expense Category is mandatory' )
          %element-ExpCat = if_abap_behv=>mk-on
        ) TO reported-expenseheader.
        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
      ENDIF.
      IF ls_expense-PayMode IS INITIAL.
        APPEND VALUE #(
          %tky = ls_expense-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Payment Mode is mandatory' )
          %element-PayMode = if_abap_behv=>mk-on
        ) TO reported-expenseheader.
        APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateVendor.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( VendorId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-VendorId IS NOT INITIAL.
        SELECT SINGLE
          FROM zexp_config
          FIELDS config_key
          WHERE config_type = 'VENDOR'
            AND config_key  = @ls_expense-VendorId
            AND is_active   = 'X'
          INTO @DATA(lv_vendor).
        IF sy-subrc <> 0.
          APPEND VALUE #(
            %tky = ls_expense-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = 'Vendor is not active or does not exist' )
            %element-VendorId = if_abap_behv=>mk-on
          ) TO reported-expenseheader.
          APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBudget.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( StoreId TotalAmt )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-StoreId IS NOT INITIAL
      AND ls_expense-TotalAmt > 0.
        SELECT SINGLE
          FROM zexp_config
          FIELDS budget_amt
          WHERE config_type = 'STORE'
            AND config_key  = @ls_expense-StoreId
            AND is_active   = 'X'
          INTO @DATA(lv_budget).
        IF sy-subrc = 0 AND lv_budget > 0.
          DATA(lv_today)       = cl_abap_context_info=>get_system_date( ).
          DATA(lv_month_start) = |{ lv_today(6) }01|.
          SELECT COALESCE( SUM( total_amt ), 0 )
            FROM zexp_h
            WHERE store_id   = @ls_expense-StoreId
              AND created_on >= @lv_month_start
              AND status     <> '04'
            INTO @DATA(lv_spent).
          DATA(lv_remaining) = CONV decfloat34( lv_budget )
                             - CONV decfloat34( lv_spent ).
          IF CONV decfloat34( ls_expense-TotalAmt ) > lv_remaining.
            DATA(lv_msg) = |Budget exceeded! Limit: { lv_budget
              } Spent: { lv_spent
              } Remaining: { lv_remaining }|.
            APPEND VALUE #(
              %tky = ls_expense-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = lv_msg )
              %element-TotalAmt = if_abap_behv=>mk-on
            ) TO reported-expenseheader.
            APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDuplicate.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseHeader
        FIELDS ( StoreId VendorId TotalAmt ExpUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_expenses).
    LOOP AT lt_expenses INTO DATA(ls_expense).
      IF ls_expense-StoreId   IS NOT INITIAL
      AND ls_expense-VendorId IS NOT INITIAL
      AND ls_expense-TotalAmt > 0.
        DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
        SELECT SINGLE
          FROM zexp_h
          FIELDS exp_uuid
          WHERE store_id   = @ls_expense-StoreId
            AND vendor_id  = @ls_expense-VendorId
            AND total_amt  = @ls_expense-TotalAmt
            AND created_on = @lv_date
            AND exp_uuid  <> @ls_expense-ExpUuid
          INTO @DATA(lv_dup).
        IF sy-subrc = 0.
          APPEND VALUE #(
            %tky = ls_expense-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = 'Duplicate expense detected for same store, vendor and amount today' )
            %element-TotalAmt = if_abap_behv=>mk-on
          ) TO reported-expenseheader.
          APPEND VALUE #( %tky = ls_expense-%tky ) TO failed-expenseheader.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

  METHOD cba_Items.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Line Item Handler
*----------------------------------------------------------------------*
CLASS lhc_expenseitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      determineItemAmounts
        FOR DETERMINE ON MODIFY
          IMPORTING keys FOR ExpenseItem~determineItemAmounts,
      update FOR MODIFY
            IMPORTING entities FOR UPDATE ExpenseItem.

          METHODS delete FOR MODIFY
            IMPORTING keys FOR DELETE ExpenseItem.

          METHODS read FOR READ
            IMPORTING keys FOR READ ExpenseItem RESULT result.

          METHODS rba_Header FOR READ
            IMPORTING keys_rba FOR READ ExpenseItem\_Header FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_expenseitem IMPLEMENTATION.

  METHOD determineItemAmounts.
    READ ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseItem
        FIELDS ( Quantity UnitPrice Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).
    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseh\\ExpenseItem.
    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-Quantity > 0 AND ls_item-UnitPrice > 0.
        DATA(lv_qty)      = CONV decfloat34( ls_item-Quantity ).
        DATA(lv_price)    = CONV decfloat34( ls_item-UnitPrice ).
        DATA(lv_item_amt) = lv_qty * lv_price.
        READ ENTITIES OF zi_expenseh IN LOCAL MODE
          ENTITY ExpenseItem BY \_Header
            FIELDS ( GstSlab Currency )
            WITH VALUE #( ( %tky = ls_item-%tky ) )
          RESULT DATA(lt_headers).
        DATA(lv_gst_rate)  = CONV decfloat34(
          VALUE #( lt_headers[ 1 ]-GstSlab OPTIONAL ) ).
        DATA(lv_gst_amt)   = ( lv_item_amt * lv_gst_rate ) / 100.
        DATA(lv_total_amt) = lv_item_amt + lv_gst_amt.
        APPEND VALUE #(
          %tky         = ls_item-%tky
          ItemAmt      = CONV #( lv_item_amt )
          ItemGstAmt   = CONV #( lv_gst_amt )
          ItemTotalAmt = CONV #( lv_total_amt )
          Currency     = VALUE #( lt_headers[ 1 ]-Currency OPTIONAL )
          %control     = VALUE #(
            ItemAmt      = if_abap_behv=>mk-on
            ItemGstAmt   = if_abap_behv=>mk-on
            ItemTotalAmt = if_abap_behv=>mk-on
            Currency     = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF zi_expenseh IN LOCAL MODE
      ENTITY ExpenseItem
        UPDATE FIELDS ( ItemAmt ItemGstAmt ItemTotalAmt Currency )
        WITH lt_update
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Lock + Authorization Handler
*----------------------------------------------------------------------*
CLASS lhc_query DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      lock_expenseheader
        FOR LOCK
          IMPORTING keys FOR LOCK ExpenseHeader,
      global_authorization
        FOR GLOBAL AUTHORIZATION
          IMPORTING REQUEST requested_authorizations FOR ExpenseHeader
          RESULT result.
ENDCLASS.

CLASS lhc_query IMPLEMENTATION.

  METHOD lock_expenseheader.
    LOOP AT keys INTO DATA(ls_key).
      TRY.
          cl_abap_lock_object_factory=>get_instance(
            iv_name = 'EZEXP_H' )->enqueue(
              it_parameter = VALUE #(
                ( name  = 'EXP_UUID'
                  value = REF #( ls_key-ExpUuid ) )
              )
            ).
        CATCH cx_abap_foreign_lock cx_abap_lock_failure.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD global_authorization.
    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed
    ).
  ENDMETHOD.

ENDCLASS.
