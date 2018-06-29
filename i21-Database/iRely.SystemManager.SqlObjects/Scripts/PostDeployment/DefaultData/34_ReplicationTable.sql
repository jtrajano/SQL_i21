GO
	PRINT N'BEGIN REPLICATION TABLE'

	-- Parent

	/* System Manager */
			DECLARE @ListTables TABLE(strTableName VARCHAR(100));
			DECLARE @TableName nvarchar(50);

			INSERT INTO @ListTables 
			VALUES 

			--Parent To Sub
				--Entity
			--Entity
			('tblEMContactDetail'),  	--1					
			('tblEMContactDetailType'), --2
			('tblEMEntity'),  --3
			('tblEMEntityAreaOfInterest'), --4  
			('tblEMEntityCardInformation'),  --5
			('tblEMEntityClass'), --6
			('tblEMEntityContactNumber'), --7 
			('tblEMEntityCredential'), --8
			('tblEMEntityCRMInformation'), --9
			('tblEMEntityEFTInformation'), --10
			---('tblEMEntityEFTInformationBackupForEncryption'),  --11
			('tblEMEntityFarm'), --12
			('tblEMEntityGroup'), --13
			('tblEMEntityGroupDetail'), --14
			('tblEMEntityImportError'), --15
			('tblEMEntityImportFile'), --16
			('tblEMEntityImportSchemaCSV'), --17
			('tblEMEntityLineOfBusiness'), --18
			('tblEMEntityLocation'), --19
			('tblEMEntityMessage'), --20
			('tblEMEntityMobileNumber'), --21
			('tblEMEntityNote'), --22
			('tblEMEntityPasswordHistory'), --23
			('tblEMEntityPhoneNumber'), --24
			('tblEMEntityPortalMenu'), --25
			('tblEMEntityPortalPermission'), --26
			('tblEMEntityPreferences'), --27
			('tblEMEntityRequireApprovalFor'), --28
			('tblEMEntitySignature'), --29
			('tblEMEntitySMTPInformation'), --30
			('tblEMEntitySplit'), --31
			('tblEMEntitySplitDetail'), --32
			('tblEMEntitySplitExceptionCategory'), --33
			('tblEMEntityTariff'), --34
			('tblEMEntityTariffCategory'), --35 
			('tblEMEntityTariffFuelSurcharge'), --36
			('tblEMEntityTariffMileage'), --37
			('tblEMEntityTariffType'), --38
			('tblEMEntityToContact'), --39
			('tblEMEntityToRole'), --40
			('tblEMEntityType'), --41

			--SM Company Configuration
		--	('tblSMCompanyPreference'),		--initialization only
				('tblAPCompanyPreference'),
				('tblARCompanyPreference'),
				('tblCTCompanyPreference'),
				--('tblGLCompanyPreferenceOption'), Exist in GL
				('tblICCompanyPreference'),
				('tblLGCompanyPreference'),
				('tblRKCompanyPreference'),
				('tblQMCompanyPreference'),
				('tblSMMultiCompany'),
		--	('tblSMCompanySetup'), -- initialization only
		--	('tblSMMultiCurrency'), -- initialization only
		--	('tblSMPricingLevel'), -- initialization only

			--SM Language
			('tblSMLanguage'),

			--SM Report Label
			('tblSMReportLabelDetail'), 
			('tblSMReportLabels '),
			('tblSMReportTranslation'), 

			--SM Security Policy
			('tblSMSecurityPolicy'),

			--Screen Labels
			('tblSMCustomLabel'),
			

			--SM Users/User Roles
		 --  ('tblEMEntity'), --1
			 ('tblSMControl'), --2
				('tblSMControlStage'), --3
					('tblSMEntityMenuFavorite'), --4
						('tblSMScreen'), --5
							('tblSMScreenStage'), --6
			--('tblSMUserLogin'), --7
			('tblSMUserPreference'), --8
			('tblSMUserRole'), --9
			('tblSMUserRoleCompanyLocationPermission'), -- 10
			('tblSMUserRoleControlPermission'), --11
			('tblSMUserRoleDashboardPermission'), --12
			('tblSMUserRoleFRPermission'), --13
			('tblSMUserRoleMenu'), --14
			('tblSMUserRoleReportPermission'), --15
			('tblSMUserRoleScreenPermission'), --16
			('tblSMUserRoleSubRole'), --17
			('tblSMUserSecurity'), --18
			('tblSMUserSecurityCompanyLocationRolePermission'), --19
			('tblSMUserSecurityControlPermission'), --20
			('tblSMUserSecurityDashboardPermission'), --21
			('tblSMUserSecurityFilterType'), --22
			('tblSMUserSecurityFRPermission'), --23
			('tblSMUserSecurityMenu'), --24													 
			('tblSMUserSecurityPasswordHistory'), --25
			('tblSMUserSecurityReportPermission'), --26
			('tblSMUserSecurityRequireApprovalFor'), --27
			('tblSMUserSecurityScreenPermission'), --28

			--Common Info Cities
			('tblSMCity'),

			--Common Info Company Locations
			('tblSMCompanyLocation'),
			('tblSMCompanyLocationAccount'),
			('tblSMCompanyLocationPricingLevel'),
			('tblSMCompanyLocationRequireApprovalFor'),
			('tblSMCompanyLocationSubLocation'),
			('tblSMCompanyLocationSubLocationCategory'),
			 
			--Common Info Countries
			('tblSMCountry'),

			--Common Info Currencies
			('tblSMCurrency '),
			('tblSMCurrencyExchangeRate '),
			('tblSMCurrencyExchangeRateDetail'), 
			('tblSMCurrencyExchangeRateType '),

			--Common Info 	Freight Terms
			('tblSMFreightTerms'),

			--Common Info Line of Business
			('tblSMLineOfBusiness'),

			--Common Info Payment Methods
			('tblSMPaymentMethod'),

			--Common Info Ship Via
			('tblSMShipVia'),
			('tblSMShipViaTruck'),

			--Common Info Terms
			('tblSMTerm '),



			--Tax
			('tblSMTaxClass'),
			('tblSMTaxCode'),
			('tblSMTaxCodeRate'),
			('tblSMTaxGroup'),
			('tblSMTaxGroupCode'),
			('tblSMTaxGroupCodeCategoryExemption'),
			('tblSMTaxType'),


			--GL
			('tblGLAccountSegment'), --1
			('tblGLAccountSystem'), --2 init only
			('tblGLAccountSegmentMapping'), --3
			('tblGLAccount'), --4
			('tblGLAccountCategory'), --5
			('tblGLAccountStructure'), --6
			('tblGLSegmentType'), --7
			('tblGLAccountGroup'), --8
			('tblGLAccountRange'), --9
			('tblGLAccountReallocation'), --10 init only
			('tblGLAccountTemplate'), --11 init only
			('tblGLAccountTemplateDetail'), --12 init only
			('tblGLAccountUnit'), --13
			('tblGLCOACrossReference'),	--14
			('tblGLCrossReferenceMapping'), -- initialization only	
			('tblGLCOATemplate'), -- initialization only	
			('tblGLCOATemplateDetail'), -- initialization only	
			('tblGLCompanyPreferenceOption'), --19 init only
			('tblGLCurrentFiscalYear'), --20
			('tblGLDeletedAccount'), --21
			('tblGLFiscalYear'), --(exclude ysnStatus, intConcurrency columns)
			('tblGLFiscalYearPeriod'), --(exclude all ysn* and intConcurrencyId columns)
			('tblGLAccountAdjustmentLog'), --24


		









		
			--CM Banks
			('tblCMBank'),

			--CM Bank Accounts
			('tblCMBankAccount'),
			('tblCMBankFileFormat'),

			--IC Inventory Categories
			('tblICCategory'),
			('tblICCategoryAccount'),
			('tblICCategoryLocation'),
			('tblICCategoryTax'),
			('tblICCategoryUOM'),
			('tblICCategoryVendor'),

			--IC Inventory Commodities
			('tblICCommodity'),
			('tblICCommodityAccount'),
			('tblICCommodityAttribute'),
			('tblICCommodityGroup'),
			('tblICCommodityProductLine'),
			('tblICCommodityUnitMeasure'),

			--IC Invenotry UOM
			('tblICUnitMeasure'),
			('tblICUnitMeasureConversion'),

			--IC Inventory Items
			('tblICItem'), --1
			('tblICItemAccount'), --2
			('tblICItemAssembly'), --3
			('tblICItemBundle'), --4
			('tblICItemCertification'), --5
			('tblICItemCommodityCost'), --6
			('tblICItemContract'), --7
			('tblICItemContractDocument'), --8
			('tblICItemCustomerXref'), --9
			('tblICItemFactory'), --10
			('tblICItemFactoryManufacturingCell'), --11
			('tblICItemKit'), --12
			('tblICItemKitDetail'), --13
			('tblICItemLicense'), --14
			('tblICItemLocation'), --15
			('tblICItemManufacturingUOM'), --16
			('tblICItemMotorFuelTax'), --17
			('tblICItemNote'), --18
			('tblICItemOwner'), --19
			('tblICItemPOSCategory'), --20
			('tblICItemPOSSLA'), --21
			('tblICItemPricing'), -- removed --22
			('tblICItemPricingLevel'), --23
			('tblICItemSpecialPricing'), --24
			('tblICItemStockType'), --25
		--	('tblICItemStockUOM'), removed --26
			('tblICItemSubLocation'), --27
			('tblICItemSubstitution'), --28
			('tblICItemSubstitutionDetail'), --29
			('tblICItemUOM'), --30
			('tblICItemUPC'), --31
			('tblICItemVendorXref'), --32

			--IC Inventory Storage Units
			('tblICStorageUnitType'),
			('tblICStorageLocation'),



			--AP Vendors
			('tblAPVendor'),
			('tblAPVendorLien'),
			('tblAPVendorPricing'),
			('tblAPVendorSpecialTax'),
			('tblAPVendorTaxException'),
			('tblAPVendorTerm'),

			--AR Customers
			('tblARCustomer'),
			('tblARCustomerAccountStatus'),
			('tblARCustomerApplicatorLicense'),
			('tblARCustomerBudget '),
			('tblARCustomerBuyback '),
			('tblARCustomerCardFueling '),
			('tblARCustomerCategoryPrice '),
			('tblARCustomerCommission '),
			('tblARCustomerCompetitor '),
			('tblARCustomerContract '),
			('tblARCustomerContractDetail '),
			('tblARCustomerFailedImport '),
			('tblARCustomerFarm '),
			('tblARCustomerFieldXRef '),
			('tblARCustomerFreightXRef '),
			('tblARCustomerGroup '),
			('tblARCustomerGroupDetail '),
			('tblARCustomerLicenseInformation '),
			('tblARCustomerLicenseModule '),
			('tblARCustomerLineOfBusiness '),
			('tblARCustomerMasterLicense'), 
			('tblARCustomerMessage '),
			('tblARCustomerPortalMenu '),
			('tblARCustomerProductVersion '),
			('tblARCustomerQuote '),
			('tblARCustomerRackQuoteCategory '),
			('tblARCustomerRackQuoteHeader '),
			('tblARCustomerRackQuoteVendor '),
			('tblARCustomerSpecialPrice '),
			('tblARCustomerSplit '),
			('tblARCustomerSplitDetail '),
			('tblARCustomerTaxingTaxException '),

			--AR Sales Reps
		--	('tblEMEntity'), -- (used for Multiple screens)
			('tblARSalesperson'),

			--CM AOP Vs Actual
			('tblCTAOP'),
			('tblCTAOPDetail'),

			--CM Associations
			('tblCTAssociation'),

			--CM Certification
			('tblICCertification'),

			--CM Condition
			('tblCTCondition'),

			--CM Contract Position
			('tblCTPosition'),

			--CM Documents
			('tblICDocument'),

			--CM INCO/Ship Term
			('tblCTContractBasis'),

			--CM Weight/Grades
			('tblCTWeightGrade'),

			--PR Employee
			('tblPREmployee'),
			('tblPREmployeeRank'),
			('tblPRWorkersCompensation'),

			--RM Brokerage Accounts
			('tblRKBrokerageAccount'),
			('tblRKTradersbyBrokersAccountMapping'),
			('tblRKBrokerageCommission	'),

			--RM Futures Broker
			--('tblEMEntity'), Inculed in Entity

			--RM Futures Market
			('tblRKFutureMarket'),
			('tblRKCommodityMarketMapping'),

			--RM Futures Trading Month
			('tblRKFuturesMonth'),

			--RM Options Trading Month
			('tblRKOptionsMonth'),

			--RM Settlement Price
			('tblRKFuturesSettlementPrice'),
			('tblRKFutSettlementPriceMarketMap'),
		    ('tblRKOptSettlementPriceMarketMap'),

			--RM Basis Entry
			('tblRKM2MBasis'),
			('tblRKM2MBasisDetail'),

			--LG Container Types
			('tblLGContainerType'),
			('tblLGContainerTypeCommodityQty'),

			--LG Equipment Types
			('tblLGEquipmentType'),
			
			

			--LG Forwarding Agent
		--	('tblEMEntity'), -- (used for Multiple screens)

			
			--LG Insurer
	   --	('tblEMEntity'), -- (used for Multiple screens)
			('tblLGInsurancePremiumFactor'),
			('tblLGInsurancePremiumFactorDetail'),
			
			--LG Reason Code
			('tblLGReasonCode'),

			--LG Shipping Lines
	   --	('tblEMEntity'), -- (used for Multiple screens)
			('tblLGShippingLineServiceContract'),
			('tblLGShippingLineServiceContractDetail'),

			--LG shipping Mode
			('tblLGShippingMode'),

			--LG Terminals
	   --	('tblEMEntity'), -- (used for Multiple screens)

			--LG Warehouse Rate Matrix
			('tblLGWarehouseRateMatrixDetail'),
			('tblLGWarehouseRateMatrixHeader'),

			--QM Quality Parameters
			('tblQMAttribute'),
			('tblQMAttributeDataType'),
			('tblQMList'),
			('tblQMListItem'),
			('tblQMSampleType'),
			('tblQMSampleTypeDetail'),
			('tblQMSampleTypeUserRole'),
			('tblQMSampleLabel'),
			('tblQMProperty'),
			('tblQMPropertyValidityPeriod'),
			('tblQMConditionalProperty'),
			('tblQMTest'),
			('tblQMTestMethod'),
			('tblQMTestProperty'),
			('tblQMProduct'),
			('tblQMProductControlPoint'),
			('tblQMProductTest'),
			('tblQMProductProperty'),
			('tblQMProductPropertyValidityPeriod'),
			('tblQMConditionalProductProperty'),
			('tblQMProductPropertyFormulaProperty'),

			--Scale
			('tblSCScaleSetup'),
			('tblSCDistributionOption'),
			('tblSCDeliverySheetImportingTemplate'),
			('tblSCListTicketTypes'),
			('tblSCTicketEmailOption'),
			('tblSCTicketFormat'),
			('tblSCTicketPrintOption'),
			('tblSCScaleDevice'),
			('tblSCTicketPool'),
			('tblSCTicketType'),
			('tblSCDeliverySheetImportingTemplateDetail'),
			('tblSCScaleOperator'),
			('tblSCTruckDriverReference'),
			('tblSCLastScaleSetup'),
			('tblSCUncompletedTicketAlert'),
		
			--Grain
			('tblGRDiscountId'),
			('tblGRDiscountLocationUse'),
			('tblGRDiscountCrossReference'),
			('tblGRDiscountSchedule'),
			('tblGRDiscountScheduleCode'),
			('tblGRDiscountScheduleLine'),
			
			

			--Manufacturing
			('tblMFAttribute'),
			('tblMFBlendValidation'),
			('tblMFBuyingGroup'),
			('tblMFCompanyPreference'),
			('tblMFDepartment'),
			('tblMFHaldheldUserMenuItemMap'),
			('tblMFHandheldMenuItem'),
			('tblMFHolidayCalendar'),
			('tblMFInventoryShipmentRestrictionType'),
			('tblMFItemChangeMap'),
			('tblMFItemContamination'),
			('tblMFItemContaminationDetail'),
			('tblMFItemGradeDiff'),
			('tblMFItemGroup'),
			('tblMFItemMachine'),
			('tblMFItemOwner'),
			('tblMFItemSubstitution'),
			('tblMFItemSubstitutionDetail'),
			('tblMFItemSubstitutionRecipe'),
			('tblMFItemSubstitutionRecipeDetail'),
			('tblMFLotStatusException'),
			('tblMFMachine'),
			('tblMFMachineMeasurement'),
			('tblMFMachinePackType'),
			('tblMFManufacturingCell'),
			('tblMFManufacturingCellPackType'),
			('tblMFManufacturingProcess'),
			('tblMFManufacturingProcessAttribute'),
			('tblMFManufacturingProcessMachine'),
			('tblMFManufacturingProcessRunDuration'),
			('tblMFMeasurement'),
			('tblMFNutrient'),
			('tblMFOneLinePrint'),
			('tblMFOrderDirection'),
			('tblMFPackType'),
			('tblMFPackTypeDetail'),
			('tblMFParentLotNumberPattern'),
			('tblMFPattern'),
			('tblMFPatternByCategory'),
			('tblMFPatternCode'),
			('tblMFPatternDetail'),
			('tblMFPatternSequence'),
			('tblMFReasonCode'),
			('tblMFReasonCodeDetail'),
			('tblMFRecipe'),
			('tblMFRecipeAlertLog'),
			('tblMFRecipeCategory'),
			('tblMFRecipeGuide'),
			('tblMFRecipeGuideNutrient'),
			('tblMFRecipeItem'),
			('tblMFRecipeItemStage'),
			('tblMFRecipeStage'),
			('tblMFRecipeSubstituteItem'),
			('tblMFRecipeSubstituteItemStage'),
			('tblMFReportCategory'),
			('tblMFReportCategoryByCustomer'),
			('tblMFReportLabel'),
			('tblMFReportLidlUCCPalletLabel'),
			('tblMFScheduleChangeoverFactor'),
			('tblMFScheduleChangeoverFactorDetail'),
			('tblMFScheduleConstraint'),
			('tblMFScheduleConstraintDetail'),
			('tblMFScheduleGroup'),
			('tblMFScheduleGroupDetail'),
			('tblMFScheduleRule'),
			('tblMFShift'),
			('tblMFShiftBreakType'),
			('tblMFShiftDetail'),
			('tblMFStorageLocationRestrictionTypeLotStatus'),
			('tblMFUserPrinterMap'),
			('tblMFUserRoleEventMap'),
			('tblMFYield'),
			('tblMFYieldDetail'),



			----Sub to parent
			  --CM Contracts
            ('tblCTContractCost'), --1
            ('tblCTContractDetail'), --2
            ('tblCTContractHeader'), --3
            ('tblCTContractDocument'), --4
            ('tblCTContractProducer'), --5
            ('tblCTContractCondition'), --6
            ('tblCTContractCertification'), --7
            ('tblCTPriceContract'), --8
            ('tblCTPriceFixation'), --9
            ('tblCTPriceFixationDetail'), -- 10

            --LG Load/ Shipment Schedules
            ('tblLGGenerateLoad'), --1
            ('tblLGLoad'), --2 
            ('tblLGLoadContainer'), --3
            ('tblLGLoadContainerCost'), --4
            ('tblLGLoadCost'), --5
            ('tblLGLoadDetail'), --6
            ('tblLGLoadDetailContainerCost'), --7
            ('tblLGLoadDetailContainerLink'), --8
            ('tblLGLoadDetailLot'), --9
            ('tblLGLoadNotifyParties'), --10
            ('tblLGLoadStorageCost'), --11
            ('tblLGLoadWarehouse'), --12
            ('tblLGLoadWarehouseContainer'), --13

            ('tblLGAllocationHeader'),
            ('tblLGAllocationDetailOrigin'),
            ('tblLGAllocationDetail'),

            ('tblLGLoadDocuments'), --7
  
            --LG Weight Claims
            ('tblLGWeightClaim'), --1
            ('tblLGWeightClaimDetail'), --2

            --IC Inventory Receipts
            ('tblICInventoryReceipt'), --1
            ('tblICInventoryReceiptCharge'), --2
            ('tblICInventoryReceiptChargePerItem'), --3
            ('tblICInventoryReceiptChargeTax'), --4
            ('tblICInventoryReceiptInspection'), --5
            ('tblICInventoryReceiptItem'), --6
            ('tblICInventoryReceiptItemAllocatedCharge'), --7
            ('tblICInventoryReceiptItemLot'), --8
            ('tblICInventoryReceiptItemTax'), --9

            --IC Inventory Shipments
            ('tblICInventoryShipment'), --1
            ('tblICInventoryShipmentCharge'), --2
            ('tblICInventoryShipmentChargePerItem'), --3
            ('tblICInventoryShipmentChargeTax'), --4
            ('tblICInventoryShipmentItem'), --5
            ('tblICInventoryShipmentItemAllocatedCharge'), --6
            ('tblICInventoryShipmentItemLot'), --7

            --IC Inventory Transfers
            ('tblICInventoryTransfer'),
            ('tblICInventoryTransferDetail'),

            --IC Inventory Adjustment
            ('tblICInventoryAdjustment'),
            ('tblICInventoryAdjustmentDetail'),


            --IC Inventory Count
            ('tblICInventoryCount'),
            ('tblICInventoryCountDetail'),

            --IC Inventory Transaction
            ('tblICInventoryActualCost'), --1
            ('tblICInventoryActualCostAdjustmentLog'), --2
            ('tblICInventoryActualCostOut'), --3
            ('tblICInventoryCostAdjustmentType'), --4
            ('tblICInventoryFIFO'), --5
            ('tblICInventoryFIFOCostAdjustmentLog'),--6
            ('tblICInventoryFIFOOut'), --7
            ('tblICInventoryFIFORevalueOutStock'),--8
            ('tblICInventoryFIFOStorage'), --9
            ('tblICInventoryFIFOStorageOut'), -- 10
            ('tblICInventoryGLAccountUsedOnPostLog'), --11
            ('tblICInventoryLIFO'), --12
            ('tblICInventoryLIFOCostAdjustmentLog'),--13
            ('tblICInventoryLIFOOut'), --14
            ('tblICInventoryLIFOStorage'), --15
            ('tblICInventoryLIFOStorageOut'),--16
            ('tblICInventoryLot'),--17
            ('tblICInventoryLotCostAdjustmentLog'), --18
            ('tblICInventoryLotOut'), --19
            ('tblICInventoryLotStorage'), --20
            ('tblICInventoryLotStorageOut'), --21
            ('tblICInventoryLotTransaction'), --22
            ('tblICInventoryLotTransactionStorage'), --23
            ('tblICInventoryTransaction'), --24
            ('tblICInventoryTransactionStorage'), --25
            ('tblICItemStock'), --26
            ('tblICItemStockUOM'), --27 -- included in first set up
            ('tblICItemStockDetail'), --28
            ('tblICStockReservation'), --29
           -- ('tblICItemPricing'), --30 -- included in first set up
            ('tblICLot'), --31
            ('tblICLotStatus'), --32
            ('tblICParentLot'), --33

            --AP Vouchers
            ('tblAPBill'), --1
            ('tblAPBillBatch'), --2
            ('tblAPBillDetail'), --3
            ('tblAPBillDetailTax'), --4

            --AR Invoices
            ('tblARInvoice'), --1
            ('tblARInvoiceAccrual'), --2
            ('tblARInvoiceDetail'), --3
            ('tblARInvoiceDetailComponent'), --4
            ('tblARInvoiceDetailCondition'), --5
            ('tblARInvoiceDetailTax'), --6

            --RM
            ('tblRKFutOptTransactionHeader'), --1        
            ('tblRKAssignFuturesToContractSummary'), --2
            ('tblRKAssignFuturesToContractSummaryHeader'), --3
            ('tblRKOptionsMatchPnS'), --4
            ('tblRKOptionsPnSExpired'), --5
            ('tblRKMatchFuturesPSHeader'), --6
            ('tblRKFutOptTransaction'), --7
            ('tblRKOptionsMatchPnSHeader'), --8
            ('tblRKOptionsPnSExercisedAssigned'), --9       
            ('tblRKMatchFuturesPSDetail'), --10

            --QM
            ('tblQMSample'), --1
            ('tblQMSampleDetail'), --2
            ('tblQMTestResult'), --3


            --GL
            ('tblGLDetail'),

            --Scale
            ('tblSCTicket'),
            ('tblSCTicketSplit'),
            ('tblSCTicketHistory'),
            ('tblQMTicketDiscount'),
            ('tblSCTicketContractUsed'),
            ('tblSCTicketDiscount'),
            ('tblSCTicketLVStaging'),
            ('tblSCTicketDiscountLVStaging'),
            ('tblSCTicketStorageType'),
            ('tblSCTicketCost'),
            ('tblSCDeliverySheet'),
            ('tblSCDeliverySheetSplit'),
            ('tblSCDeliverySheetHistory'),

            --Manufacturing
            ('tblMFBlendDemand'),
            ('tblMFBlendProductionOutputDetail'),
            ('tblMFBlendRequirement'),
            ('tblMFBlendRequirementRule'),
            ('tblMFBudget'),
            ('tblMFBudgetLog'),
            ('tblMFCustomFieldValue'),
            ('tblMFDowntime'),
            ('tblMFDowntimeMachines'),
            ('tblMFForecastItemValue'),
            ('tblMFInventoryAdjustment'),
            ('tblMFItemDemand'),
            ('tblMFItemOwnerDetail'),
            ('tblMFLotInventory'),
            ('tblMFLotSnapshot'),
            ('tblMFLotSnapshotDetail'),
            ('tblMFLotTareWeight'),
            ('tblMFOrderDetail'),
            ('tblMFOrderHeader'),
            ('tblMFOrderManifest'),
            ('tblMFOrderManifestLabel'),
            ('tblMFPickForWOStaging'),
            ('tblMFPickList'),
            ('tblMFPickListDetail'),
            ('tblMFProcessCycleCount'),
            ('tblMFProcessCycleCountMachine'),
            ('tblMFProcessCycleCountSession'),
            ('tblMFProductionSummary'),
            ('tblMFSchedule'),
            ('tblMFScheduleCalendar'),
            ('tblMFScheduleCalendarDetail'),
            ('tblMFScheduleCalendarMachineDetail'),
            ('tblMFScheduledMaintenance'),
            ('tblMFScheduledMaintenanceDetail'),
            ('tblMFScheduleMachineDetail'),
            ('tblMFScheduleWorkOrder'),
            ('tblMFScheduleWorkOrderDetail'),
            ('tblMFShiftActivity'),
            ('tblMFShiftActivityMachines'),
            ('tblMFStageWorkOrder'),
            ('tblMFTask'),
            ('tblMFWastage'),
            ('tblMFWorkOrder'),
            ('tblMFWorkOrderConsumedLot'),
            ('tblMFWorkOrderInputLot'),
            ('tblMFWorkOrderInputParentLot'),
            ('tblMFWorkOrderItem'),
            ('tblMFWorkOrderProducedLot'),
            ('tblMFWorkOrderProducedLotTransaction'),
            ('tblMFWorkOrderProductSpecification'),
            ('tblMFWorkOrderRecipe'),
            ('tblMFWorkOrderRecipeCategory'),
            ('tblMFWorkOrderRecipeComputation'),
            ('tblMFWorkOrderRecipeComputationMethod'),
            ('tblMFWorkOrderRecipeComputationType'),
            ('tblMFWorkOrderRecipeItem'),
            ('tblMFWorkOrderRecipeSubstituteItem') 


			While EXISTS(select TOP 1 strTableName from @ListTables) 
			Begin
				SELECT TOP 1 @TableName = strTableName from @ListTables

				IF @TableName is not null and NOT EXISTS(SELECT TOP 1 * from [dbo].[tblSMReplicationTable] WHERE strTableName = @TableName)
				BEGIN

					SELECT @TableName
					INSERT INTO [dbo].[tblSMReplicationTable](strTableName)
					VALUES(@TableName);

				END

				DELETE from @ListTables Where strTableName = @TableName
			END

	PRINT N'END REPLICATION TABLE'
GO