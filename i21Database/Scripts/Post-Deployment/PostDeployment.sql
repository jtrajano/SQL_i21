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
:r .\SM\DefaultData\14_CompanyPreference.sql
:r .\SM\DefaultData\15_Module.sql
:r .\SM\CustomField.sql
:r .\SM\SMDataMigrations.SQL
:r .\SM\SMDataFixes.SQL

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
:r .\TM\DefaultData\11_ApplianceType.sql
:r .\TM\Tables\tblTMCOBOLWRITE.sql

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

:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateAccountStatusView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCommentsView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateContractView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateOriginOptionView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCTLMSTView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateItemView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateInvoiceView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLocaleTaxView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLocationView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCustomerView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateSalesPersonView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateTermsView.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\TwoPartDeliveryFillReport.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithGasCheck.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithLeakCheck.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutLeakCheck.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutGasCheck.sql"
:r "..\..\..\Integration\dbo\Views\vyuTMOriginDegreeOption.sql"
:r "..\..\..\Integration\dbo\Functions\fnTMGetContractForCustomer.sql"
--:r "..\..\..\Integration\dbo\Views\vyuTMLeaseCode.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMAlterCobolWrite.sql"



-- Canned Panels
:r .\DB\1_CannedPanels_Panel.sql
:r .\DB\2_CannedPanels_Column.sql
:r .\DB\3_CannedPanels_Format.sql
:r .\DB\4_Create_Role_for_DashboardReports.sql

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
:r .\CM\Reports\SubReports\CheckVoucherMiddleSubReportAPPaymentOverflow.sql
:r .\CM\Reports\SubReports\CheckVoucherMiddleSubReportCMChecks.sql
:r .\CM\Reports\CheckVoucherMiddle.sql
:r .\CM\Reports\CheckVoucherMiddleOverflow.sql

--Accounts Receivable
:r .\AR\EntityTableDataFix.sql
:R .\AR\DefaultData\1_CustomerPortalMenu.sql
:R .\AR\DefaultData\2_SalesOrderDetailDefault.sql
:R .\AR\DefaultData\3_UpdateInvoiceOrderShipToAndBillTo.sql
:r .\AR\DefaultData\4_UpdateInvoiceOrderShipVia.sql
:r .\AR\DefaultData\5_UpdateOrderStatus.sql
:r .\AR\DefaultData\6_UpdateCustomerShipBillTo.sql
:r .\AR\DefaultData\7_UpdateInvoiceOrderSalesperson.sql
:r .\AR\DefaultData\8_UpdateInvoiceType.sql

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
:r .\AP\UpdateApprovalRecords.sql
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
:r .\IC\10_RemoveCommodityItems.sql
:r .\IC\11_RemoveOtherChargesAsset.sql
:r .\IC\12_UpdateExistingInventoryTransactionForm.sql
:r .\IC\13_MoveCommodityAttributes.sql
:r .\IC\PatchFor_1510_to_1520.sql
:r .\GL\InventoryCategoryFix.sql

--Help Desk
:R .\HD\DefaultData\1_StatusData.sql
:R .\HD\HDEntryDataFix.sql

--Contract Management
:R .\CT\1_MasterTables.sql
:R .\CT\2_DataMigration.sql

--Notes Receivable
:R .\NR\1_NoteTransType.sql

--Grain
:R .\GR\1_MasterTables.sql
:R .\GR\GRDataMigrations.sql

--Manufacturing
:R .\MF\1_MasterTables.sql
:R .\MF\2_ProcessAttribute.sql

-- Payroll
:r .\PR\DefaultData\1_TaxStatesAndLocalities.sql

-- Version Update
:r .\VersionUpdate.sql

-- Entity Management
:r .\EM\001_EMEntityPortalMenu.sql
:r .\EM\002_UpdateMenuuEntityType.sql
:r .\EM\003_FixVendorBadData.sql
:r .\EM\004_MoveFuturesBrokerData.sql
:r .\EM\005_MoveForwardingAgentData.sql
:r .\EM\006_MoveTerminalData.sql
:r .\EM\007_MoveShippingLineData.sql
:r .\EM\008_MoveTruckerData.sql
:r .\EM\009_UpdateEntityContactTypeData.sql
:r .\EM\010_UpdateVendorAccountNumber.sql
:r .\EM\011_FixEntityLocationNullTerms.sql
:r .\EM\012_DeleteOldTables.sql
-- Quality Module
:r .\QM\1_MasterTables.sql

-- Store Module
:r .\ST\1_FileFieldMapping_PricebookSale.sql


print 'END POST DEPLOYMENT'
