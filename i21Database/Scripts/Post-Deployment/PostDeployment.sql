/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

print 'BEGIN POST DEPLOYMENT'


-- System Manager Default Data
:r .\SM\DefaultData\1_MasterMenu.sql
:r .\SM\DefaultData\2_UserRole.sql
:r .\SM\DefaultData\3_Currency.sql 
:r .\SM\DefaultData\4_StartingNumbers.sql
:r .\SM\DefaultData\5_CompanySetup.sql
:r .\SM\DefaultData\6_Preferences.sql
:r .\SM\DefaultData\7_EULA.sql
:r .\SM\DefaultData\8_Country.sql
:r .\SM\DefaultData\9_ZipCode.sql
:r .\SM\DefaultData\10_Screen.sql
:r .\SM\DefaultData\11_FreightTerms.sql
:r .\SM\DefaultData\12_ReminderList.sql
:r .\SM\DefaultData\13_ShortcutKey.sql
:r .\SM\CustomField.sql
:r .\SM\SMDataMigrations.sql

-- Canned Report
:r .\Reports\1_ReportDisableConstraints.sql
:r .\Reports\2_ReportDeleteOldData.sql
:r .\Reports\3_ReportEnableConstraints.sql
:r .\Reports\4_ReportData.sql
:r .\Reports\Pxcyctag.sql

-- Tank Management
-- :r .\TM\1_OriginIndexing.sql
:r .\TM\DefaultData\1_PreferenceCompany.sql
:r .\TM\DefaultData\2_EventType.sql
:r .\TM\DefaultData\3_DeviceType.sql
:r .\TM\DefaultData\4_MeterType.sql
:r .\TM\DefaultData\5_FillMethodType.sql
:r .\TM\DefaultData\6_InventoryStatusType.sql
:r .\TM\DefaultData\7_WorkStatusType.sql
:r .\TM\DefaultData\8_WorkToDoItem.sql
:r .\TM\DefaultData\9_WorkCloseReason.sql
:r .\TM\DefaultData\10_RegulatorType.sql
----TM Reports
:r .\TM\Reports\FieldSelection\DeliveryFill.sql
:r .\TM\Reports\Layout\DeliveryFill.sql
:r .\TM\Reports\DataSource\DeliveryFill.sql
:r .\TM\Reports\DefaultCriteria\DeliveryFill.sql
:r .\TM\Reports\SubReportSettings\DeliveryFill.sql

:r .\TM\Reports\FieldSelection\DeviceLeaseDetail.sql
:r .\TM\Reports\Layout\DeviceLeaseDetail.sql
:r .\TM\Reports\DataSource\DeviceLeaseDetail.sql
:r .\TM\Reports\DefaultCriteria\DeviceLeaseDetail.sql

:r .\TM\Reports\Layout\DeviceActions.sql
:r .\TM\Reports\DataSource\DeviceActions.sql

:r .\TM\Reports\Layout\ProductTotals.sql
:r .\TM\Reports\DataSource\ProductTotals.sql

:r .\TM\Reports\DataSource\CustomerListByRoute.sql
:r .\TM\Reports\Layout\CustomerListByRoute.sql
:r .\TM\Reports\DefaultCriteria\CustomerListByRoute.sql

:r .\TM\Reports\DataSource\GasCheckLeakcheck.sql
:r .\TM\Reports\Layout\WithGasCheckSubReport.sql
:r .\TM\Reports\Layout\WithLeakCheckSubReport.sql
:r .\TM\Reports\Layout\WithoutGasCheckSubReport.sql
:r .\TM\Reports\Layout\WithoutLeakCheckSubReport.sql

:r .\TM\Reports\DataSource\OpenCallEntries.sql



-- Canned Panels
:r .\DB\1_CannedPanels_Panel.sql
:r .\DB\2_CannedPanels_Column.sql
:r .\DB\3_CannedPanels_Format.sql

-- General Ledger
:r .\GL\DefaultData\AccountStructure.sql
:r .\GL\DefaultData\AccountGroup.sql
:r .\GL\DefaultData\AccountCategory.sql
:r .\GL\DefaultData\AccountTemplate.sql
:r .\GL\DefaultData\AccountSegmentTemplate.sql
:r .\GL\GLEntryDataFix.sql
:r .\GL\ReportData\GeneralLedgerByAccountDetail.sql
:r .\GL\ReportData\IncomeStatementStandard.sql
:r .\GL\ReportData\TrialBalance.sql
:r .\GL\ReportData\TrialBalanceDetail.sql
:r .\GL\ReportData\BalanceSheetStandard.sql

-- Financial Report Designer
:r .\FRD\FRDEntryDataFix.sql

-- Cash Management
:r .\CM\1_BankTransactionTypes.sql
:r .\CM\2_DataImportStatus.sql
:r .\CM\3_PopulateSourceSystemData.sql
:r .\CM\Reports\SubReports\CheckVoucherMiddleSubReportAPPayment.sql
:r .\CM\Reports\SubReports\CheckVoucherMiddleSubReportCMChecks.sql
:r .\CM\Reports\CheckVoucherMiddle.sql

--Accounts Receivable
:r .\AR\EntityTableDataFix.sql
:R .\AR\DefaultData\1_CustomerPortalMenu.sql
:R .\AR\DefaultData\2_SalesOrderDetailDefault.sql
:R .\AR\DefaultData\3_UpdateInvoiceOrderShipToAndBillTo.sql
:r .\AR\DefaultData\4_UpdateInvoiceOrderShipVia.sql
:r .\AR\DefaultData\5_UpdateOrderStatus.sql

--Accounts Payable
--:r .\AP\RestoreVendorId.sql
--:r .\AP\FixEntitiesData.sql
:r .\AP\FixVendorGLAccountExpense.sql
:r .\AP\UpdateBillBatch.sql
:r .\AP\FixPaymentRecordStatus.sql
--:r .\AP\FixstrBillId.sql
:r .\AP\DefaultData\POOrderStatus.sql
:r .\AP\ClearPostResult.sql
:r .\AP\DateCreatedValueDefault.sql
:r .\AP\DefaultData\InsertWriteOffPaymentMethod.sql
:r .\AP\UpdatePOAddressInfo.sql
:r .\AP\UpdateBillStatus.sql

-- Inventory 
:r .\IC\00_RequiredDataFix.sql 
:r .\IC\01_InventoryTransactionTypes.sql 
:r .\IC\02_MaterialNMFC.sql 
:r .\IC\03_DefaultData.sql 
:r .\IC\04_CostingMethods.sql 
:r .\IC\05_LotStatus.sql
:r .\IC\06_FixBlankLotNumber.sql
:r .\IC\07_Status.sql
:r .\IC\08_InventoryTransactionPostingIntegration.sql
:r .\IC\09_InventoryTransactionsWithNoCounterAccountCategory.sql
:r .\IC\PatchFor_1510_to_1520.sql

--Help Desk
:R .\HD\DefaultData\1_StatusData.sql
:R .\HD\HDEntryDataFix.sql

--Contract Management
:R .\CT\1_MasterTables.sql

--Notes Receivable
:R .\NR\1_NoteTransType.sql

--Grain
:R .\GR\1_MasterTables.sql

--Manufacturing
:R .\MF\1_MasterTables.sql

-- Payroll
:r .\PR\DefaultData\1_TaxStatesAndLocalities.sql

-- Version Update
:r .\VersionUpdate.sql

-- Entity Management
:r .\EM\001_EMEntityPortalMenu.sql
:r .\EM\002_UpdateMenuuEntityType.sql
:r .\EM\003_FixVendorBadData.sql

-- Quality Module
:r .\QM\1_MasterTables.sql


print 'END POST DEPLOYMENT'
