CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_buffer.
             INCLUDE TYPE   zdrap_employeesh AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer.

    TYPES tt_mf TYPE SORTED TABLE OF ty_buffer WITH UNIQUE KEY shid.

    CLASS-DATA mt_buffer TYPE tt_mf.
ENDCLASS.
CLASS lhc_skillhist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      Create FOR MODIFY
        IMPORTING entities FOR CREATE SkillHIst,
      update FOR MODIFY
        IMPORTING
          entities FOR UPDATE  SkillHist,
      delete FOR MODIFY
        IMPORTING
          keys FOR DELETE  SkillHist,
      read FOR READ
        IMPORTING
                  keys   FOR READ  SkillHist
        RESULT    result,
      rba_skill FOR READ
        IMPORTING
                  keys_rba FOR READ  SkillHist\_Skill
                    FULL result_requested
        RESULT    result
                    LINK association_links.
ENDCLASS.

CLASS lhc_skillhist IMPLEMENTATION.
  METHOD create.
    LOOP AT entities INTO DATA(ls_create).
      SELECT SINGLE MAX( shid ) FROM zdrap_employeesh INTO @DATA(lv_max_shid).
      lv_max_shid = lv_max_shid + 1.
      ls_create-%data-shid = lv_max_shid.

      GET TIME STAMP FIELD DATA(lv_tsl).
      ls_create-%data-lastchangedat = lv_tsl.
      ls_create-%data-LocalCreatedBy = sy-uname.
      ls_create-%data-LocalCreatedAt = lv_tsl.
    ENDLOOP.

    DATA: messages   TYPE /dmo/t_message.
    IF ls_create-shid IS INITIAL.
      APPEND VALUE #( shid = ls_create-shid ) TO failed-skillHist.
      APPEND VALUE #( shid = ls_create-shid
                             %msg = new_message_with_text( text = | You have entered Invalid Details |
                             severity  = if_abap_behv_message=>severity-error )
                             %element-shid = if_abap_behv=>mk-on
                           ) TO reported-skillHist.
    ELSE.


      INSERT VALUE #( flag = 'C' data = CORRESPONDING #( ls_create-%data
      MAPPING
      eid                   = eid
      sid                   = sid
      shid                  = shid
      projname              = Projname
      projyear              = Projyear
      local_created_by      = LocalCreatedBy
      local_created_at      = LocalCreatedAt
      local_last_changed_by = LocalLastChangedBy
      local_last_changed_at = LocalLastChangedAt
      last_changed_at       = LastChangedAt
                 ) ) INTO TABLE lcl_buffer=>mt_buffer.

      IF ls_create-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_create-%cid
                         shid = ls_create-shid ) INTO TABLE mapped-skillHist.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD update.
    LOOP AT entities INTO DATA(ls_update).
      READ TABLE lcl_buffer=>mt_buffer WITH KEY shid = ls_update-shid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc <> 0.

        SELECT SINGLE * FROM zdrap_employeesh WHERE shid = @ls_update-shid INTO @DATA(ls_db).
        INSERT VALUE #( flag = 'U' data = ls_db ) INTO TABLE lcl_buffer=>mt_buffer ASSIGNING <ls_buffer>.
      ENDIF.

      IF ls_update-%control-projname IS NOT INITIAL.
        <ls_buffer>-projname = ls_update-projname.
      ENDIF.

      IF ls_update-%control-projyear IS NOT INITIAL.
        <ls_buffer>-projyear = ls_update-projyear.
      ENDIF.
**
      GET TIME STAMP FIELD DATA(lv_tsl).
      <ls_buffer>-last_changed_at = lv_tsl.
      <ls_buffer>-Local_Last_Changed_By = sy-uname.
      <ls_buffer>-Local_Last_Changed_At = lv_tsl.

    ENDLOOP.
  ENDMETHOD.
  METHOD delete.
    LOOP AT keys INTO DATA(ls_delete).
      IF ls_delete-shid IS INITIAL.
        ls_delete-shid = mapped-skillHist[ %cid = ls_delete-%cid_ref ]-shid.
      ENDIF.

      READ TABLE lcl_buffer=>mt_buffer WITH KEY shid = ls_delete-shid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        IF <ls_buffer>-flag = 'C'.
          DELETE TABLE lcl_buffer=>mt_buffer WITH TABLE KEY shid = ls_delete-shid.
        ELSE.
          <ls_buffer>-flag = 'D'.
        ENDIF.
      ELSE.
        INSERT VALUE #( flag = 'D' shid = ls_delete-shid ) INTO TABLE lcl_buffer=>mt_buffer.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD read.
    SELECT * FROM zdrap_employeesh
    FOR ALL ENTRIES IN @keys
    WHERE eid = @keys-eid
      AND sid = @keys-sid
      AND shid = @keys-shid
    INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.
  METHOD rba_skill.
  ENDMETHOD.
ENDCLASS.
