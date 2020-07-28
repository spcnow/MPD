*&---------------------------------------------------------------------*
*&  Include           /SPCX/MERP_PLANDASH_I_S02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PREPARE_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE prepare_0100 OUTPUT.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF wa110 IS INITIAL.
    DATA: lv_fcode TYPE TABLE OF sy-ucomm.
    APPEND 'MMBE' TO lv_fcode.
    APPEND 'MD04' TO lv_fcode.
    APPEND 'VL06I' TO lv_fcode.
    APPEND 'MB51' TO lv_fcode.
    APPEND 'MB53' TO lv_fcode.
    SET PF-STATUS 'STATUS_0100' EXCLUDING lv_fcode .
  ELSE.
    SET PF-STATUS 'STATUS_0100'.
  ENDIF.

  IF wa110-matnr IS INITIAL.
    SET TITLEBAR '0100'.
  ELSE.
    SET TITLEBAR '0101' WITH wa110-matnr.
  ENDIF.


  "Refresh display
  CALL METHOD alv_grid3->refresh_table_display
    EXCEPTIONS
      OTHERS = 2.
  IF sy-subrc = 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF wa110 IS NOT INITIAL.


    CALL METHOD obj_logo->free
      EXCEPTIONS
        cntl_error = 1
        OTHERS     = 2.

    CALL METHOD ref_html->load_data
      EXPORTING
        type                 = 'text'
        subtype              = 'html'
      IMPORTING
        assigned_url         = w_url
      CHANGING
        data_table           = ts_data
      EXCEPTIONS
        dp_invalid_parameter = 1
        dp_error_general     = 2
        cntl_error           = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.

    ENDIF.

    CALL METHOD ref_html->show_url
      EXPORTING
        url                    = w_url
      EXCEPTIONS
        cntl_error             = 1
        cnht_error_not_allowed = 2
        cnht_error_parameter   = 3
        dp_error_general       = 4
        OTHERS                 = 5.
    IF sy-subrc <> 0.

    ENDIF.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE g_okcode.
    WHEN 'BACK'.SET SCREEN 0. LEAVE SCREEN.
    WHEN 'EXIT'.SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CANC'.SET SCREEN 0. LEAVE SCREEN.

    WHEN 'REFRESH'.
      SUBMIT /spcx/merp_plandash
      WITH s_werks IN s_werks
      WITH s_dispo IN s_dispo
      WITH s_prgrp IN s_prgrp
      WITH s_matnr IN s_matnr
      WITH s_lifnr IN s_lifnr
      WITH s_beskz IN s_beskz
      WITH p_backlg = p_backlg
      WITH p_dohf = p_dohf
      WITH p_doh = p_doh
      WITH s_date IN s_date
      WITH g_li_grn = g_li_grn
      WITH g_li_ylw = g_li_ylw
      WITH g_li_red = g_li_red.


    WHEN 'MD04' OR 'MMBE' OR 'MB53'.
      SET PARAMETER ID 'MAT' FIELD wa110-matnr.
      SET PARAMETER ID 'WRK' FIELD s_werks-low.
      CALL TRANSACTION g_okcode AND SKIP FIRST SCREEN.
    WHEN 'MB51'.
      PERFORM bdc_mb51.
    WHEN 'VL06I'.
      PERFORM bdc_vl06.

    WHEN 'DETAIL'.
      DATA: ld_row      TYPE i.

      CALL METHOD alv_grid1->get_current_cell
        IMPORTING
          e_row = ld_row.

    WHEN OTHERS.
  ENDCASE.


ENDMODULE.


*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler DEFINITION
*---------------------------------------------------------------------*
* Double click event handling definition
*---------------------------------------------------------------------*
CLASS lcl_eventhandler DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
            e_row
            e_column
            es_row_no
            sender,  " sending control, i.e. ALV grid that raised event


      handle_size_control                 " SIZE_CONTROL
        FOR EVENT size_control OF cl_gui_alv_grid,

      handle_toolbar FOR EVENT toolbar  OF cl_gui_alv_grid.


ENDCLASS.                    "lcl_eventhandler DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler IMPLEMENTATION
*---------------------------------------------------------------------*
* Double click event implementation
*---------------------------------------------------------------------*
CLASS lcl_eventhandler IMPLEMENTATION.

  METHOD handle_double_click.
*   define local data

*   Distinguish according to sending grid instance
    CASE sender.
      WHEN alv_grid1.
        CALL METHOD alv_grid1->set_current_cell_via_id
          EXPORTING
            is_row_no = es_row_no.

        "Fill WA110 for material details.

        READ TABLE gt_matnr INTO ls_matnr INDEX e_row-index.
        IF ls_matnr-matnr IS NOT INITIAL.

          PERFORM single_update USING ls_matnr-matnr.

          "Refresh display
          CALL METHOD alv_grid1->refresh_table_display
            EXCEPTIONS
              OTHERS = 2.
          IF sy-subrc = 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          CALL METHOD alv_grid1->set_current_cell_via_id
            EXPORTING
              is_row_no = es_row_no.

          PERFORM fill_wa110.
          PERFORM fill_req_forecast.
          PERFORM fill_worst_forecast.

          "Best case scenario.
          lv_matfo-keyfigure = TEXT-bst.

          "Scheduled receipts
          CLEAR ls_matfo.
          ls_matfo-keyfigure = TEXT-sch."'Scheduled Receipts'
          LOOP AT gt_purch INTO gt_purch WHERE matnr = wa110-matnr.
            IF gt_purch-eindt < sy-datum.
              "Reduce already received qty
              ls_matfo-day0 = ls_matfo-day0 + gt_purch-menge - gt_purch-wemng.
              lv_matfo-day0 = lv_matfo-day0 + gt_purch-menge - gt_purch-wemng.

              "Add receipt stock to all subsequent days.
              LOOP AT gt_fmap INTO gt_fmap.
                REPLACE 'LS_MATFO' WITH 'LV_MATFO' INTO gt_fmap-fieldname.
                ASSIGN (gt_fmap-fieldname) TO <fs>.
                <fs> = <fs> + gt_purch-menge  - gt_purch-wemng.

              ENDLOOP.

            ELSE.
              READ TABLE gt_fmap INTO gt_fmap
                WITH KEY date = gt_purch-eindt.
              IF sy-subrc EQ 0.
                ASSIGN (gt_fmap-fieldname) TO <fs>.
                <fs> = <fs> + gt_purch-menge  - gt_purch-wemng.
              ENDIF.

              "Add receipt stock to all subsequent days.
              LOOP AT gt_fmap INTO gt_fmap
                WHERE date >= gt_purch-eindt.
                REPLACE 'LS_MATFO' WITH 'LV_MATFO' INTO gt_fmap-fieldname.
                ASSIGN (gt_fmap-fieldname) TO <fs>.
                <fs> = <fs> + gt_purch-menge  - gt_purch-wemng.

              ENDLOOP.


            ENDIF.
          ENDLOOP.
          wa110-openqty = ls_matfo-day0.
          APPEND ls_matfo TO gt_matfo. "Scheduled Receipts.
          APPEND lv_matfo TO gt_matfo. " Best case scenario.


          PERFORM fill_optimistdoh.
          PERFORM fill_html.
          PERFORM set_cell_colors USING TEXT-wst. "Worst case scenario
          PERFORM set_cell_colors USING TEXT-bst. "Best Case scenario
          PERFORM format_negatives.


        ENDIF.


*         Triggers PAI of the dynpro with the specified ok-code
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'DETAIL'.

      WHEN alv_grid3.
        CALL METHOD alv_grid1->set_current_cell_via_id
          EXPORTING
            is_row_no = es_row_no.

        CASE es_row_no-row_id.
          WHEN 1.
            CALL METHOD cl_gui_cfw=>set_new_ok_code
              EXPORTING
                new_code = 'MD04'.
*                	WHEN 2.
          WHEN 3.
            CALL METHOD cl_gui_cfw=>set_new_ok_code
              EXPORTING
                new_code = 'VL06I'.
*                  WHEN 4.
        ENDCASE.

      WHEN OTHERS.
*        RETURN.
    ENDCASE.

  ENDMETHOD.                    "handle_double_click

  METHOD handle_size_control.                 " SIZE_CONTROL

  ENDMETHOD.


  METHOD handle_toolbar.                 " Toolbar control
  ENDMETHOD.

ENDCLASS.                    "lcl_eventhandler IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM create_objects .

  CREATE OBJECT main_cont
    EXPORTING
      container_name = 'MAIN_CONT'.

**   create splitter container in which to place graphics
  CREATE OBJECT splitter
    EXPORTING
      parent  = main_cont
      rows    = 2
      columns = 1
      align   = 15. " (splitter fills the hole custom container)

**   get part of splitter container for 1st table
  CALL METHOD splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = container_top.


**   get part of splitter container for 2nd table
  CALL METHOD splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = container_forecast.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 1
      height = '70'.

  CALL METHOD splitter->set_row_sash
    EXPORTING
      id    = 1
      type  = 0
      value = 0.


  CREATE OBJECT splitter
    EXPORTING
      parent  = container_top
      rows    = 1
      columns = 2
      align   = 15. " (splitter fills the hole custom container)

  CALL METHOD splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = container_matlist.


  CALL METHOD splitter->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = container_matdetail.





  CREATE OBJECT obj_logo
    EXPORTING
      parent = container_matdetail
    EXCEPTIONS
      error  = 0.

  CALL FUNCTION 'DP_PUBLISH_WWW_URL'
    EXPORTING
      objid    = '/SPCX/SLOGOTRA'
      lifetime = 'T'
    IMPORTING
      url      = url.


  CALL METHOD obj_logo->load_picture_from_url( url = url ).

  CREATE OBJECT ref_html
    EXPORTING
      parent             = container_matdetail
    EXCEPTIONS
      cntl_error         = 1
      cntl_install_error = 2
      dp_install_error   = 3
      dp_error           = 4
      OTHERS             = 5.

  CALL METHOD obj_logo->set_display_mode(
    obj_logo->display_mode_normal_center ).


ENDFORM.                    " CREATE_OBJECTS
*&---------------------------------------------------------------------*
*&      Form  DISP_ALV1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM disp_alv1 .


*Build field catalog
  TYPES: wa_fldcat TYPE lvc_t_fcat.
  DATA: t_fldcat TYPE wa_fldcat WITH HEADER LINE.

  t_fldcat-scrtext_l = 'Status'.
  t_fldcat-seltext = 'Status'.
  t_fldcat-fieldname = 'LIGHT'.
  t_fldcat-tabname = 'GT_MATNR'.
  t_fldcat-outputlen = '4'.
  t_fldcat-icon = 'X'.
  APPEND t_fldcat.

*  t_fldcat-scrtext_l = 'Material'.
*  t_fldcat-seltext = 'Material'.
  t_fldcat-fieldname = 'MATNR'.
  t_fldcat-tabname = 'GT_MATNR'.
  t_fldcat-ref_field = 'MATNR'.
  t_fldcat-ref_table = 'MARA'.
  t_fldcat-outputlen = '18'.
  APPEND t_fldcat.


  t_fldcat-fieldname = 'MAKTX'.
  t_fldcat-tabname = 'GT_MATNR'.
  t_fldcat-ref_field = 'MAKTX'.
  t_fldcat-ref_table = 'MAKT'.
  t_fldcat-outputlen = '20'.
  APPEND t_fldcat.

  CLEAR t_fldcat.
  t_fldcat-scrtext_l = TEXT-doh.
  t_fldcat-seltext = TEXT-doh.
  t_fldcat-fieldname = 'DOH'.
  t_fldcat-tabname = 'GT_MATNR'.
  t_fldcat-outputlen = '4'.
  APPEND t_fldcat.

  PERFORM append_fcat TABLES t_fldcat USING	'MTART' 'GT_MATNR' 'MTART' 'MARA'.
  PERFORM append_fcat TABLES t_fldcat USING	'MATKL' 'GT_MATNR' 'MATKL' 'MARA'.
  PERFORM append_fcat TABLES t_fldcat USING	'MEINS' 'GT_MATNR' 'MEINS' 'MARA'.
  PERFORM append_fcat TABLES t_fldcat USING	'MAABC' 'GT_MATNR' 'MAABC' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'DISMM' 'GT_MATNR' 'DISMM' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'DISPO' 'GT_MATNR' 'DISPO' 'MARC'. "Ver. 1.1
  PERFORM append_fcat TABLES t_fldcat USING	'BESKZ' 'GT_MATNR' 'BESKZ' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'SOBSL' 'GT_MATNR' 'SOBSL' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'SCHGT' 'GT_MATNR' 'SCHGT' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'PLIFZ' 'GT_MATNR' 'PLIFZ' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'WEBAZ' 'GT_MATNR' 'WEBAZ' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'RWPRO' 'GT_MATNR' 'RWPRO' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'EISBE' 'GT_MATNR' 'EISBE' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'SHZET' 'GT_MATNR' 'SHZET' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'XCHPF' 'GT_MATNR' 'XCHPF' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'SERNP' 'GT_MATNR' 'SERNP' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'QMPUR' 'GT_MATNR' 'QMPUR' 'MARA'.
  PERFORM append_fcat TABLES t_fldcat USING	'SSQSS' 'GT_MATNR' 'SSQSS' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'QZGTP' 'GT_MATNR' 'QZGTP' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'QMATV' 'GT_MATNR' 'QMATV' 'MARC'.
  PERFORM append_fcat TABLES t_fldcat USING	'INSMK' 'GT_MATNR' 'INSMK' 'MARC'.


  IF alv_grid1 IS INITIAL.
    CREATE OBJECT alv_grid1
      EXPORTING
        i_parent = container_matlist.

  ENDIF.

*Set event handlers
  SET HANDLER: lcl_eventhandler=>handle_double_click FOR alv_grid1,
               lcl_eventhandler=>handle_size_control FOR alv_grid1.

  DATA: variant   TYPE  disvariant,
        gs_layout TYPE lvc_s_layo.

  variant-report = sy-repid.
  variant-username = sy-uname.

  CALL METHOD alv_grid1->set_table_for_first_display
    EXPORTING
      is_variant      = variant
      is_layout       = gs_layout
      i_save          = 'A'
    CHANGING
      it_outtab       = gt_matnr
      it_fieldcatalog = t_fldcat[]
    EXCEPTIONS
      OTHERS          = 4.
  IF sy-subrc = 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                                                    " DISP_ALV1


*&---------------------------------------------------------------------*
*&      Form  DISP_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_alv3 .

  IF alv_grid3 IS INITIAL.
    CREATE OBJECT alv_grid3
      EXPORTING
        i_parent = container_forecast.
  ENDIF.

  SET HANDLER: lcl_eventhandler=>handle_double_click FOR alv_grid3,
               lcl_eventhandler=>handle_size_control FOR alv_grid3,
               lcl_eventhandler=>handle_toolbar FOR alv_grid3.

  CALL METHOD alv_grid3->set_table_for_first_display
    EXPORTING
      is_layout       = gv_layout
    CHANGING
      it_outtab       = gt_matfo
      it_fieldcatalog = gt_fldcat[]
    EXCEPTIONS
      OTHERS          = 4.
  IF sy-subrc = 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                                                    " DISP_ALV2
*&---------------------------------------------------------------------*
*&      Form  FILL_HTML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_html .
  CLEAR e_data.
  FREE ts_data.
  DATA: lv_qty_c(20) TYPE c.

  DEFINE add_html.
    e_data-dataset = &1.
    APPEND e_data TO ts_data.
  END-OF-DEFINITION.

  add_html:
      '<html><body style="background-color:#f2f2f2;font-family:arial;">',
      '<style>',
      'body{background-color:#f2f2f2;font-family:arial;}',
      'table{display: inline-block; float: left;}',

      'table.right{',
      'border: 1px solid #2BA7F7;',
      'border-radius:25px;',
      'background-color: #EEEEEE;',
      'display:inline-block',
      'float: right;',
      'padding: 20px;',
      'margin : 2em;}',


      'th{font-weight:bold;}',
      'td.qty{  text-align: right;} ',
      'td.red{ background-color: red;} ',
      'td.field {  text-align: left;padding:0px 12px 0px 12px;}',
      'div{display: inline-block;padding-left:1em;padding-right:1em; border-radius:20px;margin-top:1em;}'.
  IF gt_eisbe-eisbe > wa110-total.
    add_html
    'span.yellow{ background-color:#FFFDBF; border-radius:20px;}'.
  ENDIF.
  add_html:      "CSS Table material details.
        'table.blueTable {',
        'border: 3px solid #2BA7F7;',
        'border-radius:25px;',
        'background-color: #EEEEEE;',
        'width: 80%;',
        'padding: 5px;',
        'text-align: center;}',

        'table.blueTable td, table.blueTable th {',
*        'border: 4px solid #575757;',
          'border-radius:25px;',
          'padding: 3px 0px;}',

        'table.blueTable tbody td {',
        '  font-size: 13px;}',

        'table.blueTable thead {',
        '  background: #2796DD;',
        '  background: -moz-linear-gradient(top, #5db0e5 0%, #3ca0e0 66%, #2796DD 100%);',
        '  background: -webkit-linear-gradient(top, #5db0e5 0%, #3ca0e0 66%, #2796DD 100%);',
        '  background: linear-gradient(to bottom, #5db0e5 0%, #3ca0e0 66%, #2796DD 100%);',
        '  border-bottom: 2px solid #444444;}',

        'table.blueTable thead th {',
        '  font-size: 15px;',
        '  font-weight: bold;',
        '  color: #FFFFFF;',
        '  text-align: center;',
        '  border-left: 2px solid #D0E4F5;}',

        'table.blueTable thead th:first-child {',
        '  border-left: none;}',
"Style for mouse over
       '.tooltip { ',
       '  position: relative; width:12ch; ',
*       '  display: inline-block; ',
       '  border-bottom: 1px dotted black; ',
       '} ',

       '.tooltip .tooltiptext { ',
       '  visibility: hidden; ',
       '  width: 150px; ',
       '  background-color: lightgray; ',
       '  color: #fff; ',
       '  text-align: center; ',
       '  border-radius: 6px; ',
       '  padding: 2px 10px; ',

"Position the tooltip
       '  position: absolute; ',
       '  left: -6ch; ',
       '  top: -35px; ',
*       '  z-index: 1; ',
       '} ',

       '.tooltip:hover .tooltiptext { ',
       '  visibility: visible; ',
       '} ',



        '</style>'.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = wa110-matnr
    IMPORTING
      output = lv_qty_c.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = ls_matnr-meins
*     LANGUAGE       = SY-LANGU
    IMPORTING
*     LONG_TEXT      =
      output         = ls_matnr-meins
*     SHORT_TEXT     =
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  "check inventory active
  SELECT SINGLE kzill FROM mard INTO @DATA(lv_kzill)
    WHERE matnr = @wa110-matnr
    AND werks IN @s_werks
    AND kzill NE ''.



  CONCATENATE '<h3>' TEXT-mat lv_qty_c ls_matnr-maktx(30) TEXT-unt ls_matnr-meins  '</h3>'
  INTO e_data-dataset SEPARATED BY space.
  add_html: e_data-dataset.

  add_html:
  '<table class="blueTable">',
  '<thead>',
  '<tr>'.

  PERFORM add_header USING 'MTART'.
  PERFORM add_header USING 'MATKL'.
  PERFORM add_header USING 'MAABC'.
  PERFORM add_header USING 'DISMM'.
  PERFORM add_header USING 'SCHGT'.
  PERFORM add_header USING 'XCHPF'.
  PERFORM add_header USING 'BESKZ'.
  IF lv_kzill IS NOT INITIAL.
    add_html:
      '<th class="tooltip">', TEXT-ipi ,'<span class="tooltiptext">', TEXT-ipb ,'</></th>'.
  ENDIF.
*  '<th class="tooltip">', TEXT-tb1 ,'<span class="tooltiptext">Secondary Text</>','</th>',
*  '<th>', TEXT-tb2 ,'</th>',
*  '<th>', TEXT-tb3 ,'</th>',
*  '<th>', TEXT-tb4 ,'</th>',
**  '<th>', text-tb5 ,'</th>',
*  '<th>', TEXT-tb6 ,'</th>',
*  '<th>', TEXT-tb7 ,'</th>',
*  '<th>', TEXT-tb8 ,'</th>',
**  '<th>', text-tb9 ,'</th>',
*  '<th>', TEXT-tb0 ,'</th>',

  add_html: '</tr>',
  '</thead>',
  '<tbody>',
  '<tr>',
  '<td>',ls_matnr-mtart,'</td>', "Type
  '<td>',ls_matnr-matkl,'</td>', "Group
  '<td>',ls_matnr-maabc,'</td>', "ABC
  '<td>',ls_matnr-dismm,'</td>', "MRP
*  '<td>',ls_matnr-mtart,'</td>', "Ctl
  '<td>',ls_matnr-schgt,'</td>', "Bulk
  '<td>',ls_matnr-xchpf,'</td>', "batch
  '<td>',ls_matnr-beskz,'</td>'. "proc
*  '<td>',ls_matnr-mtart,'</td>', "SP
  IF lv_kzill IS NOT INITIAL.
    add_html:'<td class ="red">',TEXT-inv,'</td>'.
  ELSE.
    add_html:'<td></td>'.
  ENDIF.


  add_html:
    '</tr>',
    '</tbody>',
    '</tr>',
    '</table>'.

*  IF gt_eisbe-schgt IS NOT INITIAL."Bulk Material
*    add_html: TEXT-bul.
*  ENDIF.

*  "Check batch managed
*  SELECT SINGLE xchpf FROM mara INTO @DATA(lv_xchar)
*    WHERE matnr = @wa110-matnr AND xchpf EQ 'X'.
*  IF sy-subrc EQ 0 OR gt_eisbe-xchar IS NOT INITIAL.
*    add_html: TEXT-bch.
*  ENDIF.



  "Safety stock value
  lv_qty_c = gt_eisbe-eisbe.

  PERFORM prepare_display_qty CHANGING lv_qty_c.
*    IF gt_eisbe-eisbe > wa110-total.
  add_html: '<p><br></br></p><div><span class="yellow">', TEXT-010, lv_qty_c,  '</span>'.
*    ENDIF.

  lv_qty_c =  wa110-doh.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<div class="tooltip" style="width:26ch;">' TEXT-113 ':' lv_qty_c INTO e_data-dataset SEPARATED BY space.
  "More than selected period message.
  IF wa110-doh EQ 99.
    lv_qty_c =  g_periods.
    PERFORM prepare_display_qty CHANGING lv_qty_c.
    CONCATENATE e_data-dataset '<span class="tooltiptext" style="width:50ch;">' TEXT-max lv_qty_c TEXT-dys '</>'
    INTO e_data-dataset SEPARATED BY space.
  ELSE.

  ENDIF.
  add_html: e_data-dataset.
  add_html: '</div></div>'.
  add_html:'<br></br><table style="display: inline-block; float: left; ">'.

  CONCATENATE '<th>' TEXT-100 '</th>' INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-storage.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-104 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-warehouse.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-101 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-kanban.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-102 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-total.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr style="background-color:#b3b3b3;padding:0px 0px 0px 24px;"><td class="field">' TEXT-105 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  add_html: '<tr><td>&nbsp</td></tr>'.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-quality.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-106 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  APPEND e_data TO ts_data.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-blocked. "Blocked stock
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-107 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  APPEND e_data TO ts_data.

  add_html: '<tr><td>&nbsp</td></tr>'.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-vendor.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-103 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-customer.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-108 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-extras.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td class="field">' TEXT-109 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  add_html:
  '</table>',
  '<tr><td>&nbsp</td></tr>',
  '<br></br><table class="right">'
  .

  CONCATENATE '<th>' TEXT-110 '</b></td></th>' INTO e_data-dataset.
  add_html: e_data-dataset .

  CLEAR lv_qty_c.
  lv_qty_c = wa110-openqty.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td>' TEXT-111 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  CLEAR lv_qty_c.
  lv_qty_c = wa110-transit.
  PERFORM prepare_display_qty CHANGING lv_qty_c.
  CONCATENATE '<tr><td>' TEXT-112 '</td><td class="qty">' lv_qty_c '</td></tr>'
  INTO e_data-dataset.
  add_html: e_data-dataset.

  add_html: '</table>'.

* e_data-dataset = '<FORM name="zzhtmlbutton" method=post action=SAPEVENT:MY_BUTTON_1?PARAM1=Hello&PARAM2=Zevolving>'.
*  APPEND e_data TO ts_data.
* e_data-dataset = '<input type=submit name="TEST_BUTTON"  class="fbutton" value="Say Hello!" title=""></form>'.
*  APPEND e_data TO ts_data.


  IF wa110-neg IS NOT INITIAL.
    add_html:
    '<font color=#ffcc00>Stock needs review. Insufficient stock for full KANBAN bins in line </font>'.
  ENDIF.
  add_html: '</body></html>'.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPEND_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_FLDCAT  text
*      -->P_0735   text
*      -->P_0736   text
*      -->P_0737   text
*      -->P_0738   text
*----------------------------------------------------------------------*
FORM append_fcat  TABLES   t_fldcat
                             "Insert a correct name for <...>
                  USING    VALUE(p_field)
                           VALUE(p_table)
                           VALUE(p_ref_field)
                           VALUE(p_ref_table).

  DATA: wa_fldcat TYPE lvc_s_fcat.

  CLEAR wa_fldcat.
  wa_fldcat-fieldname = p_field.
  wa_fldcat-tabname = p_table.
  wa_fldcat-ref_field = p_ref_field.
  wa_fldcat-ref_table = p_ref_table.
  wa_fldcat-no_out = 'X'.
  APPEND wa_fldcat TO t_fldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMAT_NEGATIVES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_negatives .
  FIELD-SYMBOLS: <fs1> TYPE any. "DOH-DAYX

  LOOP AT gt_matfo INTO ls_matfo.

    PERFORM prepare_display_qty CHANGING ls_matfo-day0.

    LOOP AT gt_fmap INTO gt_fmap WHERE fieldname CP '*DAY*'.
      ASSIGN (gt_fmap-fieldname) TO <fs1>."DOH-DAYX

      PERFORM prepare_display_qty CHANGING <fs1>.

    ENDLOOP.

    MODIFY gt_matfo FROM ls_matfo.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARE_DISPLAY_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<FS1>  text
*----------------------------------------------------------------------*
FORM prepare_display_qty  CHANGING p_qty.
  DATA: lv_last TYPE i.

  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      value = p_qty.
  IF p_qty EQ '0.000' .
    p_qty = '0'.
  ENDIF.
  IF p_qty IS NOT INITIAL AND  p_qty NE '0'.
    FIND FIRST OCCURRENCE OF '.' IN p_qty.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'FTR_CORR_SWIFT_DELETE_ENDZERO'
        CHANGING
          c_value = p_qty.
    ENDIF.

    lv_last = strlen( p_qty ) - 1 .
    IF p_qty+lv_last(1) EQ '.' .
      p_qty = p_qty(lv_last).
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1319   text
*----------------------------------------------------------------------*
FORM add_header  USING    VALUE(p_field).
  DATA: lt_dd04t TYPE TABLE OF dd04t WITH HEADER LINE.

  CLEAR lt_dd04t.
  SELECT * FROM dd04t INTO TABLE lt_dd04t WHERE rollname = p_field.
  IF sy-subrc EQ 0.
    READ TABLE lt_dd04t WITH KEY ddlanguage = sy-langu.
    IF sy-subrc NE 0.
      READ TABLE lt_dd04t INDEX 1.

    ENDIF.

  ENDIF.
  add_html:
  '<th class="tooltip">', lt_dd04t-reptext ,'<span class="tooltiptext">',lt_dd04t-scrtext_l,'</></th>'.

ENDFORM.
