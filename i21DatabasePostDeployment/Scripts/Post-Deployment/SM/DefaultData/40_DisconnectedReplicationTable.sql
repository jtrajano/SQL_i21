
PRINT N'DISCONNECTED REPLICATION TABLE '

DELETE FROM tblSMDisconReplicationArticle
DECLARE @sql nvarchar(max) = N'';
SET @sql = N'DBCC CHECKIDENT(''tblSMDisconReplicationArticle'',RESEED, 0); ' 

EXECUTE sp_executesql @sql;


 IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMDisconReplicationArticle )
	BEGIN
		DECLARE @query nvarchar(max) = N'INSERT INTO tblSMDisconReplicationArticle (strTableName) ' +
										'select t.name as TableName ' +
										'from ' +
											'sys.schemas s ' +
											'inner join sys.tables t   on s.schema_id=t.schema_id ' +
											'inner join sys.indexes i  on t.object_id=i.object_id ' +
											'inner join sys.index_columns ic on i.object_id=ic.object_id ' + 
											'and i.index_id=ic.index_id ' +
											'inner join sys.columns tc on ic.object_id=tc.object_id ' +
																	 'and ic.column_id=tc.column_id ' +
	
										'where i.is_primary_key=1 and tc.is_identity = 1 ' +
										'and t.name like ''tbl%'' AND t.name NOT IN ' + 
									'(''tblSMStartingNumber'','+
									 '''tblGLTempCOASegment'','+
									 '''tblSMCompanySetup'','+
									 '''tblSMUserLogin'','+
									 '''tblSMConnectedUser'','+
									 '''tblSMMultiCurrency'','+
									 '''tblMBILCompanyPreference'','+
									 '''tblPATCompanyPreference'','+
									 '''tblSMCompanyPreference'','+
									 '''tblTFCompanyPreference'','+
									 '''tblRKCompanyPreference'','+
									 '''tblQMCompanyPreference'','+
									 '''tblNRCompanyPreference'','+
									 '''tblIPCompanyPreference'','+
									 '''tblGRCompanyPreference'','+
									 '''tblETCompanyPreference'','+
									 '''tblCTCompanyPreference'','+
									 '''tblCFCompanyPreference'','+
									 '''tblARCompanyPreference'','+
									 '''tblAPCompanyPreference'','+
									 '''tblWHCompanyPreference'','+
									 '''tblPRCompanyPreference'','+
									 '''tblMFCompanyPreference'','+
									 '''tblLGCompanyPreference'','+
									 '''tblICCompanyPreference'','+
									 '''tblTRCompanyPreference'')' ;
	--DECLARE @query nvarchar(max) = N'INSERT INTO tblSMDisconReplicationArticle (strTableName) ' +
	--								'SELECT t.name FROM sys.tables AS t INNER JOIN sys.schemas AS s on t.[schema_id] = s.[schema_id] WHERE t.name LIKE ''tbl%'' AND t.name NOT IN ' +
	--								'(''tblSMStartingNumber'','+
	--								 '''tblGLTempCOASegment'','+
	--								 '''tblSMCompanySetup'','+
	--								 '''tblSMUserLogin'','+
	--								 '''tblSMConnectedUser'','+
	--								 '''tblSMMultiCurrency'','+
	--								 '''tblMBILCompanyPreference'','+
	--								 '''tblPATCompanyPreference'','+
	--								 '''tblSMCompanyPreference'','+
	--								 '''tblTFCompanyPreference'','+
	--								 '''tblRKCompanyPreference'','+
	--								 '''tblQMCompanyPreference'','+
	--								 '''tblNRCompanyPreference'','+
	--								 '''tblIPCompanyPreference'','+
	--								 '''tblGRCompanyPreference'','+
	--								 '''tblETCompanyPreference'','+
	--								 '''tblCTCompanyPreference'','+
	--								 '''tblCFCompanyPreference'','+
	--								 '''tblARCompanyPreference'','+
	--								 '''tblAPCompanyPreference'','+
	--								 '''tblWHCompanyPreference'','+
	--								 '''tblPRCompanyPreference'','+
	--								 '''tblMFCompanyPreference'','+
	--								 '''tblLGCompanyPreference'','+
	--								 '''tblICCompanyPreference'','+
	--								 '''tblTRCompanyPreference'')'

 
									


	exec sp_executesql @query

		--INSERT INTO tblSMDisconReplicationArticle (strTableName)
		
			--VALUES
				--('tblTRSupplyPoint'),
				--('tblARAccountStatus'),
				--('tblSMLicenseType'),
				--('tblDBPanelOwner'),
				--('tblEMContactDetail'),
				--('tblEMContactDetailType'),
				--('tblEMEntity'),
				--('tblEMEntityAreaOfInterest'),
				--('tblEMEntityCardInformation'),
				--('tblEMEntityClass'),
				--('tblEMEntityContactNumber'),
				--('tblEMEntityCredential'),
				--('tblEMEntityCRMInformation'),
				--('tblEMEntityEFTInformation'),
				--('tblEMEntityFarm'),
				--('tblEMEntityGroup'),
				--('tblEMEntityGroupDetail'),
				--('tblEMEntityImportError'),
				--('tblEMEntityImportFile'),
				--('tblEMEntityImportSchemaCSV'),
				--('tblEMEntityLineOfBusiness'),
				--('tblEMEntityLocation'),
				--('tblEMEntityMessage'),
				--('tblEMEntityMobileNumber'),
				--('tblEMEntityNote'),
				--('tblEMEntityPasswordHistory'),
				--('tblEMEntityPhoneNumber'),
				--('tblEMEntityPortalMenu'),
				--('tblEMEntityPortalPermission'),
				--('tblEMEntityPreferences'),
				--('tblEMEntityRequireApprovalFor'),
				--('tblEMEntitySignature'),
				--('tblEMEntitySMTPInformation'),
				--('tblEMEntitySplit'),
				--('tblEMEntitySplitDetail'),
				--('tblEMEntitySplitExceptionCategory'),
				--('tblEMEntityTariff'),
				--('tblEMEntityTariffCategory'),
				--('tblEMEntityTariffFuelSurcharge'),
				--('tblEMEntityTariffMileage'),
				--('tblEMEntityTariffType'),
				--('tblEMEntityToContact'),
				--('tblEMEntityToRole'),
				--('tblEMEntityType'),
				--('tblAPCompanyPreference'),
				--('tblARCompanyPreference'),
				--('tblCTCompanyPreference'),
				--('tblICCompanyPreference'),
				--('tblLGCompanyPreference'),
				--('tblRKCompanyPreference'),
				--('tblQMCompanyPreference'),
				--('tblSMMultiCompany'),
				--('tblSMSignature'),
				--('tblSMLanguage'),
				--('tblHDTicketType'),
				--('tblSMApprovalList'),
				--('tblSMReportLabelDetail'),
				--('tblSMReportLabels '),
				--('tblSMReportTranslation'),
				--('tblSMSecurityPolicy'),
				--('tblSMCustomLabel'),
				--('tblSMControl'),
				--('tblSMControlStage'),
				--('tblSMEntityMenuFavorite'),
				--('tblSMScreen'),
				--('tblSMScreenStage'),
				--('tblSMUserPreference'),
				--('tblSMUserRole'),
				--('tblSMUserRoleCompanyLocationPermission'),
				--('tblSMUserRoleControlPermission'),
				--('tblSMUserRoleDashboardPermission'),
				--('tblSMUserRoleFRPermission'),
				--('tblSMMasterMenu'),
				--('tblSMContactMenu'),
				--('tblSMUserRoleMenu'),
				--('tblSMUserRoleReportPermission'),
				--('tblSMUserRoleScreenPermission'),
				--('tblSMUserRoleSubRole'),
				--('tblSMUserSecurity'),
				--('tblSMUserSecurityCompanyLocationRolePermission'),
				--('tblSMUserSecurityControlPermission'),
				--('tblSMUserSecurityDashboardPermission'),
				--('tblSMUserSecurityFilterType'),
				--('tblSMUserSecurityFRPermission'),
				--('tblSMUserSecurityMenu'),
				--('tblSMUserSecurityPasswordHistory'),
				--('tblSMUserSecurityReportPermission'),
				--('tblSMUserSecurityRequireApprovalFor'),
				--('tblSMUserSecurityScreenPermission'),
				--('tblSMCity'),
				--('tblSMCompanyLocation'),
				--('tblSMCompanyLocationAccount'),
				--('tblSMCompanyLocationPricingLevel'),
				--('tblSMCompanyLocationRequireApprovalFor'),
				--('tblSMCompanyLocationSubLocation'),
				--('tblSMCompanyLocationSubLocationCategory'),
				--('tblSMCountry'),
				--('tblSMCurrency '),
				--('tblSMCurrencyExchangeRate '),
				--('tblSMCurrencyExchangeRateDetail'),
				--('tblSMCurrencyExchangeRateType '),
				--('tblSMFreightTerms'),
				--('tblSMLineOfBusiness'),
				--('tblSMPaymentMethod'),
				--('tblSMShipVia'),
				--('tblSMShipViaTruck'),
				--('tblSMTerm '),
				--('tblSMTaxClass'),
				--('tblSMTaxCode'),
				--('tblSMTaxCodeRate'),
				--('tblSMTaxGroup'),
				--('tblSMTaxGroupCode'),
				--('tblSMTaxGroupCodeCategoryExemption'),
				--('tblSMTaxType'),
				--('tblGLAccountSegment'),
				--('tblGLAccountSystem'),
				--('tblGLAccountSegmentMapping'),
				--('tblGLAccount'),
				--('tblGLAccountCategory'),
				--('tblGLAccountStructure'),
				--('tblGLSegmentType'),
				--('tblGLAccountGroup'),
				--('tblGLAccountRange'),
				--('tblGLAccountReallocation'),
				--('tblGLAccountTemplate'),
				--('tblGLAccountTemplateDetail'),
				--('tblGLAccountUnit'),
				--('tblGLCOACrossReference'),
				--('tblGLCrossReferenceMapping'),
				--('tblGLCOATemplate'),
				--('tblGLCOATemplateDetail'),
				--('tblGLCompanyPreferenceOption'),
				--('tblGLCurrentFiscalYear'),
				--('tblGLDeletedAccount'),
				--('tblGLFiscalYear'),
				--('tblGLFiscalYearPeriod'),
				--('tblGLAccountAdjustmentLog'),
				--('tblCMBank'),
				--('tblCMBankAccount'),
				--('tblCMBankFileFormat'),
				--('tblICEdiMapTemplateSegment'),
				--('tblICEdiMapTemplateSegmentDetail'),
				--('tblICCategory'),
				--('tblICCategoryAccount'),
				--('tblICCategoryLocation'),
				--('tblICCategoryTax'),
				--('tblICCategoryUOM'),
				--('tblICCategoryVendor'),
				--('tblICCommodity'),
				--('tblICCommodityAccount'),
				--('tblICCommodityAttribute'),
				--('tblICCommodityGroup'),
				--('tblICCommodityProductLine'),
				--('tblICCommodityUnitMeasure'),
				--('tblICUnitMeasure'),
				--('tblICUnitMeasureConversion'),
				--('tblICItem'),
				--('tblICItemAccount'),
				--('tblICItemAssembly'),
				--('tblICItemBundle'),
				--('tblICItemCertification'),
				--('tblICItemCommodityCost'),
				--('tblICItemContract'),
				--('tblICItemContractDocument'),
				--('tblICItemCustomerXref'),
				--('tblICItemFactory'),
				--('tblICItemFactoryManufacturingCell'),
				--('tblICItemKit'),
				--('tblICItemKitDetail'),
				--('tblICItemLicense'),
				--('tblICItemLocation'),
				--('tblICItemManufacturingUOM'),
				--('tblICItemMotorFuelTax'),
				--('tblICItemNote'),
				--('tblICItemOwner'),
				--('tblICItemPOSCategory'),
				--('tblICItemPOSSLA'),
				--('tblICItemPricing'),
				--('tblICItemPricingLevel'),
				--('tblICItemSpecialPricing'),
				--('tblICItemStockType'),
				--('tblICItemSubLocation'),
				--('tblICItemSubstitution'),
				--('tblICItemSubstitutionDetail'),
				--('tblICItemUOM'),
				--('tblICItemUPC'),
				--('tblICItemVendorXref'),
				--('tblICStorageUnitType'),
				--('tblICStorageLocation'),
				--('tblAPVendor'),
				--('tblAPVendorLien'),
				--('tblAPVendorPricing'),
				--('tblAPVendorSpecialTax'),
				--('tblAPVendorTaxException'),
				--('tblAPVendorTerm'),
				--('tblARCustomer'),
				--('tblARCustomerAccountStatus'),
				--('tblARCustomerApplicatorLicense'),
				--('tblARCustomerBudget '),
				--('tblARCustomerBuyback '),
				--('tblARCustomerCardFueling '),
				--('tblARCustomerCategoryPrice '),
				--('tblARCustomerCommission '),
				--('tblARCustomerCompetitor '),
				--('tblARCustomerContract '),
				--('tblARCustomerContractDetail '),
				--('tblARCustomerFailedImport '),
				--('tblARCustomerFarm '),
				--('tblARCustomerFieldXRef '),
				--('tblARCustomerFreightXRef '),
				--('tblARCustomerGroup '),
				--('tblARCustomerGroupDetail '),
				--('tblARCustomerLicenseInformation '),
				--('tblARCustomerLicenseModule '),
				--('tblARCustomerLineOfBusiness '),
				--('tblARCustomerMasterLicense'),
				--('tblARCustomerMessage '),
				--('tblARCustomerPortalMenu '),
				--('tblARCustomerProductVersion '),
				--('tblARCustomerQuote '),
				--('tblARCustomerRackQuoteCategory '),
				--('tblARCustomerRackQuoteHeader '),
				--('tblARCustomerRackQuoteVendor '),
				--('tblARCustomerSpecialPrice '),
				--('tblARCustomerSplit '),
				--('tblARCustomerSplitDetail '),
				--('tblARCustomerTaxingTaxException '),
				--('tblARSalesperson'),
				--('tblCTAOP'),
				--('tblCTAOPDetail'),
				--('tblCTAssociation'),
				--('tblICCertification'),
				--('tblCTCondition'),
				--('tblCTPosition'),
				--('tblICDocument'),
				--('tblCTContractBasis'),
				--('tblCTWeightGrade'),
				--('tblPREmployee'),
				--('tblPREmployeeRank'),
				--('tblPRWorkersCompensation'),
				--('tblPREmployeeLocationDistribution'),
				--('tblRKBrokerageAccount'),
				--('tblRKTradersbyBrokersAccountMapping'),
				--('tblRKBrokerageCommission'),
				--('tblRKFutureMarket'),
				--('tblRKCommodityMarketMapping'),
				--('tblRKFuturesMonth'),
				--('tblRKOptionsMonth'),
				--('tblRKFuturesSettlementPrice'),
				--('tblRKFutSettlementPriceMarketMap'),
				--('tblRKOptSettlementPriceMarketMap'),
				--('tblRKM2MBasis'),
				--('tblRKM2MBasisDetail'),
				--('tblLGContainerType'),
				--('tblLGContainerTypeCommodityQty'),
				--('tblLGEquipmentType'),
				--('tblLGInsurancePremiumFactor'),
				--('tblLGInsurancePremiumFactorDetail'),
				--('tblLGReasonCode'),
				--('tblLGShippingLineServiceContract'),
				--('tblLGShippingLineServiceContractDetail'),
				--('tblLGShippingMode'),
				--('tblLGWarehouseRateMatrixDetail'),
				--('tblLGWarehouseRateMatrixHeader'),
				--('tblQMAttribute'),
				--('tblQMAttributeDataType'),
				--('tblQMList'),
				--('tblQMListItem'),
				--('tblQMSampleType'),
				--('tblQMSampleTypeDetail'),
				--('tblQMSampleTypeUserRole'),
				--('tblQMSampleLabel'),
				--('tblQMProperty'),
				--('tblQMPropertyValidityPeriod'),
				--('tblQMConditionalProperty'),
				--('tblQMTest'),
				--('tblQMTestMethod'),
				--('tblQMTestProperty'),
				--('tblQMProduct'),
				--('tblQMProductControlPoint'),
				--('tblQMProductTest'),
				--('tblQMProductProperty'),
				--('tblQMProductPropertyValidityPeriod'),
				--('tblQMConditionalProductProperty'),
				--('tblQMProductPropertyFormulaProperty'),
				--('tblSCScaleSetup'),
				--('tblSCDistributionOption'),
				--('tblSCDeliverySheetImportingTemplate'),
				--('tblSCListTicketTypes'),
				--('tblSCTicketEmailOption'),
				--('tblSCTicketFormat'),
				--('tblSCTicketPrintOption'),
				--('tblSCScaleDevice'),
				--('tblSCTicketPool'),
				--('tblSCTicketType'),
				--('tblSCDeliverySheetImportingTemplateDetail'),
				--('tblSCScaleOperator'),
				--('tblSCTruckDriverReference'),
				--('tblSCLastScaleSetup'),
				--('tblSCUncompletedTicketAlert'),
				--('tblGRDiscountId'),
				--('tblGRStorageType'),
				--('tblGRStorageScheduleRule'),
				--('tblGRDiscountLocationUse'),
				--('tblGRDiscountCrossReference'),
				--('tblGRDiscountSchedule'),
				--('tblGRDiscountScheduleCode'),
				--('tblGRDiscountScheduleLine'),
				--('tblMBILInvoice'),
				--('tblMBILInvoiceItem'),
				--('tblMBILInvoiceSite'),
				--('tblMBILInvoiceTaxCode'),
				--('tblMFAttribute'),
				--('tblMFBlendValidation'),
				--('tblMFBuyingGroup'),
				--('tblMFCompanyPreference'),
				--('tblMFDepartment'),
				--('tblMFHaldheldUserMenuItemMap'),
				--('tblMFHandheldMenuItem'),
				--('tblMFHolidayCalendar'),
				--('tblMFInventoryShipmentRestrictionType'),
				--('tblMFItemChangeMap'),
				--('tblMFItemContamination'),
				--('tblMFItemContaminationDetail'),
				--('tblMFItemGradeDiff'),
				--('tblMFItemGroup'),
				--('tblMFItemMachine'),
				--('tblMFItemOwner'),
				--('tblMFItemSubstitution'),
				--('tblMFItemSubstitutionDetail'),
				--('tblMFItemSubstitutionRecipe'),
				--('tblMFItemSubstitutionRecipeDetail'),
				--('tblMFLotStatusException'),
				--('tblMFMachine'),
				--('tblMFMachineMeasurement'),
				--('tblMFMachinePackType'),
				--('tblMFManufacturingCell'),
				--('tblMFManufacturingCellPackType'),
				--('tblMFManufacturingProcess'),
				--('tblMFManufacturingProcessAttribute'),
				--('tblMFManufacturingProcessMachine'),
				--('tblMFManufacturingProcessRunDuration'),
				--('tblMFMeasurement'),
				--('tblMFNutrient'),
				--('tblMFOneLinePrint'),
				--('tblMFOrderDirection'),
				--('tblMFPackType'),
				--('tblMFPackTypeDetail'),
				--('tblMFParentLotNumberPattern'),
				--('tblMFPattern'),
				--('tblMFPatternByCategory'),
				--('tblMFPatternCode'),
				--('tblMFPatternDetail'),
				--('tblMFPatternSequence'),
				--('tblMFReasonCode'),
				--('tblMFReasonCodeDetail'),
				--('tblMFRecipe'),
				--('tblMFRecipeAlertLog'),
				--('tblMFRecipeCategory'),
				--('tblMFRecipeGuide'),
				--('tblMFRecipeGuideNutrient'),
				--('tblMFRecipeItem'),
				--('tblMFRecipeItemStage'),
				--('tblMFRecipeStage'),
				--('tblMFRecipeSubstituteItem'),
				--('tblMFRecipeSubstituteItemStage'),
				--('tblMFReportCategory'),
				--('tblMFReportCategoryByCustomer'),
				--('tblMFReportLabel'),
				--('tblMFReportLidlUCCPalletLabel'),
				--('tblMFScheduleChangeoverFactor'),
				--('tblMFScheduleChangeoverFactorDetail'),
				--('tblMFScheduleConstraint'),
				--('tblMFScheduleConstraintDetail'),
				--('tblMFScheduleGroup'),
				--('tblMFScheduleGroupDetail'),
				--('tblMFScheduleRule'),
				--('tblMFShift'),
				--('tblMFShiftBreakType'),
				--('tblMFShiftDetail'),
				--('tblMFStorageLocationRestrictionTypeLotStatus'),
				--('tblMFUserPrinterMap'),
				--('tblMFUserRoleEventMap'),
				--('tblMFYield'),
				--('tblMFYieldDetail'),
				--('tblCTContractCost'),
				--('tblCTContractDetail'),
				--('tblCTContractHeader'),
				--('tblCTContractDocument'),
				--('tblCTContractProducer'),
				--('tblCTContractCondition'),
				--('tblCTContractCertification'),
				--('tblCTPriceContract'),
				--('tblCTPriceFixation'),
				--('tblCTPriceFixationDetail'),
				--('tblLGGenerateLoad'),
				--('tblLGLoad'),
				--('tblLGLoadContainer'),
				--('tblLGLoadContainerCost'),
				--('tblLGLoadCost'),
				--('tblLGLoadDetail'),
				--('tblLGLoadDetailContainerCost'),
				--('tblLGLoadDetailContainerLink'),
				--('tblLGLoadDetailLot'),
				--('tblLGLoadNotifyParties'),
				--('tblLGLoadStorageCost'),
				--('tblLGLoadWarehouse'),
				--('tblLGLoadWarehouseContainer'),
				--('tblLGAllocationHeader'),
				--('tblLGAllocationDetail'),
				--('tblLGLoadDocuments'),
				--('tblLGWeightClaim'),
				--('tblLGWeightClaimDetail'),
				--('tblICInventoryReceipt'),
				--('tblICManufacturer'),
				--('tblICTag'),
				--('tblICBrand'),
				--('tblICInventoryReceiptCharge'),
				--('tblICInventoryReceiptChargePerItem'),
				--('tblICInventoryReceiptChargeTax'),
				--('tblICInventoryReceiptInspection'),
				--('tblICInventoryReceiptItem'),
				--('tblICInventoryReceiptItemAllocatedCharge'),
				--('tblICInventoryReceiptItemLot'),
				--('tblICInventoryReceiptItemTax'),
				--('tblICInventoryShipment'),
				--('tblICInventoryShipmentCharge'),
				--('tblICInventoryShipmentChargePerItem'),
				--('tblICInventoryShipmentChargeTax'),
				--('tblICInventoryShipmentItem'),
				--('tblICInventoryShipmentItemAllocatedCharge'),
				--('tblICInventoryShipmentItemLot'),
				--('tblICInventoryTransfer'),
				--('tblICInventoryTransferDetail'),
				--('tblICInventoryAdjustment'),
				--('tblICInventoryAdjustmentDetail'),
				--('tblICInventoryCount'),
				--('tblICInventoryCountDetail'),
				--('tblICInventoryActualCost'),
				--('tblICInventoryActualCostAdjustmentLog'),
				--('tblICInventoryActualCostOut'),
				--('tblICInventoryCostAdjustmentType'),
				--('tblICInventoryFIFO'),
				--('tblICInventoryFIFOCostAdjustmentLog'),
				--('tblICInventoryFIFOOut'),
				--('tblICInventoryFIFORevalueOutStock'),
				--('tblICInventoryFIFOStorage'),
				--('tblICInventoryFIFOStorageOut'),
				--('tblICInventoryGLAccountUsedOnPostLog'),
				--('tblICInventoryLIFO'),
				--('tblICInventoryLIFOCostAdjustmentLog'),
				--('tblICInventoryLIFOOut'),
				--('tblICInventoryLIFOStorage'),
				--('tblICInventoryLIFOStorageOut'),
				--('tblICInventoryLot'),
				--('tblICInventoryLotCostAdjustmentLog'),
				--('tblICInventoryLotOut'),
				--('tblICInventoryLotStorage'),
				--('tblICInventoryLotStorageOut'),
				--('tblICInventoryLotTransaction'),
				--('tblICInventoryLotTransactionStorage'),
				--('tblICInventoryTransaction'),
				--('tblICInventoryTransactionStorage'),
				--('tblICItemStock'),
				--('tblICItemStockUOM'),
				--('tblICItemStockDetail'),
				--('tblICStockReservation'),
				--('tblICLot'),
				--('tblICLotStatus'),
				--('tblICParentLot'),
				--('tblAPBill'),
				--('tblAPBillBatch'),
				--('tblAPBillDetail'),
				--('tblAPBillDetailTax'),
				--('tblARInvoice'),
				--('tblARInvoiceAccrual'),
				--('tblARInvoiceDetail'),
				--('tblARInvoiceDetailComponent'),
				--('tblARInvoiceDetailCondition'),
				--('tblARInvoiceDetailTax'),
				--('tblRKFutOptTransactionHeader'),
				--('tblRKAssignFuturesToContractSummary'),
				--('tblRKAssignFuturesToContractSummaryHeader'),
				--('tblRKOptionsMatchPnS'),
				--('tblRKOptionsPnSExpired'),
				--('tblRKMatchFuturesPSHeader'),
				--('tblRKMatchDerivativesHistoryForOption'),
				--('tblRKFutOptTransaction'),
				--('tblRKOptionsMatchPnSHeader'),
				--('tblRKOptionsPnSExercisedAssigned'),
				--('tblRKMatchFuturesPSDetail'),
				--('tblRKCurrencyExposure'),
				--('tblRKCurExpBankBalance'),
				--('tblRKCurExpMoneyMarket'),
				--('tblRKCurExpCurrencyContract'),
				--('tblRKCurExpStock'),
				--('tblRKCurExpNonOpenSales'),
				--('tblRKCurExpSummary'),
				--('tblQMSample'),
				--('tblQMSampleDetail'),
				--('tblQMTestResult'),
				--('tblGLDetail'),
				--('tblSCTicket'),
				--('tblSCTicketSplit'),
				--('tblSCTicketHistory'),
				--('tblQMTicketDiscount'),
				--('tblSCTicketContractUsed'),
				--('tblSCTicketDiscount'),
				--('tblSCTicketLVStaging'),
				--('tblSCTicketDiscountLVStaging'),
				--('tblSCTicketStorageType'),
				--('tblSCTicketCost'),
				--('tblSCDeliverySheet'),
				--('tblSCDeliverySheetSplit'),
				--('tblSCDeliverySheetHistory'),
				--('tblMFBlendDemand'),
				--('tblMFBlendProductionOutputDetail'),
				--('tblMFBlendRequirement'),
				--('tblMFBlendRequirementRule'),
				--('tblMFBudget'),
				--('tblMFBudgetLog'),
				--('tblMFCustomFieldValue'),
				--('tblMFDowntime'),
				--('tblMFDowntimeMachines'),
				--('tblMFForecastItemValue'),
				--('tblMFInventoryAdjustment'),
				--('tblMFItemDemand'),
				--('tblMFItemOwnerDetail'),
				--('tblMFLotInventory'),
				--('tblMFLotSnapshot'),
				--('tblMFLotSnapshotDetail'),
				--('tblMFOrderDetail'),
				--('tblMFOrderHeader'),
				--('tblMFOrderManifest'),
				--('tblMFOrderManifestLabel'),
				--('tblMFPickList'),
				--('tblMFPickListDetail'),
				--('tblMFProcessCycleCount'),
				--('tblMFProcessCycleCountMachine'),
				--('tblMFProcessCycleCountSession'),
				--('tblMFProductionSummary'),
				--('tblMFSchedule'),
				--('tblMFScheduleCalendar'),
				--('tblMFScheduleCalendarDetail'),
				--('tblMFScheduleCalendarMachineDetail'),
				--('tblMFScheduledMaintenance'),
				--('tblMFScheduledMaintenanceDetail'),
				--('tblMFScheduleMachineDetail'),
				--('tblMFScheduleWorkOrder'),
				--('tblMFScheduleWorkOrderDetail'),
				--('tblMFShiftActivity'),
				--('tblMFShiftActivityMachines'),
				--('tblMFStageWorkOrder'),
				--('tblMFTask'),
				--('tblMFWastage'),
				--('tblMFWorkOrder'),
				--('tblMFWorkOrderConsumedLot'),
				--('tblMFWorkOrderInputLot'),
				--('tblMFWorkOrderInputParentLot'),
				--('tblMFWorkOrderItem'),
				--('tblMFWorkOrderProducedLot'),
				--('tblMFWorkOrderProducedLotTransaction'),
				--('tblMFWorkOrderProductSpecification'),
				--('tblMFWorkOrderRecipe'),
				--('tblMFWorkOrderRecipeCategory'),
				--('tblMFWorkOrderRecipeComputation'),
				--('tblMFWorkOrderRecipeComputationMethod'),
				--('tblMFWorkOrderRecipeComputationType'),
				--('tblMFWorkOrderRecipeItem'),
				--('tblMFWorkOrderRecipeSubstituteItem'),
				--('tblSTHandheldScanner'),
				--('tblSTHandheldScannerExportPricebook'),
				--('tblSTHandheldScanner'),
				--('tblSTHandheldScannerImportCount'),
				--('tblSTHandheldScannerImportReceipt'),
				--('tblPATRefundCustomer'),
				--('tblPATRefundRate'),
				--('tblPATPatronageCategory'),
				--('tblPATRefundCategory'),
				--('tblPATRefundRateDetail'),
				--('tblCCSiteDetail'),
				--('tblARMarketZone'),
				--('tblTFTerminalControlNumber')



	END
	
PRINT N'END DISCONNECTED REPLICATION TABLE'
