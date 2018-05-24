CREATE  PROCEDURE [dbo].[uspSMRepAddArticleParentToSub]
@result int OUTPUT,
 @publication  As sysname

 As
 Begin
		--DECLARE @result int;
		DECLARE @ListOfArticles TABLE(strArticle VARCHAR(100));
		DECLARE @sql NVARCHAR(MAX) = N'';

		INSERT INTO @ListOfArticles
		VALUES
			
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

			--GL
			('tblGLAccountSegment'), --1
		--	('tblGLAccountSystem'), --2 init only
			('tblGLAccountSegmentMapping'), --3
			('tblGLAccount'), --4
			('tblGLAccountCategory'), --5
			('tblGLAccountStructure'), --6
			('tblGLSegmentType'), --7
			('tblGLAccountGroup'), --8
			('tblGLAccountRange'), --9
		--	('tblGLAccountReallocation'), --10 init only
		--	('tblGLAccountTemplate'), --11 init only
		--	('tblGLAccountTemplateDetail'), --12 init only
			('tblGLAccountUnit'), --13
			('tblGLCOACrossReference'),	--14
		--	('tblGLAccountSystem'), -- initialization only	
		--	('tblGLCrossReferenceMapping'), -- initialization only	
		--	('tblGLCOATemplate'), -- initialization only	
		--	('tblGLCOATemplateDetail'), -- initialization only	
		--	('tblGLCompanyPreferenceOption'), --19 init only
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
		--	('tblICItemPricing'), removed --22
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
			('tblQMProductPropertyFormulaProperty')




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
				exec @result = sp_executesql @sql;
				--select @result			
			
End

