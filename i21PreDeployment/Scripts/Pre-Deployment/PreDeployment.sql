﻿/*
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
:r .\1_TM\5_1430_to_1440.sql
:r .\1_TM\6_1510_to_1520.sql

-- CM
:r .\2_CM\1_CM.sql
:r .\2_CM\2_1410_to_1420.sql
:r .\2_CM\3_1420_to_1430.sql

-- DB
:r .\3_DB\1_1340_to_1410.sql

-- SM
:r .\4_SM\0_1510_MasterMenu.sql
:r .\4_SM\1_DataCleanup.sql
:r .\4_SM\2_DropProcedureUspCMPostMessages.sql
:r .\4_SM\3_DataMigration.sql

-- CM
:r .\5_CM\1_DropTriggers.sql

-- GL
:r .\6_GL\1_1410_to_1420.sql
:r .\6_GL\2_1430_to_1440.sql
:r .\6_GL\3_1440_to_1510.sql


-- AR
:r .\7_AR\1_1410_to_1420.sql
:r .\7_AR\FixARTransactionsAccounts.sql

-- AP
:r .\8_AP\DropAPViews.sql
:r .\8_AP\DropTriggers.sql
:r .\8_AP\1_1410_to_1420.sql
:r .\8_AP\1_1420_to_1430.sql
:r .\8_AP\DropCK_PO_OrderStatus.sql
--:r .\8_AP\AddPOVendorConstraint.sql
--:r .\8_AP\FixEntityId.sql
--:r .\8_AP\FixstrBillId.sql
--:r .\8_AP\FixPaymentWithoutVendorId.sql

-- FRD
:r .\9_FRD\1_1420_to_1430.sql
:r .\9_FRD\2_1440_to_1510.sql

-- RPT
:r .\10_RPT\1_1430_to_1430.sql

-- IC
:r .\11_IC\Fix_References_to_Foreign_Keys.sql
:r .\11_IC\Account_Category_Change_14_4.sql
:r .\11_IC\1510_to_1512.sql
:r .\11_IC\StatusImplementation.sql
:r .\11_IC\SourceType_Implementations.sql
:r .\11_IC\1520_to_1530.sql

--:r :.\11_IC\Drop_References_to_ItemCostingTableType.sql
--:r :.\11_IC\Drop_References_to_RecapTableType.sql
-- EM
:r .\12_EM\01_EntitySchemaUpdate.sql
:r .\12_EM\02_UpdateGroupIdFromNonExistence.sql
:r .\12_EM\03_EntityCustomerFarmRename_DataFix.sql
:r .\12_EM\04_EntityLocationTaxCodeUpdate.sql
:r .\12_EM\05_EntitySplitSchemaUpdate.sql
:r .\12_EM\07_EntityFarmSchemaUpdate.sql
:r .\12_EM\08_EntityShipViaSchemaUpdate.sql

:r .\12_EM\03_EntityCustomerFarmRename_DataFix.sql


--RK
:r .\13_RK\01_DropTableScript.sql

--CT
:r .\14_CT\01_Make_Column_Null.sql

--GR
:r .\15_GR\1_ConstraintDropQuery.sql
