/****** Object:  StoredProcedure [dbo].[uspSMaddarticle]    Script Date: 05/02/2018 3:35:20 PM ******/

CREATE  PROCEDURE [dbo].[uspSMRepAddArticle]
 @publication  As sysname
 AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
 BEGIN
		DECLARE @result int;
		DECLARE @ListOfArticles TABLE(strArticle VARCHAR(100));
		DECLARE @sql NVARCHAR(MAX) = N'';

		INSERT INTO @ListOfArticles
		VALUES
			--SM tables--	
				('tblSMApproval'),
			 --('tblSMApprovalAmendmentLog'),-- doesnt have primary key
				('tblSMApprovalHistory'),
				('tblSMApprovalList'),	

				('tblSMApproverConfiguration'),
				('tblSMApproverConfigurationApprovalFor'),
				('tblSMApproverConfigurationDetail'),
				('tblSMApproverConfigurationForApprovalGroup'),
				('tblSMApproverGroup'),

				('tblSMApproverGroupUserSecurity'),
				('tblSMAttachment'),
				('tblSMAttachmentDetailLink'),
				('tblSMAuditLog'),
				('tblSMBuildNumber'),

				('tblSMCalendarEntity'),
				('tblSMCalendars'),
				('tblSMCity'),
				('tblSMColumnDictionary'),
				('tblSMComboBoxValue'),

				('tblSMComment'),
				('tblSMCommentWatcher'),
				('tblSMCompanyGridLayout'),
				('tblSMCompanyLocation'),
				('tblSMCompanyLocationAccount'),
				
				('tblSMCompanyLocationPricingLevel'),		
				('tblSMCompanyLocationRequireApprovalFor'),	
				('tblSMCompanyLocationSubLocation'),	
				('tblSMCompanyLocationSubLocationCategory'),
				('tblSMCompanyPreference'),

				('tblSMCompanySetup'),		
				('tblSMConnectedUser'),		
				('tblSMContactMenu'),		
				('tblSMControl'),
				('tblSMControlStage'),
				
				('tblSMCountry'),
				('tblSMCurrency'),
				('tblSMCurrencyExchangeRate'),
				('tblSMCurrencyExchangeRateDetail'),
				('tblSMCurrencyExchangeRateType'),

				('tblSMCustomTabDetail'),
				('tblSMDefaultMenu'),
				('tblSMDocument'),
				('tblSMDocumentConfiguration'),
				('tblSMDocumentMaintenance'),

				('tblSMDocumentTypeFieldValue'),
				('tblSMEmail'),
				('tblSMEmailRecipient'),
				('tblSMEmailUpload'),
				('tblSMEntityMenuFavorite'),

				('tblSMEULA'),
				('tblSMEventInvitees'),
				('tblSMEvents'),
				('tblSMFieldValue'),
				('tblSMFileDownload'),

				('tblSMFileDownloadDetail'),
				('tblSMForBatchPosting'),
				('tblSMFreightTerms'),
				('tblSMGlobalSearch'),
				('tblSMGlobalSearchConfig'),

				('tblSMHomePanelDashboard'),
				('tblSMGridLayout'),

				('tblSMImportFileTable'),
				('tblSMLetter'),
				('tblSMLetterUpload'),
				('tblSMLanguage'),

				('tblSMLicenseType'),
				('tblSMLineOfBusiness'),
				('tblSMLoginDeviceToken'),
				('tblSMMappingDictionary'),
				('tblSMMasterMenu'),

				('tblSMMenu'),
				('tblSMModule'),
				('tblSMMultiCompany'),

				('tblSMMultiCurrency'),

				('tblSMOfflineMenu'),
				('tblSMPayment'),
				('tblSMPaymentMethod'),
				('tblSMPreferences'),
				('tblSMPricingLevel'),

				('tblSMPurchasingGroup'),
				('tblSMRecentlyViewed'),
				('tblSMRecurringHistory'),
				('tblSMRecurringTransaction'),
				('tblSMReminderList'),

				('tblSMRemoteServer'),
				('tblSMReportLabelDetail'),
				('tblSMReportLabels'),
				('tblSMReportTranslation'),
				('tblSMScreen'),

				('tblSMScreenLabel'),
				('tblSMScreenLabelStage'),
				('tblSMScreenReport'),
				('tblSMScreenStage'),
				('tblSMSearch'),

				('tblSMSearchField'),
				('tblSMSearchFilter'),
				('tblSMSecurityPolicy'),
				('tblSMShipVia'),
				('tblSMShipViaTruck'),

				--('tblSMShortcutKeys'), no Primary Keys

				('tblSMTableDictionary'),
				('tblSMTaxClass'),
				('tblSMTaxCode'),

				('tblSMTaxCodeRate'),
				('tblSMTaxGroup'),
				('tblSMTaxGroupCode'),
				('tblSMTaxGroupCodeCategoryExemption'),

				('tblSMTaxType'),
				('tblSMTerm'),
				('tblSMTransaction'),

				('tblSMTransactionLockHistory'),
				('tblSMTrustedComputer'),
				('tblSMTypeValue'),
				('tblSMUpload'),
				('tblSMUserLogin'),

				('tblSMUserPreference'),
				('tblSMUserRole'),
				('tblSMUserRoleCompanyLocationPermission'),
				('tblSMUserRoleControlPermission'),
				('tblSMUserRoleDashboardPermission'),

				('tblSMUserRoleFRPermission'),
				('tblSMUserRoleMenu'),
				('tblSMUserRoleReportPermission'),
				('tblSMUserRoleScreenPermission'),
				('tblSMUserRoleSubRole'),

				('tblSMUserSecurity'),
				('tblSMUserSecurityCompanyLocationRolePermission'),
				('tblSMUserSecurityControlPermission'),
				('tblSMUserSecurityDashboardPermission'),
				('tblSMUserSecurityFilterType'),

				('tblSMUserSecurityFRPermission'),
				('tblSMUserSecurityMenu'),
				('tblSMUserSecurityMenuFavorite'),
				('tblSMUserSecurityPasswordHistory'),
				('tblSMUserSecurityReportPermission'),

				('tblSMUserSecurityRequireApprovalFor'),
				('tblSMUserSecurityScreenPermission'),
				('tblSMXMLTagAttribute'),
				('tblSMZipCode'),
				('tblSMImportFileColumnDetail'),
				('tblSMImportFileHeader'),
				('tblSMImportFileRecordMarker'),
			
				('tblSMSignature'),



				---Entity Tables---
				('tblEMContactDetail'),
				('tblEMContactDetailType'),
				('tblEMEntity'),
				('tblEMEntityAreaOfInterest'),
				('tblEMEntityCardInformation'),

				('tblEMEntityClass'),
				('tblEMEntityContactNumber'),
				('tblEMEntityCredential'),
				('tblEMEntityCRMInformation'),

				('tblEMEntityEFTInformation'),
				---('tblEMEntityEFTInformationBackupForEncryption'), NO primary key
				('tblEMEntityFarm'),
				('tblEMEntityGroup'),
				('tblEMEntityGroupDetail'),

				('tblEMEntityImportError'),
				('tblEMEntityImportFile'),
				('tblEMEntityImportSchemaCSV'),
				('tblEMEntityLineOfBusiness'),
				('tblEMEntityLocation'),

				('tblEMEntityMessage'),
				('tblEMEntityMobileNumber'),
				('tblEMEntityNote'),
				('tblEMEntityPasswordHistory'),
				('tblEMEntityPhoneNumber'),

				('tblEMEntityPortalMenu'),
				('tblEMEntityPortalPermission'),
				('tblEMEntityPreferences'),
				('tblEMEntityRequireApprovalFor'),
				('tblEMEntitySignature'),

				('tblEMEntitySMTPInformation'),
				('tblEMEntitySplit'),
				('tblEMEntitySplitDetail'),
				('tblEMEntitySplitExceptionCategory'),
				('tblEMEntityTariff'),

				('tblEMEntityTariffCategory'),
				('tblEMEntityTariffFuelSurcharge'),
				('tblEMEntityTariffMileage'),
				('tblEMEntityTariffType'),

				('tblEMEntityToContact'),
				('tblEMEntityToRole'),
				('tblEMEntityType'),

				---GL tables---
				('tblGLAccount'),
				('tblGLAccountCategory'),
				('tblGLAccountCategoryGroup'),
				('tblGLAccountDefault'),
				('tblGLAccountDefaultDetail'),

				('tblGLAccountGroup'),
				('tblGLAccountRange'),
				('tblGLAccountReallocation'),
				('tblGLAccountReallocationDetail'),
				('tblGLAccountSegment'),

				('tblGLAccountSegmentMapping'),
				('tblGLAccountStructure'),
				('tblGLAccountSystem'),
				('tblGLAccountTemplate'),
				('tblGLAccountTemplateDetail'),

				('tblGLAccountUnit'),
				('tblGLCOACrossReference'),
				('tblGLCOATemplate'),
				('tblGLCOATemplateDetail'),
				('tblGLCompanyPreferenceOption'),

				('tblGLCrossReferenceMapping'),
				('tblGLCurrentFiscalYear'),
				('tblGLDeletedAccount'),
				('tblGLFiscalYear'),
				('tblGLFiscalYearPeriod'),

				('tblGLModuleList'),
				---('tblGLOriginAccounts'),-- NO primary keys
				('tblGLReconciledAccount'),

				---Customer Table---
				('tblARCompanyPreference'),
				('tblARCustomer'),
				('tblARCustomerAccountStatus'),
				('tblARCustomerApplicatorLicense'),
				('tblARCustomerBudget'),

				('tblARCustomerBuyback'),
				('tblARCustomerCardFueling'),
				('tblARCustomerCategoryPrice'),
				('tblARCustomerCommission'),
				('tblARCustomerCompetitor'),

				('tblARCustomerContract'),
				('tblARCustomerContractDetail'),
				('tblARCustomerFailedImport'),
				('tblARCustomerFarm'),
				('tblARCustomerFieldXRef'),

				('tblARCustomerFreightXRef'),
				('tblARCustomerGroup'),
				('tblARCustomerGroupDetail'),
				('tblARCustomerLicenseInformation'),
				('tblARCustomerLicenseModule'),

				('tblARCustomerLineOfBusiness'),
				('tblARCustomerMasterLicense'),
				('tblARCustomerMessage'),
				('tblARCustomerPortalMenu'),
				('tblARCustomerProductVersion'),

				('tblARCustomerQuote'),
				('tblARCustomerRackQuoteCategory'),
				('tblARCustomerRackQuoteHeader'),
				('tblARCustomerRackQuoteVendor'),

				('tblARCustomerSpecialPrice'),
				('tblARCustomerSplit'),
				('tblARCustomerSplitDetail'),
				('tblARCustomerTaxingTaxException'),

				('tblARSalesperson'),
				('tblARServiceCharge'),

				---Vendor tables---

				('tblAPVendor'),
				('tblAPVendorLien'),
				('tblAPVendorPricing'),
				('tblAPVendorSpecialTax'),
				('tblAPVendorTaxException'),

				('tblAPVendorTerm'),

				---Others---
				('tblTRSupplyPoint'),
				('tblTFTerminalControlNumber'),
				('tblTFTaxAuthority'),

		

				('tblPREmployee'),
				('tblPREmployeeRank'),
				('tblPRWorkersCompensation'),
				
				---Inventory tables ----
				('tblICBrand'),
				('tblICCategory'),
				('tblICCategoryAccount'),
				('tblICCategoryLocation'),
				('tblICCategoryTax'),
				('tblICCategoryVendor'),
				('tblICCommodity'),
				('tblICCommodityGroup'),
				('tblICCommodityUnitMeasure'),
				('tblICCountGroup'),
				('tblICFobPoint'),
				('tblICInventoryActualCost'),
				('tblICInventoryActualCostAdjustmentLog'),
				('tblICInventoryActualCostOut'),
				('tblICInventoryAdjustment'),
				('tblICInventoryAdjustmentDetail'),
				('tblICInventoryCount'),
				('tblICInventoryCountDetail'),
				('tblICInventoryFIFO'),
				('tblICInventoryFIFOCostAdjustmentLog'),
				('tblICInventoryFIFOOut'),
				('tblICInventoryFIFORevalueOutStock'),
				('tblICInventoryFIFOStorage'),
				('tblICInventoryFIFOStorageOut'),
				('tblICInventoryGLAccountUsedOnPostLog'),
				('tblICInventoryLIFO'),
				('tblICInventoryLIFOCostAdjustmentLog'),
				('tblICInventoryLIFOOut'),
				('tblICInventoryLIFOStorage'),
				('tblICInventoryLIFOStorageOut'),
				('tblICInventoryLot'),
				('tblICInventoryLotCostAdjustmentLog'),
				('tblICInventoryLotOut'),
				('tblICInventoryLotStorage'),
				('tblICInventoryLotStorageOut'),
				('tblICInventoryLotTransaction'),
				('tblICInventoryLotTransactionStorage'),
				('tblICInventoryReceipt'),
				('tblICInventoryReceiptCharge'),
				('tblICInventoryReceiptChargePerItem'),
				('tblICInventoryReceiptChargeTax'),
				('tblICInventoryReceiptItem'),
				('tblICInventoryReceiptItemAllocatedCharge'),
				('tblICInventoryReceiptItemLot'),
				('tblICInventoryReceiptItemTax'),
				('tblICInventoryReturned'),
				('tblICInventoryShipment'),
				('tblICInventoryShipmentCharge'),
				('tblICBackup'),
				('tblICInventoryShipmentChargePerItem'),
				('tblICBackupDetailInventoryTransaction'),
				('tblICRinFuel'),
				('tblICBackupDetailInventoryTransactionStorage'),
				('tblICInventoryShipmentItem'),
				('tblICRinFuelCategory'),
				('tblICInventoryShipmentItemAllocatedCharge'),
				('tblICInventoryShipmentItemLot'),
				('tblICBackupDetailLot'),
				('tblICInventoryStockSummary'),
				('tblICInventoryTransaction'),
				('tblICBackupDetailTransactionDetailLog'),
				('tblICRinProcess'),
				('tblICInventoryTransactionPostingIntegration'),
				('tblICImportLog'),
				('tblICSku'),
				('tblICImportLogDetail'),
				('tblICAdjustInventoryTerms'),
				('tblICInventoryTransactionStorage'),
				('tblICItemStockType'),
				('tblICStorageLocationCategory'),
				('tblICInventoryTransactionType'),
				('tblICInventoryTransactionWithNoCounterAccountCategory'),
				('tblICStorageLocationContainer'),
				('tblICStorageLocationMeasurement'),
				('tblICStorageLocationSku'),
				('tblICInventoryTransfer'),
				('tblICInventoryTransferDetail'),
				('tblICInventoryTransferNote'),
				('tblICStatus'),
				('tblICItem'),
				('tblICCategoryUOM'),
				('tblICItemAccount'),
				('tblICItemAssembly'),
				('tblICItemBundle'),
				('tblICItemCertification'),
				('tblICItemCommodityCost'),
				('tblICItemContract'),
				('tblICItemContractDocument'),
				('tblICItemCustomerXref'),
				('tblICItemFactory'),
				('tblICItemFactoryManufacturingCell'),
				('tblICItemKit'),
				('tblICItemKitDetail'),
				('tblICItemLicense'),
				('tblICBuildAssembly'),
				('tblICStorageMeasurementReadingConversion'),
				('tblICItemLocation'),
				('tblICBuildAssemblyDetail'),
				('tblICItemManufacturingUOM'),
				('tblICCatalog'),
				('tblICCompanyPreference'),
				('tblICItemMotorFuelTax'),
				('tblICItemNote'),
				('tblICItemOwner'),
				('tblICItemPOSCategory'),
				('tblICItemPOSSLA'),
				('tblICItemPricing'),
				('tblICItemPricingLevel'),
				('tblICItemSpecialPricing'),
				('tblICItemStock'),
				('tblICItemStockDetail'),
				('tblICItemStockPath'),
				('tblICItemStockUOM'),
				('tblICItemSubLocation'),
				('tblICItemSubstitution'),
				('tblICItemSubstitutionDetail'),
				('tblICM2MComputation'),
				('tblICItemUOM'),
				('tblICItemUPC'),
				('tblICCertificationCommodity'),
				('tblICInventoryCostAdjustmentType'),
				('tblICItemVendorXref'),
				('tblICLockedStorageLocation'),
				('tblICLockedSubLocation'),
				('tblICLot'),
				('tblICLotStatus'),
				('tblICParentLot'),
				('tblICPostResult'),
				('tblICContainer'),
				('tblICContainerType'),
				('tblICCostingMethod'),
				('tblICRebuildValuationGLSnapshot'),
				('tblICRinFeedStockUOM'),
				('tblICSearchReceiptVoucher'),
				('tblICSearchShipmentInvoice'),
				('tblICEquipmentLength'),
				('tblICFixLog'),
				('tblICStockReservation'),
				('tblICLineOfBusiness'),
				('tblICFuelTaxClass'),
				('tblICInventoryReceiptInspection'),
				('tblICStorageLocation'),
				('tblICStorageMeasurementReading'),
				('tblICStorageUnitType'),
				('tblICFuelTaxClassProductCode'),
				('tblICCertification'),
				('tblICFuelType'),
				('tblICCommodityProductLine'),
				('tblICManufacturer'),
				('tblICCommodityAttribute'),
				('tblICMaterialNMFC'),
				('tblICInventoryAdjustmentNote'),
				('tblICMeasurement'),
				('tblICDocument'),
				('tblICTag'),
				('tblICTransactionDetailLog'),
				('tblICUnitMeasure'),
				('tblICReadingPoint'),
				('tblICReasonCode'),
				('tblICReasonCodeWorkCenter'),
				('tblICRestriction'),
				('tblICRinFeedStock'),
				('tblICUnitMeasureConversion')


			--Create Query for adding articles
					SELECT @sql += N'exec sp_addarticle '
					+ N'@publication = '''+@publication+N''','
					+ N'@article = '''+ strArticle + N''','
					+ N'@source_owner = ''dbo'', '
					+ N'@source_object = ''' + strArticle + N''', '	
					+ N'@type = ''logbased'', ' 
					+ N'@description = '''', ' 
					+ N'@creation_script = '''', '
					+ N'@pre_creation_cmd = ''truncate'',  ' 
					+ N'@schema_option = 0x000000000803509F, '
					+ N'@identityrangemanagementoption = ''manual'', '							
					+ N'@destination_table = ''' + strArticle + N''', '	
					+ N'@destination_owner = ''dbo'', ' 
					+ N'@force_invalidate_snapshot = 1, ' 
					+ N'@status = 24, '
					+ N'@vertical_partition = ''false'', '
					+ N'@ins_cmd = ''CALL [sp_MSins_dbo'+strArticle+N']'', ' 
					+ N'@del_cmd = ''CALL [sp_MSdel_dbo'+strArticle+N']'',  ' 
					+ N'@upd_cmd = ''SCALL [sp_MSupd_dbo'+strArticle+N']'';'								
					FROM sys.tables as systables
					INNER JOIN @ListOfArticles as articles
					ON systables.name = articles.strArticle
					WHERE is_replicated = 0;

				--Executed Created Query
				EXEC @result = sp_executesql @sql;
				UPDATE tblSMReplicationSPResult SET result = 0;	
End

