*&---------------------------------------------------------------------*
*&  Include           /SPCX/MERP_PLANDASH_I_TOP
*&---------------------------------------------------------------------*

***********************************************************************
* Data definition
***********************************************************************

TYPE-POOLS: slis.                                 "ALV Declaration


TYPES: BEGIN OF t_meplanmat,
         light TYPE icon_text,
         matnr TYPE matnr,
*         matnrsort TYPE matnr,
         maktx TYPE maktx,

        "Availabile fields, not initially displayed
         mtart LIKE  mara-mtart,
         matkl LIKE  mara-matkl,
         meins LIKE  mara-meins,
         maabc LIKE  marc-maabc,
         dismm LIKE  marc-dismm,
         dispo LIKE  marc-dispo, "Version 1.1
         beskz LIKE  marc-beskz,
         sobsl LIKE  marc-sobsl,
         schgt LIKE  marc-schgt,
         plifz LIKE  marc-plifz,
         webaz LIKE  marc-webaz,
         rwpro LIKE  marc-rwpro,
         eisbe LIKE  marc-eisbe,
         shzet LIKE  marc-shzet,
         xchpf LIKE  marc-xchpf,
         sernp LIKE  marc-sernp,
         qmpur LIKE  mara-qmpur,
         ssqss LIKE  marc-ssqss,
         qzgtp LIKE  marc-qzgtp,
         qmatv LIKE  marc-qmatv,
         insmk LIKE  marc-insmk,

         doh   TYPE int4,

       END OF t_meplanmat,

       BEGIN OF t_meplanmatdet,
         matnr     TYPE matnr,
         storage   TYPE /spcx/meplan_slstock,
         warehouse TYPE /spcx/meplan_whstock,
         kanban    TYPE /spcx/meplan_kbstock,
         total     TYPE /spcx/meplan_totstock,

         blocked   TYPE /spcx/meplan_bstock,
         quality   TYPE /spcx/meplan_qstock,

         vendor    TYPE /spcx/meplan_vnstock,
         customer  TYPE /spcx/meplan_custock,
         extras    TYPE /spcx/meplan_imstock,

         openqty   TYPE /spcx/meplan_opstock,
         transit   TYPE /spcx/meplan_trstock,
         doh       TYPE /spcx/meplan_doh,
         neg       TYPE char01,
       END OF t_meplanmatdet,

       BEGIN OF t_meplanmatfor,
         matnr     TYPE matnr,
         keyfigure TYPE char40,
         day0      TYPE char13,
         day1      TYPE char13,
         day2      TYPE char13,
         day3      TYPE char13,
         day4      TYPE char13,
         day5      TYPE char13,
         day6      TYPE char13,
         day7      TYPE char13,
         day8      TYPE char13,
         day9      TYPE char13,
         day10     TYPE char13,
         day11     TYPE char13,
         day12     TYPE char13,
         day13     TYPE char13,
         day14     TYPE char13,
         day15     TYPE char13,
         day16     TYPE char13,
         day17     TYPE char13,
         day18     TYPE char13,
         day19     TYPE char13,
         day20     TYPE char13,
         day21     TYPE char13,
         day22     TYPE char13,
         day23     TYPE char13,
         day24     TYPE char13,
         day25     TYPE char13,
         day26     TYPE char13,
         day27     TYPE char13,
         day28     TYPE char13,
         day29     TYPE char13,
         day30     TYPE char13,
         day31     TYPE char13,
         day32     TYPE char13,
         day33     TYPE char13,
         day34     TYPE char13,
         day35     TYPE char13,
         day36     TYPE char13,
         day37     TYPE char13,
         day38     TYPE char13,
         day39     TYPE char13,
         day40     TYPE char13,
         day41     TYPE char13,
         day42     TYPE char13,
         day43     TYPE char13,
         day44     TYPE char13,
         day45     TYPE char13,
         day46     TYPE char13,
         day47     TYPE char13,
         day48     TYPE char13,
         day49     TYPE char13,
         day50     TYPE char13,
         colortab  TYPE lvc_t_scol,
       END OF t_meplanmatfor.



TYPES: BEGIN OF t_input,
*         lgnum   TYPE lgnum, "warehouse
         werks   TYPE werks_d,   "Plant
         dispo   LIKE marc-dispo, "MRP Controller
         beskz   LIKE marc-beskz, "Procurement type
         prgrp   LIKE pgmi-prgrp ,     "Product group
         matnr   TYPE matnr,     "Material
         lifnr   TYPE lifnr,     "Vendor/Supplier
         backlog TYPE c, "Backlog indicator
         dohflag TYPE c, "Days-on-hand flag indicator
         doh     TYPE i,   "Days-on-Hand
         date    TYPE datum, "Date range to analyze
       END OF t_input,


       "Data retrieval structures.
       BEGIN OF t_mard,
         matnr TYPE matnr,
         werks TYPE werks_d,
         lgort TYPE lgort_d,
         labst LIKE mard-labst,
         insme LIKE mard-insme,
         speme LIKE mard-speme,
         umlme LIKE mard-umlme,
         einme LIKE mard-einme,
         retme LIKE mard-retme,
         lgnum TYPE lgnum,
       END OF t_mard,

       BEGIN OF t_kanban,
         matnr TYPE matnr,
         werks TYPE werks,
         lgnum TYPE lgnum,
         umlgo LIKE pkhd-umlgo,
         meins LIKE pkhd-meins,
         pkkey LIKE pkps-pkkey,
         pkimg LIKE pkps-pkimg,
         CNSCC LIKE tpk03-CNSCC,
       END OF t_kanban,

       BEGIN OF t_fieldmap,
         date      TYPE datum,
         fieldname TYPE  char16,
       END OF t_fieldmap,

       BEGIN OF t_msku,
         matnr TYPE matnr,
         werks TYPE werks_d,
*         charg LIKE msku-charg,
         sobkz LIKE msku-sobkz,
         kunnr LIKE msku-kunnr,
         kulab LIKE msku-kulab,
         kuins LIKE msku-kuins,
       END OF t_msku,

       BEGIN OF t_resb,
         rsnum LIKE resb-rsnum,
         rspos LIKE resb-rspos,
         matnr TYPE matnr,
         bdter LIKE resb-bdter, "Requirements date
         bdmng LIKE resb-bdmng, "Requirements Qty
         meins TYPE meins,
         enmng LIKE resb-enmng, "Qty qithdrawn
       END OF t_resb,

*Build field catalog
       wa_fldcat TYPE lvc_t_fcat,

       BEGIN OF t_purch,
         ebeln LIKE ekko-ebeln,
         bstyp LIKE ekko-bstyp,
         ebelp LIKE ekpo-ebelp,
         matnr LIKE ekpo-matnr,
         werks LIKE ekpo-werks,
         webaz LIKE ekpo-webaz,
         eindt LIKE eket-eindt,
         menge LIKE eket-menge,
         wemng LIKE eket-wemng,
       END OF t_purch,

       BEGIN OF t_eisbe,
         matnr TYPE matnr,
         eisbe LIKE marc-eisbe,
         schgt LIKE marc-schgt,
         xchar LIKE marc-xchar,
         rw1tg LIKE t438r-rw1tg,
       END OF t_eisbe.

FIELD-SYMBOLS: <fs>    TYPE any.

"Data retrieval tables.
DATA: gt_eisbe  TYPE TABLE OF t_eisbe WITH HEADER LINE, "Safety Stock
      gt_resb   TYPE TABLE OF t_resb  WITH HEADER LINE, "Reservations table
      gt_purch  TYPE TABLE OF t_purch WITH HEADER LINE, "Purchase orders/SA(s) table
      gt_postab LIKE lipov OCCURS 10  WITH HEADER LINE, " table for open inbound deliveries
      gt_mard   TYPE TABLE OF t_mard  WITH HEADER LINE, "Material stock table
      gt_t320   TYPE TABLE OF t320    WITH HEADER LINE, " table t320 warehouse-plant relation
      gt_kanban TYPE TABLE OF t_kanban WITH HEADER LINE, "KANBAN bin status table
      gt_mssl   TYPE TABLE OF t_msku  WITH HEADER LINE, "Stock at vendor table
      gt_msku   TYPE TABLE OF t_msku  WITH HEADER LINE, "Stock at customer table

      "Data processing structures and tables.
      gt_matnr  TYPE TABLE OF t_meplanmat, "Material list table
      ls_matnr  TYPE t_meplanmat, "Material list structure
      wa110     TYPE t_meplanmatdet, "Material details structure

      gt_fmap   TYPE TABLE OF t_fieldmap   WITH HEADER LINE,
      gt_matfo  TYPE TABLE OF t_meplanmatfor, "Forecast table
      gt_avail  TYPE TABLE OF t_meplanmatfor, "Table to store available qty
      ls_avail  TYPE t_meplanmatfor,
      lv_matfo  TYPE t_meplanmatfor,
      ls_matfo  TYPE t_meplanmatfor. "Forecast structure


"Transaction containers
DATA:
  main_cont           TYPE REF TO  cl_gui_custom_container,
  splitter            TYPE REF TO cl_gui_splitter_container,
  splitter2           TYPE REF TO cl_gui_splitter_container,
  container_top       TYPE REF TO cl_gui_container,
  container_matlist   TYPE REF TO cl_gui_container,
  container_matdetail TYPE REF TO cl_gui_container,
  container_forecast  TYPE REF TO cl_gui_container,
  alv_grid1           TYPE REF TO cl_gui_alv_grid,
  alv_grid3           TYPE REF TO cl_gui_alv_grid,
  ref_html            TYPE REF TO cl_gui_html_viewer,

url          TYPE cndp_url, "url to store logopicture
*
*  CONSTANTS: c_spc_logo(40)   TYPE c VALUE '/SPCX/SLOGOTRA',
*             c_lifetime_trans TYPE c VALUE 'T'.
"Logo image in HTML
obj_logo   TYPE REF TO cl_gui_picture,


  gv_layout           TYPE lvc_s_layo, "ALV layout
  gt_fldcat           TYPE wa_fldcat WITH HEADER LINE, "field catalog for display of forecast

  g_selscr            TYPE t_input, "Field for selection screen values
  g_periods              TYPE i,   "Total of periods selected.

  g_okcode            LIKE sy-ucomm. "OKCODE

TYPES : BEGIN OF y_html,
          dataset(255) TYPE c,
        END OF y_html.

DATA: e_data  TYPE y_html,
      ts_data TYPE STANDARD TABLE OF y_html,
      w_url   TYPE char255.
