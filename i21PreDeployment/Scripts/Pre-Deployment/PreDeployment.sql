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
--EM
:r .\12_EM\17_DropDependencies_RenameTable.sql

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
:r .\1_TM\7_DropView.sql
:r .\1_TM\8_DropFunctions.sql

-- CM
:r .\2_CM\1_CM.sql

-- DB
:r .\3_DB\1_1340_to_1410.sql
:r .\3_DB\2_1530_to_1540.sql

-- SM
:r .\4_SM\0_1510_MasterMenu.sql
:r .\4_SM\1_DataCleanup.sql
:r .\4_SM\2_DropProcedureUspCMPostMessages.sql
:r .\4_SM\3_DataMigration.sql
:r .\4_SM\4_DataUpdateSecurityUserRequireApprovalFor.sql
:r .\4_SM\5_EncryptUsersPassword.sql
:r .\4_SM\6_TicketManagement.sql
:r .\4_SM\7_CRM.sql
:r .\4_SM\8_TransactionManagement.sql
:r .\4_SM\9_DropTblSMAlternateApproverGroup.sql
:r .\4_SM\10_DropTblSMApproverConfigurationForTransaction.sql

-- GL
:r .\6_GL\1_1410_to_1420.sql
:r .\6_GL\2_1430_to_1440.sql
--:r .\6_GL\3_1440_to_1510.sql
:r .\6_GL\4_1440_to_1530.sql


-- AR
:r .\7_AR\5_InvoiceCurrencyCleanUp.sql
:r .\7_AR\6_PaymentDetailInvoiceCleanUp.sql
:r .\7_AR\7_CompanyPreferenceCleanUp.sql

-- AP
:r .\8_AP\DropAPViews.sql
:r .\8_AP\DropTriggers.sql
:r .\8_AP\1_1410_to_1420.sql
:r .\8_AP\1_1420_to_1430.sql
:r .\8_AP\DropCK_PO_OrderStatus.sql
:r .\8_AP\UpdateShipTo.sql
:r .\8_AP\UpdateShipFrom.sql
:r .\8_AP\FixPaymentEntityId.sql
:r .\8_AP\UpdatePaymentMethod.sql
:r .\8_AP\Update1099BillDetailData.sql
:r .\8_AP\UpdateVoucherCurrency.SQL
:r .\8_AP\tblAPapivcmst.sql
--:r .\8_AP\UpdateBillToReceiptAssociation.sql

--:r .\8_AP\UpdateMissingPaymentInfo.sql
--:r .\8_AP\UpdateBillStatus.sql
--:r .\8_AP\AddPOVendorConstraint.sql
--:r .\8_AP\FixEntityId.sql
--:r .\8_AP\FixstrBillId.sql
--:r .\8_AP\FixPaymentWithoutVendorId.sql

-- FRD
:r .\9_FRD\1_1420_to_1430.sql
:r .\9_FRD\2_1440_to_1510.sql
:r .\9_FRD\3_1540_to_1610.sql

-- RPT
:r .\10_RPT\1_1430_to_1430.sql

-- IC
:r .\11_IC\Remove_Accounts_With_Deleted_Category.sql

-- EM
:r .\12_EM\01_EntitySchemaUpdate.sql
:r .\12_EM\02_UpdateGroupIdFromNonExistence.sql
:r .\12_EM\03_EntityCustomerFarmRename_DataFix.sql
:r .\12_EM\04_EntityLocationTaxCodeUpdate.sql
:r .\12_EM\05_EntitySplitSchemaUpdate.sql
:r .\12_EM\07_EntityFarmSchemaUpdate.sql
:r .\12_EM\08_EntityShipViaSchemaUpdate.sql
:r .\8_AP\UpdateShipVia.sql
:r .\12_EM\09_UpdateEntityLocationShipVia.sql
:r .\12_EM\10_CheckAndFixSpecialPricingRackLocation.sql
:r .\12_EM\11_AvoidCustomerTransportSupplierIdConflict.sql
:r .\12_EM\13_EntityUserSecuritySchemaUpdate.sql
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM01.sql -- this should always be under entity security schema change 
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM02.sql -- this should always be under entity security schema change 
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM03.sql -- this should always be under entity security schema change 
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM04.sql -- this should always be under entity security schema change 
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM05.sql -- this should always be under entity security schema change 
:r .\12_EM\14_EntityUserSecuritySchemaUpdateForTM06.sql -- this should always be under entity security schema change 
:r .\16_HD\HDGroupUserConfigDataEntryFix.sql -- this will update the security id at tblHDGroupUserConfig table (one time update)
:r .\12_EM\12_EntityEmployeeSchemaUpdate.sql
:r .\12_EM\12_UpdateCustomerFreightNullLocation.sql
:r .\12_EM\15_DropSMUserSecurityTrigger.sql
:r .\12_EM\18_FixDuplicateLocationEntry.sql
:r .\12_EM\19_CleanEntityPhoneNumber.sql

:r .\12_EM\16_CleanCustomerProductVersion.sql
:r .\12_EM\20_CleanCustomerSpecialPrice.sql
:r .\12_EM\21_CleanAPBillMissingContact.sql
--RK
:r .\13_RK\01_DropTableScript.sql

--CT

--GR
:r .\15_GR\1_ConstraintDropQuery.sql

--HD
:r .\16_HD\Drop_Constraint.sql
:r .\16_HD\OpportunitySourceDataFix.sql

--TR
:r .\17_TR\01_Drop_Column.sql

--IU
:r .\18_IU\1_DataCleanUp.sql

--MF

--CF
:r .\20_CF\FixeDataWithContraints.sql

--PR
:r .\21_PR\1_1620_to_1630.sql
:r .\21_PR\2_1630_to_1640.sql
--:r .\21_PR\2_1710_to_1720.sql

--PAT
:r .\22_PAT\1_StaticTable.sql
:r .\22_PAT\2_AddTransferType.sql
:r .\22_PAT\3_MigrateDataChanges.sql

--EM

:r .\12_EM\16_Drop_tblEntity_related_constraints.sql -- THIS IS ON THE OUTSKIRT OF SCRIPT DUE TO ITS SENSITIVITY

--MFT
:r .\23_MFT\1_CleanUp_Data.sql
:r .\23_MFT\0_Remove_Unused_Tables_FK.sql