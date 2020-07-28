*&---------------------------------------------------------------------*
*& Report /SPCX/MERP_PLANDASH
*&---------------------------------------------------------------------*
*& SPC/JMARTINEZ 01/02/2019
*& Report to show all currently open purchasing requisitions
*& and their corresponding status.
*&---------------------------------------------------------------------*
REPORT /SPCX/MERP_PLANDASH.

INCLUDE /SPCX/MERP_PLANDASH_I_TOP."Data declarations

INCLUDE /SPCX/MERP_PLANDASH_I_SCR. "Selection screen events.

INCLUDE /SPCX/MERP_PLANDASH_I_S01. "Subroutines

INCLUDE /SPCX/MERP_PLANDASH_I_S02. "Screen Processing Modules

INCLUDE /SPCX/GENERAL. "Include logo and SPC functionality

***********************************************************************
* Main program
***********************************************************************
START-OF-SELECTION.
  PERFORM auth_check.

  PERFORM prepare_fieldcat.
  PERFORM get_materials.
*  PERFORM custom_sort_materials.
  PERFORM get_details.
  PERFORM set_trafficlight.

  PERFORM create_objects.
  PERFORM disp_alv1.
  PERFORM disp_alv3.

  CALL SCREEN 100.
