*&---------------------------------------------------------------------*
*&  Include           /SPCX/MERP_PLANDASH_I_S01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_MATERIALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_materials .

  DATA: lt_materials  TYPE TABLE OF matnr WITH HEADER LINE,
        lt_materials2 TYPE TABLE OF matnr WITH HEADER LINE.
  RANGES: lr_matnr FOR mara-matnr.

  "Get all materials for plant
  SELECT matnr FROM marc INTO TABLE lt_materials
    WHERE werks IN s_werks
    AND dispo IN s_dispo
    AND matnr IN s_matnr
    AND beskz IN s_beskz.

  IF ( ( s_werks IS NOT INITIAL
    OR s_dispo IS NOT INITIAL
    OR s_matnr IS NOT INITIAL
    OR s_beskz IS NOT INITIAL )
    AND lt_materials[] IS INITIAL ).

    MESSAGE TEXT-err TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.


  lr_matnr-option = 'EQ'.
  lr_matnr-sign = 'I'.
  REFRESH lr_matnr.
  LOOP AT lt_materials.
    lr_matnr-low = lt_materials.
    APPEND lr_matnr.
  ENDLOOP.

  "Filter materials by product group
  IF s_prgrp IS NOT INITIAL.
    SELECT nrmit FROM pgmi
      INTO TABLE lt_materials
      FOR ALL ENTRIES IN lr_matnr
      WHERE prgrp IN s_prgrp
      AND werks IN s_werks
      AND nrmit EQ lr_matnr-low.

    lr_matnr-option = 'EQ'.
    lr_matnr-sign = 'I'.
    REFRESH lr_matnr.
    LOOP AT lt_materials.
      lr_matnr-low = lt_materials.
      APPEND lr_matnr.
    ENDLOOP.
    IF lr_matnr[] IS INITIAL.
      MESSAGE TEXT-err TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  "Filter materials by Vendor
  IF s_lifnr IS NOT INITIAL.
    SELECT matnr FROM eord
      INTO TABLE lt_materials
      FOR ALL ENTRIES IN lr_matnr
      WHERE matnr EQ lr_matnr-low
      AND werks IN s_werks
      AND lifnr IN s_lifnr
      AND vdatu LE sy-datum
      AND bdatu GT sy-datum.


    SELECT matnr FROM eina
      INNER JOIN eine
      ON eina~infnr = eine~infnr
      INTO TABLE lt_materials2
      FOR ALL ENTRIES IN lr_matnr
      WHERE matnr = lr_matnr-low
      AND lifnr IN s_lifnr
      AND werks IN s_werks
      AND eina~loekz NE 'X'.

    lr_matnr-option = 'EQ'.
    lr_matnr-sign = 'I'.
    REFRESH lr_matnr.
    LOOP AT lt_materials.
      lr_matnr-low = lt_materials.
      APPEND lr_matnr.
    ENDLOOP.

    LOOP AT lt_materials2.
      lr_matnr-low = lt_materials2.
      APPEND lr_matnr.
    ENDLOOP.


    IF lr_matnr[] IS INITIAL.
      MESSAGE TEXT-err TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDIF.

  REFRESH gt_matnr.

*  SELECT matnr maktx FROM makt
*    INTO CORRESPONDING FIELDS OF TABLE gt_matnr
*    FOR ALL ENTRIES IN lr_matnr
*    WHERE matnr EQ lr_matnr-low
*    AND spras EQ sy-langu.
*
  SELECT a~matnr AS matnr,
*         k~maktx AS maktx,
          a~mtart AS mtart,
          a~matkl AS matkl,
          a~meins AS meins,
          c~maabc AS maabc,
          c~dismm AS dismm,
          c~dispo AS dispo, "Version 1.1
          c~beskz AS beskz,
          c~sobsl AS sobsl,
          c~schgt AS schgt,
          c~plifz AS plifz,
          c~webaz AS webaz,
          c~rwpro AS rwpro,
          c~eisbe AS eisbe,
          c~shzet AS shzet,
          c~xchpf AS xchpf,
          c~sernp AS sernp,
          a~qmpur AS qmpur,
          c~ssqss AS ssqss,
          c~qzgtp AS qzgtp,
          c~qmatv AS qmatv,
          c~insmk AS insmk
        FROM mara AS a
        LEFT OUTER JOIN marc AS c
        ON a~matnr = c~matnr
*        LEFT OUTER JOIN makt AS k
*        ON a~matnr = k~matnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_matnr
    FOR ALL ENTRIES IN @lr_matnr
    WHERE a~matnr EQ @lr_matnr-low
*    AND k~spras EQ @sy-langu
    AND c~werks IN @s_werks
    .

  DATA: lt_makt  TYPE TABLE OF makt WITH HEADER LINE,
        lv_index LIKE sy-tabix.

  SELECT * INTO TABLE lt_makt FROM makt
    FOR ALL ENTRIES IN lr_matnr
    WHERE matnr = lr_matnr-low.

  LOOP AT gt_matnr INTO ls_matnr.
    lv_index = sy-tabix.
    READ TABLE lt_makt WITH KEY matnr = ls_matnr-matnr spras = sy-langu.
    IF sy-subrc EQ 0.
      ls_matnr-maktx = lt_makt-maktx.
    ELSE.
      READ TABLE lt_makt WITH KEY matnr = ls_matnr-matnr.
      IF sy-subrc EQ 0.
        ls_matnr-maktx = lt_makt-maktx.
      ENDIF.
    ENDIF.
    MODIFY gt_matnr FROM ls_matnr INDEX lv_index.
  ENDLOOP.
*    SELECT * INTO ls_makt FROM makt
*      FOR ALL ENTRIES IN gt_matnr
*      WHERE matnr = gt_matnr-matnr
*      AND spras = sy-langu.
*      READ TABLE gt_matnr INTO ls_matnr WITH KEY matnr = ls_makt-matnr.
*      IF sy-subrc EQ 0.
*        ls_matnr-maktx = ls_makt-maktx.
*        MODIFY gt_matnr FROM ls_matnr INDEX sy-tabix.
*      ELSE.
*            SELECT * INTO ls_makt FROM makt
*      FOR ALL ENTRIES IN gt_matnr
*      WHERE matnr = gt_matnr-matnr
*      AND spras = sy-langu.
*      READ TABLE gt_matnr INTO ls_matnr WITH KEY matnr = ls_makt-matnr.
*      IF sy-subrc EQ 0.
*        ls_matnr-maktx = ls_makt-maktx.
*        MODIFY gt_matnr FROM ls_matnr INDEX sy-tabix.
*      ELSE.
*
*      ENDIF.
*      ENDSELECT.
*      ENDIF.
*      ENDSELECT.



*        "Availabile fields, not initially displayed
*         mtart LIKE  mara-mtart,
*         matkl LIKE  mara-matkl,
*         meins LIKE  mara-meins,
*         maabc LIKE  marc-maabc,
*         dismm LIKE  marc-dismm,
*         beskz LIKE  marc-beskz,
*         sobsl LIKE  marc-sobsl,
*         schgt LIKE  marc-schgt,
*         plifz LIKE  marc-plifz,
*         webaz LIKE  marc-webaz,
*         rwpro LIKE  marc-rwpro,
*         eisbe LIKE  marc-eisbe,
*         shzet LIKE  marc-shzet,
*         xchpf LIKE  marc-xchpf,
*         sernp LIKE  marc-sernp,
*         qmpur LIKE  mara-qmpur,
*         ssqss LIKE  marc-ssqss,
*         qzgtp LIKE  marc-qzgtp,
*         qmatv LIKE  marc-qmatv,
*         insmk LIKE  marc-insmk,
*
*       END OF t_meplanmat,

  PERFORM check_entries.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CUSTOM_SORT_MATERIALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM custom_sort_materials .

*  LOOP AT gt_matnr INTO ls_matnr.
*    IF ls_matnr-matnr(1) EQ 'W'.
*      ls_matnr-matnrsort = ls_matnr-matnr+1.
*    ELSE.
*      ls_matnr-matnrsort = ls_matnr-matnr.
*    ENDIF.
*    MODIFY gt_matnr FROM ls_matnr.
*  ENDLOOP.
*  SORT gt_matnr BY matnrsort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_details .

  RANGES: lr_matnr FOR mara-matnr.


  lr_matnr-option = 'EQ'.
  lr_matnr-sign = 'I'.
  REFRESH lr_matnr.
  LOOP AT gt_matnr INTO ls_matnr.
    lr_matnr-low = ls_matnr-matnr.
    APPEND lr_matnr.
  ENDLOOP.


*Selection of material in WM and IM

  SELECT m~matnr m~werks m~lgort m~labst m~insme m~speme m~umlme m~einme m~retme
    t~lgnum
    FROM mard AS m
    LEFT OUTER JOIN t320 AS t
    ON m~werks = t~werks AND m~lgort = t~lgort
    INTO TABLE gt_mard
    FOR ALL ENTRIES IN lr_matnr
    WHERE matnr EQ lr_matnr-low
    AND m~werks IN s_werks.

  SORT gt_matnr BY matnr.


*Select KANBAN stock
  SELECT h~matnr h~werks h~lgnum h~umlgo h~meins
    p~pkkey p~pkimg k~cnscc
    FROM pkhd AS h INNER JOIN pkps AS p
    ON h~pknum = p~pknum
    INNER JOIN tpk03 AS k
    ON h~werks = k~werks AND h~pkstu = k~pkstu
    INTO TABLE gt_kanban
    FOR ALL ENTRIES IN lr_matnr
    WHERE matnr EQ lr_matnr-low
    AND h~werks IN s_werks
    AND pkbst EQ 5.

  SORT gt_kanban BY matnr werks.

  "Select stock at vendor location
  SELECT matnr werks sobkz"  SELECT matnr werks charg sobkz
    lifnr sllab slins"kunnr kulab kuins
    FROM mssl INTO TABLE gt_mssl
    FOR ALL ENTRIES IN lr_matnr
    WHERE matnr EQ lr_matnr-low
    AND werks IN s_werks.

  SORT gt_mssl BY matnr werks.

  "Select stock at customer location
  SELECT matnr werks sobkz
  kunnr kulab kuins
  FROM msku INTO TABLE gt_msku
  FOR ALL ENTRIES IN lr_matnr
  WHERE matnr EQ lr_matnr-low
  AND werks IN s_werks.

  SORT gt_msku BY matnr werks.



  PERFORM get_inbdeliveries.
  LOOP AT gt_postab WHERE matnr NOT IN lr_matnr.
    DELETE gt_postab.
  ENDLOOP.


  SELECT rsnum rspos matnr bdter bdmng meins enmng
    FROM resb AS r
    INTO TABLE gt_resb
    FOR ALL ENTRIES IN lr_matnr
    WHERE r~matnr EQ lr_matnr-low
    AND r~werks IN s_werks
    AND r~enmng < r~bdmng
    AND r~bdter <= s_date-high
    AND r~xloek EQ ' '.

  SORT gt_resb BY matnr bdter.





  "Calculate days-on-hand.
  "SUM all stock - requirements..
  TYPES: BEGIN OF t_doh_calc,
           matnr TYPE matnr,
           menge TYPE menge_d,
           doh   TYPE i,
         END OF t_doh_calc.
  DATA: lv_dohcalc TYPE TABLE OF t_doh_calc WITH HEADER LINE,
        wa_dohcalc TYPE t_doh_calc,
        lv_dohflag TYPE c,
        lv_index   LIKE sy-tabix,
        wa_color   TYPE lvc_s_scol.

  FIELD-SYMBOLS: <fs>    TYPE any.

  "Add MARD stock to calculation.
  LOOP AT gt_mard INTO gt_mard.
*    WHERE lgnum IS NOT INITIAL. "Only consider stock in WM for calc.
    CLEAR lv_dohcalc.
    lv_dohcalc-matnr = gt_mard-matnr.
*    lv_dohcalc-menge = gt_mard-labst + gt_mard-insme.
    lv_dohcalc-menge = gt_mard-labst.
    READ TABLE lv_dohcalc INTO wa_dohcalc WITH KEY matnr = lv_dohcalc-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + wa_dohcalc-menge.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ELSE.
      APPEND lv_dohcalc.
    ENDIF.
  ENDLOOP.
  "Add KANBAN bins stock to calculation for DOH
*  LOOP AT gt_kanban INTO gt_kanban.
*    READ TABLE lv_dohcalc WITH KEY matnr = gt_kanban-matnr.
*    IF sy-subrc EQ 0.
*      lv_dohcalc-menge = lv_dohcalc-menge + gt_kanban-pkimg.
*      MODIFY lv_dohcalc INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.
  "Add stock at vendor for DOH calculation
  LOOP AT gt_msku INTO gt_msku.
    READ TABLE lv_dohcalc WITH KEY matnr = gt_msku-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + gt_msku-kulab.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
  "Add stock at customer for DOH calculation
  LOOP AT gt_mssl INTO gt_msku.
    READ TABLE lv_dohcalc WITH KEY matnr = gt_msku-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + gt_msku-kulab.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  "Default 99 DOH when there is more than period selected
  LOOP AT lv_dohcalc WHERE menge NE 0.
    lv_dohcalc-doh = 99.
    MODIFY lv_dohcalc.
  ENDLOOP.
  "Use reservations qty to reduce DOH qty
  LOOP AT gt_matnr INTO ls_matnr.
    CLEAR ls_avail.
    ls_avail-matnr = ls_matnr-matnr.
    ls_avail-keyfigure = TEXT-wst."'Worst case scenario availability'
    CLEAR lv_dohflag.
    "set day 0 available stock.
    READ TABLE lv_dohcalc WITH KEY matnr = ls_matnr-matnr.
    IF sy-subrc EQ 0.
      ls_avail-day0 = lv_dohcalc-menge.
      LOOP AT gt_fmap INTO gt_fmap WHERE date >= sy-datum.
        REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
        ASSIGN (gt_fmap-fieldname) TO <fs>.
        <fs> = <fs> = lv_dohcalc-menge.
      ENDLOOP.
    ENDIF.
    LOOP AT gt_resb INTO gt_resb WHERE matnr = ls_matnr-matnr.
      READ TABLE lv_dohcalc WITH KEY matnr = gt_resb-matnr.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.
        lv_dohcalc-menge = lv_dohcalc-menge - gt_resb-bdmng + gt_resb-enmng.

        IF  gt_resb-bdter < sy-datum .
          ls_avail-day0 = lv_dohcalc-menge.
          LOOP AT gt_fmap INTO gt_fmap WHERE date >= sy-datum.
            REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
            ASSIGN (gt_fmap-fieldname) TO <fs>.
            <fs> = <fs> = lv_dohcalc-menge.
          ENDLOOP.
          IF lv_dohcalc-menge <= 0 AND lv_dohflag IS INITIAL. "Update DOH
            lv_dohcalc-doh = 0.
            lv_dohflag = 'X'.
          ENDIF.
        ELSE.
          "Search for day and change qty avail. for that day.
          LOOP AT gt_fmap INTO gt_fmap WHERE date >= gt_resb-bdter.
            REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
            ASSIGN (gt_fmap-fieldname) TO <fs>.
            <fs> = <fs> = lv_dohcalc-menge.

          ENDLOOP.



          IF lv_dohcalc-menge <= 0 AND lv_dohflag IS INITIAL. "Update DOH
            lv_dohcalc-doh = gt_resb-bdter - sy-datum.
            lv_dohflag = 'X'.
          ENDIF.
        ENDIF.
        MODIFY lv_dohcalc INDEX lv_index.

      ENDIF.
    ENDLOOP.
    APPEND ls_avail TO gt_avail.
  ENDLOOP.

  "Update DOH on main display table
  LOOP AT gt_matnr INTO ls_matnr.
    READ TABLE lv_dohcalc WITH KEY matnr = ls_matnr-matnr.
    IF sy-subrc EQ 0.
      ls_matnr-doh = lv_dohcalc-doh.
    ENDIF.
    MODIFY gt_matnr FROM ls_matnr .
  ENDLOOP.

  IF p_dohf IS NOT INITIAL.
    DELETE gt_matnr WHERE doh >= p_doh.
  ENDIF.


  CONSTANTS: c_loekzx TYPE bstyp VALUE 'X'.

  SELECT
      a~ebeln " PO number
      a~bstyp " Document category
      b~ebelp "PO item
      b~matnr "Material number
      b~werks "plant
      b~webaz " GR processing time
      c~eindt
      c~menge " scheduled qty
      c~wemng "quantity of goods received
   FROM ekko AS a
     INNER JOIN ekpo AS b ON a~ebeln = b~ebeln
     INNER JOIN eket AS c ON b~ebeln = c~ebeln
     AND b~ebelp = c~ebelp
   INTO TABLE gt_purch
    FOR ALL ENTRIES IN lr_matnr
    WHERE  a~bstyp IN ( 'F' , 'L' )
      AND   a~loekz NE c_loekzx
      AND   b~loekz EQ ' '
      AND   b~matnr EQ lr_matnr-low
      AND   b~werks IN s_werks
      AND   b~loekz NE c_loekzx
      AND c~wemng < c~menge
      AND c~slfdt <= s_date-high.


  IF p_backlg IS NOT INITIAL.
    REFRESH lr_matnr.
    lr_matnr-option = 'EQ'.
    lr_matnr-sign = 'I'.

    LOOP AT gt_purch INTO gt_purch
      WHERE eindt < sy-datum AND matnr IS NOT INITIAL.
      lr_matnr-low = gt_purch-matnr.
      APPEND lr_matnr.
    ENDLOOP.

    LOOP AT gt_matnr INTO ls_matnr WHERE matnr NOT IN lr_matnr.
      DELETE gt_matnr.
    ENDLOOP.

  ENDIF.

  "Add GR processing time to delivery date
  LOOP AT gt_purch INTO gt_purch.
    gt_purch-eindt = gt_purch-eindt + gt_purch-webaz.
    MODIFY gt_purch TRANSPORTING eindt.
  ENDLOOP.


  "Get Safety Stock value and bulk indicator.
  SELECT c~matnr c~eisbe c~schgt c~xchar r~rw1tg FROM marc AS c
    LEFT OUTER JOIN t438r AS r
    ON c~werks = r~werks AND c~rwpro = r~rwpro
    INTO TABLE gt_eisbe
    FOR ALL ENTRIES IN lr_matnr
    WHERE c~matnr = lr_matnr-low
    AND c~werks IN s_werks.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_TRAFFICLIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_trafficlight .

  LOOP AT gt_matnr INTO ls_matnr.
    PERFORM set_traffic_light.
    MODIFY gt_matnr FROM ls_matnr.
  ENDLOOP.
ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  FILL_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0798   text
*      -->P_0799   text
*      -->P_220    text
*      -->P_0801   text
*      <--P_IT_R_LGNUM  text
*----------------------------------------------------------------------*
FORM fill_range  USING    VALUE(p_sign)
                          VALUE(p_option)
                          VALUE(p_low)
                          VALUE(p_high)
                 CHANGING p_range.

  DATA: low_len TYPE i.
  low_len = strlen( p_low ).
  low_len = low_len + 3.

  p_range(1)  = p_sign.
  p_range+1(2) = p_option.
  p_range+3 = p_low.
  p_range+low_len = p_high.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_fieldcat .

  DATA: date_index  TYPE datum,
        day_index   TYPE i,
        c_fieldname TYPE char5.

  gv_layout-zebra = 'X'.
  gv_layout-ctab_fname = 'COLORTAB'.
  gv_layout-no_toolbar = 'X'.

  CLEAR gt_fldcat.
  gt_fldcat-scrtext_l = ' '.
  gt_fldcat-seltext = ' '.
  gt_fldcat-fieldname = 'KEYFIGURE'.
  gt_fldcat-tabname = 'GT_MATFO'.
  gt_fldcat-outputlen = '25'.
  gt_fldcat-fix_column = 'X'.
  gt_fldcat-key = 'X'.
  APPEND gt_fldcat.

  date_index = sy-datum.

  CLEAR gt_fldcat.
  gt_fldcat-scrtext_m = TEXT-pst.
  gt_fldcat-seltext = TEXT-pst.
  gt_fldcat-fieldname = 'DAY0'.
  gt_fldcat-no_zero = 'X'.
  gt_fldcat-decimals_o = 2.
  gt_fldcat-tabname = 'GT_MATFO'.
  gt_fldcat-outputlen = '7'.
  gt_fldcat-just = 'R'.
  APPEND gt_fldcat.

  day_index = 1.
  DO 50 TIMES.
    IF date_index <= s_date-high.

      CLEAR gt_fldcat.
      MOVE day_index TO c_fieldname.
      CONDENSE c_fieldname.
      CONCATENATE 'DAY' c_fieldname INTO c_fieldname.

      CONCATENATE date_index+4(2) date_index+6(2) "date_index+0(4)
      INTO gt_fldcat-scrtext_l SEPARATED BY '/'.

      gt_fldcat-seltext = date_index.
      gt_fldcat-fieldname = c_fieldname.
      gt_fldcat-tabname = 'GT_MATFO'.
      gt_fldcat-no_zero = 'X'.
      gt_fldcat-decimals_o = 2.
      gt_fldcat-outputlen = '5'.
      gt_fldcat-just = 'R'.
      APPEND gt_fldcat.

      CONCATENATE 'LS_MATFO-' c_fieldname INTO gt_fmap-fieldname.
      gt_fmap-date = date_index.
      APPEND gt_fmap.

      date_index = date_index + 1.
      day_index = day_index + 1.
    ENDIF.


  ENDDO.
  g_periods = day_index.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_WA110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_wa110 .
  CLEAR wa110.

  wa110-matnr = ls_matnr-matnr.

  LOOP AT gt_mard INTO gt_mard WHERE matnr = wa110-matnr.
    IF gt_mard-lgnum IS INITIAL.
      wa110-storage = wa110-storage + gt_mard-labst.
*      wa110-extras = wa110-extras + gt_mard-labst + gt_mard-insme.
    ELSE.
      wa110-warehouse = wa110-warehouse  + gt_mard-labst."Unrestricted stock
*      wa110-quality = wa110-quality + gt_mard-insme."Quality stock
    ENDIF.
    wa110-total = wa110-total + gt_mard-labst.
    wa110-blocked = wa110-blocked + gt_mard-speme.
    wa110-quality = wa110-quality + gt_mard-insme.
    wa110-extras = wa110-extras + gt_mard-umlme + gt_mard-einme + gt_mard-retme.

  ENDLOOP.

  LOOP AT gt_kanban INTO gt_kanban WHERE matnr = wa110-matnr.
    wa110-kanban = wa110-kanban + gt_kanban-pkimg.
*  Material of KANBAN is reduced from Storage locations unrstricted stock.
    "When there is material consumption on KANBAN bin.
    "Consider the stock as additional stock.
    IF gt_kanban-cnscc IS INITIAL.
      wa110-total = wa110-total - gt_kanban-pkimg.
      IF gt_kanban-lgnum IS INITIAL.
        wa110-storage = wa110-storage  - gt_kanban-pkimg.
      ELSE.
        wa110-warehouse = wa110-warehouse  - gt_kanban-pkimg.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF wa110-storage < 0.
    wa110-storage = 0.
    wa110-neg = 'X'.
  ENDIF.

  IF wa110-warehouse < 0.
    wa110-warehouse = 0.
    wa110-neg = 'X'.
  ENDIF.

  LOOP AT  gt_mssl INTO gt_msku WHERE matnr = wa110-matnr.
    wa110-vendor = wa110-vendor + gt_msku-kulab.
  ENDLOOP.

  LOOP AT  gt_msku INTO gt_msku WHERE matnr = wa110-matnr.
    wa110-customer = wa110-vendor + gt_msku-kulab.
  ENDLOOP.

  LOOP AT gt_postab INTO gt_postab WHERE matnr = wa110-matnr.
    wa110-transit = wa110-transit + gt_postab-lfimg.
  ENDLOOP.

  wa110-total = wa110-total + wa110-kanban.
  wa110-doh = ls_matnr-doh.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_REQ_FORECAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_req_forecast .
  DATA: lv_qty LIKE wa110-vendor.
  "Requirements
  REFRESH: gt_matfo.
  CLEAR ls_matfo.
  ls_matfo-keyfigure = TEXT-req."Requirements
  CLEAR lv_qty.
  lv_qty = wa110-vendor.

  LOOP AT gt_resb INTO gt_resb WHERE matnr = wa110-matnr.

    "When there is stock at vendor location 'fullfill' the first requirements
    IF lv_qty > 0.
      IF lv_qty > ( gt_resb-bdmng - gt_resb-enmng ).
        lv_qty = lv_qty - gt_resb-bdmng + gt_resb-enmng.
        gt_resb-bdmng =  gt_resb-bdmng - gt_resb-bdmng + gt_resb-enmng.
      ELSE.
        gt_resb-bdmng = gt_resb-bdmng - lv_qty.
        lv_qty = 0.
      ENDIF.
    ENDIF.

    IF gt_resb-bdter < sy-datum.
      ls_matfo-day0 = ls_matfo-day0 + gt_resb-bdmng - gt_resb-enmng.
    ELSE.
      READ TABLE gt_fmap INTO gt_fmap
      WITH KEY date = gt_resb-bdter.
      IF sy-subrc EQ 0.
        ASSIGN (gt_fmap-fieldname) TO <fs>.
        <fs> = <fs> + gt_resb-bdmng - gt_resb-enmng.
      ENDIF.
    ENDIF.

  ENDLOOP.
  APPEND ls_matfo TO gt_matfo.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_WORST_FORECAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_worst_forecast .
  "Worst case scenario.
  CLEAR lv_matfo.
  READ TABLE gt_avail INTO lv_matfo WITH KEY matnr = wa110-matnr.
  IF sy-subrc EQ 0.
    APPEND lv_matfo TO gt_matfo.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_OPTIMISTDOH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_optimistdoh .
  FIELD-SYMBOLS: <fs1> TYPE any, "DOH-DAYX
                 <fs2> TYPE any, "available qty at that day.
                 <fs3> TYPE any. "Requirements onwards

  DATA: lv_fmap  LIKE LINE OF gt_fmap[],
        ls_req   TYPE t_meplanmatfor,
        ls_best  TYPE t_meplanmatfor,
        wa_color TYPE  lvc_s_scol,
        lv_doh   TYPE i,
        lv_index LIKE sy-tabix.

  CLEAR: ls_matfo, ls_best, ls_req, gt_eisbe.

  READ TABLE gt_matfo INTO ls_best
  WITH KEY keyfigure = TEXT-bst."'Best case scenario availability'.
  IF sy-subrc EQ 0.
    lv_index = sy-tabix.
  ENDIF.

  READ TABLE gt_matfo INTO ls_req
  WITH KEY keyfigure = TEXT-req."Requirements.

  READ TABLE gt_eisbe INTO gt_eisbe WITH KEY matnr = wa110-matnr.


  LOOP AT gt_fmap INTO gt_fmap WHERE fieldname CP '*DAY*'.
    ASSIGN (gt_fmap-fieldname) TO <fs1>."DOH-DAYX

    REPLACE 'LS_MATFO' WITH 'LS_BEST' INTO gt_fmap-fieldname.
    ASSIGN (gt_fmap-fieldname) TO <fs2>."available qty at that day.

    "Requirements after that day.
    CLEAR lv_doh.
    IF <fs2> > 0."If there is stock we have enough DOH for today
      lv_doh = 1.
    ENDIF.
    LOOP AT gt_fmap INTO lv_fmap WHERE date > gt_fmap-date.
      REPLACE 'LS_MATFO' WITH 'LS_REQ' INTO lv_fmap-fieldname.
      ASSIGN (lv_fmap-fieldname) TO <fs3>.""Requirements
      <fs2> = <fs2> - <fs3>.
      IF <fs2> <=  0.
        EXIT.
      ENDIF.
      lv_doh = lv_doh + 1.
    ENDLOOP.
    "If requirements dont deplete qty, avail qty is beyond forecast
    IF <fs2> > 0.
      lv_doh = 99.
    ENDIF.
    <fs1> = lv_doh.
    " iF less than specified days on hand change cell color
    IF lv_doh <= 0.
      wa_color-fname = gt_fmap-fieldname+8.
      wa_color-color-col = 6. "red.
      APPEND wa_color TO ls_best-colortab.
    ELSEIF lv_doh < gt_eisbe-rw1tg  AND gt_eisbe-rw1tg  IS NOT INITIAL.

      wa_color-fname = gt_fmap-fieldname+8.
      wa_color-color-col = 3. "yellow
      APPEND wa_color TO ls_best-colortab.

    ELSEIF lv_doh EQ 99. "Available stock is beyond forecast dates
      wa_color-fname = gt_fmap-fieldname+8.
      wa_color-color-col = 5. "green
      APPEND wa_color TO ls_best-colortab.

    ENDIF.
  ENDLOOP.
  ls_matfo-keyfigure = TEXT-dwr."'Days on hand with receipts'.
  APPEND ls_matfo TO gt_matfo. "DOH
  MODIFY gt_matfo FROM ls_best INDEX lv_index TRANSPORTING colortab.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLORS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cell_colors USING p_keyfigure .
  DATA: lv_fmap   LIKE LINE OF gt_fmap[],
        wa_color  TYPE  lvc_s_scol,
        wa_color2 TYPE  lvc_s_scol,
        ls_best   TYPE t_meplanmatfor,
        lv_index  LIKE sy-tabix.

  FIELD-SYMBOLS: <fsb> TYPE any.

  CLEAR ls_best.
  "Set row to be formatted
  READ TABLE gt_matfo INTO ls_best
  WITH KEY keyfigure = p_keyfigure.
  IF sy-subrc EQ 0.
    lv_index = sy-tabix.
  ENDIF.

  "Loop at every day
  LOOP AT gt_fmap INTO lv_fmap WHERE fieldname CP '*DAY*'.
    REPLACE 'LS_MATFO' WITH 'LS_BEST' INTO lv_fmap-fieldname.
    ASSIGN (lv_fmap-fieldname) TO <fsb>."Assign Qty value

    READ TABLE gt_eisbe INTO gt_eisbe WITH KEY matnr = wa110-matnr.
    IF sy-subrc EQ 0
      AND gt_eisbe-eisbe >= <fsb>. "If qty is below safety stock...

      wa_color-fname = lv_fmap-fieldname+8.
      wa_color-color-col = 3. "yellow
      IF <fsb> <= 0. " If qty is 0 or negative...
        wa_color-color-col = 6. "red.
      ENDIF.

      APPEND wa_color TO ls_best-colortab.
    ENDIF.

    MODIFY gt_matfo FROM ls_best INDEX lv_index.

  ENDLOOP.
  "If below safety stock, change to color yellow

  "Turn yellow days before we run out of stock.

  READ TABLE gt_eisbe INTO gt_eisbe WITH KEY matnr = wa110-matnr.
  IF sy-subrc EQ 0 AND gt_eisbe-rw1tg IS NOT INITIAL. "If there is a coverage profile
    DATA: lv_fname(30)   TYPE c,
          lv_fnameto(30) TYPE c,
          lv_datef       TYPE datum,
          lv_datet       TYPE datum,
          lv_daynum      TYPE i.

    LOOP AT ls_best-colortab INTO wa_color "Look for days when we ran out of stock
      WHERE color-col = 6.
      lv_fname = wa_color-fname.
      REPLACE 'DAY' WITH '' INTO lv_fname.
      CONDENSE lv_fname.

      MOVE lv_fname TO lv_daynum.
      lv_daynum = lv_daynum - gt_eisbe-rw1tg.
      lv_fname = lv_daynum.
      CONDENSE lv_fname.
      CONCATENATE 'LS_MATFO-DAY' lv_fname INTO lv_fname.
      CONCATENATE 'LS_MATFO-' wa_color-fname INTO lv_fnameto.


      CLEAR lv_datef.
      READ TABLE gt_fmap INTO lv_fmap WITH KEY fieldname = lv_fname.
      IF sy-subrc EQ 0.
        lv_datef = lv_fmap-date.
      ENDIF.

      CLEAR lv_datet.
      READ TABLE gt_fmap INTO lv_fmap WITH KEY fieldname = lv_fnameto.
      IF sy-subrc EQ 0.
        lv_datet = lv_fmap-date.
      ENDIF.

      LOOP AT gt_fmap INTO lv_fmap
        WHERE date  BETWEEN lv_datef AND lv_datet ."set for X days before we run out of stock.
        READ TABLE ls_best-colortab INTO wa_color2 WITH KEY fname = gt_fmap-fieldname.
        IF sy-subrc NE 0.
          wa_color-fname = lv_fmap-fieldname+9.
          wa_color-color-col = 3. "yellow
          APPEND wa_color TO ls_best-colortab.
        ENDIF.
        MODIFY gt_matfo FROM ls_best INDEX lv_index.
      ENDLOOP.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_INBDELIVERIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_inbdeliveries .
*Get inbound deliveries
  DATA:
    it_r_lfdat TYPE RANGE OF dats WITH HEADER LINE,
    it_r_lgnum TYPE RANGE OF char3 WITH HEADER LINE,
    it_r_kostk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_wbstk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_koquk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_lvstk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_bestk TYPE RANGE OF char1 WITH HEADER LINE.

  PERFORM fill_range USING 'I' 'LE' s_date-high '' CHANGING it_r_lfdat. APPEND it_r_lfdat.
  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING  it_r_lgnum . APPEND it_r_lgnum.
  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING  it_r_kostk . APPEND it_r_kostk.
  PERFORM fill_range USING 'I' 'EQ' 'B' '' CHANGING  it_r_kostk . APPEND it_r_kostk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING  it_r_kostk . APPEND it_r_kostk.

  PERFORM fill_range USING 'I' 'BT' 'A' 'B' CHANGING it_r_wbstk . APPEND it_r_wbstk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_koquk . APPEND  it_r_koquk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING it_r_koquk . APPEND  it_r_koquk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.
  PERFORM fill_range USING 'I' 'EQ' 'B' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_bestk . APPEND  it_r_bestk.


  CALL FUNCTION 'WS_LM_DATA_SELECTION'
    EXPORTING
      if_proctype     = 'N'
      if_flag_inbound = 'X'
    TABLES
      it_lfdat        = it_r_lfdat
      it_lgnum        = it_r_lgnum
      it_werks        = s_werks
      it_matnr        = s_matnr
      it_lifnr        = s_lifnr
      it_kostk        = it_r_kostk "KOSTK range = ' ' , 'B' or 'C'.
      it_wbstk        = it_r_wbstk "WBSTK range BT 'A' and 'B'
      it_koquk        = it_r_koquk "KOUK EQ ' ' or 'C'
      it_lvstk        = it_r_lvstk "LVSTK EQ ' ', 'B' or 'C'
      it_bestk        = it_r_bestk "EQ ' '
      ct_postab       = gt_postab[]
    EXCEPTIONS
      no_data_found   = 1
      wrong_proc_type = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DELETE gt_postab WHERE matnr IS INITIAL.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check .

  DATA: chara(1)   TYPE c VALUE 'A',
        chare(1)   TYPE c VALUE 'E',
        lt_werks   TYPE TABLE OF werks_d WITH HEADER LINE,
        lv_message TYPE string.

  SELECT werks FROM t001w INTO TABLE lt_werks
    WHERE werks IN s_werks.


  LOOP AT lt_werks.
    "MD04 authorization check
    AUTHORITY-CHECK OBJECT 'M_MTDI_ORG'
             ID 'MDAKT' FIELD chare
             ID 'WERKS' FIELD lt_werks
             ID 'DISPO' DUMMY.

    IF sy-subrc <> 0.
      lv_message = TEXT-au1.
      REPLACE '&1' IN lv_message WITH lt_werks.
      MESSAGE lv_message TYPE 'E'.
      "User missing planning authorization in plant
    ENDIF.

    AUTHORITY-CHECK OBJECT 'M_MTDI_ORG'
             ID 'MDAKT' FIELD chara
             ID 'WERKS' FIELD lt_werks
             ID 'DISPO' DUMMY.

    IF sy-subrc <> 0.
      lv_message = TEXT-au3.
      REPLACE '&1' IN lv_message WITH lt_werks.
      MESSAGE lv_message TYPE 'E'.
      "User missing planning authorization in plant
    ENDIF.


    "Display materials authorization (MMBE)
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
               ID 'ACTVT' FIELD '03'
               ID 'WERKS' FIELD lt_werks.
    IF sy-subrc <> 0.
      lv_message = TEXT-au2.
      REPLACE '&1' IN lv_message WITH lt_werks.
      MESSAGE lv_message TYPE 'E'.
      "User missing material dispalay authorization in plant
    ENDIF.

  ENDLOOP.

  PERFORM sub_license_check.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_VL06
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_vl06 .
  DATA: it_bdcdata    TYPE TABLE OF bdcdata,
        wa_it_bdcdata LIKE LINE OF it_bdcdata.

  DATA opt TYPE ctu_params.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-program  = 'WS_MONITOR_INB_DEL_FREE'.
  wa_it_bdcdata-dynpro   = '1000'.
  wa_it_bdcdata-dynbegin = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'BDC_OKCODE'.
  wa_it_bdcdata-fval = '=ONLI'. " Here Give Matnr
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IF_VSTEL-LOW'. " Shipping point
**wa_it_bdcdata-fval = '0000970010090'. " Here Give SHIPPING POINT in plant?
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IT_LFDAT-LOW'.
  DATA: lv_date TYPE datum.
  lv_date = sy-datum - 30.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = lv_date
    IMPORTING
      date_external            = wa_it_bdcdata-fval
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  APPEND wa_it_bdcdata TO it_bdcdata.


  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IT_LFDAT-HIGH'.
  lv_date = sy-datum + 30.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = lv_date
    IMPORTING
      date_external            = wa_it_bdcdata-fval
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  APPEND wa_it_bdcdata TO it_bdcdata.


  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IF_LGPOS'.
  wa_it_bdcdata-fval = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IT_MATNR-LOW'.
  wa_it_bdcdata-fval = wa110-matnr.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IT_WBSTK-LOW'.
  wa_it_bdcdata-fval = 'A'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IT_WBSTK-HIGH'.
  wa_it_bdcdata-fval = 'B'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'IF_ITEM'.
  wa_it_bdcdata-fval = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.


  opt-dismode = 'E'.

  CALL TRANSACTION 'VL06IF' USING it_bdcdata OPTIONS FROM opt.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_MB51
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_mb51 .

  DATA: it_bdcdata    TYPE TABLE OF bdcdata,
        wa_it_bdcdata LIKE LINE OF it_bdcdata.

  DATA opt TYPE ctu_params.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-program  = 'RM07DOCS'.
  wa_it_bdcdata-dynpro   = '1000'.
  wa_it_bdcdata-dynbegin = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'BDC_OKCODE'.
  wa_it_bdcdata-fval = '=ONLI'. " Here Give Matnr
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'BUDAT-LOW'.
  DATA: lv_date TYPE datum.
  lv_date = sy-datum - 15.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = lv_date
    IMPORTING
      date_external            = wa_it_bdcdata-fval
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  APPEND wa_it_bdcdata TO it_bdcdata.


  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'BUDAT-HIGH'.
  lv_date = sy-datum.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = lv_date
    IMPORTING
      date_external            = wa_it_bdcdata-fval
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  APPEND wa_it_bdcdata TO it_bdcdata.


  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'WERKS-LOW'.
  wa_it_bdcdata-fval = s_werks-low.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'MATNR-LOW'.
  wa_it_bdcdata-fval = wa110-matnr.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'RFLAT_L'.
  wa_it_bdcdata-fval = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'DATABASE'.
  wa_it_bdcdata-fval = 'X '.
  APPEND wa_it_bdcdata TO it_bdcdata.

  CLEAR wa_it_bdcdata.
  wa_it_bdcdata-fnam = 'PA_DBSTD'.
  wa_it_bdcdata-fval = 'X'.
  APPEND wa_it_bdcdata TO it_bdcdata.


  opt-dismode = 'E'.

  CALL TRANSACTION 'MB51' USING it_bdcdata OPTIONS FROM opt.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_entries .
  DATA: lv_count TYPE i,
        ans      TYPE c.

  DESCRIBE TABLE gt_matnr[] LINES lv_count.

  IF lv_count > 5000.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = TEXT-pu1
        text_question         = TEXT-pu2
        text_button_1         = TEXT-pu3
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = TEXT-pu4
        icon_button_2         = 'ICON_CANCEL'
        display_cancel_button = ' '
        popup_type            = 'ICON_MESSAGE_ERROR'
      IMPORTING
        answer                = ans.
    IF ans = 2.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SINGLE_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM single_update USING in_matnr TYPE matnr.

  DATA: lv_matnr TYPE matnr.
  lv_matnr = in_matnr.

  CLEAR ls_matnr.
  SELECT SINGLE a~matnr AS matnr,
*         k~maktx AS maktx,
          a~mtart AS mtart,
          a~matkl AS matkl,
          a~meins AS meins,
          c~maabc AS maabc,
          c~dismm AS dismm,
          c~beskz AS beskz,
          c~sobsl AS sobsl,
          c~schgt AS schgt,
          c~plifz AS plifz,
          c~webaz AS webaz,
          c~rwpro AS rwpro,
          c~eisbe AS eisbe,
          c~shzet AS shzet,
          c~xchpf AS xchpf,
          c~sernp AS sernp,
          a~qmpur AS qmpur,
          c~ssqss AS ssqss,
          c~qzgtp AS qzgtp,
          c~qmatv AS qmatv,
          c~insmk AS insmk
        FROM mara AS a
        LEFT OUTER JOIN marc AS c
        ON a~matnr = c~matnr
        INTO CORRESPONDING FIELDS OF @ls_matnr
          WHERE a~matnr EQ @lv_matnr
          AND c~werks IN @s_werks.

  READ TABLE gt_matnr WITH KEY matnr = lv_matnr TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    SELECT SINGLE maktx FROM makt INTO ls_matnr-maktx
      WHERE matnr = lv_matnr AND spras = sy-langu.
    IF sy-subrc NE 0.
      SELECT SINGLE maktx FROM makt INTO ls_matnr-maktx
         WHERE matnr = lv_matnr.
    ENDIF.

    MODIFY gt_matnr INDEX sy-tabix FROM ls_matnr.
  ENDIF.


  DELETE gt_mard WHERE matnr = lv_matnr.

  SELECT m~matnr m~werks m~lgort m~labst m~insme m~speme m~umlme m~einme m~retme
    t~lgnum
    FROM mard AS m
    LEFT OUTER JOIN t320 AS t
    ON m~werks = t~werks AND m~lgort = t~lgort
    APPENDING TABLE gt_mard
    WHERE matnr = lv_matnr
    AND m~werks IN s_werks.

  SORT gt_matnr BY matnr.


  DELETE gt_kanban WHERE matnr = lv_matnr.
*Select KANBAN stock
  SELECT h~matnr h~werks h~lgnum h~umlgo h~meins
    p~pkkey p~pkimg k~cnscc
    FROM pkhd AS h INNER JOIN pkps AS p
    ON h~pknum = p~pknum
    INNER JOIN tpk03 AS k
    ON h~werks = k~werks AND h~pkstu = k~pkstu
    APPENDING TABLE gt_kanban
    WHERE matnr EQ lv_matnr
    AND h~werks IN s_werks
    AND pkbst EQ 5.

  SORT gt_kanban BY matnr werks.

*Select stock at vendor location
  DELETE gt_mssl WHERE matnr = lv_matnr.
  DELETE gt_msku WHERE matnr = lv_matnr.

  SELECT matnr werks sobkz"  SELECT matnr werks charg sobkz
    lifnr sllab slins"kunnr kulab kuins
    FROM mssl APPENDING TABLE gt_mssl
    WHERE matnr = lv_matnr
    AND werks IN s_werks.

  SORT gt_mssl BY matnr werks.

  "Select stock at customer location
  SELECT matnr werks sobkz
  kunnr kulab kuins
  FROM msku APPENDING TABLE gt_msku
  WHERE matnr EQ lv_matnr
  AND werks IN s_werks.

  SORT gt_msku BY matnr werks.

*Get inbound deliveries
  DATA:
    it_r_lfdat TYPE RANGE OF dats WITH HEADER LINE,
    it_r_lgnum TYPE RANGE OF char3 WITH HEADER LINE,
    it_r_kostk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_wbstk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_koquk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_lvstk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_bestk TYPE RANGE OF char1 WITH HEADER LINE,
    it_r_matnr TYPE RANGE OF matnr WITH HEADER LINE.

  DATA: lt_postab LIKE lipov OCCURS 10  WITH HEADER LINE. " table for open inbound deliveries

  PERFORM fill_range USING 'I' 'LE' s_date-high '' CHANGING it_r_lfdat. APPEND it_r_lfdat.
  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING  it_r_lgnum . APPEND it_r_lgnum.
  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING  it_r_kostk . APPEND it_r_kostk.
  PERFORM fill_range USING 'I' 'EQ' 'B' '' CHANGING  it_r_kostk . APPEND it_r_kostk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING  it_r_kostk . APPEND it_r_kostk.

  PERFORM fill_range USING 'I' 'BT' 'A' 'B' CHANGING it_r_wbstk . APPEND it_r_wbstk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_koquk . APPEND  it_r_koquk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING it_r_koquk . APPEND  it_r_koquk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.
  PERFORM fill_range USING 'I' 'EQ' 'B' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.
  PERFORM fill_range USING 'I' 'EQ' 'C' '' CHANGING it_r_lvstk . APPEND  it_r_lvstk.

  PERFORM fill_range USING 'I' 'EQ' ' ' '' CHANGING it_r_bestk . APPEND  it_r_bestk.
  PERFORM fill_range USING 'I' 'EQ' lv_matnr '' CHANGING it_r_matnr . APPEND  it_r_matnr.

  CALL FUNCTION 'WS_LM_DATA_SELECTION'
    EXPORTING
      if_proctype     = 'N'
      if_flag_inbound = 'X'
    TABLES
      it_lfdat        = it_r_lfdat
      it_lgnum        = it_r_lgnum
      it_werks        = s_werks
      it_matnr        = it_r_matnr
      it_lifnr        = s_lifnr
      it_kostk        = it_r_kostk "KOSTK range = ' ' , 'B' or 'C'.
      it_wbstk        = it_r_wbstk "WBSTK range BT 'A' and 'B'
      it_koquk        = it_r_koquk "KOUK EQ ' ' or 'C'
      it_lvstk        = it_r_lvstk "LVSTK EQ ' ', 'B' or 'C'
      it_bestk        = it_r_bestk "EQ ' '
      ct_postab       = lt_postab[]
    EXCEPTIONS
      no_data_found   = 1
      wrong_proc_type = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  DELETE lt_postab WHERE matnr IS INITIAL.
  DELETE gt_postab WHERE matnr = lv_matnr.
  APPEND LINES OF lt_postab TO gt_postab.

  DELETE gt_resb WHERE matnr = lv_matnr.

  SELECT rsnum rspos matnr bdter bdmng meins enmng
    FROM resb AS r
    APPENDING TABLE gt_resb
    WHERE r~matnr EQ lv_matnr
    AND r~werks IN s_werks
    AND r~enmng < r~bdmng
    AND r~bdter <= s_date-high
    AND r~xloek EQ ' '.

  SORT gt_resb BY matnr bdter.



  "Calculate days-on-hand.
  "SUM all stock - requirements..
  TYPES: BEGIN OF t_doh_calc,
           matnr TYPE matnr,
           menge TYPE menge_d,
           doh   TYPE i,
         END OF t_doh_calc.
  DATA: lv_dohcalc TYPE TABLE OF t_doh_calc WITH HEADER LINE,
        wa_dohcalc TYPE t_doh_calc,
        lv_dohflag TYPE c,
        lv_index   LIKE sy-tabix,
        wa_color   TYPE lvc_s_scol.

  RANGES: lr_matnr FOR mara-matnr.

  FIELD-SYMBOLS: <fs>    TYPE any.

  "Add MARD stock to calculation.
  LOOP AT gt_mard INTO gt_mard WHERE matnr = lv_matnr.
*    WHERE lgnum IS NOT INITIAL. "Only consider stock in WM for calc.
    CLEAR lv_dohcalc.
    lv_dohcalc-matnr = gt_mard-matnr.
*    lv_dohcalc-menge = gt_mard-labst + gt_mard-insme.
    lv_dohcalc-menge = gt_mard-labst.
    READ TABLE lv_dohcalc INTO wa_dohcalc WITH KEY matnr = lv_dohcalc-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + wa_dohcalc-menge.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ELSE.
      APPEND lv_dohcalc.
    ENDIF.
  ENDLOOP.

  "Add stock at vendor for DOH calculation
  LOOP AT gt_msku INTO gt_msku WHERE matnr = lv_matnr.
    READ TABLE lv_dohcalc WITH KEY matnr = gt_msku-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + gt_msku-kulab.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
  "Add stock at customer for DOH calculation
  LOOP AT gt_mssl INTO gt_msku WHERE matnr = lv_matnr.
    READ TABLE lv_dohcalc WITH KEY matnr = gt_msku-matnr.
    IF sy-subrc EQ 0.
      lv_dohcalc-menge = lv_dohcalc-menge + gt_msku-kulab.
      MODIFY lv_dohcalc INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  "Default 99 DOH when there is more than period selected
  LOOP AT lv_dohcalc WHERE menge NE 0.
    lv_dohcalc-doh = 99.
    MODIFY lv_dohcalc.
  ENDLOOP.
  "Use reservations qty to reduce DOH qty
  LOOP AT gt_matnr INTO ls_matnr WHERE matnr = lv_matnr.
    CLEAR ls_avail.
    ls_avail-matnr = ls_matnr-matnr.
    ls_avail-keyfigure = TEXT-wst."'Worst case scenario availability'
    CLEAR lv_dohflag.
    "set day 0 available stock.
    READ TABLE lv_dohcalc WITH KEY matnr = ls_matnr-matnr.
    IF sy-subrc EQ 0.
      ls_avail-day0 = lv_dohcalc-menge.
      LOOP AT gt_fmap INTO gt_fmap WHERE date >= sy-datum.
        REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
        ASSIGN (gt_fmap-fieldname) TO <fs>.
        <fs> = <fs> = lv_dohcalc-menge.
      ENDLOOP.
    ENDIF.
    LOOP AT gt_resb INTO gt_resb WHERE matnr = ls_matnr-matnr.
      READ TABLE lv_dohcalc WITH KEY matnr = gt_resb-matnr.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.
        lv_dohcalc-menge = lv_dohcalc-menge - gt_resb-bdmng + gt_resb-enmng.

        IF  gt_resb-bdter < sy-datum .
          ls_avail-day0 = lv_dohcalc-menge.
          LOOP AT gt_fmap INTO gt_fmap WHERE date >= sy-datum.
            REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
            ASSIGN (gt_fmap-fieldname) TO <fs>.
            <fs> = <fs> = lv_dohcalc-menge.
          ENDLOOP.
          IF lv_dohcalc-menge <= 0 AND lv_dohflag IS INITIAL. "Update DOH
            lv_dohcalc-doh = 0.
            lv_dohflag = 'X'.
          ENDIF.
        ELSE.
          "Search for day and change qty avail. for that day.
          LOOP AT gt_fmap INTO gt_fmap WHERE date >= gt_resb-bdter.
            REPLACE 'LS_MATFO' WITH 'LS_AVAIL' INTO gt_fmap-fieldname.
            ASSIGN (gt_fmap-fieldname) TO <fs>.
            <fs> = <fs> = lv_dohcalc-menge.

          ENDLOOP.



          IF lv_dohcalc-menge <= 0 AND lv_dohflag IS INITIAL. "Update DOH
            lv_dohcalc-doh = gt_resb-bdter - sy-datum.
            lv_dohflag = 'X'.
          ENDIF.
        ENDIF.
        MODIFY lv_dohcalc INDEX lv_index.

      ENDIF.
    ENDLOOP.
    READ TABLE gt_avail WITH KEY matnr = lv_matnr TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      MODIFY gt_avail INDEX sy-tabix FROM ls_avail.
    ENDIF.

  ENDLOOP.

  "Update DOH on main display table
  LOOP AT gt_matnr INTO ls_matnr WHERE matnr = lv_matnr.
    READ TABLE lv_dohcalc WITH KEY matnr = ls_matnr-matnr.
    IF sy-subrc EQ 0.
      ls_matnr-doh = lv_dohcalc-doh.
    ENDIF.
    MODIFY gt_matnr FROM ls_matnr .
  ENDLOOP.

  IF p_dohf IS NOT INITIAL.
    DELETE gt_matnr WHERE doh >= p_doh.
  ENDIF.


  CONSTANTS: c_loekzx TYPE bstyp VALUE 'X'.

  SELECT
      a~ebeln " PO number
      a~bstyp " Document category
      b~ebelp "PO item
      b~matnr "Material number
      b~werks "plant
      b~webaz " GR processing time
      c~eindt
      c~menge " scheduled qty
      c~wemng "quantity of goods received
   FROM ekko AS a
     INNER JOIN ekpo AS b ON a~ebeln = b~ebeln
     INNER JOIN eket AS c ON b~ebeln = c~ebeln
     AND b~ebelp = c~ebelp
   APPENDING TABLE gt_purch
    WHERE  a~bstyp IN ( 'F' , 'L' )
      AND   a~loekz NE c_loekzx
      AND   b~loekz EQ ' '
      AND   b~matnr = lv_matnr
      AND   b~werks IN s_werks
      AND   b~loekz NE c_loekzx
      AND c~wemng < c~menge
      AND c~slfdt <= s_date-high.


  IF p_backlg IS NOT INITIAL.
    REFRESH lr_matnr.
    lr_matnr-option = 'EQ'.
    lr_matnr-sign = 'I'.

    LOOP AT gt_purch INTO gt_purch
      WHERE eindt < sy-datum AND matnr = lv_matnr.
      lr_matnr-low = gt_purch-matnr.
      APPEND lr_matnr.
    ENDLOOP.

    LOOP AT gt_matnr INTO ls_matnr WHERE matnr NOT IN lr_matnr.
      DELETE gt_matnr.
    ENDLOOP.

  ENDIF.

  "Add GR processing time to delivery date
  LOOP AT gt_purch INTO gt_purch WHERE matnr = lv_matnr.
    gt_purch-eindt = gt_purch-eindt + gt_purch-webaz.
    MODIFY gt_purch TRANSPORTING eindt.
  ENDLOOP.


  "Get Safety Stock value and bulk indicator.
  SELECT c~matnr c~eisbe c~schgt c~xchar r~rw1tg FROM marc AS c
    LEFT OUTER JOIN t438r AS r
    ON c~werks = r~werks AND c~rwpro = r~rwpro
    APPENDING TABLE gt_eisbe
    WHERE c~matnr = lv_matnr
    AND c~werks IN s_werks.

  READ TABLE gt_matnr INTO ls_matnr WITH KEY matnr = lv_matnr.
  IF sy-subrc EQ 0.
    lv_index = sy-tabix.
    PERFORM set_traffic_light .
    MODIFY gt_matnr INDEX sy-tabix FROM ls_matnr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_TRAFFIC_LIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_traffic_light .

  IF ls_matnr-doh <= g_li_red .
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_RED_LIGHT'
      IMPORTING
        result = ls_matnr-light.
  ELSEIF ls_matnr-doh <= g_li_ylw.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_YELLOW_LIGHT'
      IMPORTING
        result = ls_matnr-light.
  ELSE.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_GREEN_LIGHT'
      IMPORTING
        result = ls_matnr-light.

  ENDIF.

ENDFORM.
