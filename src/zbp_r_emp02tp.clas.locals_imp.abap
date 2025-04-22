CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_buffer.
             INCLUDE TYPE   zdrap_employeetb AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer.

    TYPES tt_mf TYPE SORTED TABLE OF ty_buffer WITH UNIQUE KEY eid.

    CLASS-DATA mt_buffer TYPE tt_mf.
ENDCLASS.

CLASS lhc_emp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Emp
        RESULT result,
      create FOR MODIFY
        IMPORTING
          entities FOR CREATE  Emp,
      update FOR MODIFY
        IMPORTING
          entities FOR UPDATE  Emp,
      delete FOR MODIFY
        IMPORTING
          keys FOR DELETE  Emp,
      lock FOR LOCK
        IMPORTING
          keys FOR LOCK  Emp,
      read FOR READ
        IMPORTING
                  keys   FOR READ  Emp
        RESULT    result,
      cba_skill FOR MODIFY
        IMPORTING
          entities_cba FOR CREATE  Emp\_Skill,
      rba_skill FOR READ
        IMPORTING
                  keys_rba FOR READ  Emp\_Skill
                    FULL result_requested
        RESULT    result
                    LINK association_links.
ENDCLASS.

CLASS lhc_emp IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD create.

    LOOP AT entities INTO DATA(ls_create).
      SELECT SINGLE MAX( eid ) FROM zdrap_employeetb INTO @DATA(lv_max_eid).
      lv_max_eid = lv_max_eid + 1.
      ls_create-%data-eid = lv_max_eid.

      GET TIME STAMP FIELD DATA(lv_tsl).
      ls_create-%data-lastchangedat = lv_tsl.
      ls_create-%data-LocalCreatedBy = sy-uname.
      ls_create-%data-LocalCreatedAt = lv_tsl.
    ENDLOOP.

    DATA: messages   TYPE /dmo/t_message.
    IF ls_create-eid IS INITIAL.
      APPEND VALUE #( eid = ls_create-eid )
                        TO failed-emp.
      APPEND VALUE #( %msg = new_message( id = '00'
                                          number = '001'
                                          v1 = 'Invalid Details entered'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-eid = ls_create-eid
                      %delete = 'X'
                      eid = ls_create-eid ) TO reported-emp.
    ELSE.

      INSERT VALUE #( flag = 'C' data = CORRESPONDING #( ls_create-%data
      MAPPING
      eid                   = eid
      Fname                 = fname
      Lname                 = lname
      Gender                = gender
      Dept                  = dept
      Status                = status
      Doj                   = doj
      Dol                   = dol
      Salary                = salary
      Currency              = currency
      local_created_by      = LocalCreatedBy
      local_created_at      = LocalCreatedAt
      local_last_changed_by = LocalLastChangedBy
      local_last_changed_at = LocalLastChangedAt
      last_changed_at       = LastChangedAt

                 ) ) INTO TABLE lcl_buffer=>mt_buffer.

      IF ls_create-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_create-%cid
                         eid = ls_create-eid ) INTO TABLE mapped-emp.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD update.
    LOOP AT entities INTO DATA(ls_update).
      READ TABLE lcl_buffer=>mt_buffer WITH KEY eid = ls_update-eid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc <> 0.

        SELECT SINGLE * FROM zdrap_employeetb WHERE eid = @ls_update-eid INTO @DATA(ls_db).
        INSERT VALUE #( flag = 'U' data = ls_db ) INTO TABLE lcl_buffer=>mt_buffer ASSIGNING <ls_buffer>.
      ENDIF.

      IF ls_update-%control-fname IS NOT INITIAL.
        <ls_buffer>-fname = ls_update-fname.
      ENDIF.

      IF ls_update-%control-Lname IS NOT INITIAL.
        <ls_buffer>-lname = ls_update-Lname.
      ENDIF.
**
      IF ls_update-%control-Gender IS NOT INITIAL.
        <ls_buffer>-gender = ls_update-Gender.
      ENDIF.
**
      IF ls_update-%control-dept IS NOT INITIAL.
        <ls_buffer>-dept = ls_update-dept.
      ENDIF.
*
      IF ls_update-%control-Status IS NOT INITIAL.
        <ls_buffer>-status = ls_update-Status.
      ENDIF.
*
      IF ls_update-%control-doj IS NOT INITIAL.
        <ls_buffer>-doj = ls_update-doj.
      ENDIF.
*
      IF ls_update-%control-dol IS NOT INITIAL.
        <ls_buffer>-dol = ls_update-dol.
      ENDIF.
*
      IF ls_update-%control-salary IS NOT INITIAL.
        <ls_buffer>-salary = ls_update-salary.
      ENDIF.
*
      IF ls_update-%control-Currency IS NOT INITIAL.
        <ls_buffer>-currency = ls_update-Currency.
      ENDIF.

      GET TIME STAMP FIELD DATA(lv_tsl).
      <ls_buffer>-last_changed_at = lv_tsl.
      <ls_buffer>-Local_Last_Changed_By = sy-uname.
      <ls_buffer>-Local_Last_Changed_At = lv_tsl.

    ENDLOOP.
  ENDMETHOD.
  METHOD delete.
    LOOP AT keys INTO DATA(ls_delete).
      IF ls_delete-eid IS INITIAL.
        ls_delete-eid = mapped-emp[ %cid = ls_delete-%cid_ref ]-eid.
      ENDIF.

      READ TABLE lcl_buffer=>mt_buffer WITH KEY eid = ls_delete-eid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        IF <ls_buffer>-flag = 'C'.
          DELETE TABLE lcl_buffer=>mt_buffer WITH TABLE KEY eid = ls_delete-eid.
        ELSE.
          <ls_buffer>-flag = 'D'.
        ENDIF.
      ELSE.
        INSERT VALUE #( flag = 'D' eid = ls_delete-eid ) INTO TABLE lcl_buffer=>mt_buffer.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD lock.
  ENDMETHOD.
  METHOD read.
    SELECT * FROM zdrap_employeetb
    FOR ALL ENTRIES IN @keys
    WHERE eid = @keys-eid
    INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.
  METHOD cba_skill.
    DATA : ls_skills TYPE zdrap_employeesk.
    READ TABLE entities_cba ASSIGNING FIELD-SYMBOL(<lfs_skill>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(lv_po) = <lfs_skill>-eid.
    ENDIF.

    READ TABLE <lfs_skill>-%target ASSIGNING FIELD-SYMBOL(<lfs_items>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(ls_items) = CORRESPONDING zdrap_employeesk( <lfs_items> MAPPING FROM ENTITY USING CONTROL ).
    ENDIF.

    INSERT zdrap_employeesk FROM @ls_items.
    IF sy-subrc IS INITIAL.
      INSERT VALUE #( %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                      ) INTO TABLE mapped-skill.
    ELSE.
      APPEND VALUE #( %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                     ) TO failed-skill.
      APPEND VALUE #( %msg = new_message( id = '00'
                                          number = '001'
                                          v1 = 'Invalid Details entered'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-eid = lv_po
                      %key-sid = ls_items-sid
                      %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                      ) TO reported-skill.
    ENDIF.
  ENDMETHOD.
  METHOD rba_skill.
  ENDMETHOD.
ENDCLASS.
CLASS lcl_zr_emp02tp DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      finalize REDEFINITION,
      adjust_numbers REDEFINITION,
      check_before_save REDEFINITION,
      save REDEFINITION,
      cleanup REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lcl_zr_emp02tp IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.
  METHOD check_before_save.
  ENDMETHOD.
  METHOD adjust_numbers.
  ENDMETHOD.
  METHOD save.
    DATA lt_data TYPE STANDARD TABLE OF zdrap_employeetb.
    CLEAR lt_data.
    lt_data = VALUE #(  FOR row IN lcl_buffer=>mt_buffer WHERE  ( flag = 'C' ) (  row-data ) ).
    IF lt_data IS NOT INITIAL.
      INSERT zdrap_employeetb FROM TABLE @lt_data.
    ENDIF.

    lt_data = VALUE #(  FOR row IN lcl_buffer=>mt_buffer WHERE  ( flag = 'U' ) (  row-data ) ).
    IF lt_data IS NOT INITIAL.
      UPDATE zdrap_employeetb FROM TABLE @lt_data.
    ENDIF.

    lt_data = VALUE #(  FOR row IN lcl_buffer=>mt_buffer WHERE  ( flag = 'D' ) (  row-data ) ).
    IF lt_data IS NOT INITIAL.
      DELETE zdrap_employeetb FROM TABLE @lt_data.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
