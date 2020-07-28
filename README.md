# MPD
Material Planning Dashboard
1	OVERVIEW
The contents in this document will guide a user in charge of the SAP system management to enable SPC’s Material Planning Dashboard Software. The Material Planning Dashboard is a tool created by Software Projects Consulting to provide a better overview of the material planning with an enhanced interface.
2	LEGAL NOTICE 
Certain functionalities described herein or in other product documentation are available only if the software is appropriately configured. Depending on the product series, software is configured either in consultation with your SPC representative or with the help of documentation obtained from your SPC representative. Details are set forth in your agreement with Software Projects Consulting (SPC).  “SPC” always refers to the company with which you as a customer have entered into the agreement in question. This is Software Projects Consulting Inc or any majority-held subsidiary of the same. An overview of these subsidiaries can be found on our website www.SPCNOW.com. In case of an exception, the respective company will be mentioned explicitly. 
The program may only be used in accordance with the conditions set forth in the license agreement.
 Trademarks
Trademarks in this product information are not explicitly marked as such, as is the norm in technical documentation: 
	Adobe, Acrobat, and Reader are brands or registered trademarks of Adobe Systems Inc. 
	HTML and XML are brands or registered trademarks of W3C®, World Wide Web Consortium, Massachusetts Institute of Technology. 
	Java is a registered trademark of Oracle Corporation. 
	Microsoft Windows, MS Word, MS Excel, and MS SQL are registered trademarks of Microsoft Corporation. 
	Oracle is a registered trademark of Oracle Corporation.
	SAP is a brand or registered trademark of SAP SE. 
	Sybase SQL Anywhere is a trademark or registered trademark of Sybase Inc. Sybase is an SAP AG company. 
All other product names are assumed to be registered trademarks of the respective company. All trademarks are recognized.  The information contained herein is non-binding and for information purposes only. 
Copyrights 
All rights, especially copyrights, are reserved. No part of this product information or the corresponding program may be reproduced or copied in any form (print, photocopy, or other process) without the written consent of SPC. This product information is provided solely to customers of SPC for their internal use in conjunction with software licensed from SPC. This information may not be shared in any form with third parties, except the employees of the customer, without the written consent of SPC, and then also exclusively for use in conjunction with software licensed from SPC Use of SPC product code Maintenance and development may at any time cause changes to the standard system’s internal programming. For this reason, the customer is prohibited from programming in such a way that directly addresses internal programming functionalities (such as in the SAP object code). This restriction does not extend to documented code designed to facilitate customer use, such as an interface for accessing product functionalities.
 © 2015 – 2020 
Date: May 5, 2020 28, 2019

3	VERSION HISTORY

Version	Date	Change description	Page Reference
1.0	5/18/2020	Original Version	
			

4	PREREQUISITES
This version is designed to work with SAP ECC 6 service pack 5 and above. 
For getting versions compatible with SAP R/3, or SAP S4 HANA please contact SPC.

5	IMPLEMENTATION
To implement an SPC product please contact your SPC representative to help following the next steps.
If you would like assistance from an SPC member to perform the installation in your place, please provide appropriate access in all SAP systems that require the installation of the Material Planning Dashboard.
This access includes the ability to use transactions CG3Z and STMS.
The following instructions are the steps to follow in case your company decides to implement the material planning dashboard by themselves.
1.	Request transport from SPC via email.
2.	An SPC member will provide you with 2 transport files to be imported in your system.
The files provided by SPC will have a format R9XXXXX.SPD and K9XXXXX.SPD where XXXXX represents a number.

3.	Open transaction CG3Z

Upload the ‘R’ file provided by SPC by entering the transport directory.
In the ‘Source file on front end’ field, search for the location in your system where you stored the SPD  with prefix ‘R’.

In the ‘Target file on application server’ Select the directory \sapmnt\trans\data.
Name the file the same way as the provided file and remember to prefix the location with the name of your system.

 

Repeat the step for the ‘K’ file

 
Once the files have been imported successfully to the SAP system you need to 

4.	Import the transports to your system queue.

Go to transaction STMS.
Select transport management system release
 
Select the desired queue where to import the changes.
 
Go to the Extras menu > Other Requests > Add
 
Include the transport number provided by SPC member in the transport request. The transport should have a prefix: ‘SPDK’

 
After adding the transport it will be available to select in the queue.
 
Select the transport in question from the queue
 
Choose to release transport individually.
 
In the options menu Select: Ignore Invalid Component Version. Then click the checkbox button to continue.
 


Repeat step 4 for all systems in your environment.
6	POST-IMPLEMENTATION CONFIGURATION
To access the Material Planning Dashboard report from SPC Menu, maintain the product in the product table by directly entering a new value in the product maintenance transaction: 
Go to transaction /SPCX/SPCPROD
Click on ‘New Entries’.
 
Enter the values:
Function: Material Planning
Transaction code: /SPCX/MPD
Text: Material Planning Dashboard
 
Click the ‘SAVE’ button.
 


7	AUTHORIZATIONS
The following authorization objects in SAP are required to run the Material Planning Dashboard. Contact Your SAP Administrator to validate that the users for this transaction have the following authorizations.
7.1.1	PLANNING AUTHORIZATIONS(AS SEEN IN MD04)
Authorization Object:
M_MTDI_ORG
ID MDAKT = ‘E’ & ‘A’
ID WERKS = plants selected

7.1.2	AUTHORIZATION TO DISPLAY MATERIAL INFORMATION
Authorization Object:
'M_MATE_WRK'
ID ACTVT = ‘03’
ID WERKS = plants selected

7.1.3	AUTHORIZATION TO SPC CUSTOM TRANSACTIONS
In addition to the SAP standard authorization objects mentioned above the users will need authorizations to the following transactions.
SPC PRODUCT AUTHORIZATIONS
Description	Transaction
Custom table maintenance (Recommended for Key user) 	 /SPCX/PRODUCT_TB
License maintenance (Recommended for Key user).     
Activate License
Maintain License
Request License
Maintain Products	
/SPCX/SPCLICACT	
/SPCX/SPCLICMNT	
/SPCX/SPCLICREQ	
/SPCX/SPCPROD	
Transaction for SPC Products 				  	 /SPCX/GO  or
/SPCX/MENU
Material Planning Dashboard	/SPCX/MPD

8	UPGRADE
Current version of Material Planning Dashboard is designed to work with SAP ECC6 with enhancement pack 6 and above. If you want to migrate to S4 HANA please let SPC team know, you will be provided with a version compatible with S4/HANA. 

9	UNINSTALL
To uninstall your current version of the material planning dashboard contact SPC at info@spcnow.com
