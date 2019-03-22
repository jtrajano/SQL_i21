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


:r .\CreateEncryptionCertificateAndSymmetricKey.sql
GO
:r .\EncryptionDataFix.sql
GO

-- System Manager Default Data
:r .\SM\DefaultData\1_MasterMenu.sql
GO
:r .\SM\DefaultData\2_UserRole.sql
GO
:r .\SM\DefaultData\3_Currency.sql 
GO
:r .\SM\DefaultData\4_StartingNumbers.sql
GO
:r .\SM\DefaultData\5_CompanySetup.sql
GO
:r .\SM\DefaultData\5_1_MultiCurrency.sql
GO
:r .\SM\DefaultData\6_Preferences.sql
GO
:r .\SM\DefaultData\7_EULA.sql
GO
:r .\SM\DefaultData\8_Country.sql
GO
:r .\SM\DefaultData\9_ZipCode.sql
GO
:r .\SM\DefaultData\10_Screen.sql
GO
:r .\SM\DefaultData\11_FreightTerms.sql
GO
:r .\SM\DefaultData\12_ReminderList.sql
GO
:r .\SM\DefaultData\13_ShortcutKey.sql
GO
:r .\SM\DefaultData\14_CompanyPreference.sql
GO
:r .\SM\DefaultData\15_Module.sql
GO
:r .\SM\DefaultData\16_PaymentMethod.sql
GO
:r .\SM\DefaultData\17_Notification.sql
GO
:r .\SM\DefaultData\18_SecurityPolicy.sql
--:r .\SM\DefaultData\19_HomePanelDashboard.sql
GO
:r .\SM\DefaultData\20_CustomFieldMigration.sql
GO
:r .\SM\DefaultData\21_CommentMigration.sql
GO
:r .\SM\DefaultData\22_TypeValue.sql
GO
:r .\SM\DefaultData\23_ApproverConfigurationApprovalFor.sql
GO
:r .\SM\DefaultData\25_ApprovalHistory.sql
GO
:r .\SM\DefaultData\26_ActivitySource.sql
GO
:r .\SM\DefaultData\27_Language.sql
GO
:r .\SM\DefaultData\28_MultiCompany.sql
GO
:r .\SM\DefaultData\29_TransportationMode.sql
GO
:r .\SM\DefaultData\30_ImportFileHeader.sql
GO
:r .\SM\DefaultData\31_Calendar.sql
GO
:r .\SM\DefaultData\32_DynamicCSV.sql
GO
:r .\SM\CustomField.sql
GO
:r .\SM\1730_UpdateOriginSubMenusSorting.sql
GO
:r .\SM\1730_PortalMenus.sql
GO
:r .\SM\SMDataMigrations.SQL
GO
:r .\SM\SMDataFixes.SQL
GO
:r .\SM\1720_Statement_Footer_To_Report.sql
GO
:r .\SM\1730_UpdatePatronageMenus.sql
GO
:r .\SM\1730_EntityFavoriteMenu.sql
GO
:r .\SM\1730_UpdateTicketManagementMenus.sql
GO
:r .\SM\1730_UpdatePayrollMenus.sql
GO
:r .\SM\1730_UpdateGeneralLedgerMenus.sql
GO
:r .\SM\1710_to_1730_UpdateHomePanelDashboard.sql
GO
:r .\SM\1730_UpdateManufacturingMenus.sql
GO
:r .\SM\1740_UpdatePurchasingMenus.sql
GO
:r .\SM\1740_UpdateSalesMenus.sql
GO
:r .\SM\1740_RemoveLoadScheduleResources.sql
GO
:r .\SM\1810_RenameCompanyToMultiCompany.sql
GO
:r .\SM\1810_UpdatePortalMenus.sql
GO
:r .\SM\1810_UpdateTransactionsApprovalFor.sql
GO
:r .\SM\DefaultData\33_InterCompanyTransactionType.sql
GO
:r .\SM\1810_Reset_Hours_Terms.sql
GO
:r .\SM\1810_tblSMCompanyGridlayout_DeleteDuplicateRecords.sql
GO
:r .\SM\DefaultData\35_Control.sql
GO
:r .\SM\DefaultData\36_Control_Persmission.sql
GO
:r .\SM\DefaultData\TruncateReplicationTables.sql
GO
:r .\SM\DefaultData\34_ReplicationTable.sql
GO
:r .\SM\DefaultData\37_ReplicationConfiguration.sql
GO
:r .\SM\DefaultData\38_ReplicationConfigurationTable.sql
GO
:r .\SM\DefaultData\39_ReplicationConfigurationTable_InitOnly.sql
GO
:r .\SM\DefaultData\40_DisconnectedReplicationTable.sql 
GO
:r .\SM\DefaultData\41_TaxReportType.sql 
GO
:r .\SM\1810_Reset_Hours_TaxCodeRate.sql
GO
:r .\SM\1830_Arrange_Portal_Menus.sql
GO
:r .\SM\1830_DeleteDuplicatetblSMScreenData.sql
GO
:r .\SM\1830_Encrypt_Merchant_Password.sql
GO
:r .\SM\1910_MigrateINCOToFreightTerm.sql
GO
:r .\SM\1910_UpdateVantivToWorldPay.sql

-- Canned Report
:r .\Reports\1_ReportDisableConstraints.sql
GO
:r .\Reports\2_ReportDeleteOldData.sql
GO
:r .\Reports\3_ReportEnableConstraints.sql
GO
:r .\Reports\4_ReportData.sql
GO
:r .\Reports\Pxcyctag.sql
GO

-- Tank Management
-- :r .\TM\1_OriginIndexing.sql
:r .\TM\DefaultData\1_PreferenceCompany.sql
GO
:r .\TM\DefaultData\2_EventType.sql
GO
:r .\TM\DefaultData\3_DeviceType.sql
GO
:r .\TM\DefaultData\4_MeterType.sql
GO
:r .\TM\DefaultData\5_FillMethodType.sql
GO
:r .\TM\DefaultData\6_InventoryStatusType.sql
GO
:r .\TM\DefaultData\7_WorkStatusType.sql
GO
:r .\TM\DefaultData\8_WorkToDoItem.sql
GO
:r .\TM\DefaultData\9_WorkCloseReason.sql
GO
:r .\TM\DefaultData\10_RegulatorType.sql
GO
:r .\TM\DefaultData\11_ApplianceType.sql
GO
:r .\TM\DefaultData\12_BudgetCalculation.sql
GO
:r .\TM\DefaultData\13_GlobalJulianCalendar.sql
GO
:r .\TM\Tables\tblTMCOBOLWRITE.sql
GO

----TM Reports
GO
:r .\TM\Reports\FieldSelection\DeliveryFill.sql
GO
:r .\TM\Reports\Layout\DeliveryFill.sql
GO
:r .\TM\Reports\DataSource\DeliveryFill.sql
GO
:r .\TM\Reports\DefaultCriteria\DeliveryFill.sql
GO
:r .\TM\Reports\SubReportSettings\DeliveryFill.sql
GO

:r .\TM\Reports\FieldSelection\DeviceLeaseDetail.sql
GO
:r .\TM\Reports\Layout\DeviceLeaseDetail.sql
GO
:r .\TM\Reports\DataSource\DeviceLeaseDetail.sql
GO
:r .\TM\Reports\DefaultCriteria\DeviceLeaseDetail.sql

GO
:r .\TM\Reports\Layout\DeviceActions.sql
GO
:r .\TM\Reports\DataSource\DeviceActions.sql

GO
:r .\TM\Reports\Layout\ProductTotals.sql
GO
:r .\TM\Reports\DataSource\ProductTotals.sql

GO
:r .\TM\Reports\DataSource\CustomerListByRoute.sql
GO
:r .\TM\Reports\Layout\CustomerListByRoute.sql
GO
:r .\TM\Reports\DefaultCriteria\CustomerListByRoute.sql
GO

GO
:r .\TM\Reports\DataSource\GasCheckLeakcheck.sql
GO
:r .\TM\Reports\Layout\WithGasCheckSubReport.sql
GO
:r .\TM\Reports\Layout\WithLeakCheckSubReport.sql
GO
:r .\TM\Reports\Layout\WithoutGasCheckSubReport.sql
GO
:r .\TM\Reports\Layout\WithoutLeakCheckSubReport.sql
GO

GO
:r .\TM\Reports\DataSource\OpenCallEntries.sql
GO
:r .\TM\Reports\DataSource\EfficiencyReport.sql
GO
:r .\TM\Reports\Layout\EfficiencyReport.sql
GO
:r .\TM\Reports\Layout\WorkOrder.sql
GO
:r .\TM\Reports\DataSource\CallEntryPrintOut.sql
GO
:r .\TM\Reports\Layout\CallEntryPrintOut.sql
GO
:r .\TM\4_MigrateLeaseIdFromDeviceToLeaseDeviceTable.sql
GO
:r .\TM\5_ObsoletingSeasonReset.sql
GO
:r .\TM\6_SyncStartingNumberAndDispatchId.sql
GO
:r .\TM\7_GenerateManufacturerFromDevice.sql
GO

GO

GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateAccountStatusView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCommentsView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateContractView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateOriginOptionView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCTLMSTView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateItemView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateInvoiceView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLocaleTaxView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLocationView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateCustomerView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateSalesPersonView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateTermsView.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\TwoPartDeliveryFillReport.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithGasCheck.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithLeakCheck.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutLeakCheck.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutGasCheck.sql"
GO
:r "..\..\..\Integration\dbo\Views\vyuTMOriginDegreeOption.sql"
GO
:r "..\..\..\Integration\dbo\Functions\fnTMGetContractForCustomer.sql"
GO
--:r "..\..\..\Integration\dbo\Views\vyuTMLeaseCode.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMAlterCobolWrite.sql"
GO
:r ".\TM\2_DataTransferAndCorrection.sql" 
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationItemPricingView.sql"
GO
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationSiteView.sql"
GO
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationSiteSP.sql"
GO
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLeaseSearchView.sql"
GO
:r "..\..\..\Integration\dbo\Functions\fnTMGetSpecialPricing.sql"
GO
:r "..\..\..\Integration\dbo\Functions\fnTMGetSpecialPricingPrice.sql"
GO
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateGetSpecialPricingPriceTableFn.sql"
GO
:r ".\TM\3_PopulateLocatioinIdOnSiteForOriginIntegrated.sql"
GO

GO
-- Canned Panels \ Dashboard Panels
GO
:r .\DB\1_CannedPanels_Panel.sql
GO
:r .\DB\2_CannedPanels_Column.sql
GO
:r .\DB\3_CannedPanels_Format.sql
GO
:r .\DB\4_Create_Role_for_DashboardReports.sql
GO
:r .\DB\6_PanelOwnerMigration.sql
GO
:r .\DB\7_DeleteAllFloatingPanels.sql
GO

GO
-- General Ledger
GO
:r .\GL\DefaultData\1a_AccountStructure.sql
GO
:r .\GL\DefaultData\1b_AccountType.sql
GO
:r .\GL\DefaultData\1c_AccountGroup.sql
GO
:r .\GL\DefaultData\1d_RemoveDuplicateCOGSales_AccountGroup.sql
GO
:r .\GL\DefaultData\1e_AccountCategory.sql
GO
:r .\GL\DefaultData\1e_AccountCategoryMaintenance.sql
GO
:r .\GL\DefaultData\1f_AccountTemplate.sql
GO
:r .\GL\DefaultData\1g_AccountSegmentTemplate.sql
GO
:r .\GL\DefaultData\1h_AccountRange.sql
GO
:r .\GL\DefaultData\1i_RemoveCOGSales_AccountRange.sql
GO
:r .\GL\DefaultData\1j_FiscalYearPeriod.sql
GO
:r .\GL\DefaultData\1k_AccountCurrency.sql
GO
:r .\GL\DefaultData\1l_AlterTable.sql
GO
:r .\GL\DefaultData\1o_SegmentType.sql
GO
:r .\GL\GLEntryDataFix.sql
GO
:r .\GL\DefaultData\1n_UpdateFiscalUpperBounds.sql
GO
:r .\GL\DefaultData\1p_CompanyPreferenceOption.sql
GO
:r .\GL\DefaultData\1q_InsertOriginMapping.sql
GO
:r .\GL\DefaultData\1r_UpdateModuleCategory.sql
GO
:r .\GL\DefaultData\1s_UpdateChartDescription.sql
GO
:r .\GL\DefaultData\1t_InsertTrialBalanceData.sql
GO

GO
-- Financial Report Designer
GO
:r .\FRD\FRDEntryDataFix.sql
GO

GO
-- Cash Management
GO
:r .\CM\1_BankTransactionTypes.sql
GO
:r .\CM\2_DataImportStatus.sql
GO
:r .\CM\3_PopulateSourceSystemData.sql
GO
:r .\CM\4_DataFix.sql
GO
:r .\CM\5_UndepositedFund.sql
GO

GO
--Accounts Receivable
GO
:R .\AR\DefaultData\1_CustomerPortalMenu.sql
GO
:r .\AR\DefaultData\2_CleanStagingTables.sql
GO
:r .\AR\DefaultData\5_UpdateOrderStatus.sql
GO
:r .\AR\DefaultData\9_FixServiceChargeStartingNumber.sql
GO
:r .\AR\DefaultData\10_UpdateCustomerTotalARBalance.sql
GO
:r .\AR\DefaultData\11_UpdateInvoiceSODetailUOM.sql
GO
:r .\AR\DefaultData\12_UpdatesActualCostIdInInvoice.sql
GO
:r .\AR\DefaultData\13_FixOnOrderCommittedQuantity.sql
GO
:r .\AR\DefaultData\14_RemoveWriteOffFromCMUndepositedFund.sql
GO
:r .\AR\DefaultData\15_FixInvoiceDateForCredits.sql
GO
:r .\AR\DefaultData\17_AddDefaultQuoteOrderTemplate.sql
GO
:r .\AR\DefaultData\19_UpdateUsedCustomerBudget.sql
GO
:r .\AR\DefaultData\20_UpdateCommissionScheduleDetailSort.sql
GO
:r .\AR\DefaultData\21_UpdateFromPrepaymentToCustomerPrepayment.sql
GO
:r .\AR\DefaultData\22_UpdateInvoiceSubCurrency.sql
GO
:r .\AR\DefaultData\23_AddDefaultCollectionLetters.sql
GO
:r .\AR\DefaultData\24_AddDefaultPlaceHolders.sql
GO
--:r .\AR\DefaultData\26_UpdatePaymentdetailTransactionNumber.sql
GO
:r .\AR\DefaultData\27_RenamePricingForContracts.sql
GO
--:r .\AR\DefaultData\28_UpdateBaseAmounts.sql
GO
:r .\AR\DefaultData\29_UpdateInvoiceDetailLotId.sql
GO
--:r .\AR\DefaultData\30_UpdateBatchIdUsed.sql
GO
:r .\AR\DefaultData\31_UpdateCustomerRackQuoteHeader.sql
GO
:r .\AR\DefaultData\32_UpdateCommissionScheduleEntity.sql
GO
:r .\AR\DefaultData\33_UpdateSalesOrderQuoteTypes.sql
GO
:r .\AR\DefaultData\34_UpdateUnitPriceUOM.sql
GO
:r .\AR\DefaultData\35_UpdateInvoiceFromProvisional.sql
GO
:r .\AR\DefaultData\36_UpdateTaxDetailInvalidSetup.sql
GO
:r .\AR\DefaultData\99_ReCreateTriggers.sql
GO

GO
--Accounts Payable
GO
--:r .\AP\RestoreVendorId.sql
GO
--:r .\AP\FixEntitiesData.sql
GO
:r .\AP\DefaultData\APPreference.sql
GO
:r .\AP\FixVendorGLAccountExpense.sql
GO
:r .\AP\UpdateBillBatch.sql
GO
:r .\AP\FixPaymentRecordStatus.sql
GO
--:r .\AP\FixstrBillId.sql
GO
:r .\AP\DefaultData\POOrderStatus.sql
GO
:r .\AP\DefaultData\Categories1099.sql
GO
:r .\AP\DefaultData\Categories1099PATR.sql
GO
:r .\AP\DefaultData\Categories1099DIV.sql
GO
:r .\AP\ClearPostResult.sql
GO
:r .\AP\DateCreatedValueDefault.sql
GO
:r .\AP\DefaultData\InsertWriteOffPaymentMethod.sql
GO
:r .\AP\DefaultData\Threshold1099.sql
GO
:r .\AP\DefaultData\DeferredPaymentInterest.sql
GO
--:r .\AP\UpdatePOAddressInfo.sql
GO
:r .\AP\UpdateApprovalRecords.sql
GO
--:r .\AP\UpdateBillStatus.sql
GO
:r .\AP\RemoveBillTemplate.sql
GO
:r .\AP\UpdateVoucherForApproval.sql
GO
:r .\AP\UpdateBillPayToAddress.sql
GO
:r .\AP\UpdateBillGLEntriesRecords.SQL
GO
:r .\AP\UpdateBillDetailCurrencies.sql
GO
:r .\AP\UpdateOldCost.sql
GO
:r .\AP\MigrateVouchersForApproval.sql
GO
:r .\AP\MigratePOForApprovals.sql
GO
:r .\AP\UpdateVoucherDetail1099.sql
GO
:r .\AP\UpdateAmountSign.sql
GO
:r .\AP\DefaultDataBalance.sql
GO
:r .\AP\UpdatePrepayVoucherStatus.sql
GO
:r .\AP\UpdateTaxGroupId.sql
GO
:r .\AP\UpdateBillDetailRate.sql
GO
:r .\AP\DeleteInvalidBasisAdvanceStaging.sql
GO
:r .\AP\CleanBasisAdvance.sql
GO
:r .\AP\UpdateNewShipFromEntity.sql
GO
:r .\AP\UpdatePOPendingStatus.sql
GO
:r .\AP\UpdateVendorCreatePostVoucher.sql
GO
:r .\AP\VoucherPayableDefaultData.sql
GO
:r .\AP\FixStartingNumbers.sql
GO
:r .\AP\UpdateOffsetField.sql
GO

GO
-- Inventory 
GO
:r .\IC\01_InventoryTransactionTypes.sql 
GO
:r .\IC\02_DefaultData.sql 
GO
:r .\IC\03_CostingMethods.sql 
GO
:r .\IC\04_LotStatus.sql 
GO
:r .\IC\05_Status.sql 
GO
:r .\IC\06_InventoryTransactionPostingIntegration.sql 
GO
:r .\IC\07_InventoryTransactionsWithNoCounterAccountCategory.sql 
GO
:r .\IC\08_InventoryCostAdjustmentTypes.sql 
GO
:r .\IC\09_FOBPointTypes.sql 
GO
:r .\IC\10_M2MComputations.sql 
GO
:r .\IC\11_AdjustmentInventoryTerms.sql 
GO
:r .\IC\12_StockTypes.sql 
GO
:r .\IC\13_Add_Default_Edi_Mapping_Template.sql 
GO
:r .\IC\14_Add_Inventory_Report_Templates.sql 
GO
:r .\IC\Data_Fix_For_18.3\01_UpdateContractItemStatuses.sql 
GO
:r .\IC\Data_Fix_For_18.3\02_Update_ActualCostId_On_InventoryTransaction.sql 
GO
:r .\IC\Data_Fix_For_18.3\03_MigratePackedTypeToQuantityType.sql 
GO
:r .\IC\Data_Fix_For_18.3\04_AddStockUOM.sql 
GO
:r .\IC\Data_Fix_For_18.3\05_FixDebitCreditUnits.sql 
GO
:r .\IC\Data_Fix_For_18.3\06_CompanyPreferenceForOriginLastTask.sql 
GO
:r .\IC\Data_Fix_For_18.3\07_Inventory_Constraints.sql 
GO
:r .\IC\Data_Fix_For_18.3\08_Populate_Shipment_LineTotal.sql 
GO
:r .\IC\Data_Fix_For_18.3\09_RemoveAfter18.3_DataFix.sql 
GO
:r .\IC\Data_Fix_For_18.3\10_Update_Qty_Cost_For_ReceiptTaxes.sql 
GO
:r .\IC\Data_Fix_For_18.3\11_ImplementBasketChanges.sql 
GO
:r .\IC\Data_Fix_For_18.3\12_PopulateGLEntityForICTransactions.sql
GO
:r .\IC\Data_Fix_For_18.3\13_PopulateLotInTransitQtyAndWgt.sql
GO

GO
-- Patronage
GO
:r .\PAT\DefaultData\1_AddDefaultLetters.sql 
GO
:r .\PAT\DefaultData\2_DefaultCompanyPreference.sql
GO
:r .\PAT\DefaultData\3_DefaultImportOriginFlag.sql
GO
:r .\PAT\1_DropStoredProcedures.sql
GO
:r .\PAT\2_MigrateStockRecords.sql
GO
:r .\PAT\3_UpdateIssueStockNo.sql
GO
:r .\PAT\4_UpdateRetiredStockNo.sql
GO
:r .\PAT\5_UpdatePayoutType.sql
GO

GO
--Contract Management
GO
:R .\CT\1_MasterTables.sql
GO
:R .\CT\172To173.sql
GO
:R .\CT\174To181.sql
GO
:R .\CT\ExcelAndTableColumnMap.sql
GO

GO
--Notes Receivable
GO
:R .\NR\1_NoteTransType.sql
GO

GO
--Grain
GO
:R .\GR\1_MasterTables.sql
GO
:R .\GR\2_ScaleTrigger.sql
GO
:R .\GR\TicketTypes.sql
GO
:R .\GR\GRDataMigrations.sql
GO
:R .\GR\InsertStorageHistoryTypeTransaction.sql
GO
:R .\GR\FixStorageHistoryData.sql
GO
:R .\GR\MigrateTransferStorageData.sql
GO
:R .\GR\GR_InsertReadingRanges.sql
GO
:R .\GR\GR_FarmField.sql
GO

GO
--Manufacturing
GO
:R .\MF\1_MasterTables.sql
GO
:R .\MF\2_ProcessAttribute.sql
GO
:R .\MF\7_ProcessAttributeDefaultValue.sql
GO

GO
-- Payroll
GO
:r .\PR\DefaultData\1_TaxStatesAndLocalities.sql
GO
:r .\PR\DefaultData\2_ElectronicFileFormats.sql
GO
--:r .\PR\DataFixes\AddDefaultEmployeeEarningDistribution.sql
GO
--:r .\PR\DataFixes\AddPaycheckDirectDepositEntries.sql
GO
--:r .\PR\DataFixes\ResetEaningHoursToProcess.sql
GO
:r .\PR\DataFixes\SynchronizePaycheckCheckNumber.sql
GO
:r .\PR\DataFixes\UpdateEarningDeductionTaxId.sql
GO
:r .\PR\DataFixes\UpdatePaycheckTotalHours.sql
GO
:r .\PR\DataFixes\UpdateOldData.sql
GO
:r .\PR\Reports\DashboardPanelViews.sql
GO
:r .\PR\Reports\SubReports\PaycheckEarningSubReport.sql
GO
:r .\PR\Reports\SubReports\PaycheckTaxSubReport.sql
GO
:r .\PR\Reports\SubReports\PaycheckDeductionSubReport.sql
GO
:r .\PR\Reports\SubReports\PaycheckTimeOffSubReport.sql
GO
:r .\PR\Reports\PaycheckTop.sql
GO
:r .\PR\Reports\PaycheckMiddle.sql
GO
:r .\PR\Reports\PaycheckBottom.sql
GO

GO
-- Version Update
GO
:r .\VersionUpdate.sql
GO

GO
-- Entity Management
GO
:r .\EM\001_EMEntityPortalMenu.sql
GO
:r .\EM\002_UpdateMenuuEntityType.sql
GO
:r .\EM\003_FixVendorBadData.sql
GO
:r .\EM\004_MoveFuturesBrokerData.sql
GO
:r .\EM\005_MoveForwardingAgentData.sql
GO
:r .\EM\006_MoveTerminalData.sql
GO
:r .\EM\007_MoveShippingLineData.sql
GO
:r .\EM\008_MoveTruckerData.sql
GO
:r .\EM\009_UpdateEntityContactTypeData.sql
GO
:r .\EM\010_UpdateVendorAccountNumber.sql
GO
:r .\EM\011_FixEntityLocationNullTerms.sql
GO
:r .\EM\012_DeleteOldTables.sql
GO
:r .\EM\013_SetDefaultLocationToActive.sql
GO
:r .\EM\014_UpdateCustomerPricingLevel.sql
GO
:r .\EM\015_UpdateEntityTariffType.sql
GO
:r .\EM\016_MoveCustomerAccountStatusToNewTable.sql
GO
:r .\EM\017_MoveSplitCategoryToNewTable.sql
GO
:r .\EM\018_UpdateRoleId_ForEntityCredential.sql
GO
:r .\EM\019_RemoveEmailToParentEntity.sql
GO
:r .\EM\020_DefaultDataForEntityImportSchemaCSV.sql
GO
:r .\EM\021_MoveCustomerMessageToEntity.sql
GO
:r .\DB\5_FixUserIdDataEntry.sql ---used entry = 'Update DB UserId From Parent Entity' on tblEMEntityPreferences
GO

GO
:r .\EM\022_DefaultDataForContactTypeAndImport.sql
GO
:r .\EM\023_RenameEntityContactEmailDistribution.sql
GO
:r .\EM\024_delete_old_entity_table.sql
GO
:r .\EM\025_UpdatePhoneNumberAndCreateBackup.sql
GO
:r .\EM\028_MassCountryFormat.sql
GO
:r .\EM\026_ImportPhoneNumbersToNewTable.sql
GO
:r .\EM\027_MassUpdatePhoneNumber.sql
GO
:r .\EM\029_FillInPhoneAndMobile.sql
GO
:r .\EM\030-FixSalesperson.sql
GO
:r .\EM\024_CleanOrphanCustomerGroup.sql
GO
:r .\EM\031_UpdatePhoneAreaLength.sql
GO
:r .\EM\032_MigrateVendorApprovalList.sql
GO
:r .\EM\033_UpdateUserSecurityAdmin.sql
GO
:r .\EM\034_EntityClassData.sql
GO
:r .\EM\035_EncryptEFTAccountNumber.sql
GO
:r .\EM\034_UpdateEntityEmail.sql
GO
:r .\EM\036_MoveTheTermsPerType.sql
GO
:r .\EM\037_DefaultDataLocationPayee.sql
GO
--:r .\EM\038_UpdateEncryptionUsed.sql
GO
:r .\EM\039_MoveDefaultTermsToVendorTerm.sql
GO
:r .\EM\040_UpdatePasswordHistoryEncryption.sql
GO
:r .\EM\041_FixVendorNo.sql
GO
:r .\EM\Migrate_Data_1710_Moving_Format_UserSec_Ent.sql
GO
:r .\EM\1730_Fix_SplitTypeEntry.sql
GO
:r .\EM\DataMigration\1710_1720_CCSite_migration.sql
GO
:r .\EM\DataMigration\1740_Moving_Farm_Info_to_Location.sql
GO
:r .\EM\1740_Activate_Default_Contact.sql
GO
:r .\EM\1810_Set_Default_Language.sql
GO
:r .\EM\1810_Fix_Check_Payee_Name.sql
GO
:r .\EM\1910_Set_Contact_Location.sql
GO

GO
-- Quality Module
GO
:r .\QM\1_MasterTables.sql
GO

GO
-- C-Store Module
GO
:r .\ST\01_FileFieldMapping_PricebookSale.sql
GO
:r .\ST\02_FileFieldMapping_PromotionItemList.sql
GO
:r .\ST\03_FileFieldMapping_PromotionCombo.sql
GO
:r .\ST\04_FileFieldMapping_PricebookMixMatch.sql
GO
:r .\ST\05_FileFieldMapping_PricebookSendSapphire.sql
GO
:r .\ST\06_Checkout_Radiant_ISM.sql
GO
:r .\ST\07_Checkout_Radiant_MCM.sql
GO
:r .\ST\08_Checkout_Radiant_FGM.sql
GO
:r .\ST\09_Checkout_Radiant_MSM.sql
GO
:r .\ST\10_Checkout_Commander_Translog.sql
GO
:r .\ST\11_FileFieldMapping_Passport_ISM_330.sql
GO
:r .\ST\12_FileFieldMapping_Passport_FGM_330.sql
GO
:r .\ST\13_FileFieldMapping_Passport_MCM_330.sql
GO
:r .\ST\14_FileFieldMapping_Passport_MSM_330.sql
GO
:r .\ST\15_FileFieldMapping_Passport_TLM_330.sql
GO
:r .\ST\16_FileFieldMapping_Passport_TLM_340.sql
GO
:r .\ST\17_FileFieldMapping_Passport_FGM_340.sql
GO
:r .\ST\18_FileFieldMapping_Passport_ISM_340.sql
GO
:r .\ST\19_FileFieldMapping_Passport_MCM_340.sql
GO
:r .\ST\20_FileFieldMapping_Passport_MSM_340.sql
GO
:r .\ST\21_FileFieldMapping_Passport_CBT.sql
GO
:r .\ST\22_FileFieldMapping_Passport_ITT.sql
GO
:r .\ST\23_FileFieldMapping_Passport_ILT.sql
GO
:r .\ST\24_FileFieldMapping_Passport_MMT.sql
GO
:r .\ST\25_DataFix.sql
GO

GO
-- Motor Fuel Tax
GO
:r .\TF\DefaultData\01_TaxAuthority.sql
GO
:r .\TF\DefaultData\02_TerminalControl.sql
GO
:r .\TF\DefaultData\03_TaxCategory.sql
GO
:r .\TF\DefaultData\04_TransactionSource.sql
GO
:r .\TF\DefaultData\IN_Indiana.sql
GO
:r .\TF\DefaultData\IL_Illinois.sql
GO
:r .\TF\DefaultData\NE_Nebraska.sql
GO
:r .\TF\DefaultData\MS_Mississippi.sql
GO
GO
:r .\TF\DefaultData\LA_Louisiana.sql
GO
:r .\TF\DefaultData\MI_Michigan.sql
GO
:r .\TF\DefaultData\NC_NorthCarolina.sql
GO
:r .\TF\DefaultData\OR_Oregon.sql
GO
:r .\TF\DefaultData\WA_Washington.sql
GO
:r .\TF\DefaultData\OH_Ohio.sql
GO
:r .\TF\DefaultData\NM_NewMexico.sql
GO
:r .\TF\DefaultData\SC_SouthCarolina.sql
GO
:r .\TF\DefaultData\PA_Pennsylvania.sql
GO
:r .\TF\DefaultData\MT_Montana.sql
GO
:r .\TF\DefaultData\MN_Minnesota.sql
GO
:r .\TF\DefaultData\KS_Kansas.sql
GO
:r .\TF\DefaultData\KY_Kentucky.sql
GO
:r .\TF\DefaultData\ID_Idaho.sql
GO
:r .\TF\DefaultData\OK_Oklahoma.sql
GO
:r .\TF\DefaultData\TX_Texas.sql
GO
:r .\TF\DefaultData\AR_Arkansas.sql
GO
:r .\TF\DefaultData\AfterUpgradeCleanup.sql
GO

GO
--Integration
GO
:R .\IP\1_MasterTables.sql
GO

GO
-- Common
GO
--:r .\Common\ErrorMessages.sql 
GO

GO
--Logistics
GO
:R .\LG\1_MasterTables.sql
GO
:R .\LG\2_DataFixes.sql
GO

GO
--RiskManagement
GO
:R .\RM\01_MasterScript.sql
GO
:R .\RM\02_DataFix.sql
GO

GO
--FRM
GO

GO

GO

GO
--CCR
GO
:r .\CCR\SiteDataFix.sql
GO
:r .\CCR\RemoveCCRObsoleteScreen.sql
GO
:r .\CCR\ImportFileDefault.sql
GO

GO
--TR
GO
:r .\TR\RemoveObsoleteScreen.sql
GO
:r .\TR\CleanUp_TR_Data.sql
GO

GO
--Help Desk
GO
:R .\HD\DefaultData\1_StatusData.sql
GO
:R .\HD\DefaultData\2_Screen.sql
GO
:R .\HD\DefaultData\3_UpgradeTypeAndEnvironment.sql
GO
:R .\HD\HDEntryDataFix.sql
GO
:R .\HD\CustomField.sql
GO
:R .\HD\RemoveHDObsoleteScreen.sql
GO
:R .\HD\RenameHDScreen.sql
GO

GO
--CRM
GO
:R .\CRM\SplitCRMData.sql
GO
:R .\CRM\RenameCRMScreen.sql
GO

GO
-- Card Fueling
GO
:r .\CF\1_ImportMapping.sql
GO
:r .\CF\2_DataFix.sql
GO
:r .\CF\3_DataFixPriceAdjustment.sql
GO
:r .\CF\4_18.1To18.3DataConversion.sql
GO
:r .\CF\5_18.3To19.1DataConversion.sql
GO

GO

GO
-- Vendor rebate
GO
:r .\VR\1_UpdateColumnTableProgramItem.sql
GO

GO
--MIGRATE AUDIT LOGS
GO
:r .\SM\1910_MigrateAuditLog.sql
GO

GO

GO
--SM - this should always be the last to execute
GO
	-- REMINDER: DO NOT ADD ANY SQL FILE AFTER THIS
GO
:r .\SM\1830_ReIndexTables.sql
GO
:r .\SM\1830_CreateReIndexMaintenancePlan.sql
GO
:r .\SM\1910_CreateAuditLogMigrationPlan.sql
GO

GO
-- MB - Meter Billing
GO
:r .\MB\ImportFileDefault.sql


print 'END POST DEPLOYMENT'
