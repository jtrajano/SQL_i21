﻿CREATE PROCEDURE uspIPItemPopulateStgXML @intItemId INT
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
		,@intCompanyId int
        ,@intTransactionId int
        ,@intItemScreenId int

	SET @strItemXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL

	Select @intCompanyId=intCompanyId
	From tblICItem 
	Where intItemId=@intItemId 

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

	SELECT    @intItemScreenId    =    intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item'

    Select @intTransactionId=intTransactionId 
    from tblSMTransaction
    Where intRecordId =@intItemId
    and intScreenId =@intItemScreenId

	INSERT INTO tblICItemStage (
		intItemId
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
		,intMultiCompanyId = intCompanyId
		,intTransactionId=@intTransactionId
        ,intCompanyId=@intCompanyId
	FROM tblIPMultiCompany
	WHERE ysnParent = 0
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
