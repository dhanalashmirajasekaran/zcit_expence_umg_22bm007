CLASS zexp_config_loader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zexp_config_loader IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_config TYPE TABLE OF zexp_config.

    lt_config = VALUE #(
      " STORE data
      ( client = sy-mandt config_type = 'STORE' config_key = 'ZUD-MAS'
        config_value = 'ZUD-Chennai' config_desc = 'Chennai Store'
        addl_field1 = 'Chennai' addl_field2 = 'Tamil Nadu'
        addl_field3 = 'CC1001' budget_amt = '50000'
        currency = 'INR' is_active = 'X' )
      ( client = sy-mandt config_type = 'STORE' config_key = 'ZUD-MUM'
        config_value = 'ZUD-Mumbai' config_desc = 'Mumbai Store'
        addl_field1 = 'Mumbai' addl_field2 = 'Maharashtra'
        addl_field3 = 'CC1002' budget_amt = '75000'
        currency = 'INR' is_active = 'X' )
      ( client = sy-mandt config_type = 'STORE' config_key = 'ZUD-BLR'
        config_value = 'ZUD-Bangalore' config_desc = 'Bangalore Store'
        addl_field1 = 'Bangalore' addl_field2 = 'Karnataka'
        addl_field3 = 'CC1003' budget_amt = '60000'
        currency = 'INR' is_active = 'X' )
      ( client = sy-mandt config_type = 'STORE' config_key = 'ZUD-DEL'
        config_value = 'ZUD-Delhi' config_desc = 'Delhi Store'
        addl_field1 = 'Delhi' addl_field2 = 'Delhi NCR'
        addl_field3 = 'CC1004' budget_amt = '80000'
        currency = 'INR' is_active = 'X' )

      " VENDOR data
      ( client = sy-mandt config_type = 'VENDOR' config_key = 'VEN001'
        config_value = 'Sri Electricals'
        config_desc = 'Electrical supplier' is_active = 'X' )
      ( client = sy-mandt config_type = 'VENDOR' config_key = 'VEN002'
        config_value = 'Kumar Plumbing'
        config_desc = 'Plumbing supplier' is_active = 'X' )
      ( client = sy-mandt config_type = 'VENDOR' config_key = 'VEN003'
        config_value = 'Clean Masters'
        config_desc = 'Housekeeping supplier' is_active = 'X' )
      ( client = sy-mandt config_type = 'VENDOR' config_key = 'VEN004'
        config_value = 'Deco Props Ltd'
        config_desc = 'Visual merchandising' is_active = 'X' )
      ( client = sy-mandt config_type = 'VENDOR' config_key = 'VEN005'
        config_value = 'City Repairs'
        config_desc = 'General repairs' is_active = 'X' )
    ).

    DELETE FROM zexp_config.
    INSERT zexp_config FROM TABLE @lt_config.

    IF sy-subrc = 0.
      out->write( 'Config data inserted successfully!' ).
    ELSE.
      out->write( 'Error inserting config data!' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
