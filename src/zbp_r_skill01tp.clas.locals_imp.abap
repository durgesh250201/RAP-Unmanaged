CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_buffer.
             INCLUDE TYPE   zdrap_employeesk AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer.

    TYPES tt_mf TYPE SORTED TABLE OF ty_buffer WITH UNIQUE KEY sid.

    CLASS-DATA mt_buffer TYPE tt_mf.
ENDCLASS.

CLASS lhc_skill DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      create FOR MODIFY
        IMPORTING entities FOR CREATE Skill,
      update FOR MODIFY
        IMPORTING
          entities FOR UPDATE  Skill,
      delete FOR MODIFY
        IMPORTING
          keys FOR DELETE  Skill,
      read FOR READ
        IMPORTING
                  keys   FOR READ  Skill
        RESULT    result,
      rba_emp FOR READ
        IMPORTING
                  keys_rba FOR READ  Skill\_Emp
                    FULL result_requested
        RESULT    result
                    LINK association_links,
      cba_skillhist FOR MODIFY
        IMPORTING
          entities_cba FOR CREATE  Skill\_SkillHist,
      rba_skillhist FOR READ
        IMPORTING
                  keys_rba FOR READ  Skill\_SkillHist
                    FULL result_requested
        RESULT    result
                    LINK association_links.
ENDCLASS.

CLASS lhc_skill IMPLEMENTATION.
  METHOD update.
    LOOP AT entities INTO DATA(ls_update).
      READ TABLE lcl_buffer=>mt_buffer WITH KEY sid = ls_update-sid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc <> 0.

        SELECT SINGLE * FROM zdrap_employeesk WHERE sid = @ls_update-sid INTO @DATA(ls_db).
        INSERT VALUE #( flag = 'U' data = ls_db ) INTO TABLE lcl_buffer=>mt_buffer ASSIGNING <ls_buffer>.
      ENDIF.

      IF ls_update-%control-Sname IS NOT INITIAL.
        <ls_buffer>-Sname = ls_update-Sname.
      ENDIF.

      IF ls_update-%control-exp IS NOT INITIAL.
        <ls_buffer>-exp = ls_update-exp.
      ENDIF.
**
      IF ls_update-%control-Hotskill IS NOT INITIAL.
        <ls_buffer>-Hotskill = ls_update-Hotskill.
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
      IF ls_delete-sid IS INITIAL.
        ls_delete-sid = mapped-skill[ %cid = ls_delete-%cid_ref ]-sid.
      ENDIF.

      READ TABLE lcl_buffer=>mt_buffer WITH KEY sid = ls_delete-sid ASSIGNING FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        IF <ls_buffer>-flag = 'C'.
          DELETE TABLE lcl_buffer=>mt_buffer WITH TABLE KEY sid = ls_delete-sid.
        ELSE.
          <ls_buffer>-flag = 'D'.
        ENDIF.
      ELSE.
        INSERT VALUE #( flag = 'D' sid = ls_delete-sid ) INTO TABLE lcl_buffer=>mt_buffer.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD read.
    SELECT * FROM zdrap_employeesk
      FOR ALL ENTRIES IN @keys
      WHERE eid = @keys-eid
        AND sid = @keys-sid
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.
  METHOD create.

    LOOP AT entities INTO DATA(ls_create).
      SELECT SINGLE MAX( sid ) FROM zdrap_employeesk INTO @DATA(lv_max_sid).
      lv_max_sid = lv_max_sid + 1.
      ls_create-%data-sid = lv_max_sid.

      GET TIME STAMP FIELD DATA(lv_tsl).
      ls_create-%data-lastchangedat = lv_tsl.
      ls_create-%data-LocalCreatedBy = sy-uname.
      ls_create-%data-LocalCreatedAt = lv_tsl.
    ENDLOOP.

    DATA: messages   TYPE /dmo/t_message.
    IF ls_create-sid IS INITIAL.
      APPEND VALUE #( sid = ls_create-sid ) TO failed-skill.
      APPEND VALUE #( sid = ls_create-sid
                             %msg = new_message_with_text( text = | You have entered Invalid Details |
                             severity  = if_abap_behv_message=>severity-error )
                             %element-sid = if_abap_behv=>mk-on
                           ) TO reported-skill.
    ELSE.


      INSERT VALUE #( flag = 'C' data = CORRESPONDING #( ls_create-%data
      MAPPING
      eid                   = eid
      sid                   = sid
      Sname                 = sname
      Exp                   = exp
      Hotskill              = hotskill
      local_created_by      = LocalCreatedBy
      local_created_at      = LocalCreatedAt
      local_last_changed_by = LocalLastChangedBy
      local_last_changed_at = LocalLastChangedAt
      last_changed_at       = LastChangedAt
                 ) ) INTO TABLE lcl_buffer=>mt_buffer.

      IF ls_create-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_create-%cid
                         sid = ls_create-sid ) INTO TABLE mapped-skill.
      ENDIF.
    ENDIF.


  ENDMETHOD.
  METHOD rba_emp.
  ENDMETHOD.
  METHOD cba_skillhist.
    DATA : ls_sklhis TYPE zdrap_employeesh.
    READ TABLE entities_cba ASSIGNING FIELD-SYMBOL(<lfs_skill>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(lv_po) = <lfs_skill>-eid.
    ENDIF.

    READ TABLE <lfs_skill>-%target ASSIGNING FIELD-SYMBOL(<lfs_items>) INDEX 1.
    IF sy-subrc EQ 0.
      DATA(ls_items) = CORRESPONDING zdrap_employeesh( <lfs_items> MAPPING FROM ENTITY USING CONTROL ).
    ENDIF.

    INSERT zdrap_employeesh FROM @ls_items.
    IF sy-subrc IS INITIAL.
      INSERT VALUE #( %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                      shid = ls_items-shid
                      ) INTO TABLE mapped-skillhist.
    ELSE.
      APPEND VALUE #( %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                      shid = ls_items-shid
                     ) TO failed-skillhist.
      APPEND VALUE #( %msg = new_message( id = '00'
                                          number = '001'
                                          v1 = 'Invalid Details entered'
                                          severity = if_abap_behv_message=>severity-error )
                      %key-eid = lv_po
                      %key-sid = ls_items-sid
                      %cid = <lfs_skill>-%cid_ref
                      eid = lv_po
                      sid = ls_items-sid
                      shid = ls_items-shid
                      ) TO reported-skillhist.
    ENDIF.
  ENDMETHOD.
  METHOD rba_skillhist.
  ENDMETHOD.
ENDCLASS.
