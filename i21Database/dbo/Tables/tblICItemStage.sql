CREATE TABLE tblICItemStage (
	intItemStageId INT identity(1, 1) CONSTRAINT PK_tblICItemStage_intItemStageId PRIMARY KEY
	,intItemId INT
	,strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS
	,strItemXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemAccountXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemAddOnXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemAssemblyXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemBundleXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemCertificationXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemCommodityCostXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemContractXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemContractDocumentXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemCustomerXrefXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemFactoryXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemFactoryManufacturingCellXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemKitXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemKitDetailXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemLicenseXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemLocationXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemManufacturingUOMXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemMotorFuelTaxXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemNoteXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemOwnerXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemPOSCategoryXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemPOSSLAXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemPricingXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemPricingLevelXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemSpecialPricingXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemSubLocationXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemSubstituteXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemSubstitutionXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemSubstitutionDetailXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemUOMXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemUOMUpcXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemUPCXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemVendorXrefXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemBookXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intMultiCompanyId INT
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intTransactionId int
    ,intCompanyId int
	,ysnMailSent Bit
	)
