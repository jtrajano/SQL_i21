﻿CREATE TABLE tblICItemStage (
	intItemStageId INT identity(1, 1) CONSTRAINT PK_tblICItemStage_intItemStageId PRIMARY KEY
	,intItemId INT
	,strItemXML NVARCHAR(MAX)
	,strItemAccountXML NVARCHAR(MAX)
	,strItemAddOnXML NVARCHAR(MAX)
	,strItemAssemblyXML NVARCHAR(MAX)
	,strItemBundleXML NVARCHAR(MAX)
	,strItemCertificationXML NVARCHAR(MAX)
		,strItemCommodityCostXML NVARCHAR(MAX)
		,strItemContractXML NVARCHAR(MAX)
		,strItemContractDocumentXML NVARCHAR(MAX)
		,strItemCustomerXrefXML NVARCHAR(MAX)
		,strItemFactoryXML NVARCHAR(MAX)
		,strItemFactoryManufacturingCellXML NVARCHAR(MAX)
		,strItemKitXML NVARCHAR(MAX)
		,strItemKitDetailXML NVARCHAR(MAX)
		,strItemLicenseXML NVARCHAR(MAX)
		,strItemLocationXML NVARCHAR(MAX)
		,strItemManufacturingUOMXML NVARCHAR(MAX)
		,strItemMotorFuelTaxXML NVARCHAR(MAX)
		,strItemNoteXML NVARCHAR(MAX)
		,strItemOwnerXML NVARCHAR(MAX)
		,strItemPOSCategoryXML NVARCHAR(MAX)
		,strItemPOSSLAXML NVARCHAR(MAX)
		,strItemPricingXML NVARCHAR(MAX)
		,strItemPricingLevelXML NVARCHAR(MAX)
		,strItemSpecialPricingXML NVARCHAR(MAX)
		,strItemSubLocationXML NVARCHAR(MAX)
		,strItemSubstituteXML NVARCHAR(MAX)
		,strItemSubstitutionXML NVARCHAR(MAX)
		,strItemSubstitutionDetailXML NVARCHAR(MAX)
		,strItemUOMXML NVARCHAR(MAX)
		,strItemUOMUpcXML NVARCHAR(MAX)
		,strItemUPCXML NVARCHAR(MAX)
		,strItemVendorXrefXML NVARCHAR(MAX)
		,strItemBookXML NVARCHAR(MAX)
	,strRowState NVARCHAR(50)
	,strUserName NVARCHAR(50)
	,intMultiCompanyId INT
	,strFeedStatus NVARCHAR(50)
	,strMessage NVARCHAR(MAX)
	)
