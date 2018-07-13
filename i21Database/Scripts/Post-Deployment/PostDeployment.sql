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
:r .\EncryptionDataFix.sql

-- System Manager Default Data
:r .\SM\DefaultData\1_MasterMenu.sql
:r .\SM\DefaultData\2_UserRole.sql
:r .\SM\DefaultData\3_Currency.sql 
:r .\SM\DefaultData\4_StartingNumbers.sql
:r .\SM\DefaultData\5_CompanySetup.sql
:r .\SM\DefaultData\5_1_MultiCurrency.sql
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
:r .\SM\DefaultData\16_PaymentMethod.sql
:r .\SM\DefaultData\17_Notification.sql
:r .\SM\DefaultData\18_SecurityPolicy.sql
--:r .\SM\DefaultData\19_HomePanelDashboard.sql
:r .\SM\DefaultData\20_CustomFieldMigration.sql
:r .\SM\DefaultData\21_CommentMigration.sql
:r .\SM\DefaultData\22_TypeValue.sql
:r .\SM\DefaultData\23_ApproverConfigurationApprovalFor.sql
:r .\SM\DefaultData\25_ApprovalHistory.sql
:r .\SM\DefaultData\26_ActivitySource.sql
:r .\SM\DefaultData\27_Language.sql
:r .\SM\DefaultData\28_MultiCompany.sql
:r .\SM\DefaultData\29_TransportationMode.sql
:r .\SM\DefaultData\30_ImportFileHeader.sql
:r .\SM\DefaultData\31_Calendar.sql
:r .\SM\DefaultData\32_DynamicCSV.sql
:r .\SM\CustomField.sql
:r .\SM\1730_UpdateOriginSubMenusSorting.sql
:r .\SM\1730_PortalMenus.sql
:r .\SM\SMDataMigrations.SQL
:r .\SM\SMDataFixes.SQL
:r .\SM\1720_Statement_Footer_To_Report.sql
:r .\SM\1730_UpdatePatronageMenus.sql
:r .\SM\1730_EntityFavoriteMenu.sql
:r .\SM\1730_UpdateTicketManagementMenus.sql
:r .\SM\1730_UpdatePayrollMenus.sql
:r .\SM\1730_UpdateGeneralLedgerMenus.sql
:r .\SM\1710_to_1730_UpdateHomePanelDashboard.sql
:r .\SM\1730_UpdateManufacturingMenus.sql
:r .\SM\1740_UpdatePurchasingMenus.sql
:r .\SM\1740_UpdateSalesMenus.sql
:r .\SM\1740_RemoveLoadScheduleResources.sql
:r .\SM\1810_RenameCompanyToMultiCompany.sql
:r .\SM\1810_UpdatePortalMenus.sql
:r .\SM\1810_UpdateTransactionsApprovalFor.sql
:r .\SM\DefaultData\33_InterCompanyTransactionType.sql
:r .\SM\DefaultData\34_ReplicationTable.sql
:r .\SM\1810_Reset_Hours_Terms.sql
:r .\SM\1810_tblSMCompanyGridlayout_DeleteDuplicateRecords.sql
:r .\SM\DefaultData\35_Control.sql
:r .\SM\DefaultData\36_Control_Persmission.sql
:r .\SM\DefaultData\37_ReplicationConfiguration.sql
:r .\SM\DefaultData\38_ReplicationConfigurationTable.sql
:r .\SM\DefaultData\39_ReplicationConfigurationTable_InitOnly.sql
:r .\SM\1810_Reset_Hours_TaxCodeRate.sql
:r .\SM\1830_Arrange_Portal_Menus.sql
:r .\SM\1830_DeleteDuplicatetblSMScreenData.sql
:r .\SM\1830_Encrypt_Merchant_Password.sql

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
:r .\TM\DefaultData\12_BudgetCalculation.sql
:r .\TM\DefaultData\13_GlobalJulianCalendar.sql
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
:r .\TM\Reports\DataSource\EfficiencyReport.sql
:r .\TM\Reports\Layout\EfficiencyReport.sql
:r .\TM\Reports\Layout\WorkOrder.sql
:r .\TM\Reports\DataSource\CallEntryPrintOut.sql
:r .\TM\Reports\Layout\CallEntryPrintOut.sql
:r .\TM\4_MigrateLeaseIdFromDeviceToLeaseDeviceTable.sql
:r .\TM\5_ObsoletingSeasonReset.sql


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
:r ".\TM\2_DataTransferAndCorrection.sql" 
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationItemPricingView.sql"
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationSiteView.sql"
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationSiteSP.sql"
:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateLeaseSearchView.sql"
:r "..\..\..\Integration\dbo\Functions\fnTMGetSpecialPricing.sql"
:r "..\..\..\Integration\dbo\Functions\fnTMGetSpecialPricingPrice.sql"
--:r "..\..\..\Integration\dbo\Stored Procedures\uspTMRecreateGetSpecialPricingPriceTableFn.sql"
:r ".\TM\3_PopulateLocatioinIdOnSiteForOriginIntegrated.sql"

-- Canned Panels \ Dashboard Panels
:r .\DB\1_CannedPanels_Panel.sql
:r .\DB\2_CannedPanels_Column.sql
:r .\DB\3_CannedPanels_Format.sql
:r .\DB\4_Create_Role_for_DashboardReports.sql
:r .\DB\6_PanelOwnerMigration.sql
:r .\DB\7_DeleteAllFloatingPanels.sql

-- General Ledger
:r .\GL\DefaultData\1a_AccountStructure.sql
:r .\GL\DefaultData\1b_AccountType.sql
:r .\GL\DefaultData\1c_AccountGroup.sql
:r .\GL\DefaultData\1d_RemoveDuplicateCOGSales_AccountGroup.sql
:r .\GL\DefaultData\1e_AccountCategory.sql
:r .\GL\DefaultData\1e_AccountCategoryMaintenance.sql
:r .\GL\DefaultData\1f_AccountTemplate.sql
:r .\GL\DefaultData\1g_AccountSegmentTemplate.sql
:r .\GL\DefaultData\1h_AccountRange.sql
:r .\GL\DefaultData\1i_RemoveCOGSales_AccountRange.sql
:r .\GL\DefaultData\1j_FiscalYearPeriod.sql
:r .\GL\DefaultData\1k_AccountCurrency.sql
:r .\GL\DefaultData\1l_AlterTable.sql
:r .\GL\DefaultData\1o_SegmentType.sql
:r .\GL\GLEntryDataFix.sql
:r .\GL\ReportData\GeneralLedgerByAccountDetail.sql
:r .\GL\ReportData\IncomeStatementStandard.sql
:r .\GL\ReportData\TrialBalance.sql
:r .\GL\ReportData\TrialBalanceDetail.sql
:r .\GL\ReportData\BalanceSheetStandard.sql
:r .\GL\DefaultData\1n_UpdateFiscalUpperBounds.sql
:r .\GL\DefaultData\1p_CompanyPreferenceOption.sql
:r .\GL\DefaultData\1q_InsertOriginMapping.sql
:r .\GL\DefaultData\1r_UpdateModuleCategory.sql
:r .\GL\DefaultData\1s_UpdateChartDescription.sql

-- Financial Report Designer
:r .\FRD\FRDEntryDataFix.sql

-- Cash Management
:r .\CM\1_BankTransactionTypes.sql
:r .\CM\2_DataImportStatus.sql
:r .\CM\3_PopulateSourceSystemData.sql
:r .\CM\4_DataFix.sql

--Accounts Receivable
:R .\AR\DefaultData\1_CustomerPortalMenu.sql
:r .\AR\DefaultData\5_UpdateOrderStatus.sql
:r .\AR\DefaultData\9_FixServiceChargeStartingNumber.sql
:r .\AR\DefaultData\10_UpdateCustomerTotalARBalance.sql
:r .\AR\DefaultData\11_UpdateInvoiceSODetailUOM.sql
:r .\AR\DefaultData\12_UpdatesActualCostIdInInvoice.sql
:r .\AR\DefaultData\13_FixOnOrderCommittedQuantity.sql
:r .\AR\DefaultData\14_RemoveWriteOffFromCMUndepositedFund.sql
:r .\AR\DefaultData\15_FixInvoiceDateForCredits.sql
:r .\AR\DefaultData\17_AddDefaultQuoteOrderTemplate.sql
:r .\AR\DefaultData\19_UpdateUsedCustomerBudget.sql
:r .\AR\DefaultData\20_UpdateCommissionScheduleDetailSort.sql
:r .\AR\DefaultData\21_UpdateFromPrepaymentToCustomerPrepayment.sql
:r .\AR\DefaultData\22_UpdateInvoiceSubCurrency.sql
:r .\AR\DefaultData\23_AddDefaultCollectionLetters.sql
:r .\AR\DefaultData\24_AddDefaultPlaceHolders.sql
--:r .\AR\DefaultData\26_UpdatePaymentdetailTransactionNumber.sql
:r .\AR\DefaultData\27_RenamePricingForContracts.sql
--:r .\AR\DefaultData\28_UpdateBaseAmounts.sql
:r .\AR\DefaultData\29_UpdateInvoiceDetailLotId.sql
--:r .\AR\DefaultData\30_UpdateBatchIdUsed.sql
:r .\AR\DefaultData\31_UpdateCustomerRackQuoteHeader.sql
:r .\AR\DefaultData\32_UpdateCommissionScheduleEntity.sql
:r .\AR\DefaultData\33_UpdateSalesOrderQuoteTypes.sql
:r .\AR\DefaultData\34_UpdateUnitPriceUOM.sql
:r .\AR\DefaultData\99_ReCreateTriggers.sql

--Accounts Payable
--:r .\AP\RestoreVendorId.sql
--:r .\AP\FixEntitiesData.sql
:r .\AP\FixVendorGLAccountExpense.sql
:r .\AP\UpdateBillBatch.sql
:r .\AP\FixPaymentRecordStatus.sql
--:r .\AP\FixstrBillId.sql
:r .\AP\DefaultData\POOrderStatus.sql
:r .\AP\DefaultData\Categories1099.sql
:r .\AP\DefaultData\Categories1099PATR.sql
:r .\AP\DefaultData\Categories1099DIV.sql
:r .\AP\ClearPostResult.sql
:r .\AP\DateCreatedValueDefault.sql
:r .\AP\DefaultData\InsertWriteOffPaymentMethod.sql
:r .\AP\DefaultData\Threshold1099.sql
:r .\AP\DefaultData\DeferredPaymentInterest.sql
--:r .\AP\UpdatePOAddressInfo.sql
:r .\AP\UpdateApprovalRecords.sql
--:r .\AP\UpdateBillStatus.sql
:r .\AP\RemoveBillTemplate.sql
:r .\AP\UpdateVoucherForApproval.sql
:r .\AP\UpdateBillPayToAddress.sql
:r .\AP\UpdateBillGLEntriesRecords.SQL
:r .\AP\UpdateBillDetailCurrencies.sql
:r .\AP\UpdateOldCost.sql
:r .\AP\MigrateVouchersForApproval.sql
:r .\AP\MigratePOForApprovals.sql
:r .\AP\UpdateVoucherDetail1099.sql
:r .\AP\UpdateAmountSign.sql
:r .\AP\DefaultDataBalance.sql
:r .\AP\UpdatePrepayVoucherStatus.sql
:r .\AP\UpdateTaxGroupId.sql
:r .\AP\UpdateBillDetailRate.sql
:r .\AP\DeleteInvalidBasisAdvanceStaging.sql
:r .\AP\CleanBasisAdvance.sql
:r .\AP\UpdateNewShipFromEntity.sql
:r .\AP\UpdatePOPendingStatus.sql
:r .\AP\UpdateVendorCreatePostVoucher.sql

-- Inventory 
:r .\IC\01_InventoryTransactionTypes.sql 
:r .\IC\02_DefaultData.sql 
:r .\IC\03_CostingMethods.sql 
:r .\IC\04_LotStatus.sql 
:r .\IC\05_Status.sql 
:r .\IC\06_InventoryTransactionPostingIntegration.sql 
:r .\IC\07_InventoryTransactionsWithNoCounterAccountCategory.sql 
:r .\IC\08_InventoryCostAdjustmentTypes.sql 
:r .\IC\09_FOBPointTypes.sql 
:r .\IC\10_M2MComputations.sql 
:r .\IC\11_AdjustmentInventoryTerms.sql 
:r .\IC\12_StockTypes.sql 
:r .\IC\Data_Fix_For_18.1\01_UpdateContractItemStatuses.sql 
:r .\IC\Data_Fix_For_18.1\02_Update_ActualCostId_On_InventoryTransaction.sql 
:r .\IC\Data_Fix_For_18.1\03_MigratePackedTypeToQuantityType.sql 
:r .\IC\Data_Fix_For_18.1\04_AddStockUOM.sql 
:r .\IC\Data_Fix_For_18.1\05_FixDebitCreditUnits.sql 
:r .\IC\Data_Fix_For_18.1\06_CompanyPreferenceForOriginLastTask.sql 
:r .\IC\Data_Fix_For_18.1\07_Inventory_Constraints.sql 
:r .\IC\Data_Fix_For_18.1\08_Populate_Shipment_LineTotal.sql 
:r .\IC\Data_Fix_For_18.1\09_RemoveAfter18.3_DataFix.sql 
:r .\IC\Data_Fix_For_18.1\10_Update_Qty_Cost_For_ReceiptTaxes.sql 
:r .\IC\Data_Fix_For_18.1\11_ImplementBasketChanges.sql 

-- Patronage
:r .\PAT\DefaultData\1_AddDefaultLetters.sql 
:r .\PAT\DefaultData\2_DefaultCompanyPreference.sql
:r .\PAT\1_DropStoredProcedures.sql
:r .\PAT\2_MigrateStockRecords.sql
:r .\PAT\3_UpdateIssueStockNo.sql
:r .\PAT\4_UpdateRetiredStockNo.sql
:r .\PAT\5_UpdatePayoutType.sql

--Contract Management
:R .\CT\1_MasterTables.sql
:R .\CT\172To173.sql
:R .\CT\174To181.sql
--Notes Receivable
:R .\NR\1_NoteTransType.sql

--Grain
:R .\GR\1_MasterTables.sql
:R .\GR\TicketTypes.sql
:R .\GR\GRDataMigrations.sql

--Manufacturing
:R .\MF\1_MasterTables.sql
:R .\MF\2_ProcessAttribute.sql
:R .\MF\7_ProcessAttributeDefaultValue.sql

-- Payroll
:r .\PR\DefaultData\1_TaxStatesAndLocalities.sql
:r .\PR\DefaultData\2_ElectronicFileFormats.sql
:r .\PR\DataFixes\AddDefaultEmployeeEarningDistribution.sql
:r .\PR\DataFixes\AddPaycheckDirectDepositEntries.sql
:r .\PR\DataFixes\ResetEaningHoursToProcess.sql
:r .\PR\DataFixes\SynchronizePaycheckCheckNumber.sql
:r .\PR\DataFixes\UpdateEarningDeductionTaxId.sql
:r .\PR\DataFixes\UpdatePaycheckTotalHours.sql
:r .\PR\DataFixes\UpdateOldData.sql
:r .\PR\Reports\DashboardPanelViews.sql
:r .\PR\Reports\SubReports\PaycheckEarningSubReport.sql
:r .\PR\Reports\SubReports\PaycheckTaxSubReport.sql
:r .\PR\Reports\SubReports\PaycheckDeductionSubReport.sql
:r .\PR\Reports\SubReports\PaycheckTimeOffSubReport.sql
:r .\PR\Reports\PaycheckTop.sql
:r .\PR\Reports\PaycheckMiddle.sql
:r .\PR\Reports\PaycheckBottom.sql

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
:r .\EM\013_SetDefaultLocationToActive.sql
:r .\EM\014_UpdateCustomerPricingLevel.sql
:r .\EM\015_UpdateEntityTariffType.sql
:r .\EM\016_MoveCustomerAccountStatusToNewTable.sql
:r .\EM\017_MoveSplitCategoryToNewTable.sql
:r .\EM\018_UpdateRoleId_ForEntityCredential.sql
:r .\EM\019_RemoveEmailToParentEntity.sql
:r .\EM\020_DefaultDataForEntityImportSchemaCSV.sql
:r .\EM\021_MoveCustomerMessageToEntity.sql
:r .\DB\5_FixUserIdDataEntry.sql ---used entry = 'Update DB UserId From Parent Entity' on tblEMEntityPreferences

:r .\EM\022_DefaultDataForContactTypeAndImport.sql
:r .\EM\023_RenameEntityContactEmailDistribution.sql
:r .\EM\024_delete_old_entity_table.sql
:r .\EM\025_UpdatePhoneNumberAndCreateBackup.sql
:r .\EM\028_MassCountryFormat.sql
:r .\EM\026_ImportPhoneNumbersToNewTable.sql
:r .\EM\027_MassUpdatePhoneNumber.sql
:r .\EM\029_FillInPhoneAndMobile.sql
:r .\EM\030-FixSalesperson.sql
:r .\EM\024_CleanOrphanCustomerGroup.sql
:r .\EM\031_UpdatePhoneAreaLength.sql
:r .\EM\032_MigrateVendorApprovalList.sql
:r .\EM\033_UpdateUserSecurityAdmin.sql
:r .\EM\034_EntityClassData.sql
:r .\EM\035_EncryptEFTAccountNumber.sql
:r .\EM\034_UpdateEntityEmail.sql
:r .\EM\036_MoveTheTermsPerType.sql
:r .\EM\037_DefaultDataLocationPayee.sql
--:r .\EM\038_UpdateEncryptionUsed.sql
:r .\EM\039_MoveDefaultTermsToVendorTerm.sql
:r .\EM\040_UpdatePasswordHistoryEncryption.sql
:r .\EM\Migrate_Data_1710_Moving_Format_UserSec_Ent.sql
:r .\EM\1730_Fix_SplitTypeEntry.sql
:r .\EM\DataMigration\1710_1720_CCSite_migration.sql
:r .\EM\DataMigration\1740_Moving_Farm_Info_to_Location.sql
:r .\EM\1740_Activate_Default_Contact.sql
:r .\EM\1810_Set_Default_Language.sql
:r .\EM\1810_Fix_Check_Payee_Name.sql

-- Quality Module
:r .\QM\1_MasterTables.sql

-- Store Module
:r .\ST\01_FileFieldMapping_PricebookSale.sql
:r .\ST\02_FileFieldMapping_PromotionItemList.sql
:r .\ST\03_FileFieldMapping_PromotionCombo.sql
:r .\ST\04_FileFieldMapping_PricebookMixMatch.sql
:r .\ST\05_FileFieldMapping_PricebookSendSapphire.sql
:r .\ST\06_Checkout_Radiant_ISM.sql
:r .\ST\07_Checkout_Radiant_MCM.sql
:r .\ST\08_Checkout_Radiant_FGM.sql
:r .\ST\09_Checkout_Radiant_MSM.sql
:r .\ST\10_Checkout_Commander_Translog.sql
:r .\ST\11_FileFieldMapping_Passport_ISM.sql
:r .\ST\12_FileFieldMapping_Passport_FGM.sql
:r .\ST\13_FileFieldMapping_Passport_MCM.sql
:r .\ST\14_FileFieldMapping_Passport_MSM.sql

-- Motor Fuel Tax
:r .\TF\DefaultData\01_TaxAuthority.sql
:r .\TF\DefaultData\02_TerminalControl.sql
:r .\TF\DefaultData\IN_Indiana.sql
:r .\TF\DefaultData\IL_Illinois.sql
:r .\TF\DefaultData\NE_Nebraska.sql
:r .\TF\DefaultData\MS_Mississippi.sql
:r .\TF\DefaultData\LA_Louisiana.sql
:r .\TF\DefaultData\MI_Michigan.sql
:r .\TF\DefaultData\NC_NorthCarolina.sql
:r .\TF\DefaultData\OR_Oregon.sql
:r .\TF\DefaultData\WA_Washington.sql
:r .\TF\DefaultData\OH_Ohio.sql
:r .\TF\DefaultData\NM_NewMexico.sql
:r .\TF\DefaultData\SC_SouthCarolina.sql
:r .\TF\DefaultData\PA_Pennsylvania.sql
:r .\TF\DefaultData\AfterUpgradeCleanup.sql

--Integration
:R .\IP\1_MasterTables.sql

-- Common
--:r .\Common\ErrorMessages.sql 

--Logistics
:R .\LG\1_MasterTables.sql

--RiskManagement
:R .\RM\01_MasterScript.sql
:R .\RM\02_DataFix.sql

--FRM
:r .\FRM\DefaultData\1_OfflineMenu.sql
:r .\FRM\1_OfflineGuid.sql

--CCR
:r .\CCR\SiteDataFix.sql
:r .\CCR\RemoveCCRObsoleteScreen.sql

--TR
:r .\TR\RemoveObsoleteScreen.sql
:r .\TR\CleanUp_TR_Data.sql

--Help Desk
:R .\HD\DefaultData\1_StatusData.sql
:R .\HD\DefaultData\2_Screen.sql
:R .\HD\HDEntryDataFix.sql
:R .\HD\CustomField.sql
:R .\HD\RemoveHDObsoleteScreen.sql
:R .\HD\RenameHDScreen.sql

--CRM
:R .\CRM\SplitCRMData.sql
:R .\CRM\RenameCRMScreen.sql

-- Card Fueling
:r .\CF\1_ImportMapping.sql
:r .\CF\2_DataFix.sql
:r .\CF\3_DataFixPriceAdjustment.sql

-- Vendor rebate
:r .\VR\1_UpdateColumnTableProgramItem.sql


--SM - this should always be the last to execute
	-- REMINDER: DO NOT ADD ANY SQL FILE AFTER THIS
:r .\SM\1830_ReIndexTables.sql
:r .\SM\1830_CreateReIndexMaintenancePlan.sql



print 'END POST DEPLOYMENT'
