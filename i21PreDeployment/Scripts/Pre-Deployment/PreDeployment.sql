/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Validate Origin records
-- --coctlmst
:r .\UpdateValidation\1_CheckCoctlmst.sql

-- Delete Objects
:r .\DeleteScripts.sql

-- TM
:r .\1_TM\1_1320_to_1340.sql
:r .\1_TM\2_DropUniqueConstraints.sql
:r .\1_TM\3_1410_to_1420.sql
:r .\1_TM\4_1420_to_1430.sql

-- CM
:r .\2_CM\1_CM.sql
:r .\2_CM\2_1410_to_1420.sql
:r .\2_CM\3_1420_to_1430.sql

-- DB
:r .\3_DB\1_1340_to_1410.sql

-- SM
:r .\4_SM\1_DataCleanup.sql

-- CM
:r .\5_CM\1_DropTriggers.sql

-- GL
:r .\6_GL\1_1410_to_1420.sql
:r .\6_GL\2_1430_to_1440.sql

-- AR
:r .\7_AR\1_1410_to_1420.sql

-- AP
:r .\8_AP\DropAPViews.sql
:r .\8_AP\1_1410_to_1420.sql
:r .\8_AP\1_1420_to_1430.sql
:r .\8_AP\FixEntityId.sql
:r .\8_AP\FixstrBillId.sql
:r .\8_AP\FixPaymentWithoutVendorId.sql
:r .\8_AP\FixVendorGLAccountExpense.sql

-- FRD
:r .\9_FRD\1_1420_to_1430.sql

-- RPT
:r .\10_RPT\1_1430_to_1430.sql