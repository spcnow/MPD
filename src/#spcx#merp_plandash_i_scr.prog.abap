*&---------------------------------------------------------------------*
*&  Include           /SPCX/MERP_PLANDASH_I_SCR
*&---------------------------------------------------------------------*

***********************************************************************
* Selection screen
***********************************************************************
SELECTION-SCREEN    BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-bl1.

SELECT-OPTIONS:
s_werks FOR g_selscr-werks OBLIGATORY MEMORY ID wrk,
s_dispo FOR g_selscr-dispo,
s_prgrp FOR g_selscr-prgrp,
s_matnr FOR g_selscr-matnr,
s_lifnr FOR g_selscr-lifnr,
s_beskz FOR g_selscr-beskz.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-bl2.
PARAMETERS p_backlg AS CHECKBOX.
PARAMETERS: p_dohf AS CHECKBOX DEFAULT 'X',
            p_doh  TYPE int1 VISIBLE LENGTH 3 DEFAULT 7.
SELECTION-SCREEN COMMENT 38(22) TEXT-001.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-bl3.
SELECT-OPTIONS s_date FOR g_selscr-date NO-EXTENSION OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl3.
SELECTION-SCREEN PUSHBUTTON 1(45) but1 USER-COMMAND lights VISIBLE LENGTH 15.
PARAMETERS g_li_grn TYPE int1 DEFAULT 30 NO-DISPLAY.
PARAMETERS g_li_ylw TYPE int1 DEFAULT 7 NO-DISPLAY.
PARAMETERS g_li_red TYPE int1 DEFAULT 0 NO-DISPLAY.




***********************************************************************
* INITIALIZATION
***********************************************************************
INITIALIZATION.


  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = 'ICON_AVAILABILITY_CHECK'
      text   = TEXT-stl
      info   = TEXT-stl
    IMPORTING
      result = but1
    EXCEPTIONS
      OTHERS = 0.


  PERFORM show_logo.
***********************************************************************
* AT SELECTION SCREEN
***********************************************************************
AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'LIGHTS'.

      DATA: lt_popup TYPE TABLE OF sval WITH HEADER LINE.

      lt_popup-tabname = 'MDAMP'.
      lt_popup-fieldname = 'BERR1'.
      lt_popup-fieldtext = TEXT-red.
      lt_popup-value = g_li_red.
      APPEND lt_popup.


      lt_popup-tabname = 'MDAMP'.
      lt_popup-fieldname = 'BERY1'.
      lt_popup-fieldtext = TEXT-ylw.
      lt_popup-value = g_li_ylw.
      APPEND lt_popup.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          start_column    = '60'
          start_row       = '5'
          popup_title     = TEXT-pop
        TABLES
          fields          = lt_popup
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      READ TABLE lt_popup INTO lt_popup WITH KEY fieldname = 'BERR1'.
      g_li_red = lt_popup-value.
      READ TABLE lt_popup INTO lt_popup WITH KEY fieldname = 'BERY1'.
      g_li_ylw = lt_popup-value.
  ENDCASE.

  AT SELECTION-SCREEN OUTPUT.

    LOOP AT SCREEN.
    IF screen-name EQ 'S_DATE-LOW'.
      screen-input = ' '.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'S_DATE-HIGH'.
      screen-required = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  s_date-sign = 'I'.
  s_date-option = 'BT'.
  s_date-low = sy-datum.
  s_date-high = sy-datum + 30.
  APPEND s_date.
