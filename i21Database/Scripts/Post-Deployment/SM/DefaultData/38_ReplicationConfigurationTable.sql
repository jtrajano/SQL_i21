GO
	PRINT N'BEGIN REPLICATION CONFIGURATION TABLE'
 



DECLARE @ListOfScreenTables TABLE(id int IDENTITY(1,1) PRIMARY KEY, strArticle NVARCHAR(max), strScreen NVARCHAR(max), strModule NVARCHAR(MAX));


INSERT INTO @ListOfScreenTables
VALUES      

--##****************************************************************************##
--##****************************************************************************##
--##************    		 Parent to Subsidiary            *******************##
--##****************************************************************************##
--##****************************************************************************##


--########################
--##   Entity Manager   ##---------------------------------------------------------------
--########################


--##   Entity Users
--##   Entity Vendors
--##   Entity Customers
--##   Entity Sales Reps
--##   Entity Employees
--##   Entity Futures Broker
--##   Entity Forwarding Agents
--##   Entity Insurers
--##   Entity Shipping Lines
--##   Entity Terminals
--##   Entity User Profile
--##-----------------------------------------------------------------------------------------------

	('tblEMContactDetail', 'Entities', 'Entity Management'),			
	('tblEMContactDetailType ', 'Entities', 'Entity Management'),
	('tblEMEntity', 'Entities', 'Entity Management'),
	('tblEMEntityAreaOfInterest', 'Entities', 'Entity Management'),
	('tblEMEntityCardInformation', 'Entities', 'Entity Management'),
	('tblEMEntityClass', 'Entities', 'Entity Management'),
	('tblEMEntityContactNumber', 'Entities', 'Entity Management'),
	('tblEMEntityCredential', 'Entities', 'Entity Management'),
	('tblEMEntityCRMInformation', 'Entities', 'Entity Management'),
	('tblEMEntityEFTInformation', 'Entities', 'Entity Management'),
	('tblEMEntityEFTInformationBackupForEncryption', 'Entities', 'Entity Management'),
	('tblEMEntityFarm', 'Entities', 'Entity Management'),
	('tblEMEntityGroup', 'Entities', 'Entity Management'),
	('tblEMEntityGroupDetail', 'Entities', 'Entity Management'),
	('tblEMEntityImportError', 'Entities', 'Entity Management'),
	('tblEMEntityImportFile', 'Entities', 'Entity Management'),
	('tblEMEntityImportSchemaCSV', 'Entities', 'Entity Management'),
	('tblEMEntityLineOfBusiness', 'Entities', 'Entity Management'),
	('tblEMEntityLocation', 'Entities', 'Entity Management'),
	('tblEMEntityMessage', 'Entities', 'Entity Management'),
	('tblEMEntityMobileNumber', 'Entities', 'Entity Management'),
	('tblEMEntityNote', 'Entities', 'Entity Management'),
	('tblEMEntityPasswordHistory', 'Entities', 'Entity Management'),
	('tblEMEntityPhoneNumber', 'Entities', 'Entity Management'),
	('tblEMEntityPortalMenu', 'Entities', 'Entity Management'),
	('tblEMEntityPortalPermission', 'Entities', 'Entity Management'),
	('tblEMEntityPreferences', 'Entities', 'Entity Management'),
	('tblEMEntityRequireApprovalFor', 'Entities', 'Entity Management'),
	('tblEMEntitySignature', 'Entities', 'Entity Management'),
	('tblEMEntitySMTPInformation', 'Entities', 'Entity Management'),
	('tblEMEntitySplit', 'Entities', 'Entity Management'),
	('tblEMEntitySplitDetail', 'Entities', 'Entity Management'),
	('tblEMEntitySplitExceptionCategory', 'Entities', 'Entity Management'),
	('tblEMEntityTariff', 'Entities', 'Entity Management'),
	('tblEMEntityTariffCategory', 'Entities', 'Entity Management'),
	('tblEMEntityTariffFuelSurcharge', 'Entities', 'Entity Management'),
	('tblEMEntityTariffMileage', 'Entities', 'Entity Management'),
	('tblEMEntityTariffType', 'Entities', 'Entity Management'),
	('tblEMEntityToContact', 'Entities', 'Entity Management'),
	('tblEMEntityToRole', 'Entities', 'Entity Management'),
	('tblEMEntityType', 'Entities', 'Entity Management'),

		


---------------------------------------------------------------------------------------------------




--########################
--##   System Manager   ##---------------------------------------------------------------
--########################

--##   SM Configuration
--##-----------------------------------------------------------------------------------------------

	('tblSMCompanyPreference', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMMultiCompany', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMCurrency', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMCountry', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMTerm', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMCompanySetup', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMMultiCurrency', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMPricingLevel', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
	('tblSMLicenseType', 'Company Configuration, Currency, Country and Terms', 'System Manager'),
---------------------------------------------------------------------------------------------------

--##   SM Language >> not exist in strNamespace in tblSMScreen
--##-----------------------------------------------------------------------------------------------


--##   SM Report Labels >> not exist in strNamespace in tblSMScreen
--##-----------------------------------------------------------------------------------------------
	('tblSMReportLabels', 'Report Labels and Language', 'System Manager'),
	('tblSMReportLabelDetail', 'Report Labels and Language', 'System Manager'),
	('tblSMReportTranslation', 'Report Labels and Language', 'System Manager'),
	('tblSMLanguage', 'Report Labels and Language', 'System Manager'),
---------------------------------------------------------------------------------------------------



--##   SM Security Policy
--##-----------------------------------------------------------------------------------------------

		('tblSMSecurityPolicy', 'Security Policy', 'System Manager'),

---------------------------------------------------------------------------------------------------


--##   SM Screen Labels >> not exist in strNamespace in tblSMScreen
--##-----------------------------------------------------------------------------------------------
		
		('tblSMCustomLabel', 'Screen Label', 'System Manager'),

--## User and User Role
--##-----------------------------------------------------------------------------------------------

	--Users
	--tblEM*
	('tblSMMasterMenu', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMContactMenu', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityScreenPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMControl', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMControlStage', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMEntityMenuFavorite', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMScreen', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMScreenStage', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserLogin', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserPreference', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRole', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleCompanyLocationPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleControlPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleDashboardPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleFRPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleMenu', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleReportPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleScreenPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleSubRole', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurity', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityCompanyLocationRolePermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityControlPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityDashboardPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityFilterType', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityFRPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityMenu', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityPasswordHistory', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityReportPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityRequireApprovalFor', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserSecurityScreenPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	--User Roles
	('tblSMUserRole', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleCompanyLocationPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleControlPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleDashboardPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleFRPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleMenu', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleReportPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleScreenPermission', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMUserRoleSubRole', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMScreen', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMControl', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMSecurityPolicy', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMLineOfBusiness', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	--Company Locations
	('tblSMCompanyLocation', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCompanyLocationAccount', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCompanyLocationPricingLevel', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCompanyLocationRequireApprovalFor', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCompanyLocationSubLocation', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCompanyLocationSubLocationCategory', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMCountry', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMScreen', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMApprovalList', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMTaxCode', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMTaxGroup', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMTaxGroupCode', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblSMTaxGroupCodeCategoryExemption', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblGLAccount', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblICLotStatus', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('tblICStorageLocation', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	--tblEM*
	--Company Configuration (Multi Company)
	('tblSMMultiCompany	', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	('Approval List', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),
	--tblEM*
	('tblSMApproverGroup', 'Users, User Roles, Security Policies, Line of Business, Company Location, Company Configuration (Multi Company) and Approval List', 'System Manager'),

---------------------------------------------------------------------------------------------------


		

--##   SM City
--##-----------------------------------------------------------------------------------------------

		('tblSMCity', 'Cities', 'System Manager'),

---------------------------------------------------------------------------------------------------


--##   Company Location
--##-----------------------------------------------------------------------------------------------

		('tblSMCompanyLocation', 'Company Locations', 'System Manager'),
		('tblSMCompanyLocationAccount', 'Company Locations', 'System Manager'),
		('tblSMCompanyLocationPricingLevel', 'Company Locations', 'System Manager'),
		('tblSMCompanyLocationRequireApprovalFor', 'Company Locations', 'System Manager'),
		
		('tblSMCompanyLocationSubLocation', 'Company Locations', 'System Manager'),
		('tblSMCompanyLocationSubLocationCategory', 'Company Locations', 'System Manager'),
		('tblSMCountry', 'Company Locations', 'System Manager'),
		('tblSMScreen', 'Company Locations', 'System Manager'),
		
		('tblSMApprovalList', 'Company Locations', 'System Manager'),
		('tblSMTaxGroup', 'Company Locations', 'System Manager'),
		('tblSMTaxGroupCode', 'Company Locations', 'System Manager'),
		('tblSMTaxGroupCodeCategoryExemption', 'Company Locations', 'System Manager'),
		
		('tblGLAccount', 'Company Locations', 'System Manager'),
		('tblICLotStatus', 'Company Locations', 'System Manager'),
		('tblICStorageLocation', 'Company Locations', 'System Manager'),
		
---------------------------------------------------------------------------------------------------
		

--##   SM Country
--##-----------------------------------------------------------------------------------------------

		('tblSMCountry', 'Countries', 'System Manager'),

---------------------------------------------------------------------------------------------------
		

--##   SM Currency
--## Currencies and Currency Exchange Rates and Currency Exchange Rate Types
--##-----------------------------------------------------------------------------------------------

		('tblSMCurrency ', 'Currencies, Currency Exchange Rates and Currency Exchange Rate Types', 'System Manager'),
		('tblSMCurrencyExchangeRate  ', 'Currencies, Currency Exchange Rates and Currency Exchange Rate Types', 'System Manager'),
		('tblSMCurrencyExchangeRateDetail  ', 'Currencies, Currency Exchange Rates and Currency Exchange Rate Types', 'System Manager'),
		('tblSMCurrencyExchangeRateType  ', 'Currencies, Currency Exchange Rates and Currency Exchange Rate Types', 'System Manager'),

---------------------------------------------------------------------------------------------------
		

--##   SM FreightTerm
--##-----------------------------------------------------------------------------------------------

		('tblSMFreightTerms', 'Freight Terms', 'System Manager'),	

---------------------------------------------------------------------------------------------------
		

--##   SM Line of Business
--##-----------------------------------------------------------------------------------------------

		('tblSMLineOfBusiness', 'Line Of Business', 'System Manager'),	

---------------------------------------------------------------------------------------------------
		

--##   SM Payment Method
--##-----------------------------------------------------------------------------------------------

		('tblSMPaymentMethod', 'Payment Methods', 'System Manager'),

---------------------------------------------------------------------------------------------------
		

--##   Sm Ship Via
--##-----------------------------------------------------------------------------------------------

		('tblSMShipVia', 'Ship Via', 'System Manager'),
		('tblSMShipViaTruck', 'Ship Via', 'System Manager'),
		('tblSMTransportationMode', 'Ship Via', 'System Manager'),
		

---------------------------------------------------------------------------------------------------		


--##   SM Term
--##-----------------------------------------------------------------------------------------------

		('tblSMTerm', 'Terms', 'System Manager'),

---------------------------------------------------------------------------------------------------
		


--########################
--##   GENERAL LEDGER   ##------------------------------------------------------
--########################
		
--##   Account Groups
--##   Account Structure
--##   Chart of Accounts
--##   Fiscal Year
--##   Segment Account
--##   Account Range

	
--## Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range








--##-----------------------------------------------------------------------------------------------

		('tblGLAccountSegment', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountSystem', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountSegmentMapping', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccount', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountCategory', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountStructure', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLSegmentType', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountGroup', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountRange', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountReallocation', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountTemplate', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountTemplateDetail', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountUnit', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCOACrossReference', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountSystem', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCrossReferenceMapping', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCOATemplate', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCOATemplateDetail', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCompanyPreferenceOption', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLDeletedAccount', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountAdjustmentLog', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLDeletedAccount', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),

		('tblGLAccountSystem', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountReallocation', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountTemplate', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLAccountTemplateDetail', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCrossReferenceMapping', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCOATemplate', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCOATemplateDetail', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
		('tblGLCompanyPreferenceOption', 'Account Groups, Account Structure, Chart of Accounts, Fiscal Year, Segment Account and Account Range', 'General Ledger'),
	
---------------------------------------------------------------------------------------------------
		



--#########################
--##   Cash Management   ##------------------------------------------------------------------------  
--#########################


--##   CM Bank
--##-----------------------------------------------------------------------------------------------

		('tblCMBank', 'Banks', 'Cash Management'),

---------------------------------------------------------------------------------------------------		


--CM Bank Accounts
--##-----------------------------------------------------------------------------------------------

		('tblCMBankAccount', 'BankAccounts and Bank File Format', 'Cash Management'),
		('tblCMBankFileFormat', 'BankAccounts and Bank File Format', 'Cash Management'),
---------------------------------------------------------------------------------------------------



--###################
--##   Inventory   ##-------------------------------------------------------------
--###################
--------------------------------------------------------------------------------


--##   IC Categories
--##-----------------------------------------------------------------------------------------------

		('tblICCategory', 'Categories', 'Inventory'),
		('tblICCategoryAccount', 'Categories', 'Inventory'),
		('tblICCategoryLocation', 'Categories', 'Inventory'),
		('tblICCategoryTax', 'Categories', 'Inventory'),
		('tblICCategoryUOM', 'Categories', 'Inventory'),
		('tblICCategoryVendor', 'Categories', 'Inventory'),
		
---------------------------------------------------------------------------------------------------

--##   IC Commodities
--##-----------------------------------------------------------------------------------------------

		('tblICCommodity', 'Commodities', 'Inventory'),
		('tblICCommodityAccount', 'Commodities', 'Inventory'),
		('tblICCommodityAttribute', 'Commodities', 'Inventory'),
		('tblICCommodityGroup', 'Commodities', 'Inventory'),
		('tblICCommodityProductLine', 'Commodities', 'Inventory'),
		('tblICCommodityUnitMeasure', 'Commodities', 'Inventory'),
		('tblICUnitMeasure', 'Commodities', 'Inventory'),
		

				
		
---------------------------------------------------------------------------------------------------

--##   IC UOM
--##-----------------------------------------------------------------------------------------------

		('tblICUnitMeasure', 'Inventory UOM', 'Inventory'),
		('tblICUnitMeasureConversion', 'Inventory UOM', 'Inventory'),

---------------------------------------------------------------------------------------------------


--##   IC Items
--##-----------------------------------------------------------------------------------------------

		('tblICItem', 'Items', 'Inventory'),
		('tblICItemAccount', 'Items', 'Inventory'),
		('tblICItemAssembly', 'Items', 'Inventory'),
		('tblICItemBundle', 'Items', 'Inventory'),
		('tblICItemCertification', 'Items', 'Inventory'),
		('tblICItemCommodityCost', 'Items', 'Inventory'),
		('tblICItemContract', 'Items', 'Inventory'),
		('tblICItemContractDocument', 'Items', 'Inventory'),
		('tblICItemCustomerXref', 'Items', 'Inventory'),
		('tblICItemFactory', 'Items', 'Inventory'),
		('tblICItemFactoryManufacturingCell', 'Items', 'Inventory'),
		('tblICItemKit', 'Items', 'Inventory'),
		('tblICItemKitDetail', 'Items', 'Inventory'),
		('tblICItemLicense', 'Items', 'Inventory'),
		('tblICItemLocation', 'Items', 'Inventory'),
		('tblICItemManufacturingUOM', 'Items', 'Inventory'),
		('tblICItemMotorFuelTax', 'Items', 'Inventory'),
		('tblICItemNote', 'Items', 'Inventory'),
		('tblICItemOwner', 'Items', 'Inventory'),
		('tblICItemPOSCategory', 'Items', 'Inventory'),
		('tblICItemPOSSLA', 'Items', 'Inventory'),
		('tblICItemPricing', 'Items', 'Inventory'),
	--	('tblICItemPricingLevel', 'Items', 'Inventory'),
		('tblICItemSpecialPricing', 'Items', 'Inventory'),
		('tblICItemStockType', 'Items', 'Inventory'),
	--	('tblICItemStockUOM', 'Items', 'Inventory'),
		('tblICItemSubLocation', 'Items', 'Inventory'),
		('tblICItemSubstitution', 'Items', 'Inventory'),
		('tblICItemSubstitutionDetail', 'Items', 'Inventory'),
		('tblICItemUOM', 'Items', 'Inventory'),
		('tblICItemUPC', 'Items', 'Inventory'),
		('tblICItemVendorXref', 'Items', 'Inventory'),

---------------------------------------------------------------------------------------------------


--IC Storage Units
--##-----------------------------------------------------------------------------------------------

		('tblICStorageUnitType', 'Storage Units', 'Inventory'),
		('tblICStorageLocation', 'Storage Units', 'Inventory'),

---------------------------------------------------------------------------------------------------



--########################
--##   Purchasing(AP)   ##---------------------------------------------------------------------------
--########################


--##   Vendors
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity ', 'Vendors', 'Purchasing'),
		('tblAPVendor', 'Vendors', 'Purchasing'),
		('tblAPVendorLien', 'Vendors', 'Purchasing'),
		('tblAPVendorPricing', 'Vendors', 'Purchasing'),
		('tblAPVendorSpecialTax', 'Vendors', 'Purchasing'),
		('tblAPVendorTaxException', 'Vendors', 'Purchasing'),
		('tblAPVendorTerm', 'Vendors', 'Purchasing'),

---------------------------------------------------------------------------------------------------



--#################
--##   Sales(AR) ##------------------------------------------------------------------------------------
--#################


--##   Customer
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity ', 'Customer', 'Sales'),
		('tblARAccountStatus', 'Customer', 'Sales'),
		('tblTRSupplyPoint','Customer','Sales'),
		('tblARCustomer', 'Customer', 'Sales'),
		('tblARCustomerAccountStatus', 'Customer', 'Sales'),
		('tblARCustomerApplicatorLicense', 'Customer', 'Sales'),
		('tblARCustomerBudget', 'Customer', 'Sales'),
		('tblARCustomerBuyback', 'Customer', 'Sales'),
		('tblARCustomerCardFueling', 'Customer', 'Sales'),
		('tblARCustomerCategoryPrice ', 'Customer', 'Sales'),
		('tblARCustomerCommission', 'Customer', 'Sales'),
		('tblARCustomerCompetitor', 'Customer', 'Sales'),
		('tblARCustomerContract', 'Customer', 'Sales'),
		('tblARCustomerContractDetail', 'Customer', 'Sales'),
		('tblARCustomerFailedImport', 'Customer', 'Sales'),
		('tblARCustomerFarm', 'Customer', 'Sales'),
		('tblARCustomerFieldXRef', 'Customer', 'Sales'),
		('tblARCustomerFreightXRef', 'Customer', 'Sales'),
		('tblARCustomerGroup', 'Customer', 'Sales'),
		('tblARCustomerGroupDetail', 'Customer', 'Sales'),
		('tblARCustomerLicenseInformation', 'Customer', 'Sales'),
		('tblARCustomerLicenseModule', 'Customer', 'Sales'),
		('tblARCustomerLineOfBusiness', 'Customer', 'Sales'),
		('tblARCustomerMasterLicense ', 'Customer', 'Sales'),
		('tblARCustomerMessage','Customer','Sales'),
		('tblARCustomerPortalMenu', 'Customer', 'Sales'),
		('tblARCustomerProductVersion', 'Customer', 'Sales'),
		('tblARCustomerQuote', 'Customer', 'Sales'),
		('tblARCustomerRackQuoteCategory', 'Customer', 'Sales'),
		('tblARCustomerRackQuoteHeader', 'Customer', 'Sales'),
		('tblARCustomerRackQuoteVendor', 'Customer', 'Sales'),
		('tblARCustomerSpecialPrice ', 'Customer', 'Sales'),
		('tblARCustomerSplit', 'Customer', 'Sales'),
		('tblARCustomerSplitDetail', 'Customer', 'Sales'),
		('tblARCustomerTaxingTaxException', 'Customer', 'Sales'),

---------------------------------------------------------------------------------------------------
		

--##   AR Sales Rep
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity', 'Sales Rep', 'Sales'),
		('tblARSalesperson', 'Sales Rep', 'Sales'),

---------------------------------------------------------------------------------------------------


 
--#############################
--##   Contract Management   ##------------------------------------------------------------------------
--#############################


--##   AOP Vs Actual ***
--##-----------------------------------------------------------------------------------------------
		('tblCTAOP', 'AOP Vs Actual', 'Contract Management'),
			('tblCTAOPDetail', 'AOP Vs Actual', 'Contract Management'),

--##   Associations
--##-----------------------------------------------------------------------------------------------

		('tblCTAssociation', 'Associations', 'Contract Management'),

---------------------------------------------------------------------------------------------------
		

--##   Certification ***
--##-----------------------------------------------------------------------------------------------
		('tblICCertification', 'Certification', 'Contract Management'),


--##   Condition
--##-----------------------------------------------------------------------------------------------

		('tblCTCondition', 'Condition', 'Contract Management'),

---------------------------------------------------------------------------------------------------


--##   Contract Position ***
--##-----------------------------------------------------------------------------------------------
		('tblCTPosition', 'Contract Position', 'Contract Management'),


--##   Documents
--##-----------------------------------------------------------------------------------------------

		('tblICDocument', 'Documents', 'Contract Management'),

---------------------------------------------------------------------------------------------------
		

--##   INCO/Ship Term ***
--##-----------------------------------------------------------------------------------------------

		('tblCTContractBasis', 'INCO/Ship Term', 'Contract Management'),

---------------------------------------------------------------------------------------------------
--##   Weight/Grades ***
--##-----------------------------------------------------------------------------------------------

		('tblCTWeightGrade', 'Weight/Grades', 'Contract Management'),

---------------------------------------------------------------------------------------------------
 

--#################  
--##   Payroll   ##--------------------------------------------------------------------------------------
--#################


--##   PR Employee
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity', 'Employee', 'Payroll'),
		('tblPREmployee', 'Employee', 'Payroll'),
		('tblPREmployeeRank', 'Employee', 'Payroll'),
		('tblPRWorkersCompensation', 'Employee', 'Payroll'),

---------------------------------------------------------------------------------------------------



--#########################
--##   Risk Management   ##-------------------------------------------------------------------------------
--#########################


--##-----------------------------------------------------------------------------------------------
	--  Brokerage Account
		('tblRKBrokerageAccount', 'Brokerage Account', 'Risk Management'),
		('tblRKTradersbyBrokersAccountMapping', 'Brokerage Account', 'Risk Management'),
		('tblRKBrokerageCommission', 'Brokerage Account', 'Risk Management'),

---------------------------------------------------------------------------------------------------
		

	--  Futures Broker ***
		('tblEMEntity', 'Futures Broker', 'Risk Management'),
	
	--	Futures Market ***
		('tblRKFutureMarket', 'Futures Market', 'Risk Management'),
		('tblRKCommodityMarketMapping', 'Futures Market', 'Risk Management'),		
	
	--	Futures Trading Month ***
		('tblRKFuturesMonth', 'Futures Trading Month', 'Risk Management'),		
	
	--	Options Trading Month ***
		('tblRKOptionsMonth', 'Options Trading Month', 'Risk Management'),		

	--	Settlement Price  ***
		('tblRKFuturesSettlementPrice', 'Settlement Price', 'Risk Management'),
		('tblRKFutSettlementPriceMarketMap', 'Settlement Price', 'Risk Management'),
		('tblRKOptSettlementPriceMarketMap', 'Settlement Price', 'Risk Management'),
	
	--	Basis Entry ***
		('tblRKM2MBasis', 'Basis Entry', 'Risk Management'),	
		('tblRKM2MBasisDetail', 'Basis Entry', 'Risk Management'),	


--###################
--##   Logistics   ##-------------------------------------------------------------------------------------
--###################


--##   Container Types 
--##-----------------------------------------------------------------------------------------------

		('tblLGContainerType', 'Container Types', 'Logistics'),
		('tblLGContainerTypeCommodityQty', 'Container Types', 'Logistics'),

---------------------------------------------------------------------------------------------------

	
--##   Equipment Types ***
--##-----------------------------------------------------------------------------------------------

		('tblLGEquipmentType', 'Equipment Types', 'Logistics'),


--##   Forwarding Agents ***
--##-----------------------------------------------------------------------------------------------
		('tblEMEntity', 'Forwarding Agents', 'Logistics'),


--##   Insurers	***		
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity', 'Insurers', 'Logistics'),
		('tblLGInsurancePremiumFactor', 'Insurers', 'Logistics'),
		('tblLGInsurancePremiumFactorDetail', 'Insurers', 'Logistics'),
	
--##   Reason Code 
--##-----------------------------------------------------------------------------------------------

		('tblLGReasonCode', 'Reason Code', 'Logistics'),

---------------------------------------------------------------------------------------------------
		
	
--##   Shipping Lines ***
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity', 'Shipping Lines', 'Logistics'),
		('tblLGShippingLineServiceContract', 'Shipping Lines', 'Logistics'),
		('tblLGShippingLineServiceContractDetail', 'Shipping Lines', 'Logistics'),

---------------------------------------------------------------------------------------------------	

--##   Shipping Mode 
--##-----------------------------------------------------------------------------------------------

		('tblLGShippingMode', 'Shipping Mode', 'Logistics'),
			
---------------------------------------------------------------------------------------------------
			

--##   Terminals ***
--##-----------------------------------------------------------------------------------------------

		('tblEMEntity', 'Terminals', 'Logistics'),
	

--##   Warehouse Rate Matrix 
--##-----------------------------------------------------------------------------------------------

		('tblLGWarehouseRateMatrixDetail', 'Warehouse Rate Matrix', 'Logistics'),
		('tblLGWarehouseRateMatrixHeader', 'Warehouse Rate Matrix', 'Logistics'),

---------------------------------------------------------------------------------------------------
		


--#################
--##   Quality   ##------------------------------------------------------------------------------
--#################


--##   Quality Parameters Quality Parameters
--##-----------------------------------------------------------------------------------------------

		('tblQMAttribute', 'Quality Parameters', 'Quality'),
		('tblQMAttributeDataType', 'Quality Parameters', 'Quality'),
		('tblQMList', 'Quality Parameters', 'Quality'),
		('tblQMListItem', 'Quality Parameters', 'Quality'),
		('tblQMSampleType', 'Quality Parameters', 'Quality'),
		('tblQMSampleTypeDetail', 'Quality Parameters', 'Quality'),
		('tblQMSampleTypeUserRole', 'Quality Parameters', 'Quality'),
		('tblQMSampleLabel', 'Quality Parameters', 'Quality'),
		('tblQMProperty', 'Quality Parameters', 'Quality'),
		('tblQMPropertyValidityPeriod', 'Quality Parameters', 'Quality'),
		('tblQMConditionalProperty', 'Quality Parameters', 'Quality'),
		('tblQMTest', 'Quality Parameters', 'Quality'),
		('tblQMTestMethod', 'Quality Parameters', 'Quality'),
		('tblQMTestProperty', 'Quality Parameters', 'Quality'),
		('tblQMProduct', 'Quality Parameters', 'Quality'),
		('tblQMProductControlPoint', 'Quality Parameters', 'Quality'),
		('tblQMProductTest', 'Quality Parameters', 'Quality'),
		('tblQMProductProperty', 'Quality Parameters', 'Quality'),
		('tblQMProductPropertyValidityPeriod', 'Quality Parameters', 'Quality'),
		('tblQMConditionalProductProperty', 'Quality Parameters', 'Quality'),
		('tblQMProductPropertyFormulaProperty', 'Quality Parameters', 'Quality'),




--########################		
--##   Scale  ##---------------------------------------------------------------------------
--########################
		
	('tblSCScaleSetup', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),					
	('tblSCDistributionOption', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCDeliverySheetImportingTemplate', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCListTicketTypes', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTicketEmailOption', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTicketFormat', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTicketPrintOption', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCScaleDevice', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTicketPool', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTicketType', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCDeliverySheetImportingTemplateDetail', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCScaleOperator', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCTruckDriverReference', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCLastScaleSetup', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),
	('tblSCUncompletedTicketAlert', 'Scale Station, Ticket Pool, Truck/Driver/Reference, Ticket Format(Print Out) and Physical Scale/Grade', 'Scale'),

--##------------------------------------------------------------------------------------------------




--########################		
--##  Manufacturing  ##---------------------------------------------------------------------------
--########################
	('tblMFBlendValidation', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFBuyingGroup', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFCompanyPreference', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFDepartment', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFHaldheldUserMenuItemMap', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFHandheldMenuItem', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFHolidayCalendar', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFInventoryShipmentRestrictionType', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemChangeMap', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemContamination', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemContaminationDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemGradeDiff', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemGroup', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemMachine', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemOwner', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemSubstitution', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemSubstitutionDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemSubstitutionRecipe', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFItemSubstitutionRecipeDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFLotStatusException', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFMachine', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFMachineMeasurement', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFMachinePackType', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFManufacturingCell', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFManufacturingCellPackType', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFManufacturingProcess', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFManufacturingProcessAttribute', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFManufacturingProcessMachine', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFNutrient', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFOrderDirection', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFPackType', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFPackTypeDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFParentLotNumberPattern', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFPattern', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFPatternByCategory', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFPatternDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFReasonCode', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFReasonCodeDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipe', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeAlertLog', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeCategory', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeGuide', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeGuideNutrient', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeItem', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeItemStage', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeStage', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeSubstituteItem', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFRecipeSubstituteItemStage', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFReportCategory', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFReportCategoryByCustomer', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFReportLabel', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleChangeoverFactor', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleChangeoverFactorDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleConstraint', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleConstraintDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleGroup', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleGroupDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFScheduleRule', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFShift', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFShiftBreakType', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFShiftDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFStorageLocationRestrictionTypeLotStatus', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFUserPrinterMap', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFUserRoleEventMap', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFYield', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),
	('tblMFYieldDetail', 'Recipe, Machine, Manufacturing Process,Manufacturing Cell,Pack type, Shift, Schedule change over, and Schedule rule', 'Manufacturing'),

--##------------------------------------------------------------------------------------------------










---------------------------------------------------------------------------------------------------
-------------				end of Parent to Subsidiary           ------------------------------
---------------------------------------------------------------------------------------------------



--*****************************************************************************
--*****************************************************************************
---***********    			 Subsidiary to Parent        **********************
--*****************************************************************************
--*****************************************************************************



--#############################
--##   Contract Management   ##-------------------------------------------------
--#############################


--## CT Contracts 
--##-----------------------------------------------------------------------------------------------

		('tblCTContractCost', 'Contracts', 'Contract Management'),
		('tblCTContractDetail', 'Contracts', 'Contract Management'),
		('tblCTContractHeader', 'Contracts', 'Contract Management'),
		('tblCTContractDocument', 'Contracts', 'Contract Management'),
		('tblCTContractProducer', 'Contracts', 'Contract Management'),
		('tblCTContractCondition', 'Contracts', 'Contract Management'),
		('tblCTContractCertification', 'Contracts', 'Contract Management'),
		('tblCTPriceContract', 'Contracts', 'Contract Management'),
		('tblCTPriceFixation', 'Contracts', 'Contract Management'),
		('tblCTPriceFixationDetail', 'Contracts', 'Contract Management'),

---------------------------------------------------------------------------------------------------
		

--###################
--##   Logistics   ##-----------------------------------------------------------------------------
--###################

--##   LG Load and Shipment Schedules
--##-----------------------------------------------------------------------------------------------

		('tblLGGenerateLoad', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoad', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadContainer', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadContainerCost', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadCost', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadDetail', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadDetailContainerCost', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadDetailContainerLink', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadDetailLot', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadNotifyParties', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadStorageCost', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadWarehouse', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadWarehouseContainer', 'Load and Shipment Schedules', 'Logistics'),
		('tblLGLoadDocuments', 'Load and Shipment Schedules', 'Logistics'),

---------------------------------------------------------------------------------------------------

--##   LG Weight Claims
--##-----------------------------------------------------------------------------------------------

		('tblLGWeightClaim', 'Weight Claims', 'Logistics'),
		('tblLGWeightClaimDetail', 'Weight Claims', 'Logistics'),

---------------------------------------------------------------------------------------------------


--###################
--##   Inventory   ##--------------------------------------------------------------    
--###################

--##   IC Inventory Receipts
--##-----------------------------------------------------------------------------------------------

		('tblICInventoryReceipt', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptCharge', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptChargePerItem', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptChargeTax', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptInspection', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptItem', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptItemAllocatedCharge', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptItemLot', 'Inventory Receipts', 'Inventory'),
		('tblICInventoryReceiptItemTax', 'Inventory Receipts', 'Inventory'),



---------------------------------------------------------------------------------------------------
		

--##   IC Inventory Shipments
--##-----------------------------------------------------------------------------------------------

		('tblICInventoryShipment', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentCharge', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentChargePerItem', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentChargeTax', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentItem', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentItemAllocatedCharge', 'Inventory Shipments', 'Inventory'),
		('tblICInventoryShipmentItemLot', 'Inventory Shipments', 'Inventory'),


---------------------------------------------------------------------------------------------------


--##   IC Inventory Transfers
--##-----------------------------------------------------------------------------------------------

		('tblICInventoryTransfer', 'Inventory Transfers', 'Inventory'),
		('tblICInventoryTransferDetail', 'Inventory Transfers', 'Inventory'),

---------------------------------------------------------------------------------------------------		


--##   IC Inventory Adjustment
--##-----------------------------------------------------------------------------------------------

		('tblICInventoryAdjustment', 'Inventory Adjustment', 'Inventory'),
		('tblICInventoryAdjustmentDetail', 'Inventory Adjustment', 'Inventory'),

---------------------------------------------------------------------------------------------------


--##   IC Inventory Count
--##-----------------------------------------------------------------------------------------------

		('tblICInventoryCount', 'Inventory Count', 'Inventory'),
		('tblICInventoryCountDetail', 'Inventory Count', 'Inventory'),

---------------------------------------------------------------------------------------------------		


--##   IC Inventory Transaction / Inventory Valuation
--##------------------------------------------------------------------------------------------------

		('tblICInventoryActualCost', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryActualCostAdjustmentLog', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryActualCostOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryCostAdjustmentType', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryFIFO', 'Inventory Valuation', 'Inventory'),                              
		('tblICInventoryFIFOCostAdjustmentLog  ', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryFIFOOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryFIFORevalueOutStock', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryFIFOStorage', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryFIFOStorageOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryGLAccountUsedOnPostLog', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLIFO', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLIFOCostAdjustmentLog', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLIFOOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLIFOStorage', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLIFOStorageOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLot', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotCostAdjustmentLog', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotStorage', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotStorageOut', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotTransaction', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryLotTransactionStorage', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryTransaction', 'Inventory Valuation', 'Inventory'),
		('tblICInventoryTransactionStorage', 'Inventory Valuation', 'Inventory'),
		('tblICItemStock', 'Inventory Valuation', 'Inventory'),
		('tblICItemStockUOM', 'Inventory Valuation', 'Inventory'),
		('tblICItemStockDetail', 'Inventory Valuation', 'Inventory'),
		('tblICStockReservation', 'Inventory Valuation', 'Inventory'),
		('tblICItemPricing', 'Inventory Valuation', 'Inventory'),
		('tblICLot', 'Inventory Valuation', 'Inventory'),
		('tblICLotStatus', 'Inventory Valuation', 'Inventory'),
		('tblICParentLot', 'Inventory Valuation', 'Inventory'),

----------------------------------------------------------------------------------------------


--####################
--##   Purchasing   ##-------------------------------------------------------------------------
--####################

--##   AP Vouchers
--##------------------------------------------------------------------------------------------

		('tblAPBill', 'Vouchers', 'Purchasing'),
		('tblAPBillBatch', 'Vouchers', 'Purchasing'),
		('tblAPBillDetail', 'Vouchers', 'Purchasing'),
		('tblAPBillDetailTax', 'Vouchers', 'Purchasing'),

-----------------------------------------------------------------------------------------------



--###############
--##   Sales   ##------------------------------------------------------------------------------
--###############

--##   AR Invoices
--##------------------------------------------------------------------------------------------------


		('tblARInvoice', 'Invoices', 'Sales'),
		('tblARInvoiceAccrual', 'Invoices', 'Sales'),
		('tblARInvoiceDetail', 'Invoices', 'Sales'),
		('tblARInvoiceDetailComponent', 'Invoices', 'Sales'),
		('tblARInvoiceDetailCondition', 'Invoices', 'Sales'),
		('tblARInvoiceDetailTax', 'Invoices', 'Sales'),

------------------------------------------------------------------------------------------------



--#########################
--##   Risk Management   ##---------------------------------------------------------------------
--#########################

--##   RM Derivative Entry
--##   RM Assign Derivative
--##   RM Match Derivative
--##   RM Option Lifecycle
--##------------------------------------------------------------------------------------------------


		('tblRKFutOptTransactionHeader', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKAssignFuturesToContractSummary', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKAssignFuturesToContractSummaryHeader', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKOptionsMatchPnS', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKOptionsPnSExpired', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKMatchFuturesPSHeader', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKFutOptTransaction', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKOptionsMatchPnSHeader', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKOptionsPnSExercisedAssigned', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),
		('tblRKMatchFuturesPSDetail', 'RM Derivative Entry, RM Assign Derivative, RM Match Derivative and RM Option Lifecycle', 'Risk Management'),

--------------------------------------------------------------------------------------------------



--#################
--##   Quality   ##--------------------------------------------------------------------------------
--#################

--##   QM Sample Entry  	
--##------------------------------------------------------------------------------------------------


		('tblQMSample', 'Sample Entry', 'Risk Management'),
		('tblQMSampleDetail', 'Sample Entry', 'Risk Management'),
		('tblQMTestResult', 'Sample Entry', 'Risk Management'),

----------------------------------------------------------------------------------------------------

		
		
--########################		
--##   General Ledger   ##---------------------------------------------------------------------------
--########################

--##   GL Transaction
--##------------------------------------------------------------------------------------------------


	   ('tblGLDetail', 'Transaction', 'General Ledger'),  
   
-----------------------------------------------------------------------------------------------------


--########################		
--##   Scale  ##---------------------------------------------------------------------------
--########################

--##------------------------------------------------------------------------------------------------

	('tblSCTicket', 'Scale Transaction', 'Scale'),
	('tblSCTicketSplit', 'Scale Transaction', 'Scale'),
	('tblSCTicketHistory', 'Scale Transaction', 'Scale'),
	('tblQMTicketDiscount', 'Scale Transaction', 'Scale'),
	('tblSCTicketContractUsed', 'Scale Transaction', 'Scale'),
	('tblSCTicketDiscount', 'Scale Transaction', 'Scale'),
	('tblSCTicketLVStaging', 'Scale Transaction', 'Scale'),
	('tblSCTicketDiscountLVStaging', 'Scale Transaction', 'Scale'),
	('tblSCTicketStorageType', 'Scale Transaction', 'Scale'),
	('tblSCTicketCost', 'Scale Transaction', 'Scale'),
	('tblSCDeliverySheet', 'Scale Transaction', 'Scale'),
	('tblSCDeliverySheetSplit', 'Scale Transaction', 'Scale'),
	('tblSCDeliverySheetHistory', 'Scale Transaction', 'Scale'),

	   

-----------------------------------------------------------------------------------------------------

--########################		
--##   Manufacturing   ##---------------------------------------------------------------------------
--########################


--##------------------------------------------------------------------------------------------------

			('tblMFBlendDemand', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFBlendProductionOutputDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFBlendRequirement', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFBlendRequirementRule', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFBudget', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFBudgetLog', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFCustomFieldValue', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFDowntime', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFDowntimeMachines', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFForecastItemValue', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFInventoryAdjustment', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFItemDemand', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFItemOwnerDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFLotInventory', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFLotSnapshot', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFLotSnapshotDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFLotTareWeight', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFOrderDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFOrderHeader', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFOrderManifest', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFOrderManifestLabel', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'), 
			('tblMFPickForWOStaging', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFPickList', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFPickListDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFProcessCycleCount', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFProcessCycleCountMachine', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFProcessCycleCountSession', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFProductionSummary', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFSchedule', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleCalendar', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleCalendarDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleCalendarMachineDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduledMaintenance', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduledMaintenanceDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleMachineDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleWorkOrder', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFScheduleWorkOrderDetail', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFShiftActivity', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFShiftActivityMachines', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFStageWorkOrder', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFTask', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWastage', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrder', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderConsumedLot', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderInputLot', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderInputParentLot', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderItem', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderProducedLot', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderProducedLotTransaction', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderProductSpecification', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipe', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeCategory', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeComputation', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeComputationMethod', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeComputationType', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeItem', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFWorkOrderRecipeSubstituteItem', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing'),
			('tblMFPatternSequence', 'Blend production, Process production, FG Production, Bag off, Work Order, Production calendar, and Work Order Schedule', 'Manufacturing') 
		

	
-----------------------------------------------------------------------------------------------------






		DECLARE @intModuleId int,
				@Id int,
				@intScreenId int,
				@intReplicationTableId int,
				@intReplicationConfigurationId int,
				@table NVARCHAR(MAX),
				@screen NVARCHAR(MAX),
				@module NVARCHAR(MAX);


		WHILE  (SELECT TOP 1 count(*) FROM @ListOfScreenTables) != 0
		BEGIN

			SET @table = null;
			SET @screen = null;
			SET	@module = null;
			SELECT Top 1 @Id = id, @table = strArticle, @screen = strScreen, @module = strModule FROM @ListOfScreenTables;		


			SET @intModuleId = null;
			SELECT @intModuleId = intModuleId FROM tblSMModule WHERE strModule = @module
			
			SET @intReplicationConfigurationId = null;
			IF @intModuleId IS NOT NULL
			BEGIN
				SELECT TOP 1 @intReplicationConfigurationId = intReplicationConfigurationId FROM tblSMReplicationConfiguration WHERE intModuleId = @intModuleId AND strScreen = @screen
			END

			SET @intReplicationTableId = null		
			SELECT TOP 1 @intReplicationTableId = intReplicationTableId FROM tblSMReplicationTable WHERE strTableName = @table
			
			IF @intReplicationConfigurationId IS NOT NULL AND @intReplicationTableId IS NOT NULL
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMReplicationConfigurationTable WHERE intReplicationConfigurationId = @intReplicationConfigurationId AND intReplicationTableId = @intReplicationTableId)
				BEGIN
						INSERT INTO tblSMReplicationConfigurationTable (intReplicationConfigurationId, intReplicationTableId)
						VALUES (@intReplicationConfigurationId, @intReplicationTableId)
				END
			END
			

			DELETE from @ListOfScreenTables Where id = @Id
		END		


		PRINT N'END OF REPLICATION CONFIGURATION TABLES'



