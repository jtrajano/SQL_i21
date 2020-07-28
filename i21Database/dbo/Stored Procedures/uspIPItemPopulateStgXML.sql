CREATE PROCEDURE uspIPItemPopulateStgXML @intItemId INT
	,@strRowState NVARCHAR(50)
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strItemXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strItemAccountXML NVARCHAR(MAX)
		,@strItemAddOnXML NVARCHAR(MAX)
		,@strItemAssemblyXML NVARCHAR(MAX)
		,@strItemBundleXML NVARCHAR(MAX)
		,@strItemCertificationXML NVARCHAR(MAX)
		,@strItemCommodityCostXML NVARCHAR(MAX)
		,@strItemContractXML NVARCHAR(MAX)
		,@strItemContractDocumentXML NVARCHAR(MAX)
		,@strItemCustomerXrefXML NVARCHAR(MAX)
		,@strItemFactoryXML NVARCHAR(MAX)
		,@strItemFactoryManufacturingCellXML NVARCHAR(MAX)
		,@strItemKitXML NVARCHAR(MAX)
		,@strItemKitDetailXML NVARCHAR(MAX)
		,@strItemLicenseXML NVARCHAR(MAX)
		,@strItemLocationXML NVARCHAR(MAX)
		,@strItemManufacturingUOMXML NVARCHAR(MAX)
		,@strItemMotorFuelTaxXML NVARCHAR(MAX)
		,@strItemNoteXML NVARCHAR(MAX)
		,@strItemOwnerXML NVARCHAR(MAX)
		,@strItemPOSCategoryXML NVARCHAR(MAX)
		,@strItemPOSSLAXML NVARCHAR(MAX)
		,@strItemPricingXML NVARCHAR(MAX)
		,@strItemPricingLevelXML NVARCHAR(MAX)
		,@strItemSpecialPricingXML NVARCHAR(MAX)
		,@strItemSubLocationXML NVARCHAR(MAX)
		,@strItemSubstituteXML NVARCHAR(MAX)
		,@strItemSubstitutionXML NVARCHAR(MAX)
		,@strItemSubstitutionDetailXML NVARCHAR(MAX)
		,@strItemUOMXML NVARCHAR(MAX)
		,@strItemUOMUpcXML NVARCHAR(MAX)
		,@strItemUPCXML NVARCHAR(MAX)
		,@strItemVendorXrefXML NVARCHAR(MAX)
		,@strItemBookXML NVARCHAR(MAX)
		,@intCompanyId INT
		,@intTransactionId INT
		,@intItemScreenId INT
		,@strItemNo NVARCHAR(50)

	SET @strItemXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strItemNo = NULL

	SELECT @intCompanyId = intCompanyId
		,@strItemNo = strItemNo
	FROM tblICItem
	WHERE intItemId = @intItemId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intItemId = ' + LTRIM(@intItemId)

	SELECT @strObjectName = 'vyuIPGetItem'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemXML OUTPUT
		,NULL
		,NULL

	SELECT @strLastModifiedUser = t.strName
	FROM tblEMEntity t
	JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
	WHERE ET.strType = 'User'
		AND t.intEntityId = @intUserId
		AND t.strEntityNo <> ''

	IF @strLastModifiedUser IS NULL
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblSMUserSecurity
				WHERE strUserName = 'irelyadmin'
				)
			SELECT TOP 1 @intUserId = intEntityId
				,@strLastModifiedUser = strUserName
			FROM tblSMUserSecurity
			WHERE strUserName = 'irelyadmin'
		ELSE
			SELECT TOP 1 @intUserId = intEntityId
				,@strLastModifiedUser = strUserName
			FROM tblSMUserSecurity
	END

	SELECT @strObjectName = 'vyuIPGetItemAccount'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemAccountXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemAddOn'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemAddOnXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemAssembly'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemAssemblyXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemBundle'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemBundleXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemCertification'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemCertificationXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemCommodityCost'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemCommodityCostXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemContract'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemContractXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemContractDocument'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemContractDocumentXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemCustomerXref'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemCustomerXrefXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemFactory'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemFactoryXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemFactoryManufacturingCell'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemFactoryManufacturingCellXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemKit'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemKitXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemKitDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemKitDetailXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemLicense'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemLicenseXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemLocation'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemLocationXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemManufacturingUOM'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemManufacturingUOMXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemMotorFuelTax'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemMotorFuelTaxXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemNote'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemNoteXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemOwner'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemOwnerXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemPOSCategory'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemPOSCategoryXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemPOSSLA'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemPOSSLAXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemPricing'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemPricingXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemPricingLevel'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemPricingLevelXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemSpecialPricing'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSpecialPricingXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemSubLocation'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSubLocationXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemSubstitute'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSubstituteXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemSubstitution'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSubstitutionXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemSubstitutionDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemSubstitutionDetailXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemUOM'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemUOMXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemUomUpc'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemUOMUpcXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemUPC'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemUPCXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemVendorXref'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemVendorXrefXML OUTPUT
		,NULL
		,NULL

	SELECT @strObjectName = 'vyuIPGetItemBook'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemBookXML OUTPUT
		,NULL
		,NULL

	SELECT @intItemScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'Inventory.view.Item'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intRecordId = @intItemId
		AND intScreenId = @intItemScreenId

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)
		,@intMultiCompanyId INT

	SELECT @intMultiCompanyId = min(intCompanyId)
	FROM tblIPMultiCompany
	WHERE ysnParent = 0

	WHILE @intMultiCompanyId IS NOT NULL
	BEGIN
		SELECT @strServerName = strServerName
			,@strDatabaseName = strDatabaseName
		FROM tblIPMultiCompany
		WHERE intCompanyId = @intMultiCompanyId

		IF EXISTS (
				SELECT 1
				FROM master.dbo.sysdatabases
				WHERE name = @strDatabaseName
				)
		BEGIN
			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + 
				'.dbo.tblICItemStage (
		intItemId
		,strItemNo
		,strItemXML
		,strItemAccountXML
		,strItemAddOnXML
		,strItemAssemblyXML
		,strItemBundleXML
		,strItemCertificationXML
		,strItemCommodityCostXML
		,strItemContractXML
		,strItemContractDocumentXML
		,strItemCustomerXrefXML
		,strItemFactoryXML
		,strItemFactoryManufacturingCellXML
		,strItemKitXML
		,strItemKitDetailXML
		,strItemLicenseXML
		,strItemLocationXML
		,strItemManufacturingUOMXML
		,strItemMotorFuelTaxXML
		,strItemNoteXML
		,strItemOwnerXML
		,strItemPOSCategoryXML
		,strItemPOSSLAXML
		,strItemPricingXML
		,strItemPricingLevelXML
		,strItemSpecialPricingXML
		,strItemSubLocationXML
		,strItemSubstituteXML
		,strItemSubstitutionXML
		,strItemSubstitutionDetailXML
		,strItemUOMXML
		,strItemUOMUpcXML
		,strItemUPCXML
		,strItemVendorXrefXML
		,strItemBookXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		,intTransactionId 
        ,intCompanyId 
		)
	SELECT intItemId = @intItemId
		,strItemNo=@strItemNo
		,strItemXML = @strItemXML
		,strItemAccountXML = @strItemAccountXML
		,strItemAddOnXML = @strItemAddOnXML
		,strItemAssemblyXML = @strItemAssemblyXML
		,strItemBundleXML = @strItemBundleXML
		,strItemCertificationXML = @strItemCertificationXML
		,strItemCommodityCostXML = @strItemCommodityCostXML
		,strItemContractXML = @strItemContractXML
		,strItemContractDocumentXML = @strItemContractDocumentXML
		,strItemCustomerXrefXML = @strItemCustomerXrefXML
		,strItemFactoryXML = @strItemFactoryXML
		,strItemFactoryManufacturingCellXML = @strItemFactoryManufacturingCellXML
		,strItemKitXML = @strItemKitXML
		,strItemKitDetailXML = @strItemKitDetailXML
		,strItemLicenseXML = @strItemLicenseXML
		,strItemLocationXML = @strItemLocationXML
		,strItemManufacturingUOMXML = @strItemManufacturingUOMXML
		,strItemMotorFuelTaxXML = @strItemMotorFuelTaxXML
		,strItemNoteXML = @strItemNoteXML
		,strItemOwnerXML = @strItemOwnerXML
		,strItemPOSCategoryXML = @strItemPOSCategoryXML
		,strItemPOSSLAXML = @strItemPOSSLAXML
		,strItemPricingXML = @strItemPricingXML
		,strItemPricingLevelXML = @strItemPricingLevelXML
		,strItemSpecialPricingXML=@strItemSpecialPricingXML
		,strItemSubLocationXML = @strItemSubLocationXML
		,strItemSubstituteXML = @strItemSubstituteXML
		,strItemSubstitutionXML = @strItemSubstitutionXML
		,strItemSubstitutionDetailXML = @strItemSubstitutionDetailXML
		,strItemUOMXML = @strItemUOMXML
		,strItemUOMUpcXML = @strItemUOMUpcXML
		,strItemUPCXML = @strItemUPCXML
		,strItemVendorXrefXML = @strItemVendorXrefXML
		,strItemBookXML=@strItemBookXML
		,strRowState = @strRowState
		,strUserName = @strLastModifiedUser
		,intMultiCompanyId = @intMultiCompanyId
		,intTransactionId=@intTransactionId
        ,intCompanyId=@intCompanyId'

			EXEC sp_executesql @strSQL
				,
				N'@intItemId int
		,@strItemNo nvarchar(50)
		,@strItemXML nvarchar(MAX)
		,@strItemAccountXML nvarchar(MAX)
		,@strItemAddOnXML nvarchar(MAX)
		,@strItemAssemblyXML nvarchar(MAX)
		,@strItemBundleXML nvarchar(MAX)
		,@strItemCertificationXML nvarchar(MAX)
		,@strItemCommodityCostXML nvarchar(MAX)
		,@strItemContractXML nvarchar(MAX)
		,@strItemContractDocumentXML nvarchar(MAX)
		,@strItemCustomerXrefXML nvarchar(MAX)
		,@strItemFactoryXML nvarchar(MAX)
		,@strItemFactoryManufacturingCellXML nvarchar(MAX)
		,@strItemKitXML nvarchar(MAX)
		,@strItemKitDetailXML nvarchar(MAX)
		,@strItemLicenseXML nvarchar(MAX)
		,@strItemLocationXML nvarchar(MAX)
		,@strItemManufacturingUOMXML nvarchar(MAX)
		,@strItemMotorFuelTaxXML nvarchar(MAX)
		,@strItemNoteXML nvarchar(MAX)
		,@strItemOwnerXML nvarchar(MAX)
		,@strItemPOSCategoryXML nvarchar(MAX)
		,@strItemPOSSLAXML nvarchar(MAX)
		,@strItemPricingXML nvarchar(MAX)
		,@strItemPricingLevelXML nvarchar(MAX)
		,@strItemSpecialPricingXML nvarchar(MAX)
		,@strItemSubLocationXML nvarchar(MAX)
		,@strItemSubstituteXML nvarchar(MAX)
		,@strItemSubstitutionXML nvarchar(MAX)
		,@strItemSubstitutionDetailXML nvarchar(MAX)
		,@strItemUOMXML nvarchar(MAX)
		,@strItemUOMUpcXML nvarchar(MAX)
		,@strItemUPCXML nvarchar(MAX)
		,@strItemVendorXrefXML nvarchar(MAX)
		,@strItemBookXML nvarchar(MAX)
		,@strRowState nvarchar(50)
		,@strLastModifiedUser nvarchar(50)
		,@intMultiCompanyId int
		,@intTransactionId int
        ,@intCompanyId int'
				,@intItemId
				,@strItemNo
				,@strItemXML
				,@strItemAccountXML
				,@strItemAddOnXML
				,@strItemAssemblyXML
				,@strItemBundleXML
				,@strItemCertificationXML
				,@strItemCommodityCostXML
				,@strItemContractXML
				,@strItemContractDocumentXML
				,@strItemCustomerXrefXML
				,@strItemFactoryXML
				,@strItemFactoryManufacturingCellXML
				,@strItemKitXML
				,@strItemKitDetailXML
				,@strItemLicenseXML
				,@strItemLocationXML
				,@strItemManufacturingUOMXML
				,@strItemMotorFuelTaxXML
				,@strItemNoteXML
				,@strItemOwnerXML
				,@strItemPOSCategoryXML
				,@strItemPOSSLAXML
				,@strItemPricingXML
				,@strItemPricingLevelXML
				,@strItemSpecialPricingXML
				,@strItemSubLocationXML
				,@strItemSubstituteXML
				,@strItemSubstitutionXML
				,@strItemSubstitutionDetailXML
				,@strItemUOMXML
				,@strItemUOMUpcXML
				,@strItemUPCXML
				,@strItemVendorXrefXML
				,@strItemBookXML
				,@strRowState
				,@strLastModifiedUser
				,@intMultiCompanyId
				,@intTransactionId
				,@intCompanyId
		END

		SELECT @intMultiCompanyId = min(intCompanyId)
		FROM tblIPMultiCompany
		WHERE ysnParent = 0
			AND intCompanyId > @intMultiCompanyId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
