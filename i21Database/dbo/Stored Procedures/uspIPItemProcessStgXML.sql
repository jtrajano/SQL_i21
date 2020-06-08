CREATE PROCEDURE [dbo].[uspIPItemProcessStgXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@strErrorMessage NVARCHAR(MAX)
		,@strItemXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@strUserName NVARCHAR(100)
		,@intNewItemId INT
		,@strItemNo NVARCHAR(50)
		,@ErrMsg NVARCHAR(MAX)
		,@strManufacturer NVARCHAR(50)
		,@strBrandCode NVARCHAR(50)
		,@strDimensionUOM NVARCHAR(50)
		,@strWeightUOM NVARCHAR(50)
		,@strPatronageCategoryCode NVARCHAR(50)
		,@strRinFuelCategoryCode NVARCHAR(50)
		,@strMedicationTag NVARCHAR(50)
		,@strIngredientTag NVARCHAR(50)
		,@strCommodityCode NVARCHAR(50)
		,@strCategoryCode NVARCHAR(50)
		,@strOrigin NVARCHAR(50)
		,@strMaterialPackType NVARCHAR(50)
		,@strOwner NVARCHAR(50)
		,@strCustomer NVARCHAR(50)
		,@strModule NVARCHAR(50)
		,@strBuyingGroup NVARCHAR(50)
		,@strAccountManager NVARCHAR(50)
		,@strSecondaryStatus NVARCHAR(50)
		,@strM2MComputation NVARCHAR(50)
		,@strTonnageTaxUOM NVARCHAR(50)
		,@strSourceName NVARCHAR(50)
		,@intItemStageId INT
		,@intManufacturerId INT
		,@intBrandId INT
		,@intDimensionUOMId INT
		,@intWeightUOMId INT
		,@intPatronageCategoryId INT
		,@intRinFuelCategoryId INT
		,@intRINFuelTypeId INT
		,@intMedicationTag INT
		,@intIngredientTag INT
		,@intCommodityId INT
		,@intCategoryId INT
		,@intOriginId INT
		,@intMaterialPackTypeId INT
		,@intOwnerId INT
		,@intCustomerId INT
		,@intModuleId INT
		,@intBuyingGroupId INT
		,@intAccountManagerId INT
		,@intLotStatusId INT
		,@intM2MComputationId INT
		,@intTonnageTaxUOMId INT
		,@intDataSourceId INT
		,@intLastModifiedUserId INT
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
		,@strCustomerProduct NVARCHAR(MAX)
		,@strSubstitutionItem NVARCHAR(MAX)
		,@strItemBookXML NVARCHAR(MAX)
		,@intItemId INT
		,@strBook NVARCHAR(50)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intLoadScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strDescription NVARCHAR(50)
		,@intItemScreenId INT
		,@intItemLocationId INT
		,@strLocationName NVARCHAR(50)
		,@intLocationId INT
		,@strPhysicalItemNo NVARCHAR(50)
		,@intPhysicalItemId INT
		,@strNewLotTracking NVARCHAR(50)
		,@strOldLotTracking NVARCHAR(50)

	DECLARE @tblICItemStage TABLE (intItemStageId INT)

	INSERT INTO @tblICItemStage (intItemStageId)
	SELECT intItemStageId
	FROM tblICItemStage
	WHERE strFeedStatus IS NULL
	Order by intItemStageId

	UPDATE tblICItemStage
	SET strFeedStatus = 'In-Progress'
	WHERE intItemStageId IN (
			SELECT S.intItemStageId
			FROM @tblICItemStage S
			)


	SELECT @intItemStageId = MIN(intItemStageId)
	FROM @tblICItemStage

	WHILE @intItemStageId IS NOT NULL
	BEGIN
		SELECT @intNewItemId = NULL
			,@intItemId = NULL
			,@strItemXML = NULL
			,@strItemAccountXML = NULL
			,@strItemAddOnXML = NULL
			,@strItemAssemblyXML = NULL
			,@strItemBundleXML = NULL
			,@strItemCertificationXML = NULL
			,@strItemCommodityCostXML = NULL
			,@strItemContractXML = NULL
			,@strItemContractDocumentXML = NULL
			,@strItemCustomerXrefXML = NULL
			,@strItemFactoryXML = NULL
			,@strItemFactoryManufacturingCellXML = NULL
			,@strItemKitXML = NULL
			,@strItemKitDetailXML = NULL
			,@strItemLicenseXML = NULL
			,@strItemLocationXML = NULL
			,@strItemManufacturingUOMXML = NULL
			,@strItemMotorFuelTaxXML = NULL
			,@strItemNoteXML = NULL
			,@strItemOwnerXML = NULL
			,@strItemPOSCategoryXML = NULL
			,@strItemPOSSLAXML = NULL
			,@strItemPricingXML = NULL
			,@strItemPricingLevelXML = NULL
			,@strItemSubLocationXML = NULL
			,@strItemSubstituteXML = NULL
			,@strItemSubstitutionXML = NULL
			,@strItemSubstitutionDetailXML = NULL
			,@strItemUOMXML = NULL
			,@strItemUOMUpcXML = NULL
			,@strItemUPCXML = NULL
			,@strItemVendorXrefXML = NULL
			,@strItemSpecialPricingXML = NULL
			,@strRowState = NULL
			,@strUserName = NULL
			,@strItemBookXML = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL

		SELECT @intItemId = intItemId
			,@strItemXML = strItemXML
			,@strItemAccountXML = strItemAccountXML
			,@strItemAddOnXML = strItemAddOnXML
			,@strItemAssemblyXML = strItemAssemblyXML
			,@strItemBundleXML = strItemBundleXML
			,@strItemCertificationXML = strItemCertificationXML
			,@strItemCommodityCostXML = strItemCommodityCostXML
			,@strItemContractXML = strItemContractXML
			,@strItemContractDocumentXML = strItemContractDocumentXML
			,@strItemCustomerXrefXML = strItemCustomerXrefXML
			,@strItemFactoryXML = strItemFactoryXML
			,@strItemFactoryManufacturingCellXML = strItemFactoryManufacturingCellXML
			,@strItemKitXML = strItemKitXML
			,@strItemKitDetailXML = strItemKitDetailXML
			,@strItemLicenseXML = strItemLicenseXML
			,@strItemLocationXML = strItemLocationXML
			,@strItemManufacturingUOMXML = strItemManufacturingUOMXML
			,@strItemMotorFuelTaxXML = strItemMotorFuelTaxXML
			,@strItemNoteXML = strItemNoteXML
			,@strItemOwnerXML = strItemOwnerXML
			,@strItemPOSCategoryXML = strItemPOSCategoryXML
			,@strItemPOSSLAXML = strItemPOSSLAXML
			,@strItemPricingXML = strItemPricingXML
			,@strItemPricingLevelXML = strItemPricingLevelXML
			,@strItemSubLocationXML = strItemSubLocationXML
			,@strItemSubstituteXML = strItemSubstituteXML
			,@strItemSubstitutionXML = strItemSubstitutionXML
			,@strItemSubstitutionDetailXML = strItemSubstitutionDetailXML
			,@strItemUOMXML = strItemUOMXML
			,@strItemUOMUpcXML = strItemUOMUpcXML
			,@strItemUPCXML = strItemUPCXML
			,@strItemVendorXrefXML = strItemVendorXrefXML
			,@strItemSpecialPricingXML = strItemSpecialPricingXML
			,@strItemBookXML = strItemBookXML
			,@strRowState = strRowState
			,@strUserName = strUserName
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblICItemStage
		WHERE intItemStageId = @intItemStageId

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemXML

			SELECT @strManufacturer = NULL
				,@strBrandCode = NULL
				,@strDimensionUOM = NULL
				,@strWeightUOM = NULL
				,@strPatronageCategoryCode = NULL
				,@strRinFuelCategoryCode = NULL
				,@strMedicationTag = NULL
				,@strIngredientTag = NULL
				,@strCommodityCode = NULL
				,@strCategoryCode = NULL
				,@strOrigin = NULL
				,@strMaterialPackType = NULL
				,@strOwner = NULL
				,@strCustomer = NULL
				,@strModule = NULL
				,@strBuyingGroup = NULL
				,@strAccountManager = NULL
				,@strSecondaryStatus = NULL
				,@strM2MComputation = NULL
				,@strTonnageTaxUOM = NULL
				,@strSourceName = NULL
				,@strItemNo = NULL
				,@strPhysicalItemNo = NULL

			SELECT @strManufacturer = strManufacturer
				,@strBrandCode = strBrandCode
				,@strDimensionUOM = strDimensionUOM
				,@strWeightUOM = strWeightUOM
				,@strPatronageCategoryCode = strPatronageCategoryCode
				,@strRinFuelCategoryCode = strRinFuelCategoryCode
				,@strMedicationTag = strMedicationTag
				,@strIngredientTag = strIngredientTag
				,@strCommodityCode = strCommodityCode
				,@strCategoryCode = strCategoryCode
				,@strOrigin = strOrigin
				,@strMaterialPackType = strMaterialPackType
				,@strOwner = strOwner
				,@strCustomer = strCustomer
				,@strModule = strModule
				,@strBuyingGroup = strBuyingGroup
				,@strAccountManager = strAccountManager
				,@strSecondaryStatus = strSecondaryStatus
				,@strM2MComputation = strM2MComputation
				,@strTonnageTaxUOM = strTonnageTaxUOM
				,@strSourceName = strSourceName
				,@strItemNo = strItemNo
				,@strPhysicalItemNo = strPhysicalItemNo
			FROM OPENXML(@idoc, 'vyuIPGetItems/vyuIPGetItem', 2) WITH (
					strManufacturer NVARCHAR(50) Collate Latin1_General_CI_AS
					,strBrandCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strDimensionUOM NVARCHAR(50) Collate Latin1_General_CI_AS
					,strWeightUOM NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPatronageCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strRinFuelCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strMedicationTag NVARCHAR(50) Collate Latin1_General_CI_AS
					,strIngredientTag NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strOrigin NVARCHAR(50) Collate Latin1_General_CI_AS
					,strMaterialPackType NVARCHAR(50) Collate Latin1_General_CI_AS
					,strOwner NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCustomer NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModule NVARCHAR(50) Collate Latin1_General_CI_AS
					,strBuyingGroup NVARCHAR(50) Collate Latin1_General_CI_AS
					,strAccountManager NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSecondaryStatus NVARCHAR(50) Collate Latin1_General_CI_AS
					,strM2MComputation NVARCHAR(50) Collate Latin1_General_CI_AS
					,strTonnageTaxUOM NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSourceName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPhysicalItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			SELECT @intManufacturerId = NULL

			SELECT @intManufacturerId = intManufacturerId
			FROM tblICManufacturer
			WHERE strManufacturer = @strManufacturer

			SELECT @strErrorMessage = ''

			IF @strManufacturer IS NOT NULL
				AND @intManufacturerId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Manufacturer ' + @strManufacturer + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Manufacturer ' + @strManufacturer + ' is not available.'
				END
			END

			SELECT @intBrandId = NULL

			SELECT @intBrandId = intBrandId
			FROM tblICBrand
			WHERE strBrandCode = @strBrandCode

			IF @strBrandCode IS NOT NULL
				AND @intBrandId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Brand ' + @strBrandCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Brand ' + @strBrandCode + ' is not available.'
				END
			END

			SELECT @intDimensionUOMId = NULL

			SELECT @intDimensionUOMId = intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strUnitMeasure = @strDimensionUOM

			IF @strDimensionUOM IS NOT NULL
				AND @intDimensionUOMId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Dimension UOM ' + @strDimensionUOM + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Dimension UOM ' + @strDimensionUOM + ' is not available.'
				END
			END

			SELECT @intWeightUOMId = NULL

			SELECT @intWeightUOMId = intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strUnitMeasure = @strWeightUOM

			IF @strWeightUOM IS NOT NULL
				AND @intWeightUOMId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Weight UOM ' + @strWeightUOM + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Weight UOM ' + @strWeightUOM + ' is not available.'
				END
			END

			SELECT @intPatronageCategoryId = NULL

			SELECT @intPatronageCategoryId = intPatronageCategoryId
			FROM tblPATPatronageCategory
			WHERE strCategoryCode = @strPatronageCategoryCode

			IF @strPatronageCategoryCode IS NOT NULL
				AND @intPatronageCategoryId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Patronage Category Code ' + @strPatronageCategoryCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Patronage Category Code ' + @strPatronageCategoryCode + ' is not available.'
				END
			END

			SELECT @intRinFuelCategoryId = NULL

			SELECT @intRinFuelCategoryId = intRinFuelCategoryId
			FROM tblICRinFuelCategory
			WHERE strRinFuelCategoryCode = @strRinFuelCategoryCode

			IF @strRinFuelCategoryCode IS NOT NULL
				AND @intRinFuelCategoryId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Rin Fuel Category Code ' + @strRinFuelCategoryCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Rin Fuel Category Code ' + @strRinFuelCategoryCode + ' is not available.'
				END
			END

			SELECT @intMedicationTag = NULL

			SELECT @intMedicationTag = intTagId
			FROM tblICTag
			WHERE strTagNumber = @strMedicationTag

			IF @strMedicationTag IS NOT NULL
				AND @intMedicationTag IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Medication Tag ' + @strMedicationTag + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Medication Tag ' + @strMedicationTag + ' is not available.'
				END
			END

			SELECT @intIngredientTag = NULL

			SELECT @intIngredientTag = intTagId
			FROM tblICTag
			WHERE strTagNumber = @strIngredientTag

			IF @strIngredientTag IS NOT NULL
				AND @intIngredientTag IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Ingredient Tag ' + @strIngredientTag + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Ingredient Tag ' + @strIngredientTag + ' is not available.'
				END
			END

			SELECT @intCommodityId = NULL

			SELECT @intCommodityId = intCommodityId
			FROM tblICCommodity
			WHERE strCommodityCode = @strCommodityCode

			IF @strCommodityCode IS NOT NULL
				AND @intCommodityId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Commodity Code ' + @strCommodityCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Commodity Code ' + @strCommodityCode + ' is not available.'
				END
			END

			SELECT @intCategoryId = NULL

			SELECT @intCategoryId = intCategoryId
			FROM tblICCategory
			WHERE strCategoryCode = @strCategoryCode

			IF @strCategoryCode IS NOT NULL
				AND @intCategoryId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Category Code ' + @strCategoryCode + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Category Code ' + @strCategoryCode + ' is not available.'
				END
			END

			SELECT @intOriginId = NULL

			SELECT @intOriginId = intCommodityAttributeId
			FROM tblICCommodityAttribute
			WHERE strDescription = @strOrigin

			IF @strOrigin IS NOT NULL
				AND @intOriginId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Origin ' + @strOrigin + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Origin ' + @strOrigin + ' is not available.'
				END
			END

			SELECT @intMaterialPackTypeId = NULL

			SELECT @intMaterialPackTypeId = intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strUnitMeasure = @strMaterialPackType

			IF @strMaterialPackType IS NOT NULL
				AND @intMaterialPackTypeId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Material Pack Type ' + @strMaterialPackType + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Material Pack Type ' + @strMaterialPackType + ' is not available.'
				END
			END

			SELECT @intOwnerId = NULL

			SELECT @intOwnerId = intEntityId
			FROM tblARCustomer
			WHERE strCustomerNumber = @strOwner

			IF @strOwner IS NOT NULL
				AND @intOwnerId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Owner ' + @strOwner + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Owner ' + @strOwner + ' is not available.'
				END
			END

			SELECT @intCustomerId = NULL

			SELECT @intCustomerId = intEntityId
			FROM tblARCustomer
			WHERE strCustomerNumber = @strCustomer

			IF @strCustomer IS NOT NULL
				AND @intCustomerId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Customer ' + @strCustomer + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Customer ' + @strCustomer + ' is not available.'
				END
			END

			SELECT @intModuleId = NULL

			SELECT @intModuleId = intModuleId
			FROM tblSMModule
			WHERE strModule = @strModule

			IF @strModule IS NOT NULL
				AND @intModuleId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Module ' + @strModule + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Module ' + @strModule + ' is not available.'
				END
			END

			SELECT @intBuyingGroupId = NULL

			SELECT @intBuyingGroupId = intBuyingGroupId
			FROM tblMFBuyingGroup
			WHERE strBuyingGroup = @strBuyingGroup

			IF @strBuyingGroup IS NOT NULL
				AND @intBuyingGroupId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Buying Group ' + @strBuyingGroup + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Buying Group ' + @strBuyingGroup + ' is not available.'
				END
			END

			SELECT @intAccountManagerId = NULL

			SELECT @intAccountManagerId = intEntityId
			FROM tblEMEntity
			WHERE strName = @strAccountManager

			IF @strAccountManager IS NOT NULL
				AND @intAccountManagerId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Account Manager ' + @strAccountManager + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Account Manager ' + @strAccountManager + ' is not available.'
				END
			END

			SELECT @intLotStatusId = NULL

			SELECT @intLotStatusId = intLotStatusId
			FROM tblICLotStatus
			WHERE strSecondaryStatus = @strSecondaryStatus

			IF @strSecondaryStatus IS NOT NULL
				AND @intLotStatusId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Lot Status ' + @strSecondaryStatus + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Lot Status ' + @strSecondaryStatus + ' is not available.'
				END
			END

			SELECT @intM2MComputationId = NULL

			SELECT @intM2MComputationId = intM2MComputationId
			FROM tblICM2MComputation
			WHERE strM2MComputation = @strM2MComputation

			IF @strM2MComputation IS NOT NULL
				AND @intM2MComputationId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'M2MComputation ' + @strM2MComputation + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'M2MComputation ' + @strM2MComputation + ' is not available.'
				END
			END

			SELECT @intTonnageTaxUOMId = NULL

			SELECT @intTonnageTaxUOMId = intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strUnitMeasure = @strTonnageTaxUOM

			IF @strTonnageTaxUOM IS NOT NULL
				AND @intTonnageTaxUOMId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Tonnage Tax UOM ' + @strTonnageTaxUOM + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Tonnage Tax UOM ' + @strTonnageTaxUOM + ' is not available.'
				END
			END

			SELECT @intDataSourceId = NULL

			SELECT @intDataSourceId = intDataSourceId
			FROM tblICDataSource
			WHERE strSourceName = @strSourceName

			IF @strSourceName IS NOT NULL
				AND @intDataSourceId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Source Name ' + @strSourceName + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Source Name ' + @strSourceName + ' is not available.'
				END
			END

			SELECT @intPhysicalItemId = NULL

			SELECT @intPhysicalItemId = intItemId
			FROM tblICItem
			WHERE strItemNo = @strPhysicalItemNo

			IF @strPhysicalItemNo IS NOT NULL
				AND @intPhysicalItemId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Physical Item ' + @strPhysicalItemNo + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Physical Item ' + @strPhysicalItemNo + ' is not available.'
				END
			END

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblICItem
						WHERE IsNULL(intItemRefId, 0) = @intItemId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				DELETE
				FROM tblICItem
				WHERE intItemRefId = @intItemId

				EXEC sp_xml_removedocument @idoc

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblICItem (
					strItemNo
					,strShortName
					,strType
					,strBundleType
					,strDescription
					,intManufacturerId
					,intBrandId
					,intCategoryId
					,strStatus
					,strModelNo
					,strInventoryTracking
					,strLotTracking
					,ysnRequireCustomerApproval
					,intRecipeId
					,ysnSanitationRequired
					,intLifeTime
					,strLifeTimeType
					,intReceiveLife
					,strGTIN
					,strRotationType
					,intNMFCId
					,ysnStrictFIFO
					,intDimensionUOMId
					,dblHeight
					,dblWidth
					,dblDepth
					,intWeightUOMId
					,dblWeight
					,intMaterialPackTypeId
					,strMaterialSizeCode
					,intInnerUnits
					,intLayerPerPallet
					,intUnitPerLayer
					,dblStandardPalletRatio
					,strMask1
					,strMask2
					,strMask3
					,dblMaxWeightPerPack
					,intPatronageCategoryId
					,intPatronageCategoryDirectId
					,ysnStockedItem
					,ysnDyedFuel
					,strBarcodePrint
					,ysnMSDSRequired
					,strEPANumber
					,ysnInboundTax
					,ysnOutboundTax
					,ysnRestrictedChemical
					,ysnFuelItem
					,ysnTankRequired
					,ysnAvailableTM
					,dblDefaultFull
					,strFuelInspectFee
					,strRINRequired
					,intRINFuelTypeId
					,dblDenaturantPercent
					,ysnTonnageTax
					,ysnLoadTracking
					,dblMixOrder
					,ysnHandAddIngredient
					,intMedicationTag
					,intIngredientTag
					,intHazmatTag
					,strVolumeRebateGroup
					,intPhysicalItem
					,ysnExtendPickTicket
					,ysnExportEDI
					,ysnHazardMaterial
					,ysnMaterialFee
					,ysnAutoBlend
					,dblUserGroupFee
					,dblWeightTolerance
					,dblOverReceiveTolerance
					,strMaintenanceCalculationMethod
					,dblMaintenanceRate
					,ysnListBundleSeparately
					,intModuleId
					,strNACSCategory
					,strWICCode
					,intAGCategory
					,ysnReceiptCommentRequired
					,strCountCode
					,ysnLandedCost
					,strLeadTime
					,ysnTaxable
					,strKeywords
					,dblCaseQty
					,dtmDateShip
					,dblTaxExempt
					,ysnDropShip
					,ysnCommisionable
					,ysnSpecialCommission
					,intCommodityId
					,intCommodityHierarchyId
					,dblGAShrinkFactor
					,intOriginId
					,intProductTypeId
					,intRegionId
					,intSeasonId
					,intClassVarietyId
					,intProductLineId
					,intGradeId
					,strMarketValuation
					,ysnInventoryCost
					,ysnAccrue
					,ysnMTM
					,ysnPrice
					,strCostMethod
					,strCostType
					,intOnCostTypeId
					,dblAmount
					,intCostUOMId
					,intPackTypeId
					,strWeightControlCode
					,dblBlendWeight
					,dblNetWeight
					,dblUnitPerCase
					,dblQuarantineDuration
					,intOwnerId
					,intCustomerId
					,dblCaseWeight
					,strWarehouseStatus
					,ysnKosherCertified
					,ysnFairTradeCompliant
					,ysnOrganic
					,ysnRainForestCertified
					,dblRiskScore
					,dblDensity
					,dtmDateAvailable
					,ysnMinorIngredient
					,ysnExternalItem
					,strExternalGroup
					,ysnSellableItem
					,dblMinStockWeeks
					,dblFullContainerSize
					,ysnHasMFTImplication
					,intBuyingGroupId
					,intAccountManagerId
					,intConcurrencyId
					,ysnItemUsedInDiscountCode
					,ysnUsedForEnergyTracExport
					,strInvoiceComments
					,strPickListComments
					,intLotStatusId
					,strRequired
					,ysnBasisContract
					,intM2MComputationId
					,intTonnageTaxUOMId
					,ysn1099Box3
					,ysnUseWeighScales
					,ysnLotWeightsRequired
					,ysnBillable
					,ysnSupported
					,ysnDisplayInHelpdesk
					,intHazmatMessage
					,strOriginStatus
					,intCompanyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					,strServiceType
					,intDataSourceId
					,intItemRefId
					)
				SELECT strItemNo
					,strShortName
					,strType
					,strBundleType
					,strDescription
					,@intManufacturerId
					,@intBrandId
					,@intCategoryId
					,strStatus
					,strModelNo
					,strInventoryTracking
					,strLotTracking
					,ysnRequireCustomerApproval
					,intRecipeId
					,ysnSanitationRequired
					,intLifeTime
					,strLifeTimeType
					,intReceiveLife
					,strGTIN
					,strRotationType
					,intNMFCId
					,ysnStrictFIFO
					,@intDimensionUOMId
					,dblHeight
					,dblWidth
					,dblDepth
					,@intWeightUOMId
					,dblWeight
					,@intMaterialPackTypeId
					,strMaterialSizeCode
					,intInnerUnits
					,intLayerPerPallet
					,intUnitPerLayer
					,dblStandardPalletRatio
					,strMask1
					,strMask2
					,strMask3
					,dblMaxWeightPerPack
					,@intPatronageCategoryId
					,intPatronageCategoryDirectId
					,ysnStockedItem
					,ysnDyedFuel
					,strBarcodePrint
					,ysnMSDSRequired
					,strEPANumber
					,ysnInboundTax
					,ysnOutboundTax
					,ysnRestrictedChemical
					,ysnFuelItem
					,ysnTankRequired
					,ysnAvailableTM
					,dblDefaultFull
					,strFuelInspectFee
					,strRINRequired
					,@intRINFuelTypeId
					,dblDenaturantPercent
					,ysnTonnageTax
					,ysnLoadTracking
					,dblMixOrder
					,ysnHandAddIngredient
					,@intMedicationTag
					,@intIngredientTag
					,intHazmatTag
					,strVolumeRebateGroup
					,@intPhysicalItemId
					,ysnExtendPickTicket
					,ysnExportEDI
					,ysnHazardMaterial
					,ysnMaterialFee
					,ysnAutoBlend
					,dblUserGroupFee
					,dblWeightTolerance
					,dblOverReceiveTolerance
					,strMaintenanceCalculationMethod
					,dblMaintenanceRate
					,ysnListBundleSeparately
					,@intModuleId
					,strNACSCategory
					,strWICCode
					,intAGCategory
					,ysnReceiptCommentRequired
					,strCountCode
					,ysnLandedCost
					,strLeadTime
					,ysnTaxable
					,strKeywords
					,dblCaseQty
					,dtmDateShip
					,dblTaxExempt
					,ysnDropShip
					,ysnCommisionable
					,ysnSpecialCommission
					,@intCommodityId
					,intCommodityHierarchyId
					,dblGAShrinkFactor
					,@intOriginId
					,intProductTypeId
					,intRegionId
					,intSeasonId
					,intClassVarietyId
					,intProductLineId
					,intGradeId
					,strMarketValuation
					,ysnInventoryCost
					,ysnAccrue
					,ysnMTM
					,ysnPrice
					,strCostMethod
					,strCostType
					,intOnCostTypeId
					,dblAmount
					,intCostUOMId
					,intPackTypeId
					,strWeightControlCode
					,dblBlendWeight
					,dblNetWeight
					,dblUnitPerCase
					,dblQuarantineDuration
					,@intOwnerId
					,@intCustomerId
					,dblCaseWeight
					,strWarehouseStatus
					,ysnKosherCertified
					,ysnFairTradeCompliant
					,ysnOrganic
					,ysnRainForestCertified
					,dblRiskScore
					,dblDensity
					,dtmDateAvailable
					,ysnMinorIngredient
					,ysnExternalItem
					,strExternalGroup
					,ysnSellableItem
					,dblMinStockWeeks
					,dblFullContainerSize
					,ysnHasMFTImplication
					,@intBuyingGroupId
					,@intAccountManagerId
					,intConcurrencyId
					,ysnItemUsedInDiscountCode
					,ysnUsedForEnergyTracExport
					,strInvoiceComments
					,strPickListComments
					,@intLotStatusId
					,strRequired
					,ysnBasisContract
					,@intM2MComputationId
					,@intTonnageTaxUOMId
					,ysn1099Box3
					,ysnUseWeighScales
					,ysnLotWeightsRequired
					,ysnBillable
					,ysnSupported
					,ysnDisplayInHelpdesk
					,intHazmatMessage
					,strOriginStatus
					,intCompanyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					,strServiceType
					,@intDataSourceId
					,intItemId
				FROM OPENXML(@idoc, 'vyuIPGetItems/vyuIPGetItem', 2) WITH (
						intItemId INT
						,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strShortName NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strBundleType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
						,intManufacturerId INT
						,intBrandId INT
						,intCategoryId INT
						,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strModelNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strInventoryTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnRequireCustomerApproval BIT
						,intRecipeId INT
						,ysnSanitationRequired BIT
						,intLifeTime INT
						,strLifeTimeType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intReceiveLife INT
						,strGTIN NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strRotationType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intNMFCId INT
						,ysnStrictFIFO BIT
						,intDimensionUOMId INT
						,dblHeight NUMERIC(18, 6)
						,dblWidth NUMERIC(18, 6)
						,dblDepth NUMERIC(18, 6)
						,intWeightUOMId INT
						,dblWeight NUMERIC(18, 6)
						,intMaterialPackTypeId INT
						,strMaterialSizeCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intInnerUnits INT
						,intLayerPerPallet INT
						,intUnitPerLayer INT
						,dblStandardPalletRatio NUMERIC(18, 6)
						,strMask1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strMask2 NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strMask3 NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,dblMaxWeightPerPack NUMERIC(18, 6)
						,intPatronageCategoryId INT
						,intPatronageCategoryDirectId INT
						,ysnStockedItem BIT
						,ysnDyedFuel BIT
						,strBarcodePrint NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnMSDSRequired BIT
						,strEPANumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnInboundTax BIT
						,ysnOutboundTax BIT
						,ysnRestrictedChemical BIT
						,ysnFuelItem BIT
						,ysnTankRequired BIT
						,ysnAvailableTM BIT
						,dblDefaultFull NUMERIC(18, 6)
						,strFuelInspectFee NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strRINRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intRINFuelTypeId INT
						,dblDenaturantPercent NUMERIC(18, 6)
						,ysnTonnageTax BIT
						,ysnLoadTracking BIT
						,dblMixOrder NUMERIC(18, 6)
						,ysnHandAddIngredient BIT
						,intMedicationTag INT
						,intIngredientTag INT
						,intHazmatTag INT
						,strVolumeRebateGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnExtendPickTicket BIT
						,ysnExportEDI BIT
						,ysnHazardMaterial BIT
						,ysnMaterialFee BIT
						,ysnAutoBlend BIT
						,dblUserGroupFee NUMERIC(18, 6)
						,dblWeightTolerance NUMERIC(18, 6)
						,dblOverReceiveTolerance NUMERIC(18, 6)
						,strMaintenanceCalculationMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,dblMaintenanceRate NUMERIC(18, 6)
						,ysnListBundleSeparately BIT
						,intModuleId INT
						,strNACSCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strWICCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intAGCategory INT
						,ysnReceiptCommentRequired BIT
						,strCountCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnLandedCost BIT
						,strLeadTime NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnTaxable BIT
						,strKeywords NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
						,dblCaseQty NUMERIC(18, 6)
						,dtmDateShip DATETIME
						,dblTaxExempt NUMERIC(18, 6)
						,ysnDropShip BIT
						,ysnCommisionable BIT
						,ysnSpecialCommission BIT
						,intCommodityId INT
						,intCommodityHierarchyId INT
						,dblGAShrinkFactor NUMERIC(18, 6)
						,intOriginId INT
						,intProductTypeId INT
						,intRegionId INT
						,intSeasonId INT
						,intClassVarietyId INT
						,intProductLineId INT
						,intGradeId INT
						,strMarketValuation NVARCHAR(50)
						,ysnInventoryCost BIT
						,ysnAccrue BIT
						,ysnMTM BIT
						,ysnPrice BIT
						,strCostMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strCostType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intOnCostTypeId INT
						,dblAmount NUMERIC(18, 6)
						,intCostUOMId INT
						,intPackTypeId INT
						,strWeightControlCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,dblBlendWeight NUMERIC(18, 6)
						,dblNetWeight NUMERIC(18, 6)
						,dblUnitPerCase NUMERIC(18, 6)
						,dblQuarantineDuration NUMERIC(18, 6)
						,intOwnerId INT
						,intCustomerId INT
						,dblCaseWeight NUMERIC(18, 6)
						,strWarehouseStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnKosherCertified BIT
						,ysnFairTradeCompliant BIT
						,ysnOrganic BIT
						,ysnRainForestCertified BIT
						,dblRiskScore NUMERIC(18, 6)
						,dblDensity NUMERIC(18, 6)
						,dtmDateAvailable DATETIME
						,ysnMinorIngredient BIT
						,ysnExternalItem BIT
						,strExternalGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnSellableItem BIT
						,dblMinStockWeeks NUMERIC(18, 6)
						,dblFullContainerSize NUMERIC(18, 6)
						,ysnHasMFTImplication BIT
						,intBuyingGroupId INT
						,intAccountManagerId INT
						,intConcurrencyId INT
						,ysnItemUsedInDiscountCode BIT
						,ysnUsedForEnergyTracExport BIT
						,strInvoiceComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
						,strPickListComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
						,intLotStatusId INT
						,strRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,ysnBasisContract BIT
						,intM2MComputationId INT
						,intTonnageTaxUOMId INT
						,ysn1099Box3 BIT
						,ysnUseWeighScales BIT
						,ysnLotWeightsRequired BIT
						,ysnBillable BIT
						,ysnSupported BIT
						,ysnDisplayInHelpdesk BIT
						,intHazmatMessage INT
						,strOriginStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intCompanyId INT
						,dtmDateCreated DATETIME
						,dtmDateModified DATETIME
						,intCreatedByUserId INT
						,intModifiedByUserId INT
						,strServiceType NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intDataSourceId TINYINT
						,intItemRefId INT
						)

				SELECT @intNewItemId = SCOPE_IDENTITY()

				SELECT @strDescription = 'Created from inter-company : ' + @strItemNo

				EXEC uspSMAuditLog @keyValue = @intNewItemId
					,@screenName = 'Inventory.view.Item'
					,@entityId = @intLastModifiedUserId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@changeDescription = @strDescription
					,@fromValue = ''
					,@toValue = @strItemNo
			END

			IF @strRowState = 'Modified'
			BEGIN
				SELECT @strNewLotTracking = NULL

				SELECT @strOldLotTracking = NULL

				SELECT @strNewLotTracking = strLotTracking
				FROM OPENXML(@idoc, 'vyuIPGetItems/vyuIPGetItem', 2) WITH (strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS)

				SELECT @strOldLotTracking = strLotTracking
				FROM tblICItem
				WHERE intItemRefId = @intItemId

				IF @strOldLotTracking = @strNewLotTracking
				BEGIN
					UPDATE tblICItem
					SET strItemNo = x.strItemNo
						,strShortName = x.strShortName
						,strType = x.strType
						,strBundleType = x.strBundleType
						,strDescription = x.strDescription
						,intManufacturerId = @intManufacturerId
						,intBrandId = @intBrandId
						,intCategoryId = @intCategoryId
						,strStatus = x.strStatus
						,strModelNo = x.strModelNo
						,strInventoryTracking = x.strInventoryTracking
						,ysnRequireCustomerApproval = x.ysnRequireCustomerApproval
						,intRecipeId = x.intRecipeId
						,ysnSanitationRequired = x.ysnSanitationRequired
						,intLifeTime = x.intLifeTime
						,strLifeTimeType = x.strLifeTimeType
						,intReceiveLife = x.intReceiveLife
						,strGTIN = x.strGTIN
						,strRotationType = x.strRotationType
						,intNMFCId = x.intNMFCId
						,ysnStrictFIFO = x.ysnStrictFIFO
						,intDimensionUOMId = @intDimensionUOMId
						,dblHeight = x.dblHeight
						,dblWidth = x.dblWidth
						,dblDepth = x.dblDepth
						,intWeightUOMId = @intWeightUOMId
						,dblWeight = x.dblWeight
						,intMaterialPackTypeId = @intMaterialPackTypeId
						,strMaterialSizeCode = x.strMaterialSizeCode
						,intInnerUnits = x.intInnerUnits
						,intLayerPerPallet = x.intLayerPerPallet
						,intUnitPerLayer = x.intUnitPerLayer
						,dblStandardPalletRatio = x.dblStandardPalletRatio
						,strMask1 = x.strMask1
						,strMask2 = x.strMask2
						,strMask3 = x.strMask3
						,dblMaxWeightPerPack = x.dblMaxWeightPerPack
						,intPatronageCategoryId = @intPatronageCategoryId
						,intPatronageCategoryDirectId = x.intPatronageCategoryDirectId
						,ysnStockedItem = x.ysnStockedItem
						,ysnDyedFuel = x.ysnDyedFuel
						,strBarcodePrint = x.strBarcodePrint
						,ysnMSDSRequired = x.ysnMSDSRequired
						,strEPANumber = x.strEPANumber
						,ysnInboundTax = x.ysnInboundTax
						,ysnOutboundTax = x.ysnOutboundTax
						,ysnRestrictedChemical = x.ysnRestrictedChemical
						,ysnFuelItem = x.ysnFuelItem
						,ysnTankRequired = x.ysnTankRequired
						,ysnAvailableTM = x.ysnAvailableTM
						,dblDefaultFull = x.dblDefaultFull
						,strFuelInspectFee = x.strFuelInspectFee
						,strRINRequired = x.strRINRequired
						,intRINFuelTypeId = x.intRINFuelTypeId
						,dblDenaturantPercent = x.dblDenaturantPercent
						,ysnTonnageTax = x.ysnTonnageTax
						,ysnLoadTracking = x.ysnLoadTracking
						,dblMixOrder = x.dblMixOrder
						,ysnHandAddIngredient = x.ysnHandAddIngredient
						,intMedicationTag = @intMedicationTag
						,intIngredientTag = @intIngredientTag
						,intHazmatTag = x.intHazmatTag
						,strVolumeRebateGroup = x.strVolumeRebateGroup
						,intPhysicalItem = @intPhysicalItemId
						,ysnExtendPickTicket = x.ysnExtendPickTicket
						,ysnExportEDI = x.ysnExportEDI
						,ysnHazardMaterial = x.ysnHazardMaterial
						,ysnMaterialFee = x.ysnMaterialFee
						,ysnAutoBlend = x.ysnAutoBlend
						,dblUserGroupFee = x.dblUserGroupFee
						,dblWeightTolerance = x.dblWeightTolerance
						,dblOverReceiveTolerance = x.dblOverReceiveTolerance
						,strMaintenanceCalculationMethod = x.strMaintenanceCalculationMethod
						,dblMaintenanceRate = x.dblMaintenanceRate
						,ysnListBundleSeparately = x.ysnListBundleSeparately
						,intModuleId = x.intModuleId
						,strNACSCategory = x.strNACSCategory
						,strWICCode = x.strWICCode
						,intAGCategory = x.intAGCategory
						,ysnReceiptCommentRequired = x.ysnReceiptCommentRequired
						,strCountCode = x.strCountCode
						,ysnLandedCost = x.ysnLandedCost
						,strLeadTime = x.strLeadTime
						,ysnTaxable = x.ysnTaxable
						,strKeywords = x.strKeywords
						,dblCaseQty = x.dblCaseQty
						,dtmDateShip = x.dtmDateShip
						,dblTaxExempt = x.dblTaxExempt
						,ysnDropShip = x.ysnDropShip
						,ysnCommisionable = x.ysnCommisionable
						,ysnSpecialCommission = x.ysnSpecialCommission
						,intCommodityId = @intCommodityId
						,intCommodityHierarchyId = x.intCommodityHierarchyId
						,dblGAShrinkFactor = x.dblGAShrinkFactor
						,intOriginId = @intOriginId
						,intProductTypeId = x.intProductTypeId
						,intRegionId = x.intRegionId
						,intSeasonId = x.intSeasonId
						,intClassVarietyId = x.intClassVarietyId
						,intProductLineId = x.intProductLineId
						,intGradeId = x.intGradeId
						,strMarketValuation = x.strMarketValuation
						,ysnInventoryCost = x.ysnInventoryCost
						,ysnAccrue = x.ysnAccrue
						,ysnMTM = x.ysnMTM
						,ysnPrice = x.ysnPrice
						,strCostMethod = x.strCostMethod
						,strCostType = x.strCostType
						,intOnCostTypeId = x.intOnCostTypeId
						,dblAmount = x.dblAmount
						,intCostUOMId = x.intCostUOMId
						,intPackTypeId = x.intPackTypeId
						,strWeightControlCode = x.strWeightControlCode
						,dblBlendWeight = x.dblBlendWeight
						,dblNetWeight = x.dblNetWeight
						,dblUnitPerCase = x.dblUnitPerCase
						,dblQuarantineDuration = x.dblQuarantineDuration
						,intOwnerId = @intOwnerId
						,intCustomerId = @intCustomerId
						,dblCaseWeight = x.dblCaseWeight
						,strWarehouseStatus = x.strWarehouseStatus
						,ysnKosherCertified = x.ysnKosherCertified
						,ysnFairTradeCompliant = x.ysnFairTradeCompliant
						,ysnOrganic = x.ysnOrganic
						,ysnRainForestCertified = x.ysnRainForestCertified
						,dblRiskScore = x.dblRiskScore
						,dblDensity = x.dblDensity
						,dtmDateAvailable = x.dtmDateAvailable
						,ysnMinorIngredient = x.ysnMinorIngredient
						,ysnExternalItem = x.ysnExternalItem
						,strExternalGroup = x.strExternalGroup
						,ysnSellableItem = x.ysnSellableItem
						,dblMinStockWeeks = x.dblMinStockWeeks
						,dblFullContainerSize = x.dblFullContainerSize
						,ysnHasMFTImplication = x.ysnHasMFTImplication
						,intBuyingGroupId = @intBuyingGroupId
						,intAccountManagerId = @intAccountManagerId
						,intConcurrencyId = x.intConcurrencyId
						,ysnItemUsedInDiscountCode = x.ysnItemUsedInDiscountCode
						,ysnUsedForEnergyTracExport = x.ysnUsedForEnergyTracExport
						,strInvoiceComments = x.strInvoiceComments
						,strPickListComments = x.strPickListComments
						,intLotStatusId = @intLotStatusId
						,strRequired = x.strRequired
						,ysnBasisContract = x.ysnBasisContract
						,intM2MComputationId = @intM2MComputationId
						,intTonnageTaxUOMId = @intTonnageTaxUOMId
						,ysn1099Box3 = x.ysn1099Box3
						,ysnUseWeighScales = x.ysnUseWeighScales
						,ysnLotWeightsRequired = x.ysnLotWeightsRequired
						,ysnBillable = x.ysnBillable
						,ysnSupported = x.ysnSupported
						,ysnDisplayInHelpdesk = x.ysnDisplayInHelpdesk
						,intHazmatMessage = x.intHazmatMessage
						,strOriginStatus = x.strOriginStatus
						,intCompanyId = x.intCompanyId
						,dtmDateCreated = x.dtmDateCreated
						,dtmDateModified = x.dtmDateModified
						,intCreatedByUserId = x.intCreatedByUserId
						,intModifiedByUserId = x.intModifiedByUserId
						,strServiceType = x.strServiceType
						,intDataSourceId = @intDataSourceId
					FROM OPENXML(@idoc, 'vyuIPGetItems/vyuIPGetItem', 2) WITH (
							strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strShortName NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strBundleType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
							,intManufacturerId INT
							,intBrandId INT
							,intCategoryId INT
							,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strModelNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
							,strInventoryTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnRequireCustomerApproval BIT
							,intRecipeId INT
							,ysnSanitationRequired BIT
							,intLifeTime INT
							,strLifeTimeType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intReceiveLife INT
							,strGTIN NVARCHAR(100) COLLATE Latin1_General_CI_AS
							,strRotationType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intNMFCId INT
							,ysnStrictFIFO BIT
							,intDimensionUOMId INT
							,dblHeight NUMERIC(18, 6)
							,dblWidth NUMERIC(18, 6)
							,dblDepth NUMERIC(18, 6)
							,intWeightUOMId INT
							,dblWeight NUMERIC(18, 6)
							,intMaterialPackTypeId INT
							,strMaterialSizeCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intInnerUnits INT
							,intLayerPerPallet INT
							,intUnitPerLayer INT
							,dblStandardPalletRatio NUMERIC(18, 6)
							,strMask1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strMask2 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strMask3 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblMaxWeightPerPack NUMERIC(18, 6)
							,intPatronageCategoryId INT
							,intPatronageCategoryDirectId INT
							,ysnStockedItem BIT
							,ysnDyedFuel BIT
							,strBarcodePrint NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnMSDSRequired BIT
							,strEPANumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnInboundTax BIT
							,ysnOutboundTax BIT
							,ysnRestrictedChemical BIT
							,ysnFuelItem BIT
							,ysnTankRequired BIT
							,ysnAvailableTM BIT
							,dblDefaultFull NUMERIC(18, 6)
							,strFuelInspectFee NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strRINRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intRINFuelTypeId INT
							,dblDenaturantPercent NUMERIC(18, 6)
							,ysnTonnageTax BIT
							,ysnLoadTracking BIT
							,dblMixOrder NUMERIC(18, 6)
							,ysnHandAddIngredient BIT
							,intMedicationTag INT
							,intIngredientTag INT
							,intHazmatTag INT
							,strVolumeRebateGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnExtendPickTicket BIT
							,ysnExportEDI BIT
							,ysnHazardMaterial BIT
							,ysnMaterialFee BIT
							,ysnAutoBlend BIT
							,dblUserGroupFee NUMERIC(18, 6)
							,dblWeightTolerance NUMERIC(18, 6)
							,dblOverReceiveTolerance NUMERIC(18, 6)
							,strMaintenanceCalculationMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblMaintenanceRate NUMERIC(18, 6)
							,ysnListBundleSeparately BIT
							,intModuleId INT
							,strNACSCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strWICCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intAGCategory INT
							,ysnReceiptCommentRequired BIT
							,strCountCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnLandedCost BIT
							,strLeadTime NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnTaxable BIT
							,strKeywords NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
							,dblCaseQty NUMERIC(18, 6)
							,dtmDateShip DATETIME
							,dblTaxExempt NUMERIC(18, 6)
							,ysnDropShip BIT
							,ysnCommisionable BIT
							,ysnSpecialCommission BIT
							,intCommodityId INT
							,intCommodityHierarchyId INT
							,dblGAShrinkFactor NUMERIC(18, 6)
							,intOriginId INT
							,intProductTypeId INT
							,intRegionId INT
							,intSeasonId INT
							,intClassVarietyId INT
							,intProductLineId INT
							,intGradeId INT
							,strMarketValuation NVARCHAR(50)
							,ysnInventoryCost BIT
							,ysnAccrue BIT
							,ysnMTM BIT
							,ysnPrice BIT
							,strCostMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strCostType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intOnCostTypeId INT
							,dblAmount NUMERIC(18, 6)
							,intCostUOMId INT
							,intPackTypeId INT
							,strWeightControlCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblBlendWeight NUMERIC(18, 6)
							,dblNetWeight NUMERIC(18, 6)
							,dblUnitPerCase NUMERIC(18, 6)
							,dblQuarantineDuration NUMERIC(18, 6)
							,intOwnerId INT
							,intCustomerId INT
							,dblCaseWeight NUMERIC(18, 6)
							,strWarehouseStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnKosherCertified BIT
							,ysnFairTradeCompliant BIT
							,ysnOrganic BIT
							,ysnRainForestCertified BIT
							,dblRiskScore NUMERIC(18, 6)
							,dblDensity NUMERIC(18, 6)
							,dtmDateAvailable DATETIME
							,ysnMinorIngredient BIT
							,ysnExternalItem BIT
							,strExternalGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnSellableItem BIT
							,dblMinStockWeeks NUMERIC(18, 6)
							,dblFullContainerSize NUMERIC(18, 6)
							,ysnHasMFTImplication BIT
							,intBuyingGroupId INT
							,intAccountManagerId INT
							,intConcurrencyId INT
							,ysnItemUsedInDiscountCode BIT
							,ysnUsedForEnergyTracExport BIT
							,strInvoiceComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
							,strPickListComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
							,intLotStatusId INT
							,strRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnBasisContract BIT
							,intM2MComputationId INT
							,intTonnageTaxUOMId INT
							,ysn1099Box3 BIT
							,ysnUseWeighScales BIT
							,ysnLotWeightsRequired BIT
							,ysnBillable BIT
							,ysnSupported BIT
							,ysnDisplayInHelpdesk BIT
							,intHazmatMessage INT
							,strOriginStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intCompanyId INT
							,dtmDateCreated DATETIME
							,dtmDateModified DATETIME
							,intCreatedByUserId INT
							,intModifiedByUserId INT
							,strServiceType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intDataSourceId TINYINT
							) x
					WHERE tblICItem.intItemRefId = @intItemId
				END
				ELSE
				BEGIN
					UPDATE tblICItem
					SET strItemNo = x.strItemNo
						,strShortName = x.strShortName
						,strType = x.strType
						,strBundleType = x.strBundleType
						,strDescription = x.strDescription
						,intManufacturerId = @intManufacturerId
						,intBrandId = @intBrandId
						,intCategoryId = @intCategoryId
						,strStatus = x.strStatus
						,strModelNo = x.strModelNo
						,strInventoryTracking = x.strInventoryTracking
						,strLotTracking = x.strLotTracking
						,ysnRequireCustomerApproval = x.ysnRequireCustomerApproval
						,intRecipeId = x.intRecipeId
						,ysnSanitationRequired = x.ysnSanitationRequired
						,intLifeTime = x.intLifeTime
						,strLifeTimeType = x.strLifeTimeType
						,intReceiveLife = x.intReceiveLife
						,strGTIN = x.strGTIN
						,strRotationType = x.strRotationType
						,intNMFCId = x.intNMFCId
						,ysnStrictFIFO = x.ysnStrictFIFO
						,intDimensionUOMId = @intDimensionUOMId
						,dblHeight = x.dblHeight
						,dblWidth = x.dblWidth
						,dblDepth = x.dblDepth
						,intWeightUOMId = @intWeightUOMId
						,dblWeight = x.dblWeight
						,intMaterialPackTypeId = @intMaterialPackTypeId
						,strMaterialSizeCode = x.strMaterialSizeCode
						,intInnerUnits = x.intInnerUnits
						,intLayerPerPallet = x.intLayerPerPallet
						,intUnitPerLayer = x.intUnitPerLayer
						,dblStandardPalletRatio = x.dblStandardPalletRatio
						,strMask1 = x.strMask1
						,strMask2 = x.strMask2
						,strMask3 = x.strMask3
						,dblMaxWeightPerPack = x.dblMaxWeightPerPack
						,intPatronageCategoryId = @intPatronageCategoryId
						,intPatronageCategoryDirectId = x.intPatronageCategoryDirectId
						,ysnStockedItem = x.ysnStockedItem
						,ysnDyedFuel = x.ysnDyedFuel
						,strBarcodePrint = x.strBarcodePrint
						,ysnMSDSRequired = x.ysnMSDSRequired
						,strEPANumber = x.strEPANumber
						,ysnInboundTax = x.ysnInboundTax
						,ysnOutboundTax = x.ysnOutboundTax
						,ysnRestrictedChemical = x.ysnRestrictedChemical
						,ysnFuelItem = x.ysnFuelItem
						,ysnTankRequired = x.ysnTankRequired
						,ysnAvailableTM = x.ysnAvailableTM
						,dblDefaultFull = x.dblDefaultFull
						,strFuelInspectFee = x.strFuelInspectFee
						,strRINRequired = x.strRINRequired
						,intRINFuelTypeId = x.intRINFuelTypeId
						,dblDenaturantPercent = x.dblDenaturantPercent
						,ysnTonnageTax = x.ysnTonnageTax
						,ysnLoadTracking = x.ysnLoadTracking
						,dblMixOrder = x.dblMixOrder
						,ysnHandAddIngredient = x.ysnHandAddIngredient
						,intMedicationTag = @intMedicationTag
						,intIngredientTag = @intIngredientTag
						,intHazmatTag = x.intHazmatTag
						,strVolumeRebateGroup = x.strVolumeRebateGroup
						,intPhysicalItem = @intPhysicalItemId
						,ysnExtendPickTicket = x.ysnExtendPickTicket
						,ysnExportEDI = x.ysnExportEDI
						,ysnHazardMaterial = x.ysnHazardMaterial
						,ysnMaterialFee = x.ysnMaterialFee
						,ysnAutoBlend = x.ysnAutoBlend
						,dblUserGroupFee = x.dblUserGroupFee
						,dblWeightTolerance = x.dblWeightTolerance
						,dblOverReceiveTolerance = x.dblOverReceiveTolerance
						,strMaintenanceCalculationMethod = x.strMaintenanceCalculationMethod
						,dblMaintenanceRate = x.dblMaintenanceRate
						,ysnListBundleSeparately = x.ysnListBundleSeparately
						,intModuleId = x.intModuleId
						,strNACSCategory = x.strNACSCategory
						,strWICCode = x.strWICCode
						,intAGCategory = x.intAGCategory
						,ysnReceiptCommentRequired = x.ysnReceiptCommentRequired
						,strCountCode = x.strCountCode
						,ysnLandedCost = x.ysnLandedCost
						,strLeadTime = x.strLeadTime
						,ysnTaxable = x.ysnTaxable
						,strKeywords = x.strKeywords
						,dblCaseQty = x.dblCaseQty
						,dtmDateShip = x.dtmDateShip
						,dblTaxExempt = x.dblTaxExempt
						,ysnDropShip = x.ysnDropShip
						,ysnCommisionable = x.ysnCommisionable
						,ysnSpecialCommission = x.ysnSpecialCommission
						,intCommodityId = @intCommodityId
						,intCommodityHierarchyId = x.intCommodityHierarchyId
						,dblGAShrinkFactor = x.dblGAShrinkFactor
						,intOriginId = @intOriginId
						,intProductTypeId = x.intProductTypeId
						,intRegionId = x.intRegionId
						,intSeasonId = x.intSeasonId
						,intClassVarietyId = x.intClassVarietyId
						,intProductLineId = x.intProductLineId
						,intGradeId = x.intGradeId
						,strMarketValuation = x.strMarketValuation
						,ysnInventoryCost = x.ysnInventoryCost
						,ysnAccrue = x.ysnAccrue
						,ysnMTM = x.ysnMTM
						,ysnPrice = x.ysnPrice
						,strCostMethod = x.strCostMethod
						,strCostType = x.strCostType
						,intOnCostTypeId = x.intOnCostTypeId
						,dblAmount = x.dblAmount
						,intCostUOMId = x.intCostUOMId
						,intPackTypeId = x.intPackTypeId
						,strWeightControlCode = x.strWeightControlCode
						,dblBlendWeight = x.dblBlendWeight
						,dblNetWeight = x.dblNetWeight
						,dblUnitPerCase = x.dblUnitPerCase
						,dblQuarantineDuration = x.dblQuarantineDuration
						,intOwnerId = @intOwnerId
						,intCustomerId = @intCustomerId
						,dblCaseWeight = x.dblCaseWeight
						,strWarehouseStatus = x.strWarehouseStatus
						,ysnKosherCertified = x.ysnKosherCertified
						,ysnFairTradeCompliant = x.ysnFairTradeCompliant
						,ysnOrganic = x.ysnOrganic
						,ysnRainForestCertified = x.ysnRainForestCertified
						,dblRiskScore = x.dblRiskScore
						,dblDensity = x.dblDensity
						,dtmDateAvailable = x.dtmDateAvailable
						,ysnMinorIngredient = x.ysnMinorIngredient
						,ysnExternalItem = x.ysnExternalItem
						,strExternalGroup = x.strExternalGroup
						,ysnSellableItem = x.ysnSellableItem
						,dblMinStockWeeks = x.dblMinStockWeeks
						,dblFullContainerSize = x.dblFullContainerSize
						,ysnHasMFTImplication = x.ysnHasMFTImplication
						,intBuyingGroupId = @intBuyingGroupId
						,intAccountManagerId = @intAccountManagerId
						,intConcurrencyId = x.intConcurrencyId
						,ysnItemUsedInDiscountCode = x.ysnItemUsedInDiscountCode
						,ysnUsedForEnergyTracExport = x.ysnUsedForEnergyTracExport
						,strInvoiceComments = x.strInvoiceComments
						,strPickListComments = x.strPickListComments
						,intLotStatusId = @intLotStatusId
						,strRequired = x.strRequired
						,ysnBasisContract = x.ysnBasisContract
						,intM2MComputationId = @intM2MComputationId
						,intTonnageTaxUOMId = @intTonnageTaxUOMId
						,ysn1099Box3 = x.ysn1099Box3
						,ysnUseWeighScales = x.ysnUseWeighScales
						,ysnLotWeightsRequired = x.ysnLotWeightsRequired
						,ysnBillable = x.ysnBillable
						,ysnSupported = x.ysnSupported
						,ysnDisplayInHelpdesk = x.ysnDisplayInHelpdesk
						,intHazmatMessage = x.intHazmatMessage
						,strOriginStatus = x.strOriginStatus
						,intCompanyId = x.intCompanyId
						,dtmDateCreated = x.dtmDateCreated
						,dtmDateModified = x.dtmDateModified
						,intCreatedByUserId = x.intCreatedByUserId
						,intModifiedByUserId = x.intModifiedByUserId
						,strServiceType = x.strServiceType
						,intDataSourceId = @intDataSourceId
					FROM OPENXML(@idoc, 'vyuIPGetItems/vyuIPGetItem', 2) WITH (
							strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strShortName NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strBundleType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
							,intManufacturerId INT
							,intBrandId INT
							,intCategoryId INT
							,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strModelNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
							,strInventoryTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnRequireCustomerApproval BIT
							,intRecipeId INT
							,ysnSanitationRequired BIT
							,intLifeTime INT
							,strLifeTimeType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intReceiveLife INT
							,strGTIN NVARCHAR(100) COLLATE Latin1_General_CI_AS
							,strRotationType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intNMFCId INT
							,ysnStrictFIFO BIT
							,intDimensionUOMId INT
							,dblHeight NUMERIC(18, 6)
							,dblWidth NUMERIC(18, 6)
							,dblDepth NUMERIC(18, 6)
							,intWeightUOMId INT
							,dblWeight NUMERIC(18, 6)
							,intMaterialPackTypeId INT
							,strMaterialSizeCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intInnerUnits INT
							,intLayerPerPallet INT
							,intUnitPerLayer INT
							,dblStandardPalletRatio NUMERIC(18, 6)
							,strMask1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strMask2 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strMask3 NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblMaxWeightPerPack NUMERIC(18, 6)
							,intPatronageCategoryId INT
							,intPatronageCategoryDirectId INT
							,ysnStockedItem BIT
							,ysnDyedFuel BIT
							,strBarcodePrint NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnMSDSRequired BIT
							,strEPANumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnInboundTax BIT
							,ysnOutboundTax BIT
							,ysnRestrictedChemical BIT
							,ysnFuelItem BIT
							,ysnTankRequired BIT
							,ysnAvailableTM BIT
							,dblDefaultFull NUMERIC(18, 6)
							,strFuelInspectFee NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strRINRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intRINFuelTypeId INT
							,dblDenaturantPercent NUMERIC(18, 6)
							,ysnTonnageTax BIT
							,ysnLoadTracking BIT
							,dblMixOrder NUMERIC(18, 6)
							,ysnHandAddIngredient BIT
							,intMedicationTag INT
							,intIngredientTag INT
							,intHazmatTag INT
							,strVolumeRebateGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnExtendPickTicket BIT
							,ysnExportEDI BIT
							,ysnHazardMaterial BIT
							,ysnMaterialFee BIT
							,ysnAutoBlend BIT
							,dblUserGroupFee NUMERIC(18, 6)
							,dblWeightTolerance NUMERIC(18, 6)
							,dblOverReceiveTolerance NUMERIC(18, 6)
							,strMaintenanceCalculationMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblMaintenanceRate NUMERIC(18, 6)
							,ysnListBundleSeparately BIT
							,intModuleId INT
							,strNACSCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strWICCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intAGCategory INT
							,ysnReceiptCommentRequired BIT
							,strCountCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnLandedCost BIT
							,strLeadTime NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnTaxable BIT
							,strKeywords NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
							,dblCaseQty NUMERIC(18, 6)
							,dtmDateShip DATETIME
							,dblTaxExempt NUMERIC(18, 6)
							,ysnDropShip BIT
							,ysnCommisionable BIT
							,ysnSpecialCommission BIT
							,intCommodityId INT
							,intCommodityHierarchyId INT
							,dblGAShrinkFactor NUMERIC(18, 6)
							,intOriginId INT
							,intProductTypeId INT
							,intRegionId INT
							,intSeasonId INT
							,intClassVarietyId INT
							,intProductLineId INT
							,intGradeId INT
							,strMarketValuation NVARCHAR(50)
							,ysnInventoryCost BIT
							,ysnAccrue BIT
							,ysnMTM BIT
							,ysnPrice BIT
							,strCostMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,strCostType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intOnCostTypeId INT
							,dblAmount NUMERIC(18, 6)
							,intCostUOMId INT
							,intPackTypeId INT
							,strWeightControlCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,dblBlendWeight NUMERIC(18, 6)
							,dblNetWeight NUMERIC(18, 6)
							,dblUnitPerCase NUMERIC(18, 6)
							,dblQuarantineDuration NUMERIC(18, 6)
							,intOwnerId INT
							,intCustomerId INT
							,dblCaseWeight NUMERIC(18, 6)
							,strWarehouseStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnKosherCertified BIT
							,ysnFairTradeCompliant BIT
							,ysnOrganic BIT
							,ysnRainForestCertified BIT
							,dblRiskScore NUMERIC(18, 6)
							,dblDensity NUMERIC(18, 6)
							,dtmDateAvailable DATETIME
							,ysnMinorIngredient BIT
							,ysnExternalItem BIT
							,strExternalGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnSellableItem BIT
							,dblMinStockWeeks NUMERIC(18, 6)
							,dblFullContainerSize NUMERIC(18, 6)
							,ysnHasMFTImplication BIT
							,intBuyingGroupId INT
							,intAccountManagerId INT
							,intConcurrencyId INT
							,ysnItemUsedInDiscountCode BIT
							,ysnUsedForEnergyTracExport BIT
							,strInvoiceComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
							,strPickListComments NVARCHAR(500) COLLATE Latin1_General_CI_AS
							,intLotStatusId INT
							,strRequired NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,ysnBasisContract BIT
							,intM2MComputationId INT
							,intTonnageTaxUOMId INT
							,ysn1099Box3 BIT
							,ysnUseWeighScales BIT
							,ysnLotWeightsRequired BIT
							,ysnBillable BIT
							,ysnSupported BIT
							,ysnDisplayInHelpdesk BIT
							,intHazmatMessage INT
							,strOriginStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intCompanyId INT
							,dtmDateCreated DATETIME
							,dtmDateModified DATETIME
							,intCreatedByUserId INT
							,intModifiedByUserId INT
							,strServiceType NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,intDataSourceId TINYINT
							) x
					WHERE tblICItem.intItemRefId = @intItemId
				END

				SELECT @intNewItemId = intItemId
					,@strItemNo = strItemNo
				FROM tblICItem
				WHERE tblICItem.intItemRefId = @intItemId
			END

			EXEC sp_xml_removedocument @idoc

			------------------Item Account------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemAccountXML

			DECLARE @tblICItemAccount TABLE (
				intItemAccountId INT identity(1, 1)
				,strAccountCategory NVARCHAR(50) Collate Latin1_General_CI_AS
				,strAccountId NVARCHAR(40) Collate Latin1_General_CI_AS
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemAccount TABLE (
				intItemId INT
				,intAccountCategoryId INT
				,intAccountId INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemAccount (
				strAccountCategory
				,strAccountId
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strAccountCategory
				,strAccountId
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemAccounts/vyuIPGetItemAccount', 2) WITH (
					strAccountCategory NVARCHAR(50) Collate Latin1_General_CI_AS
					,strAccountId NVARCHAR(40) Collate Latin1_General_CI_AS
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			DECLARE @intItemAccountId INT
				,@strAccountCategory NVARCHAR(50)
				,@strAccountId NVARCHAR(40)
				,@strCreatedBy NVARCHAR(50)
				,@strModifiedBy NVARCHAR(50)
				,@intAccountCategoryId INT
				,@intAccountId INT
				,@intCreatedById INT
				,@intModifiedById INT
				,@intSort INT
				,@dtmDateCreated DATETIME
				,@dtmDateModified DATETIME

			SELECT @intItemAccountId = min(intItemAccountId)
			FROM @tblICItemAccount

			WHILE @intItemAccountId IS NOT NULL
			BEGIN
				SELECT @strAccountCategory = NULL
					,@strAccountId = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL
					,@strErrorMessage = ''

				SELECT @strAccountCategory = strAccountCategory
					,@strAccountId = strAccountId
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemAccount
				WHERE intItemAccountId = @intItemAccountId

				SELECT @intAccountCategoryId = NULL

				SELECT @intAccountCategoryId = intAccountCategoryId
				FROM tblGLAccountCategory
				WHERE strAccountCategory = @strAccountCategory

				IF @strAccountCategory IS NOT NULL
					AND @intAccountCategoryId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Account Category ' + @strAccountCategory + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Account Category ' + @strAccountCategory + ' is not available.'
					END
				END

				SELECT @intAccountId = NULL

				SELECT @intAccountId = intAccountId
				FROM tblGLAccount
				WHERE strAccountId = @strAccountId

				IF @strAccountId IS NOT NULL
					AND @intAccountId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Account ' + @strAccountId + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Account ' + @strAccountId + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemAccount (
					intItemId
					,intAccountCategoryId
					,intAccountId
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intAccountCategoryId
					,@intAccountId
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemAccountId = min(intItemAccountId)
				FROM @tblICItemAccount
				WHERE intItemAccountId > @intItemAccountId
			END

			DELETE IA
			FROM tblICItemAccount IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemAccount IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAccountCategoryId = IA.intAccountCategoryId
						AND IA1.intAccountId = IA.intAccountId
					)

			UPDATE IA1
			SET intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemAccount IA
			JOIN tblICItemAccount IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intAccountCategoryId = IA.intAccountCategoryId
				AND IA1.intAccountId = IA.intAccountId

			INSERT INTO tblICItemAccount (
				intItemId
				,intAccountCategoryId
				,intAccountId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intAccountCategoryId
				,intAccountId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemAccount IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemAccount IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAccountCategoryId = IA.intAccountCategoryId
						AND IA1.intAccountId = IA.intAccountId
					)

			DELETE
			FROM @tblICItemAccount

			DELETE
			FROM @tblICFinalItemAccount

			EXEC sp_xml_removedocument @idoc

			------------------Item AddOn------------------------------------------------------
			DECLARE @intItemAddOnId INT
				,@strAddOnItemNo NVARCHAR(50)
				,@dblQuantity NUMERIC(38, 20)
				,@strUnitMeasure NVARCHAR(50)
				,@intConcurrencyId INT
				,@intAddOnItemId INT
				,@intUnitMeasureId INT
				,@ysnAutoAdd BIT
				,@intItemUOMId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemAddOnXML

			DECLARE @tblICItemAddOn TABLE (
				intItemAddOnId INT identity(1, 1)
				,strAddOnItemNo NVARCHAR(50)
				,dblQuantity NUMERIC(38, 20)
				,strUnitMeasure NVARCHAR(50)
				,ysnAutoAdd BIT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50)
				,strModifiedBy NVARCHAR(50)
				)
			DECLARE @tblICFinalItemAddOn TABLE (
				intItemId INT
				,intAddOnItemId INT
				,dblQuantity NUMERIC(38, 20)
				,intItemUOMId INT
				,ysnAutoAdd BIT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemAddOn (
				strAddOnItemNo
				,dblQuantity
				,strUnitMeasure
				,ysnAutoAdd
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strAddOnItemNo
				,dblQuantity
				,strUnitMeasure
				,ysnAutoAdd
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemAddOns/vyuIPGetItemAddOn', 2) WITH (
					strAddOnItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblQuantity NUMERIC(38, 20)
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnAutoAdd BIT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					)

			SELECT @intItemAddOnId = min(intItemAddOnId)
			FROM @tblICItemAddOn

			WHILE @intItemAddOnId IS NOT NULL
			BEGIN
				SELECT @strAddOnItemNo = NULL
					,@dblQuantity = NULL
					,@strUnitMeasure = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intUnitMeasureId = NULL
					,@ysnAutoAdd = NULL
					,@strErrorMessage = ''

				SELECT @strAddOnItemNo = strAddOnItemNo
					,@dblQuantity = dblQuantity
					,@strUnitMeasure = strUnitMeasure
					,@ysnAutoAdd = ysnAutoAdd
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemAddOn
				WHERE intItemAddOnId = @intItemAddOnId

				SELECT @intAddOnItemId = NULL

				SELECT @intAddOnItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strAddOnItemNo

				IF @strAddOnItemNo IS NOT NULL
					AND @intAddOnItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Add-on Item ' + @strAddOnItemNo + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Add-on Item ' + @strAddOnItemNo + ' is not available.'
					END
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intAddOnItemId
					AND intUnitMeasureId = @intUnitMeasureId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemAddOn (
					intItemId
					,intAddOnItemId
					,dblQuantity
					,intItemUOMId
					,ysnAutoAdd
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intAddOnItemId
					,@dblQuantity
					,@intItemUOMId
					,@ysnAutoAdd
					,1
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemAddOnId = min(intItemAddOnId)
				FROM @tblICItemAddOn
				WHERE intItemAddOnId > @intItemAddOnId
			END

			DELETE IA
			FROM tblICItemAddOn IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemAddOn IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAddOnItemId = IA.intAddOnItemId
					)

			UPDATE IA1
			SET dblQuantity = IA.dblQuantity
				,intItemUOMId = IA.intItemUOMId
				,intConcurrencyId = IA.intConcurrencyId + 1
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
				,ysnAutoAdd = IA.ysnAutoAdd
			FROM @tblICFinalItemAddOn IA
			JOIN tblICItemAddOn IA1 ON IA1.intAddOnItemId = IA.intAddOnItemId
				AND IA1.intItemId = IA.intItemId

			INSERT INTO tblICItemAddOn (
				intItemId
				,intAddOnItemId
				,dblQuantity
				,intItemUOMId
				,ysnAutoAdd
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intAddOnItemId
				,dblQuantity
				,intItemUOMId
				,ysnAutoAdd
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemAddOn IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemAddOn IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAddOnItemId = IA.intAddOnItemId
					)

			DELETE
			FROM @tblICItemAddOn

			DELETE
			FROM @tblICFinalItemAddOn

			EXEC sp_xml_removedocument @idoc

			------------------Item Assembly------------------------------------------------------
			DECLARE @intItemAssemblyId INT
				,@strAssemblyItemNo NVARCHAR(50)
				,@intAssemblyItemId INT
				,@dblUnit NUMERIC(38, 20)
				,@dblCost NUMERIC(38, 20)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemAssemblyXML

			DECLARE @tblICItemAssembly TABLE (
				intItemAssemblyId INT identity(1, 1)
				,strAssemblyItemNo NVARCHAR(50)
				,strDescription NVARCHAR(100)
				,dblQuantity NUMERIC(38, 20)
				,strUnitMeasure NVARCHAR(50)
				,dblUnit NUMERIC(38, 20)
				,dblCost NUMERIC(38, 20)
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50)
				,strModifiedBy NVARCHAR(50)
				)
			DECLARE @tblICFinalItemAssembly TABLE (
				intItemId INT
				,intAssemblyItemId INT
				,strDescription NVARCHAR(100)
				,dblQuantity NUMERIC(38, 20)
				,intItemUnitMeasureId INT
				,dblUnit NUMERIC(38, 20)
				,dblCost NUMERIC(38, 20)
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemAssembly (
				strAssemblyItemNo
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,dblUnit
				,dblCost
				,intSort
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strAssemblyItemNo
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,dblUnit
				,dblCost
				,intSort
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemAssemblys/vyuIPGetItemAssembly', 2) WITH (
					strAssemblyItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strDescription NVARCHAR(100) Collate Latin1_General_CI_AS
					,dblQuantity NUMERIC(38, 20)
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblUnit NUMERIC(38, 20)
					,dblCost NUMERIC(38, 20)
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					)

			SELECT @intItemAssemblyId = min(intItemAssemblyId)
			FROM @tblICItemAssembly

			WHILE @intItemAssemblyId IS NOT NULL
			BEGIN
				SELECT @strAssemblyItemNo = NULL
					,@dblQuantity = NULL
					,@strUnitMeasure = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intUnitMeasureId = NULL
					,@dblUnit = NULL
					,@dblCost = NULL
					,@intSort = NULL
					,@strErrorMessage = ''

				SELECT @strAssemblyItemNo = strAssemblyItemNo
					,@dblQuantity = dblQuantity
					,@strUnitMeasure = strUnitMeasure
					,@dblUnit = dblUnit
					,@dblCost = dblCost
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemAssembly
				WHERE intItemAssemblyId = @intItemAssemblyId

				SELECT @intAssemblyItemId = NULL

				SELECT @intAssemblyItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strAssemblyItemNo

				IF @strAssemblyItemNo IS NOT NULL
					AND @intAssemblyItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Assembly Item ' + @strAssemblyItemNo + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Assembly Item ' + @strAssemblyItemNo + ' is not available.'
					END
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Assembly Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Assembly Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intAssemblyItemId
					AND intUnitMeasureId = @intUnitMeasureId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemAssembly (
					intItemId
					,intAssemblyItemId
					,dblQuantity
					,intItemUnitMeasureId
					,dblUnit
					,dblCost
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intAssemblyItemId
					,@dblQuantity
					,@intItemUOMId
					,@dblUnit
					,@dblCost
					,@intSort
					,1
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemAssemblyId = min(intItemAssemblyId)
				FROM @tblICItemAssembly
				WHERE intItemAssemblyId > @intItemAssemblyId
			END

			DELETE IA
			FROM tblICItemAssembly IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemAssembly IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAssemblyItemId = IA.intAssemblyItemId
					)

			UPDATE IA1
			SET dblQuantity = IA.dblQuantity
				,intItemUnitMeasureId = IA.intItemUnitMeasureId
				,dblUnit = IA.dblUnit
				,dblCost = IA.dblCost
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId + 1
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemAssembly IA
			JOIN tblICItemAssembly IA1 ON IA1.intAssemblyItemId = IA.intAssemblyItemId
				AND IA1.intItemId = IA.intItemId

			INSERT INTO tblICItemAssembly (
				intItemId
				,intAssemblyItemId
				,dblQuantity
				,intItemUnitMeasureId
				,dblUnit
				,dblCost
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intAssemblyItemId
				,dblQuantity
				,intItemUnitMeasureId
				,dblUnit
				,dblCost
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemAssembly IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemAssembly IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intAssemblyItemId = IA.intAssemblyItemId
					)

			DELETE
			FROM @tblICItemAssembly

			DELETE
			FROM @tblICFinalItemAssembly

			EXEC sp_xml_removedocument @idoc

			------------------Item Bundle------------------------------------------------------
			DECLARE @intItemBundleId INT
				,@strBundleItemNo NVARCHAR(50)
				,@intBundleItemId INT
				,@ysnAddOn BIT
				,@dblMarkUpOrDown NUMERIC(38, 20)
				,@dtmBeginDate DATETIME
				,@dtmEndDate DATETIME

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemBundleXML

			DECLARE @tblICItemBundle TABLE (
				intItemBundleId INT identity(1, 1)
				,strBundleItemNo NVARCHAR(50)
				,strDescription NVARCHAR(100)
				,dblQuantity NUMERIC(38, 20)
				,strUnitMeasure NVARCHAR(50)
				,ysnAddOn BIT
				,dblMarkUpOrDown NUMERIC(38, 20)
				,dtmBeginDate DATETIME
				,dtmEndDate DATETIME
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50)
				,strModifiedBy NVARCHAR(50)
				)
			DECLARE @tblICFinalItemBundle TABLE (
				intItemId INT
				,intBundleItemId INT
				,strDescription NVARCHAR(100)
				,dblQuantity NUMERIC(38, 20)
				,intItemUnitMeasureId INT
				,ysnAddOn BIT
				,dblMarkUpOrDown NUMERIC(38, 20)
				,dtmBeginDate DATETIME
				,dtmEndDate DATETIME
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemBundle (
				strBundleItemNo
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,ysnAddOn
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strBundleItemNo
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,ysnAddOn
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemBundles/vyuIPGetItemBundle', 2) WITH (
					strBundleItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strDescription NVARCHAR(100) Collate Latin1_General_CI_AS
					,dblQuantity NUMERIC(38, 20)
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnAddOn BIT
					,dblMarkUpOrDown NUMERIC(38, 20)
					,dtmBeginDate DATETIME
					,dtmEndDate DATETIME
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					)

			SELECT @intItemBundleId = min(intItemBundleId)
			FROM @tblICItemBundle

			WHILE @intItemBundleId IS NOT NULL
			BEGIN
				SELECT @strBundleItemNo = NULL
					,@dblQuantity = NULL
					,@strUnitMeasure = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intUnitMeasureId = NULL
					,@dblUnit = NULL
					,@dblCost = NULL
					,@intSort = NULL
					,@strErrorMessage = ''

				SELECT @strBundleItemNo = strBundleItemNo
					,@dblQuantity = dblQuantity
					,@strUnitMeasure = strUnitMeasure
					,@ysnAddOn = ysnAddOn
					,@dblMarkUpOrDown = dblMarkUpOrDown
					,@dtmBeginDate = dtmBeginDate
					,@dtmEndDate = dtmEndDate
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemBundle
				WHERE intItemBundleId = @intItemBundleId

				SELECT @intBundleItemId = NULL

				SELECT @intBundleItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strBundleItemNo

				IF @strBundleItemNo IS NOT NULL
					AND @intBundleItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Bundle Item ' + @strBundleItemNo + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Bundle Item ' + @strBundleItemNo + ' is not available.'
					END
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Bundle Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Bundle Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intBundleItemId
					AND intUnitMeasureId = @intUnitMeasureId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemBundle (
					intItemId
					,intBundleItemId
					,dblQuantity
					,intItemUnitMeasureId
					,ysnAddOn
					,dblMarkUpOrDown
					,dtmBeginDate
					,dtmEndDate
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intBundleItemId
					,@dblQuantity
					,@intItemUOMId
					,@ysnAddOn
					,@dblMarkUpOrDown
					,@dtmBeginDate
					,@dtmEndDate
					,1
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemBundleId = min(intItemBundleId)
				FROM @tblICItemBundle
				WHERE intItemBundleId > @intItemBundleId
			END

			DELETE IA
			FROM tblICItemBundle IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemBundle IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intBundleItemId = IA.intBundleItemId
					)

			UPDATE IA1
			SET dblQuantity = IA.dblQuantity
				,intItemUnitMeasureId = IA.intItemUnitMeasureId
				,ysnAddOn = IA.ysnAddOn
				,dblMarkUpOrDown = IA.dblMarkUpOrDown
				,dtmBeginDate = IA.dtmBeginDate
				,dtmEndDate = IA.dtmEndDate
				,intConcurrencyId = IA1.intConcurrencyId + 1
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemBundle IA
			JOIN tblICItemBundle IA1 ON IA1.intBundleItemId = IA.intBundleItemId
				AND IA1.intItemId = IA.intItemId

			INSERT INTO tblICItemBundle (
				intItemId
				,intBundleItemId
				,dblQuantity
				,intItemUnitMeasureId
				,ysnAddOn
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intBundleItemId
				,dblQuantity
				,intItemUnitMeasureId
				,ysnAddOn
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemBundle IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemBundle IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intBundleItemId = IA.intBundleItemId
					)

			DELETE
			FROM @tblICItemBundle

			DELETE
			FROM @tblICFinalItemBundle

			EXEC sp_xml_removedocument @idoc

			------------------Item Certification------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemCertificationXML

			DECLARE @tblICItemCertification TABLE (
				intItemCertificationId INT identity(1, 1)
				,strCertificationName NVARCHAR(40) Collate Latin1_General_CI_AS
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemCertification TABLE (
				intItemId INT
				,intCertificationId INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemCertification (
				strCertificationName
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strCertificationName
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemCertifications/vyuIPGetItemCertification', 2) WITH (
					strCertificationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			DECLARE @intItemCertificationId INT
				,@strCertificationName NVARCHAR(50)
				,@intCertificationId INT

			SELECT @intItemCertificationId = min(intItemCertificationId)
			FROM @tblICItemCertification

			WHILE @intItemCertificationId IS NOT NULL
			BEGIN
				SELECT @strCertificationName = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strCertificationName = strCertificationName
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemCertification
				WHERE intItemCertificationId = @intItemCertificationId

				SELECT @intCertificationId = NULL

				SELECT @intCertificationId = intCertificationId
				FROM tblICCertification
				WHERE strCertificationName = @strCertificationName

				IF @strCertificationName IS NOT NULL
					AND @intCertificationId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Certification ' + @strCertificationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemCertification (
					intItemId
					,intCertificationId
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intCertificationId
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemCertificationId = min(intItemCertificationId)
				FROM @tblICItemCertification
				WHERE intItemCertificationId > @intItemCertificationId
			END

			DELETE IA
			FROM tblICItemCertification IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemCertification IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intCertificationId = IA.intCertificationId
					)

			UPDATE IA1
			SET intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemCertification IA
			JOIN tblICItemCertification IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intCertificationId = IA.intCertificationId

			INSERT INTO tblICItemCertification (
				intItemId
				,intCertificationId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intCertificationId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemCertification IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemCertification IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intCertificationId = IA.intCertificationId
					)

			DELETE
			FROM @tblICItemCertification

			DELETE
			FROM @tblICFinalItemCertification

			EXEC sp_xml_removedocument @idoc

			------------------Item UOM------------------------------------------------------
			DECLARE @strWeightUnitMeasure NVARCHAR(50)
				,@intVolumeUOMId INT
				,@strVolumeUnitMeasure NVARCHAR(50)
				,@strDimensionUnitMeasure NVARCHAR(50)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemUOMXML

			DECLARE @tblICItemUOM TABLE (
				intItemUOMId INT identity(1, 1)
				,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dblUnitQty NUMERIC(18, 6)
				,dblWeight NUMERIC(18, 6)
				,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strUpcCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strLongUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,ysnStockUnit BIT
				,ysnAllowPurchase BIT
				,ysnAllowSale BIT
				,dblLength NUMERIC(18, 6)
				,dblWidth NUMERIC(18, 6)
				,dblHeight NUMERIC(18, 6)
				,strDimensionUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dblVolume NUMERIC(18, 6)
				,intVolumeUOMId INT
				,strVolumeUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dblMaxQty NUMERIC(18, 6)
				,ysnStockUOM BIT
				,strSourceName NVARCHAR(200) COLLATE Latin1_General_CI_AS
				,intUpcCode BIGINT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				)
			DECLARE @tblICFinalItemUOM TABLE (
				intItemId INT NOT NULL
				,intUnitMeasureId INT NOT NULL
				,dblUnitQty NUMERIC(38, 20) NULL DEFAULT((0))
				,dblWeight NUMERIC(18, 6) NULL DEFAULT((0))
				,intWeightUOMId INT NULL
				,strUpcCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strLongUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,ysnStockUnit BIT NULL DEFAULT((0))
				,ysnAllowPurchase BIT NULL DEFAULT((0))
				,ysnAllowSale BIT NULL DEFAULT((0))
				,dblLength NUMERIC(18, 6) NULL DEFAULT((0))
				,dblWidth NUMERIC(18, 6) NULL DEFAULT((0))
				,dblHeight NUMERIC(18, 6) NULL DEFAULT((0))
				,intDimensionUOMId INT NULL
				,dblVolume NUMERIC(18, 6) NULL DEFAULT((0))
				,intVolumeUOMId INT NULL
				,dblMaxQty NUMERIC(18, 6) NULL DEFAULT((0))
				,ysnStockUOM BIT NULL
				,intSort INT NULL
				,intConcurrencyId INT NULL DEFAULT((0))
				,dtmDateCreated DATETIME NULL
				,dtmDateModified DATETIME NULL
				,intCreatedByUserId INT NULL
				,intModifiedByUserId INT NULL
				,intDataSourceId TINYINT NULL
				,intUpcCode BIGINT
				)

			INSERT INTO @tblICItemUOM (
				strUnitMeasure
				,dblUnitQty
				,dblWeight
				,strWeightUnitMeasure
				,strUpcCode
				,strLongUPCCode
				,ysnStockUnit
				,ysnAllowPurchase
				,ysnAllowSale
				,dblLength
				,dblWidth
				,dblHeight
				,strDimensionUnitMeasure
				,dblVolume
				,intVolumeUOMId
				,strVolumeUnitMeasure
				,dblMaxQty
				,ysnStockUOM
				,strSourceName
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strUnitMeasure
				,dblUnitQty
				,dblWeight
				,strWeightUnitMeasure
				,strUpcCode
				,strLongUPCCode
				,ysnStockUnit
				,ysnAllowPurchase
				,ysnAllowSale
				,dblLength
				,dblWidth
				,dblHeight
				,strDimensionUnitMeasure
				,dblVolume
				,intVolumeUOMId
				,strVolumeUnitMeasure
				,dblMaxQty
				,ysnStockUOM
				,strSourceName
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemUOMs/vyuIPGetItemUOM', 2) WITH (
					strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,dblUnitQty NUMERIC(18, 6)
					,dblWeight NUMERIC(18, 6)
					,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strUpcCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strLongUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,ysnStockUnit BIT
					,ysnAllowPurchase BIT
					,ysnAllowSale BIT
					,dblLength NUMERIC(18, 6)
					,dblWidth NUMERIC(18, 6)
					,dblHeight NUMERIC(18, 6)
					,strDimensionUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,dblVolume NUMERIC(18, 6)
					,intVolumeUOMId INT
					,strVolumeUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,dblMaxQty NUMERIC(18, 6)
					,ysnStockUOM BIT
					,strSourceName NVARCHAR(200) COLLATE Latin1_General_CI_AS
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
					)

			SELECT @intItemUOMId = min(intItemUOMId)
			FROM @tblICItemUOM

			WHILE @intItemUOMId IS NOT NULL
			BEGIN
				SELECT @strUnitMeasure = NULL
					,@strWeightUnitMeasure = NULL
					,@strVolumeUnitMeasure = NULL
					,@strDimensionUnitMeasure = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@strErrorMessage = ''

				SELECT @strUnitMeasure = strUnitMeasure
					,@strWeightUnitMeasure = strWeightUnitMeasure
					,@strVolumeUnitMeasure = strVolumeUnitMeasure
					,@strDimensionUnitMeasure = strDimensionUnitMeasure
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'UnitMeasure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'UnitMeasure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intWeightUOMId = NULL

				SELECT @intWeightUOMId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strWeightUnitMeasure

				IF @strWeightUnitMeasure IS NOT NULL
					AND @intWeightUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Weight Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Weight Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
				END

				SELECT @intVolumeUOMId = NULL

				SELECT @intVolumeUOMId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strVolumeUnitMeasure

				IF @strVolumeUnitMeasure IS NOT NULL
					AND @intVolumeUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Volume Unit Measure ' + @strVolumeUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Volume Unit Measure ' + @strVolumeUnitMeasure + ' is not available.'
					END
				END

				SELECT @intDimensionUOMId = NULL

				SELECT @intDimensionUOMId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strDimensionUOM

				IF @strDimensionUOM IS NOT NULL
					AND @intDimensionUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Dimension Unit Measure ' + @strDimensionUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Dimension Unit Measure ' + @strDimensionUnitMeasure + ' is not available.'
					END
				END

				SELECT @intDataSourceId = NULL

				SELECT @intDataSourceId = intDataSourceId
				FROM tblICDataSource
				WHERE strSourceName = @strSourceName

				IF @strSourceName IS NOT NULL
					AND @intDataSourceId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Source Name ' + @strSourceName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Source Name ' + @strSourceName + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemUOM (
					intItemId
					,intUnitMeasureId
					,dblUnitQty
					,dblWeight
					,intWeightUOMId
					,strUpcCode
					,strLongUPCCode
					,ysnStockUnit
					,ysnAllowPurchase
					,ysnAllowSale
					,dblLength
					,dblWidth
					,dblHeight
					,intDimensionUOMId
					,dblVolume
					,intVolumeUOMId
					,dblMaxQty
					,ysnStockUOM
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					,intDataSourceId
					)
				SELECT @intNewItemId
					,@intUnitMeasureId
					,dblUnitQty
					,dblWeight
					,@intWeightUOMId
					,strUpcCode
					,strLongUPCCode
					,ysnStockUnit
					,ysnAllowPurchase
					,ysnAllowSale
					,dblLength
					,dblWidth
					,dblHeight
					,@intDimensionUOMId
					,dblVolume
					,@intVolumeUOMId
					,dblMaxQty
					,ysnStockUOM
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,@intCreatedById
					,@intModifiedById
					,@intDataSourceId
				FROM @tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId

				SELECT @intItemUOMId = min(intItemUOMId)
				FROM @tblICItemUOM
				WHERE intItemUOMId > @intItemUOMId
			END

			DELETE IA
			FROM tblICItemUOM IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemUOM IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intUnitMeasureId = IA.intUnitMeasureId
					)

			UPDATE IA1
			SET dblUnitQty = IA.dblUnitQty
				,dblWeight = IA.dblWeight
				,intWeightUOMId = IA.intWeightUOMId
				,strUpcCode = IA.strUpcCode
				,strLongUPCCode = IA.strLongUPCCode
				,ysnStockUnit = IA.ysnStockUnit
				,ysnAllowPurchase = IA.ysnAllowPurchase
				,ysnAllowSale = IA.ysnAllowSale
				,dblLength = IA.dblLength
				,dblWidth = IA.dblWidth
				,dblHeight = IA.dblHeight
				,intDimensionUOMId = IA.intDimensionUOMId
				,dblVolume = IA.dblVolume
				,intVolumeUOMId = IA.intVolumeUOMId
				,dblMaxQty = IA.dblMaxQty
				,ysnStockUOM = IA.ysnStockUOM
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
				,intDataSourceId = IA.intDataSourceId
			FROM @tblICFinalItemUOM IA
			JOIN tblICItemUOM IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intUnitMeasureId = IA.intUnitMeasureId

			INSERT INTO tblICItemUOM (
				intItemId
				,intUnitMeasureId
				,dblUnitQty
				,dblWeight
				,intWeightUOMId
				,strUpcCode
				,strLongUPCCode
				,ysnStockUnit
				,ysnAllowPurchase
				,ysnAllowSale
				,dblLength
				,dblWidth
				,dblHeight
				,intDimensionUOMId
				,dblVolume
				,intVolumeUOMId
				,dblMaxQty
				,ysnStockUOM
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				,intDataSourceId
				)
			SELECT intItemId
				,intUnitMeasureId
				,dblUnitQty
				,dblWeight
				,intWeightUOMId
				,strUpcCode
				,strLongUPCCode
				,ysnStockUnit
				,ysnAllowPurchase
				,ysnAllowSale
				,dblLength
				,dblWidth
				,dblHeight
				,intDimensionUOMId
				,dblVolume
				,intVolumeUOMId
				,dblMaxQty
				,ysnStockUOM
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				,intDataSourceId
			FROM @tblICFinalItemUOM IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemUOM IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intUnitMeasureId = IA.intUnitMeasureId
					)

			DELETE
			FROM @tblICItemUOM

			DELETE
			FROM @tblICFinalItemUOM

			EXEC sp_xml_removedocument @idoc

			------------------Item UOM UPC------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemUPCXML

			DELETE
			FROM tblICItemUPC
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemUPC (
				[intItemId]
				,[intItemUnitMeasureId]
				,[dblUnitQty]
				,strUPCCode
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,IU.intItemUOMId
				,x.[dblUnitQty]
				,strUPCCode
				,x.intSort
				,x.intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemUomUpcs/vyuIPGetItemUomUpc', 2) WITH (
					strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblUnitQty NUMERIC(18, 6)
					,strUPCCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intNewItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId

			EXEC sp_xml_removedocument @idoc

			------------------Item Location------------------------------------------------------
			DECLARE @strVendorId NVARCHAR(50)
				,@strIssueUnitMeasure NVARCHAR(50)
				,@strReceiveUnitMeasure NVARCHAR(50)
				,@strCountGroup NVARCHAR(50)
				,@strShipVia NVARCHAR(100)
				,@strStorageLocation NVARCHAR(100)
				,@strSubLocationName NVARCHAR(100)
				,@intCompanyLocationSubLocationId INT
				,@intStorageLocationId INT
				,@intShipViaId INT
				,@intCountGroupId INT
				,@intReceiveUnitMeasureId INT
				,@intIssueUnitMeasureId INT
				,@intReceiveItemUOMId INT
				,@intIssueItemUOMId INT
				,@intVendorId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemLocationXML

			DECLARE @tblICItemLocation TABLE (
				intItemLocationId INT identity(1, 1)
				,strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
				,intCostingMethod INT
				,intAllowNegativeInventory INT
				,intGrossUOMId INT
				,intFamilyId INT
				,intClassId INT
				,intProductCodeId INT
				,intFuelTankId INT
				,strPassportFuelId1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strPassportFuelId2 NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strPassportFuelId3 NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,ysnTaxFlag1 BIT
				,ysnTaxFlag2 BIT
				,ysnTaxFlag3 BIT
				,ysnTaxFlag4 BIT
				,ysnPromotionalItem BIT
				,intMixMatchId INT
				,ysnDepositRequired BIT
				,intDepositPLUId INT
				,intBottleDepositNo INT
				,ysnSaleable BIT
				,ysnQuantityRequired BIT
				,ysnScaleItem BIT
				,ysnFoodStampable BIT
				,ysnReturnable BIT
				,ysnPrePriced BIT
				,ysnOpenPricePLU BIT
				,ysnLinkedItem BIT
				,strVendorCategory NVARCHAR(50)
				,ysnCountBySINo BIT
				,strSerialNoBegin NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strSerialNoEnd NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,ysnIdRequiredLiquor BIT
				,ysnIdRequiredCigarette BIT
				,intMinimumAge INT
				,ysnApplyBlueLaw1 BIT
				,ysnApplyBlueLaw2 BIT
				,ysnCarWash BIT
				,intItemTypeCode INT
				,intItemTypeSubCode INT
				,ysnAutoCalculateFreight BIT
				,intFreightMethodId INT
				,dblFreightRate NUMERIC(18, 6)
				,intShipViaId INT
				,intNegativeInventory INT
				,dblReorderPoint NUMERIC(18, 6)
				,dblMinOrder NUMERIC(18, 6)
				,dblSuggestedQty NUMERIC(18, 6)
				,dblLeadTime NUMERIC(18, 6)
				,strCounted NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,ysnCountedDaily BIT
				,intAllowZeroCostTypeId INT
				,ysnLockedInventory BIT
				,ysnStorageUnitRequired BIT
				,strStorageUnitNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,intCostAdjustmentType INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strIssueUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strReceiveUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strCountGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,strShipVia NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,strSubLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				,strSourceName NVARCHAR(200) COLLATE Latin1_General_CI_AS
				)
			DECLARE @tblICFinalItemLocation TABLE (
				intItemId INT NOT NULL
				,intLocationId INT NULL
				,intVendorId INT NULL
				,strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
				,intCostingMethod INT NULL
				,intAllowNegativeInventory INT NOT NULL DEFAULT((3))
				,intSubLocationId INT NULL
				,intStorageLocationId INT NULL
				,intIssueUOMId INT NULL
				,intReceiveUOMId INT NULL
				,intGrossUOMId INT NULL
				,intFamilyId INT NULL
				,intClassId INT NULL
				,intProductCodeId INT NULL
				,intFuelTankId INT NULL
				,strPassportFuelId1 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strPassportFuelId2 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strPassportFuelId3 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,ysnTaxFlag1 BIT NULL
				,ysnTaxFlag2 BIT NULL
				,ysnTaxFlag3 BIT NULL
				,ysnTaxFlag4 BIT NULL
				,ysnPromotionalItem BIT NULL
				,intMixMatchId INT NULL
				,ysnDepositRequired BIT NULL
				,intDepositPLUId INT NULL
				,intBottleDepositNo INT NULL
				,ysnSaleable BIT NULL
				,ysnQuantityRequired BIT NULL
				,ysnScaleItem BIT NULL
				,ysnFoodStampable BIT NULL
				,ysnReturnable BIT NULL
				,ysnPrePriced BIT NULL
				,ysnOpenPricePLU BIT NULL
				,ysnLinkedItem BIT NULL
				,strVendorCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,ysnCountBySINo BIT NULL
				,strSerialNoBegin NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strSerialNoEnd NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,ysnIdRequiredLiquor BIT NULL
				,ysnIdRequiredCigarette BIT NULL
				,intMinimumAge INT NULL
				,ysnApplyBlueLaw1 BIT NULL
				,ysnApplyBlueLaw2 BIT NULL
				,ysnCarWash BIT NULL
				,intItemTypeCode INT NULL
				,intItemTypeSubCode INT NULL
				,ysnAutoCalculateFreight BIT NULL
				,intFreightMethodId INT NULL
				,dblFreightRate NUMERIC(18, 6) NULL DEFAULT((0))
				,intShipViaId INT NULL
				,intNegativeInventory INT NULL DEFAULT((3))
				,dblReorderPoint NUMERIC(18, 6) NULL DEFAULT((0))
				,dblMinOrder NUMERIC(18, 6) NULL DEFAULT((0))
				,dblSuggestedQty NUMERIC(18, 6) NULL DEFAULT((0))
				,dblLeadTime NUMERIC(18, 6) NULL DEFAULT((0))
				,strCounted NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,intCountGroupId INT NULL
				,ysnCountedDaily BIT NULL DEFAULT((0))
				,intAllowZeroCostTypeId INT NULL
				,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
				ysnLockedInventory BIT NULL DEFAULT((0))
				,ysnStorageUnitRequired BIT NULL DEFAULT((1))
				,strStorageUnitNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				,intCostAdjustmentType TINYINT NULL
				,intSort INT NULL
				,intConcurrencyId INT NULL DEFAULT((0))
				,dtmDateCreated DATETIME NULL
				,dtmDateModified DATETIME NULL
				,intCreatedByUserId INT NULL
				,intModifiedByUserId INT NULL
				,intDataSourceId TINYINT NULL
				)

			INSERT INTO @tblICItemLocation (
				strDescription
				,intCostingMethod
				,intAllowNegativeInventory
				,intGrossUOMId
				,intFamilyId
				,intClassId
				,intProductCodeId
				,intFuelTankId
				,strPassportFuelId1
				,strPassportFuelId2
				,strPassportFuelId3
				,ysnTaxFlag1
				,ysnTaxFlag2
				,ysnTaxFlag3
				,ysnTaxFlag4
				,ysnPromotionalItem
				,intMixMatchId
				,ysnDepositRequired
				,intDepositPLUId
				,intBottleDepositNo
				,ysnSaleable
				,ysnQuantityRequired
				,ysnScaleItem
				,ysnFoodStampable
				,ysnReturnable
				,ysnPrePriced
				,ysnOpenPricePLU
				,ysnLinkedItem
				,strVendorCategory
				,ysnCountBySINo
				,strSerialNoBegin
				,strSerialNoEnd
				,ysnIdRequiredLiquor
				,ysnIdRequiredCigarette
				,intMinimumAge
				,ysnApplyBlueLaw1
				,ysnApplyBlueLaw2
				,ysnCarWash
				,intItemTypeCode
				,intItemTypeSubCode
				,ysnAutoCalculateFreight
				,intFreightMethodId
				,dblFreightRate
				,intShipViaId
				,intNegativeInventory
				,dblReorderPoint
				,dblMinOrder
				,dblSuggestedQty
				,dblLeadTime
				,strCounted
				,ysnCountedDaily
				,intAllowZeroCostTypeId
				,ysnLockedInventory
				,ysnStorageUnitRequired
				,strStorageUnitNo
				,intCostAdjustmentType
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				,strVendorId
				,strLocationName
				,strIssueUnitMeasure
				,strReceiveUnitMeasure
				,strCountGroup
				,strShipVia
				,strStorageLocation
				,strSubLocationName
				,strSourceName
				)
			SELECT strDescription
				,intCostingMethod
				,intAllowNegativeInventory
				,intGrossUOMId
				,intFamilyId
				,intClassId
				,intProductCodeId
				,intFuelTankId
				,strPassportFuelId1
				,strPassportFuelId2
				,strPassportFuelId3
				,ysnTaxFlag1
				,ysnTaxFlag2
				,ysnTaxFlag3
				,ysnTaxFlag4
				,ysnPromotionalItem
				,intMixMatchId
				,ysnDepositRequired
				,intDepositPLUId
				,intBottleDepositNo
				,ysnSaleable
				,ysnQuantityRequired
				,ysnScaleItem
				,ysnFoodStampable
				,ysnReturnable
				,ysnPrePriced
				,ysnOpenPricePLU
				,ysnLinkedItem
				,strVendorCategory
				,ysnCountBySINo
				,strSerialNoBegin
				,strSerialNoEnd
				,ysnIdRequiredLiquor
				,ysnIdRequiredCigarette
				,intMinimumAge
				,ysnApplyBlueLaw1
				,ysnApplyBlueLaw2
				,ysnCarWash
				,intItemTypeCode
				,intItemTypeSubCode
				,ysnAutoCalculateFreight
				,intFreightMethodId
				,dblFreightRate
				,intShipViaId
				,intNegativeInventory
				,dblReorderPoint
				,dblMinOrder
				,dblSuggestedQty
				,dblLeadTime
				,strCounted
				,ysnCountedDaily
				,intAllowZeroCostTypeId
				,ysnLockedInventory
				,ysnStorageUnitRequired
				,strStorageUnitNo
				,intCostAdjustmentType
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				,strVendorId
				,strLocationName
				,strIssueUnitMeasure
				,strReceiveUnitMeasure
				,strCountGroup
				,strShipVia
				,strStorageLocation
				,strSubLocationName
				,strSourceName
			FROM OPENXML(@idoc, 'vyuIPGetItemLocations/vyuIPGetItemLocation', 2) WITH (
					strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
					,intCostingMethod INT
					,intAllowNegativeInventory INT
					,intGrossUOMId INT
					,intFamilyId INT
					,intClassId INT
					,intProductCodeId INT
					,intFuelTankId INT
					,strPassportFuelId1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strPassportFuelId2 NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strPassportFuelId3 NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,ysnTaxFlag1 BIT
					,ysnTaxFlag2 BIT
					,ysnTaxFlag3 BIT
					,ysnTaxFlag4 BIT
					,ysnPromotionalItem BIT
					,intMixMatchId INT
					,ysnDepositRequired BIT
					,intDepositPLUId INT
					,intBottleDepositNo INT
					,ysnSaleable BIT
					,ysnQuantityRequired BIT
					,ysnScaleItem BIT
					,ysnFoodStampable BIT
					,ysnReturnable BIT
					,ysnPrePriced BIT
					,ysnOpenPricePLU BIT
					,ysnLinkedItem BIT
					,strVendorCategory NVARCHAR(50)
					,ysnCountBySINo BIT
					,strSerialNoBegin NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strSerialNoEnd NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,ysnIdRequiredLiquor BIT
					,ysnIdRequiredCigarette BIT
					,intMinimumAge INT
					,ysnApplyBlueLaw1 BIT
					,ysnApplyBlueLaw2 BIT
					,ysnCarWash BIT
					,intItemTypeCode INT
					,intItemTypeSubCode INT
					,ysnAutoCalculateFreight BIT
					,intFreightMethodId INT
					,dblFreightRate NUMERIC(18, 6)
					,intShipViaId INT
					,intNegativeInventory INT
					,dblReorderPoint NUMERIC(18, 6)
					,dblMinOrder NUMERIC(18, 6)
					,dblSuggestedQty NUMERIC(18, 6)
					,dblLeadTime NUMERIC(18, 6)
					,strCounted NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,ysnCountedDaily BIT
					,intAllowZeroCostTypeId INT
					,ysnLockedInventory BIT
					,ysnStorageUnitRequired BIT
					,strStorageUnitNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,intCostAdjustmentType INT
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strIssueUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strReceiveUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCountGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strShipVia NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strSubLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strSourceName NVARCHAR(200) COLLATE Latin1_General_CI_AS
					)

			SELECT @intItemLocationId = min(intItemLocationId)
			FROM @tblICItemLocation

			WHILE @intItemLocationId IS NOT NULL
			BEGIN
				SELECT @strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@strVendorId = NULL
					,@strLocationName = NULL
					,@strIssueUnitMeasure = NULL
					,@strReceiveUnitMeasure = NULL
					,@strCountGroup = NULL
					,@strShipVia = NULL
					,@strStorageLocation = NULL
					,@strSubLocationName = NULL
					,@strSourceName = NULL
					,@strErrorMessage = ''

				SELECT @strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@strVendorId = strVendorId
					,@strLocationName = strLocationName
					,@strIssueUnitMeasure = strIssueUnitMeasure
					,@strReceiveUnitMeasure = strReceiveUnitMeasure
					,@strCountGroup = strCountGroup
					,@strShipVia = strShipVia
					,@strStorageLocation = strStorageLocation
					,@strSubLocationName = strSubLocationName
					,@strSourceName = strSourceName
				FROM @tblICItemLocation
				WHERE intItemLocationId = @intItemLocationId

				SELECT @intDataSourceId = NULL

				SELECT @intDataSourceId = intDataSourceId
				FROM tblICDataSource
				WHERE strSourceName = @strSourceName

				IF @strSourceName IS NOT NULL
					AND @intDataSourceId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Source Name ' + @strSourceName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Source Name ' + @strSourceName + ' is not available.'
					END
				END

				SELECT @intCompanyLocationSubLocationId = NULL

				SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strSubLocationName

				IF @strSubLocationName IS NOT NULL
					AND @intCompanyLocationSubLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Sub Location ' + @strSubLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Sub Location ' + @strSubLocationName + ' is not available.'
					END
				END

				SELECT @intStorageLocationId = NULL

				SELECT @intStorageLocationId = intStorageLocationId
				FROM tblICStorageLocation
				WHERE strName = @strStorageLocation

				IF @strStorageLocation IS NOT NULL
					AND @intStorageLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Storage Location ' + @strShipVia + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Storage Location ' + @strShipVia + ' is not available.'
					END
				END

				SELECT @intShipViaId = NULL

				SELECT @intShipViaId = intEntityId
				FROM tblSMShipVia
				WHERE strShipVia = @strShipVia

				IF @strShipVia IS NOT NULL
					AND @intShipViaId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Ship Via ' + @strShipVia + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Ship Via ' + @strShipVia + ' is not available.'
					END
				END

				SELECT @intCountGroupId = NULL

				SELECT @intCountGroupId = intCountGroupId
				FROM tblICCountGroup
				WHERE strCountGroup = @strCountGroup

				IF @strCountGroup IS NOT NULL
					AND @intCountGroupId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Count Group ' + @strCountGroup + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Count Group ' + @strCountGroup + ' is not available.'
					END
				END

				SELECT @intReceiveUnitMeasureId = NULL

				SELECT @intReceiveUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strReceiveUnitMeasure

				IF @strReceiveUnitMeasure IS NOT NULL
					AND @intReceiveUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strReceiveUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strReceiveUnitMeasure + ' is not available.'
					END
				END

				SELECT @intReceiveItemUOMId = NULL

				SELECT @intReceiveItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intNewItemId
					AND intUnitMeasureId = @intReceiveUnitMeasureId

				IF @strReceiveUnitMeasure IS NOT NULL
					AND @intReceiveItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strReceiveUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strReceiveUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intIssueUnitMeasureId = NULL

				SELECT @intIssueUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strIssueUnitMeasure

				IF @strIssueUnitMeasure IS NOT NULL
					AND @intIssueUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strIssueUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strIssueUnitMeasure + ' is not available.'
					END
				END

				SELECT @intIssueItemUOMId = NULL

				SELECT @intIssueItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intNewItemId
					AND intUnitMeasureId = @intIssueUnitMeasureId

				IF @strIssueUnitMeasure IS NOT NULL
					AND @intIssueItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strIssueUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strIssueUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intVendorId = NULL

				SELECT @intVendorId = intEntityId
				FROM tblAPVendor
				WHERE strVendorId = @strVendorId

				IF @strVendorId IS NOT NULL
					AND @intVendorId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Vendor ' + @strVendorId + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Vendor ' + @strVendorId + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemLocation (
					intItemId
					,intLocationId
					,intVendorId
					,strDescription
					,intCostingMethod
					,intAllowNegativeInventory
					,intSubLocationId
					,intStorageLocationId
					,intIssueUOMId
					,intReceiveUOMId
					,intGrossUOMId
					,intFamilyId
					,intClassId
					,intProductCodeId
					,intFuelTankId
					,strPassportFuelId1
					,strPassportFuelId2
					,strPassportFuelId3
					,ysnTaxFlag1
					,ysnTaxFlag2
					,ysnTaxFlag3
					,ysnTaxFlag4
					,ysnPromotionalItem
					,intMixMatchId
					,ysnDepositRequired
					,intDepositPLUId
					,intBottleDepositNo
					,ysnSaleable
					,ysnQuantityRequired
					,ysnScaleItem
					,ysnFoodStampable
					,ysnReturnable
					,ysnPrePriced
					,ysnOpenPricePLU
					,ysnLinkedItem
					,strVendorCategory
					,ysnCountBySINo
					,strSerialNoBegin
					,strSerialNoEnd
					,ysnIdRequiredLiquor
					,ysnIdRequiredCigarette
					,intMinimumAge
					,ysnApplyBlueLaw1
					,ysnApplyBlueLaw2
					,ysnCarWash
					,intItemTypeCode
					,intItemTypeSubCode
					,ysnAutoCalculateFreight
					,intFreightMethodId
					,dblFreightRate
					,intShipViaId
					,intNegativeInventory
					,dblReorderPoint
					,dblMinOrder
					,dblSuggestedQty
					,dblLeadTime
					,strCounted
					,intCountGroupId
					,ysnCountedDaily
					,intAllowZeroCostTypeId
					,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
					ysnLockedInventory
					,ysnStorageUnitRequired
					,strStorageUnitNo
					,intCostAdjustmentType
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					,intDataSourceId
					)
				SELECT @intNewItemId
					,@intLocationId
					,@intVendorId
					,strDescription
					,intCostingMethod
					,intAllowNegativeInventory
					,@intCompanyLocationSubLocationId
					,@intStorageLocationId
					,@intIssueItemUOMId
					,@intReceiveItemUOMId
					,intGrossUOMId
					,intFamilyId
					,intClassId
					,intProductCodeId
					,intFuelTankId
					,strPassportFuelId1
					,strPassportFuelId2
					,strPassportFuelId3
					,ysnTaxFlag1
					,ysnTaxFlag2
					,ysnTaxFlag3
					,ysnTaxFlag4
					,ysnPromotionalItem
					,intMixMatchId
					,ysnDepositRequired
					,intDepositPLUId
					,intBottleDepositNo
					,ysnSaleable
					,ysnQuantityRequired
					,ysnScaleItem
					,ysnFoodStampable
					,ysnReturnable
					,ysnPrePriced
					,ysnOpenPricePLU
					,ysnLinkedItem
					,strVendorCategory
					,ysnCountBySINo
					,strSerialNoBegin
					,strSerialNoEnd
					,ysnIdRequiredLiquor
					,ysnIdRequiredCigarette
					,intMinimumAge
					,ysnApplyBlueLaw1
					,ysnApplyBlueLaw2
					,ysnCarWash
					,intItemTypeCode
					,intItemTypeSubCode
					,ysnAutoCalculateFreight
					,intFreightMethodId
					,dblFreightRate
					,@intShipViaId
					,intNegativeInventory
					,dblReorderPoint
					,dblMinOrder
					,dblSuggestedQty
					,dblLeadTime
					,strCounted
					,@intCountGroupId
					,ysnCountedDaily
					,intAllowZeroCostTypeId
					,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
					ysnLockedInventory
					,ysnStorageUnitRequired
					,strStorageUnitNo
					,intCostAdjustmentType
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,@intCreatedById
					,@intModifiedById
					,@intDataSourceId
				FROM @tblICItemLocation
				WHERE intItemLocationId = @intItemLocationId

				SELECT @intItemLocationId = min(intItemLocationId)
				FROM @tblICItemLocation
				WHERE intItemLocationId > @intItemLocationId
			END

			DELETE IA
			FROM tblICItemLocation IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemLocation IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intLocationId = IA.intLocationId
					) and IA.intLocationId is not null

			UPDATE IA1
			SET intVendorId = @intVendorId
				,strDescription = IA.strDescription
				,intCostingMethod = IA.intCostingMethod
				,intAllowNegativeInventory = IA.intAllowNegativeInventory
				,intSubLocationId = @intCompanyLocationSubLocationId
				,intStorageLocationId = @intStorageLocationId
				,intIssueUOMId = @intIssueItemUOMId
				,intReceiveUOMId = @intReceiveItemUOMId
				,intGrossUOMId = IA.intGrossUOMId
				,intFamilyId = IA.intFamilyId
				,intClassId = IA.intClassId
				,intProductCodeId = IA.intProductCodeId
				,intFuelTankId = IA.intFuelTankId
				,strPassportFuelId1 = IA.strPassportFuelId1
				,strPassportFuelId2 = IA.strPassportFuelId2
				,strPassportFuelId3 = IA.strPassportFuelId3
				,ysnTaxFlag1 = IA.ysnTaxFlag1
				,ysnTaxFlag2 = IA.ysnTaxFlag2
				,ysnTaxFlag3 = IA.ysnTaxFlag3
				,ysnTaxFlag4 = IA.ysnTaxFlag4
				,ysnPromotionalItem = IA.ysnPromotionalItem
				,intMixMatchId = IA.intMixMatchId
				,ysnDepositRequired = IA.ysnDepositRequired
				,intDepositPLUId = IA.intDepositPLUId
				,intBottleDepositNo = IA.intBottleDepositNo
				,ysnSaleable = IA.ysnSaleable
				,ysnQuantityRequired = IA.ysnQuantityRequired
				,ysnScaleItem = IA.ysnScaleItem
				,ysnFoodStampable = IA.ysnFoodStampable
				,ysnReturnable = IA.ysnReturnable
				,ysnPrePriced = IA.ysnPrePriced
				,ysnOpenPricePLU = IA.ysnOpenPricePLU
				,ysnLinkedItem = IA.ysnLinkedItem
				,strVendorCategory = IA.strVendorCategory
				,ysnCountBySINo = IA.ysnCountBySINo
				,strSerialNoBegin = IA.strSerialNoBegin
				,strSerialNoEnd = IA.strSerialNoEnd
				,ysnIdRequiredLiquor = IA.ysnIdRequiredLiquor
				,ysnIdRequiredCigarette = IA.ysnIdRequiredCigarette
				,intMinimumAge = IA.intMinimumAge
				,ysnApplyBlueLaw1 = IA.ysnApplyBlueLaw1
				,ysnApplyBlueLaw2 = IA.ysnApplyBlueLaw2
				,ysnCarWash = IA.ysnCarWash
				,intItemTypeCode = IA.intItemTypeCode
				,intItemTypeSubCode = IA.intItemTypeSubCode
				,ysnAutoCalculateFreight = IA.ysnAutoCalculateFreight
				,intFreightMethodId = IA.intFreightMethodId
				,dblFreightRate = IA.dblFreightRate
				,intShipViaId = @intShipViaId
				,intNegativeInventory = IA.intNegativeInventory
				,dblReorderPoint = IA.dblReorderPoint
				--,dblMinOrder = IA.dblMinOrder
				,dblSuggestedQty = IA.dblSuggestedQty
				--,dblLeadTime = IA.dblLeadTime
				,strCounted = IA.strCounted
				,intCountGroupId = @intCountGroupId
				,ysnCountedDaily = IA.ysnCountedDaily
				,intAllowZeroCostTypeId = IA.intAllowZeroCostTypeId
				,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
				ysnLockedInventory = IA.ysnLockedInventory
				,ysnStorageUnitRequired = IA.ysnStorageUnitRequired
				,strStorageUnitNo = IA.strStorageUnitNo
				,intCostAdjustmentType = IA.intCostAdjustmentType
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = @intCreatedById
				,intModifiedByUserId = @intModifiedById
				,intDataSourceId = @intDataSourceId
			FROM @tblICFinalItemLocation IA
			JOIN tblICItemLocation IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intLocationId = IA.intLocationId

			INSERT INTO tblICItemLocation (
				intItemId
				,intLocationId
				,intVendorId
				,strDescription
				,intCostingMethod
				,intAllowNegativeInventory
				,intSubLocationId
				,intStorageLocationId
				,intIssueUOMId
				,intReceiveUOMId
				,intGrossUOMId
				,intFamilyId
				,intClassId
				,intProductCodeId
				,intFuelTankId
				,strPassportFuelId1
				,strPassportFuelId2
				,strPassportFuelId3
				,ysnTaxFlag1
				,ysnTaxFlag2
				,ysnTaxFlag3
				,ysnTaxFlag4
				,ysnPromotionalItem
				,intMixMatchId
				,ysnDepositRequired
				,intDepositPLUId
				,intBottleDepositNo
				,ysnSaleable
				,ysnQuantityRequired
				,ysnScaleItem
				,ysnFoodStampable
				,ysnReturnable
				,ysnPrePriced
				,ysnOpenPricePLU
				,ysnLinkedItem
				,strVendorCategory
				,ysnCountBySINo
				,strSerialNoBegin
				,strSerialNoEnd
				,ysnIdRequiredLiquor
				,ysnIdRequiredCigarette
				,intMinimumAge
				,ysnApplyBlueLaw1
				,ysnApplyBlueLaw2
				,ysnCarWash
				,intItemTypeCode
				,intItemTypeSubCode
				,ysnAutoCalculateFreight
				,intFreightMethodId
				,dblFreightRate
				,intShipViaId
				,intNegativeInventory
				,dblReorderPoint
				,dblMinOrder
				,dblSuggestedQty
				,dblLeadTime
				,strCounted
				,intCountGroupId
				,ysnCountedDaily
				,intAllowZeroCostTypeId
				,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
				ysnLockedInventory
				,ysnStorageUnitRequired
				,strStorageUnitNo
				,intCostAdjustmentType
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				,intDataSourceId
				)
			SELECT intItemId
				,intLocationId
				,intVendorId
				,strDescription
				,intCostingMethod
				,intAllowNegativeInventory
				,intSubLocationId
				,intStorageLocationId
				,intIssueUOMId
				,intReceiveUOMId
				,intGrossUOMId
				,intFamilyId
				,intClassId
				,intProductCodeId
				,intFuelTankId
				,strPassportFuelId1
				,strPassportFuelId2
				,strPassportFuelId3
				,ysnTaxFlag1
				,ysnTaxFlag2
				,ysnTaxFlag3
				,ysnTaxFlag4
				,ysnPromotionalItem
				,intMixMatchId
				,ysnDepositRequired
				,intDepositPLUId
				,intBottleDepositNo
				,ysnSaleable
				,ysnQuantityRequired
				,ysnScaleItem
				,ysnFoodStampable
				,ysnReturnable
				,ysnPrePriced
				,ysnOpenPricePLU
				,ysnLinkedItem
				,strVendorCategory
				,ysnCountBySINo
				,strSerialNoBegin
				,strSerialNoEnd
				,ysnIdRequiredLiquor
				,ysnIdRequiredCigarette
				,intMinimumAge
				,ysnApplyBlueLaw1
				,ysnApplyBlueLaw2
				,ysnCarWash
				,intItemTypeCode
				,intItemTypeSubCode
				,ysnAutoCalculateFreight
				,intFreightMethodId
				,dblFreightRate
				,intShipViaId
				,intNegativeInventory
				,dblReorderPoint
				,dblMinOrder
				,dblSuggestedQty
				,dblLeadTime
				,strCounted
				,intCountGroupId
				,ysnCountedDaily
				,intAllowZeroCostTypeId
				,-- 1 OR NULL = No, 2 = Yes, 3 = Yes but warn user
				ysnLockedInventory
				,ysnStorageUnitRequired
				,strStorageUnitNo
				,intCostAdjustmentType
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				,intDataSourceId
			FROM @tblICFinalItemLocation IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemLocation IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intLocationId = IA.intLocationId
					)

			DELETE
			FROM @tblICFinalItemLocation

			DELETE
			FROM @tblICItemLocation

			EXEC sp_xml_removedocument @idoc

			------------------Item Commodity cost------------------------------------------------------
			DECLARE @intItemCommodityCostId INT
				,@intCommodityCostId INT
				,@dblLastCost NUMERIC(38, 20)
				,@dblStandardCost NUMERIC(38, 20)
				,@dblAverageCost NUMERIC(38, 20)
				,@dblEOMCost NUMERIC(38, 20)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemCommodityCostXML

			DECLARE @tblICItemCommodityCost TABLE (
				intItemCommodityCostId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblLastCost NUMERIC(38, 20)
				,dblStandardCost NUMERIC(38, 20)
				,dblAverageCost NUMERIC(38, 20)
				,dblEOMCost NUMERIC(38, 20)
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemCommodityCost TABLE (
				intItemId INT
				,intItemLocationId INT
				,dblLastCost NUMERIC(38, 20)
				,dblStandardCost NUMERIC(38, 20)
				,dblAverageCost NUMERIC(38, 20)
				,dblEOMCost NUMERIC(38, 20)
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemCommodityCost (
				strLocationName
				,dblLastCost
				,dblStandardCost
				,dblAverageCost
				,dblEOMCost
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,dblLastCost
				,dblStandardCost
				,dblAverageCost
				,dblEOMCost
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemCommodityCosts/vyuIPGetItemCommodityCost', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblLastCost NUMERIC(38, 20)
					,dblStandardCost NUMERIC(38, 20)
					,dblAverageCost NUMERIC(38, 20)
					,dblEOMCost NUMERIC(38, 20)
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemCommodityCostId = min(intItemCommodityCostId)
			FROM @tblICItemCommodityCost

			WHILE @intItemCommodityCostId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strLocationName = strLocationName
					,@dblLastCost = dblLastCost
					,@dblStandardCost = dblStandardCost
					,@dblAverageCost = dblAverageCost
					,@dblEOMCost = dblEOMCost
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemCommodityCost
				WHERE intItemCommodityCostId = @intItemCommodityCostId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemCommodityCost (
					intItemId
					,intItemLocationId
					,dblLastCost
					,dblStandardCost
					,dblAverageCost
					,dblEOMCost
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemLocationId
					,@dblLastCost
					,@dblStandardCost
					,@dblAverageCost
					,@dblEOMCost
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemCommodityCostId = min(intItemCommodityCostId)
				FROM @tblICItemCommodityCost
				WHERE intItemCommodityCostId > @intItemCommodityCostId
			END

			DELETE IA
			FROM tblICItemCommodityCost IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemCommodityCost IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			UPDATE IA1
			SET dblLastCost = IA.dblLastCost
				,dblStandardCost = IA.dblStandardCost
				,dblAverageCost = IA.dblAverageCost
				,dblEOMCost = IA.dblEOMCost
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemCommodityCost IA
			JOIN tblICItemCommodityCost IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intItemLocationId = IA.intItemLocationId

			INSERT INTO tblICItemCommodityCost (
				intItemId
				,intItemLocationId
				,dblLastCost
				,dblStandardCost
				,dblAverageCost
				,dblEOMCost
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intItemLocationId
				,dblLastCost
				,dblStandardCost
				,dblAverageCost
				,dblEOMCost
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemCommodityCost IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemCommodityCost IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			DELETE
			FROM @tblICItemCommodityCost

			DELETE
			FROM @tblICFinalItemCommodityCost

			EXEC sp_xml_removedocument @idoc

			------------------Item Contract------------------------------------------------------
			DECLARE @intItemContractId INT
				--,@strLocationName NVARCHAR(50)
				,@intContractId INT
				,@strContractItemNo NVARCHAR(50)
				,@strContractItemName NVARCHAR(100)
				,@strCountry NVARCHAR(100)
				,@strGrade NVARCHAR(50)
				,@strGradeType NVARCHAR(50)
				,@strGarden NVARCHAR(50)
				,@dblYieldPercent NUMERIC(38, 20)
				,@dblTolerancePercent NUMERIC(38, 20)
				,@dblFranchisePercent NUMERIC(38, 20)
				,@strStatus NVARCHAR(50)
				,@intCountryId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemContractXML

			DECLARE @tblICItemContract TABLE (
				intItemContractId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strContractItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
				,strContractItemName NVARCHAR(100) Collate Latin1_General_CI_AS
				,strCountry NVARCHAR(100) Collate Latin1_General_CI_AS
				,strGrade NVARCHAR(50) Collate Latin1_General_CI_AS
				,strGradeType NVARCHAR(50) Collate Latin1_General_CI_AS
				,strGarden NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblYieldPercent NUMERIC(38, 20)
				,dblTolerancePercent NUMERIC(38, 20)
				,dblFranchisePercent NUMERIC(38, 20)
				,strStatus NVARCHAR(50) Collate Latin1_General_CI_AS
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemContract TABLE (
				intItemId INT
				,intItemLocationId INT
				,strContractItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
				,strContractItemName NVARCHAR(100) Collate Latin1_General_CI_AS
				,intCountryId INT
				,strGrade NVARCHAR(50) Collate Latin1_General_CI_AS
				,strGradeType NVARCHAR(50) Collate Latin1_General_CI_AS
				,strGarden NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblYieldPercent NUMERIC(38, 20)
				,dblTolerancePercent NUMERIC(38, 20)
				,dblFranchisePercent NUMERIC(38, 20)
				,strStatus NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemContract (
				strLocationName
				,strContractItemNo
				,strContractItemName
				,strCountry
				,strGrade
				,strGradeType
				,strGarden
				,dblYieldPercent
				,dblTolerancePercent
				,dblFranchisePercent
				,strStatus
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,strContractItemNo
				,strContractItemName
				,strCountry
				,strGrade
				,strGradeType
				,strGarden
				,dblYieldPercent
				,dblTolerancePercent
				,dblFranchisePercent
				,strStatus
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemContracts/vyuIPGetItemContract', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strContractItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strContractItemName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strCountry NVARCHAR(100) Collate Latin1_General_CI_AS
					,strGrade NVARCHAR(50) Collate Latin1_General_CI_AS
					,strGradeType NVARCHAR(50) Collate Latin1_General_CI_AS
					,strGarden NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblYieldPercent NUMERIC(38, 20)
					,dblTolerancePercent NUMERIC(38, 20)
					,dblFranchisePercent NUMERIC(38, 20)
					,strStatus NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemContractId = min(intItemContractId)
			FROM @tblICItemContract

			WHILE @intItemContractId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strErrorMessage = ''

				SELECT @strLocationName = strLocationName
					,@strContractItemNo = strContractItemNo
					,@strContractItemName = strContractItemName
					,@strCountry = strCountry
					,@strGrade = strGrade
					,@strGradeType = strGradeType
					,@strGarden = strGarden
					,@dblYieldPercent = dblYieldPercent
					,@dblTolerancePercent = dblTolerancePercent
					,@dblFranchisePercent = dblFranchisePercent
					,@strStatus = strStatus
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemContract
				WHERE intItemContractId = @intItemContractId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intCountryId = NULL

				SELECT @intCountryId = intCountryID
				FROM tblSMCountry
				WHERE strCountry = @strCountry

				IF @strCountry IS NOT NULL
					AND @intCountryId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Country ' + @strCountry + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Country ' + @strCountry + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemContract (
					intItemId
					,intItemLocationId
					,strContractItemNo
					,strContractItemName
					,intCountryId
					,strGrade
					,strGradeType
					,strGarden
					,dblYieldPercent
					,dblTolerancePercent
					,dblFranchisePercent
					,strStatus
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemLocationId
					,@strContractItemNo
					,@strContractItemName
					,@intCountryId
					,@strGrade
					,@strGradeType
					,@strGarden
					,@dblYieldPercent
					,@dblTolerancePercent
					,@dblFranchisePercent
					,@strStatus
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemContractId = min(intItemContractId)
				FROM @tblICItemContract
				WHERE intItemContractId > @intItemContractId
			END

			DELETE IA
			FROM tblICItemContract IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemContract IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
						AND IA1.strContractItemNo = IA.strContractItemNo
					)

			UPDATE IA1
			SET strContractItemName = IA.strContractItemName
				,intCountryId = IA.intCountryId
				,strGrade = IA.strGrade
				,strGradeType = IA.strGradeType
				,strGarden = IA.strGarden
				,dblYieldPercent = IA.dblYieldPercent
				,dblTolerancePercent = IA.dblTolerancePercent
				,dblFranchisePercent = IA.dblFranchisePercent
				,strStatus = IA.strStatus
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemContract IA
			JOIN tblICItemContract IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intItemLocationId = IA.intItemLocationId
				AND IA1.strContractItemNo = IA.strContractItemNo

			INSERT INTO tblICItemContract (
				intItemId
				,intItemLocationId
				,strContractItemNo
				,strContractItemName
				,intCountryId
				,strGrade
				,strGradeType
				,strGarden
				,dblYieldPercent
				,dblTolerancePercent
				,dblFranchisePercent
				,strStatus
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intItemLocationId
				,strContractItemNo
				,strContractItemName
				,intCountryId
				,strGrade
				,strGradeType
				,strGarden
				,dblYieldPercent
				,dblTolerancePercent
				,dblFranchisePercent
				,strStatus
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemContract IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemContract IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
						AND IA1.strContractItemNo = IA.strContractItemNo
					)

			DELETE
			FROM @tblICFinalItemContract

			DELETE
			FROM @tblICFinalItemContract

			EXEC sp_xml_removedocument @idoc

			------------------Item Contract Document------------------------------------------------------
			DECLARE @intItemContractDocumentId INT
				,@intDocumentId INT
				,@strDocument NVARCHAR(50)
				,@strDocumentName NVARCHAR(50)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemContractDocumentXML

			DECLARE @tblICItemContractDocument TABLE (
				intItemContractDocumentId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strContractItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
				,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemContractDocument TABLE (
				intItemId INT
				,intItemContractId INT
				,intDocumentId INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemContractDocument (
				strLocationName
				,strContractItemNo
				,strDocumentName
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,strContractItemNo
				,strDocumentName
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemContractDocuments/vyuIPGetItemContractDocument', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strContractItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemContractDocumentId = min(intItemContractDocumentId)
			FROM @tblICItemContractDocument

			WHILE @intItemContractDocumentId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strContractItemNo = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL
					,@strDocumentName = NULL
					,@strErrorMessage = ''

				SELECT @strLocationName = strLocationName
					,@strContractItemNo = strContractItemNo
					,@strDocumentName = strDocumentName
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemContractDocument
				WHERE intItemContractDocumentId = @intItemContractDocumentId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intDocumentId = NULL

				SELECT @intDocumentId = intDocumentId
				FROM tblICDocument
				WHERE strDocumentName = @strDocumentName

				IF @strDocument IS NOT NULL
					AND @intDocumentId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Document ' + @strDocument + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Document ' + @strDocument + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intItemContractId = NULL

				SELECT @intItemContractId = intItemContractId
				FROM tblICItemContract
				WHERE intItemId = @intNewItemId
					AND intItemLocationId = @intItemLocationId
					AND strContractItemNo = @strContractItemNo

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemContractDocument (
					intItemId
					,intItemContractId
					,intDocumentId
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemContractId
					,@intDocumentId
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemContractDocumentId = min(intItemContractDocumentId)
				FROM @tblICItemContractDocument
				WHERE intItemContractDocumentId > @intItemContractDocumentId
			END

			DELETE IA
			FROM tblICItemContractDocument IA
			JOIN tblICItemContract IC ON IC.intItemContractId = IA.intItemContractId
			WHERE IC.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemContractDocument IA1
					WHERE IA1.intItemId = IC.intItemId
						AND IA1.intItemContractId = IC.intItemContractId
						AND IA1.intDocumentId = IA.intDocumentId
					)

			UPDATE IA1
			SET intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemContractDocument IA
			JOIN tblICItemContract IC ON IC.intItemContractId = IA.intItemContractId
			JOIN tblICItemContractDocument IA1 ON IC.intItemId = IA.intItemId
				AND IA1.intItemContractId = IA.intItemContractId
				AND IA1.intDocumentId = IA.intDocumentId

			INSERT INTO tblICItemContractDocument (
				intItemContractId
				,intDocumentId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT IA.intItemContractId
				,IA.intDocumentId
				,IA.intSort
				,IA.intConcurrencyId
				,IA.dtmDateCreated
				,IA.dtmDateModified
				,IA.intCreatedByUserId
				,IA.intModifiedByUserId
			FROM @tblICFinalItemContractDocument IA
			JOIN tblICItemContract IC ON IC.intItemContractId = IA.intItemContractId
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemContractDocument IA1
					JOIN tblICItemContract IC1 ON IC1.intItemContractId = IA1.intItemContractId
					WHERE IC1.intItemId = @intNewItemId
						AND IA1.intItemContractId = IA.intItemContractId
						AND IA1.intDocumentId = IA.intDocumentId
					)

			DELETE
			FROM @tblICItemContractDocument

			DELETE
			FROM @tblICFinalItemContractDocument

			EXEC sp_xml_removedocument @idoc

			------------------Item Customer X ref------------------------------------------------------
			DECLARE @intItemCustomerXrefId INT
				,@strCustomerName NVARCHAR(100)
				,@intEntityId INT
				,@strProductDescription NVARCHAR(MAX)
				,@strPickTicketNotes NVARCHAR(MAX)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemCustomerXrefXML

			DECLARE @tblICItemCustomerXref TABLE (
				intItemCustomerXrefId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strCustomerName NVARCHAR(100) Collate Latin1_General_CI_AS
				,strCustomerProduct NVARCHAR(100) Collate Latin1_General_CI_AS
				,strProductDescription NVARCHAR(MAX) Collate Latin1_General_CI_AS
				,strPickTicketNotes NVARCHAR(MAX) Collate Latin1_General_CI_AS
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemCustomerXref TABLE (
				intItemId INT
				,intItemLocationId INT
				,intCustomerId INT
				,strCustomerProduct NVARCHAR(50)
				,strProductDescription NVARCHAR(Max)
				,strPickTicketNotes NVARCHAR(max)
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemCustomerXref (
				strLocationName
				,strCustomerName
				,strCustomerProduct
				,strProductDescription
				,strPickTicketNotes
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,strCustomerName
				,strCustomerProduct
				,strProductDescription
				,strPickTicketNotes
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemCustomerXrefs/vyuIPGetItemCustomerXref', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCustomerName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strCustomerProduct NVARCHAR(100) Collate Latin1_General_CI_AS
					,strProductDescription NVARCHAR(MAX) Collate Latin1_General_CI_AS
					,strPickTicketNotes NVARCHAR(MAX) Collate Latin1_General_CI_AS
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemCustomerXrefId = min(intItemCustomerXrefId)
			FROM @tblICItemCustomerXref

			WHILE @intItemCustomerXrefId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strCustomerName = NULL
					,@strCustomerProduct = NULL
					,@strProductDescription = NULL
					,@strPickTicketNotes = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strLocationName = strLocationName
					,@strCustomerName = strCustomerName
					,@strCustomerProduct = strCustomerProduct
					,@strProductDescription = strProductDescription
					,@strPickTicketNotes = strPickTicketNotes
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemCustomerXref
				WHERE intItemCustomerXrefId = @intItemCustomerXrefId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intEntityId = NULL

				SELECT @intEntityId = E.intEntityId
				FROM tblEMEntity E
				JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId
					AND ET.strType = 'Customer'
				WHERE strName = @strCustomer

				IF @strCustomer IS NOT NULL
					AND @intEntityId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Customer ' + @strCustomer + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Customer ' + @strCustomer + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemCustomerXref (
					intItemId
					,intItemLocationId
					,intCustomerId
					,strCustomerProduct
					,strProductDescription
					,strPickTicketNotes
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemLocationId
					,@intCustomerId
					,@strCustomerProduct
					,@strProductDescription
					,@strPickTicketNotes
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemCustomerXrefId = min(intItemCustomerXrefId)
				FROM @tblICItemCustomerXref
				WHERE intItemCustomerXrefId > @intItemCustomerXrefId
			END

			DELETE IA
			FROM tblICItemCustomerXref IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemCustomerXref IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
						AND IA1.intCustomerId = IA.intCustomerId
					)

			UPDATE IA1
			SET intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemCustomerXref IA
			JOIN tblICItemCustomerXref IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intItemLocationId = IA.intItemLocationId
				AND IA1.intCustomerId = IA.intCustomerId

			INSERT INTO tblICItemCustomerXref (
				intItemId
				,intItemLocationId
				,intCustomerId
				,strCustomerProduct
				,strProductDescription
				,strPickTicketNotes
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intItemLocationId
				,intCustomerId
				,strCustomerProduct
				,strProductDescription
				,strPickTicketNotes
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemCustomerXref IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemCustomerXref IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
						AND IA1.intCustomerId = IA.intCustomerId
					)

			DELETE
			FROM @tblICItemCustomerXref

			DELETE
			FROM @tblICFinalItemCustomerXref

			EXEC sp_xml_removedocument @idoc

			------------------Item Factory------------------------------------------------------
			DECLARE @intItemFactoryId INT
				,@ysnDefault BIT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemFactoryXML

			DECLARE @tblICItemFactory TABLE (
				intItemFactoryId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,ysnDefault BIT
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemFactory TABLE (
				intItemId INT
				,intFactoryId INT
				,ysnDefault BIT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemFactory (
				strLocationName
				,ysnDefault
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,ysnDefault
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemFactorys/vyuIPGetItemFactory', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnDefault BIT
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemFactoryId = min(intItemFactoryId)
			FROM @tblICItemFactory

			WHILE @intItemFactoryId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@ysnDefault = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strLocationName = strLocationName
					,@ysnDefault = ysnDefault
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemFactory
				WHERE intItemFactoryId = @intItemFactoryId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemFactory (
					intItemId
					,intFactoryId
					,ysnDefault
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intLocationId
					,@ysnDefault
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemFactoryId = min(intItemFactoryId)
				FROM @tblICItemFactory
				WHERE intItemFactoryId > @intItemFactoryId
			END

			DELETE IA
			FROM tblICItemFactory IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemFactory IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intFactoryId = IA.intFactoryId
					)

			UPDATE IA1
			SET ysnDefault = IA.ysnDefault
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemFactory IA
			JOIN tblICItemFactory IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intFactoryId = IA.intFactoryId

			INSERT INTO tblICItemFactory (
				intItemId
				,intFactoryId
				,ysnDefault
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intFactoryId
				,ysnDefault
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemFactory IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemFactory IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intFactoryId = IA.intFactoryId
					)

			DELETE
			FROM @tblICItemFactory

			DELETE
			FROM @tblICFinalItemFactory

			EXEC sp_xml_removedocument @idoc

			------------------Item Factory Manufacturing Cell------------------------------------------------------
			DECLARE @intItemFactoryManufacturingCellId INT
				,@intPreference INT
				,@intManufacturingCellId INT
				,@strCellName NVARCHAR(50)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemFactoryManufacturingCellXML

			DECLARE @tblICItemFactoryManufacturingCell TABLE (
				intItemFactoryManufacturingCellId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strCellName NVARCHAR(50) Collate Latin1_General_CI_AS
				,ysnDefault BIT
				,intPreference INT
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				)
			DECLARE @tblICFinalItemFactoryManufacturingCell TABLE (
				intItemId INT
				,intItemFactoryId INT
				,intManufacturingCellId INT
				,ysnDefault BIT
				,intPreference INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemFactoryManufacturingCell (
				strLocationName
				,strCellName
				,ysnDefault
				,intPreference
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
				)
			SELECT strLocationName
				,strCellName
				,ysnDefault
				,intPreference
				,strCreatedBy
				,strModifiedBy
				,intSort
				,dtmDateCreated
				,dtmDateModified
			FROM OPENXML(@idoc, 'vyuIPGetItemFactoryManufacturingCells/vyuIPGetItemFactoryManufacturingCell', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCellName NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnDefault BIT
					,intPreference INT
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					)

			SELECT @intItemFactoryManufacturingCellId = min(intItemFactoryManufacturingCellId)
			FROM @tblICItemFactoryManufacturingCell

			WHILE @intItemFactoryManufacturingCellId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strCellName = NULL
					,@ysnDefault = NULL
					,@intPreference = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@intSort = NULL
					,@dtmDateCreated = NULL
					,@dtmDateModified = NULL

				SELECT @strErrorMessage = ''

				SELECT @strLocationName = strLocationName
					,@strCellName = strCellName
					,@ysnDefault = ysnDefault
					,@intPreference = intPreference
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
					,@intSort = intSort
					,@dtmDateCreated = dtmDateCreated
					,@dtmDateModified = dtmDateModified
				FROM @tblICItemFactoryManufacturingCell
				WHERE intItemFactoryManufacturingCellId = @intItemFactoryManufacturingCellId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intManufacturingCellId = NULL

				SELECT @intManufacturingCellId = intManufacturingCellId
				FROM tblMFManufacturingCell
				WHERE strCellName = @strCellName

				IF @strCellName IS NOT NULL
					AND @intManufacturingCellId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Manufacturing cell name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Manufacturing cell name ' + @strLocationName + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				SELECT @intItemFactoryId = NULL

				SELECT @intItemFactoryId = intItemFactoryId
				FROM tblICItemFactory
				WHERE intItemId = @intNewItemId
					AND intFactoryId = @intLocationId

				INSERT INTO @tblICFinalItemFactoryManufacturingCell (
					intItemId
					,intItemFactoryId
					,intManufacturingCellId
					,ysnDefault
					,intPreference
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemFactoryId
					,@intManufacturingCellId
					,@ysnDefault
					,@intPreference
					,@intSort
					,1 intConcurrencyId
					,@dtmDateCreated
					,@dtmDateModified
					,@intCreatedById
					,@intModifiedById

				SELECT @intItemFactoryManufacturingCellId = min(intItemFactoryManufacturingCellId)
				FROM @tblICItemFactoryManufacturingCell
				WHERE intItemFactoryManufacturingCellId > @intItemFactoryManufacturingCellId
			END

			DELETE IA
			FROM tblICItemFactoryManufacturingCell IA
			JOIN tblICItemFactory ItemFactory ON ItemFactory.intItemFactoryId = IA.intItemFactoryId
			WHERE ItemFactory.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemFactoryManufacturingCell IA1
					WHERE IA1.intItemId = ItemFactory.intItemId
						AND IA1.intManufacturingCellId = IA.intManufacturingCellId
					)

			UPDATE IA1
			SET ysnDefault = IA.ysnDefault
				,intPreference = IA.intPreference
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemFactoryManufacturingCell IA
			JOIN tblICItemFactoryManufacturingCell IA1 ON IA1.intItemFactoryId = IA.intItemFactoryId
				AND IA1.intManufacturingCellId = IA.intManufacturingCellId

			INSERT INTO tblICItemFactoryManufacturingCell (
				intItemFactoryId
				,ysnDefault
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemFactoryId
				,ysnDefault
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemFactoryManufacturingCell IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemFactoryManufacturingCell IA1
					WHERE IA1.intItemFactoryId = IA.intItemFactoryId
						AND IA1.intManufacturingCellId = IA.intManufacturingCellId
					)

			DELETE
			FROM @tblICItemFactoryManufacturingCell

			DELETE
			FROM @tblICFinalItemFactoryManufacturingCell

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemKitXML

			DELETE
			FROM tblICItemKit
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemKit (
				intItemId
				,strComponent
				,strInputType
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,strComponent
				,strInputType
				,intSort
				,1 AS intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemKits/vyuIPGetItemKit', 2) WITH (
					strComponent NVARCHAR(200) Collate Latin1_General_CI_AS
					,strInputType NVARCHAR(200) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemKitDetailXML

			DELETE
			FROM tblICItemKitDetail
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemKitDetail (
				intItemKitId
				,intItemId
				,dblQuantity
				,intItemUnitMeasureId
				,dblPrice
				,ysnSelected
				,inSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT (
					SELECT TOP 1 intItemKitId
					FROM tblICItemKit
					WHERE intItemId = @intNewItemId
					) AS intItemKitId
				,@intNewItemId
				,dblQuantity
				,IU.intItemUOMId
				,dblPrice
				,ysnSelected
				,inSort
				,1 intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemKits/vyuIPGetItemKit', 2) WITH (
					dblQuantity NUMERIC(38, 20)
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblPrice NUMERIC(18, 6)
					,ysnSelected INT
					,inSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intNewItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemLicenseXML

			DELETE
			FROM tblICItemLicense
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemLicense (
				intItemId
				,intLicenseTypeId
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,LT.intLicenseTypeId
				,1 AS intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemLicenses/vyuIPGetItemLicense', 2) WITH (
					intItemId INT
					,strCode INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US1.strUserName = x.strModifiedBy
			LEFT JOIN tblSMLicenseType LT ON LT.strCode = x.strCode

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemManufacturingUOMXML

			DELETE
			FROM tblICItemManufacturingUOM
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemManufacturingUOM (
				intItemId
				,intUnitMeasureId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,UM.intUnitMeasureId
				,x.intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemManufacturingUOMs/vyuIPGetItemManufacturingUOM', 2) WITH (
					strUnitMeasure NVARCHAR(200) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemMotorFuelTaxXML

			DELETE
			FROM tblICItemMotorFuelTax
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemMotorFuelTax (
				intItemId
				,intTaxAuthorityId
				,intProductCodeId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,TA.intTaxAuthorityId
				,PC.intProductCodeId
				,x.intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemMotorFuelTaxs/vyuIPGetItemMotorFuelTax', 2) WITH (
					strTaxAuthorityCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strProductCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblTFTaxAuthority TA ON TA.strTaxAuthorityCode = x.strTaxAuthorityCode
			LEFT JOIN tblTFProductCode PC ON PC.strProductCode = x.strProductCode

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemNoteXML

			DELETE
			FROM tblICItemNote
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemNote (
				intItemId
				,intItemLocationId
				,strCommentType
				,strComments
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,IL.intItemLocationId
				,x.strCommentType
				,x.strComments
				,x.intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemNotes/vyuIPGetItemNote', 2) WITH (
					strCommentType NVARCHAR(50) Collate Latin1_General_CI_AS
					,strComments NVARCHAR(MAX) Collate Latin1_General_CI_AS
					,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = x.strLocationName
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = L.intCompanyLocationId
				AND IL.intItemId = @intNewItemId

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemOwnerXML

			DELETE
			FROM tblICItemOwner
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemOwner (
				intItemId
				,intOwnerId
				,ysnDefault
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,C.intEntityId
				,x.ysnDefault
				,x.intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemOwners/vyuIPGetItemOwner', 2) WITH (
					strCustomerNumber NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnDefault BIT
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblARCustomer C ON C.strCustomerNumber = x.strCustomerNumber

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemPOSCategoryXML

			DELETE
			FROM tblICItemPOSCategory
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemPOSCategory (
				intItemId
				,intCategoryId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,C.intCategoryId
				,x.intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemPOSCategorys/vyuIPGetItemPOSCategory', 2) WITH (
					strCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,ysnDefault BIT
					,intSort INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICCategory C ON C.strCategoryCode = x.strCategoryCode

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemPOSSLAXML

			DELETE
			FROM tblICItemPOSSLA
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemPOSSLA (
				intItemId
				,strSLAContract
				,dblContractPrice
				,ysnServiceWarranty
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,strSLAContract
				,dblContractPrice
				,ysnServiceWarranty
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemPOSSLAs/vyuIPGetItemPOSSLA', 2) WITH (
					strSLAContract NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,dblContractPrice NUMERIC(18, 6)
					,ysnServiceWarranty BIT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strCategoryCode NVARCHAR(50) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICCategory C ON C.strCategoryCode = x.strCategoryCode

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemPricingXML

			DELETE
			FROM tblICItemPricing
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemPricing (
				intItemId
				,intItemLocationId
				,dblAmountPercent
				,dblSalePrice
				,dblMSRPPrice
				,strPricingMethod
				,dblLastCost
				,dblStandardCost
				,dblAverageCost
				,dblEndMonthCost
				,dblDefaultGrossPrice
				,intSort
				,ysnIsPendingUpdate
				,dtmDateChanged
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				,intDataSourceId
				)
			SELECT @intNewItemId
				,IL.intItemLocationId
				,x.dblAmountPercent
				,x.dblSalePrice
				,x.dblMSRPPrice
				,x.strPricingMethod
				,x.dblLastCost
				,x.dblStandardCost
				,x.dblAverageCost
				,x.dblEndMonthCost
				,x.dblDefaultGrossPrice
				,x.intSort
				,x.ysnIsPendingUpdate
				,x.dtmDateChanged
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
				,DS.intDataSourceId
			FROM OPENXML(@idoc, 'vyuIPGetItemPricings/vyuIPGetItemPricing', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblAmountPercent NUMERIC(18, 6)
					,dblSalePrice NUMERIC(18, 6)
					,dblMSRPPrice NUMERIC(18, 6)
					,strPricingMethod NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblLastCost NUMERIC(18, 6)
					,dblStandardCost NUMERIC(18, 6)
					,dblAverageCost NUMERIC(18, 6)
					,dblEndMonthCost NUMERIC(18, 6)
					,dblDefaultGrossPrice NUMERIC(18, 6)
					,intSort INT
					,ysnIsPendingUpdate BIT
					,dtmDateChanged DATETIME
					,intConcurrencyId INT
					,intDataSourceId INT
					,strSourceName NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
				AND intItemId = @intNewItemId
			LEFT JOIN tblICDataSource DS ON DS.strSourceName Collate Latin1_General_CI_AS = x.strSourceName

			EXEC sp_xml_removedocument @idoc

			------------------Item Pricing Level------------------------------------------------------
			DECLARE @intItemPricingLevelId INT
				,@strCurrency NVARCHAR(50)
				,@intCurrencyId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemPricingLevelXML

			DECLARE @tblICItemPricingLevel TABLE (
				intItemPricingLevelId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strPriceLevel NVARCHAR(50) Collate Latin1_General_CI_AS
				,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblUnit NUMERIC(18, 6)
				,dtmEffectiveDate DATETIME
				,dblMin NUMERIC(18, 6)
				,dblMax NUMERIC(18, 6)
				,strPricingMethod NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblAmountRate NUMERIC(18, 6)
				,dblUnitPrice NUMERIC(18, 6)
				,strCommissionOn NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblCommissionRate NUMERIC(18, 6)
				,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,dtmDateChanged DATETIME
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				)
			DECLARE @tblICFinalItemPricingLevel TABLE (
				intItemId INT
				,intItemLocationId INT
				,strPriceLevel NVARCHAR(50) Collate Latin1_General_CI_AS
				,intItemUnitMeasureId INT
				,dblUnit NUMERIC(18, 6)
				,dtmEffectiveDate DATETIME
				,dblMin NUMERIC(18, 6)
				,dblMax NUMERIC(18, 6)
				,strPricingMethod NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblAmountRate NUMERIC(18, 6)
				,dblUnitPrice NUMERIC(18, 6)
				,strCommissionOn NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblCommissionRate NUMERIC(18, 6)
				,intCurrencyId INT
				,intSort INT
				,dtmDateChanged DATETIME
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemPricingLevel (
				strLocationName
				,strPriceLevel
				,strUnitMeasure
				,dblUnit
				,dtmEffectiveDate
				,dblMin
				,dblMax
				,strPricingMethod
				,dblAmountRate
				,dblUnitPrice
				,strCommissionOn
				,dblCommissionRate
				,strCurrency
				,intSort
				,dtmDateChanged
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strLocationName
				,strPriceLevel
				,strUnitMeasure
				,dblUnit
				,dtmEffectiveDate
				,dblMin
				,dblMax
				,strPricingMethod
				,dblAmountRate
				,dblUnitPrice
				,strCommissionOn
				,dblCommissionRate
				,strCurrency
				,intSort
				,dtmDateChanged
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemPricingLevels/vyuIPGetItemPricingLevel', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPriceLevel NVARCHAR(50) Collate Latin1_General_CI_AS
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblUnit NUMERIC(18, 6)
					,dtmEffectiveDate DATETIME
					,dblMin NUMERIC(18, 6)
					,dblMax NUMERIC(18, 6)
					,strPricingMethod NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblAmountRate NUMERIC(18, 6)
					,dblUnitPrice NUMERIC(18, 6)
					,strCommissionOn NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblCommissionRate NUMERIC(18, 6)
					,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,dtmDateChanged DATETIME
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					)

			SELECT @intItemPricingLevelId = min(intItemPricingLevelId)
			FROM @tblICItemPricingLevel

			WHILE @intItemPricingLevelId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strUnitMeasure = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@strCurrency = NULL

				SELECT @strErrorMessage = ''

				SELECT @strLocationName = strLocationName
					,@strUnitMeasure = strUnitMeasure
					,@strCurrency = strCurrency
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemPricingLevel
				WHERE intItemPricingLevelId = @intItemPricingLevelId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE @strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intNewItemId
					AND intUnitMeasureId = @intUnitMeasureId

				IF @strUnitMeasure IS NOT NULL
					AND @intItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intCurrencyId = NULL

				SELECT @intCurrencyId = intCurrencyID
				FROM tblSMCurrency
				WHERE strCurrency = @strCurrency

				IF @strCurrency IS NOT NULL
					AND @intCurrencyId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Currency name ' + @strCurrency + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Currency name ' + @strCurrency + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemPricingLevel (
					intItemId
					,intItemLocationId
					,strPriceLevel
					,intItemUnitMeasureId
					,dblUnit
					,dtmEffectiveDate
					,dblMin
					,dblMax
					,strPricingMethod
					,dblAmountRate
					,dblUnitPrice
					,strCommissionOn
					,dblCommissionRate
					,intCurrencyId
					,intSort
					,dtmDateChanged
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemLocationId
					,strPriceLevel
					,@intItemUOMId intItemUnitMeasureId
					,dblUnit
					,dtmEffectiveDate
					,dblMin
					,dblMax
					,strPricingMethod
					,dblAmountRate
					,dblUnitPrice
					,strCommissionOn
					,dblCommissionRate
					,@intCurrencyId
					,intSort
					,dtmDateChanged
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,@intCreatedById
					,@intModifiedById
				FROM @tblICItemPricingLevel
				WHERE intItemPricingLevelId = @intItemPricingLevelId

				SELECT @intItemPricingLevelId = min(intItemPricingLevelId)
				FROM @tblICItemPricingLevel
				WHERE intItemPricingLevelId > @intItemPricingLevelId
			END

			DELETE IA
			FROM tblICItemPricingLevel IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemPricingLevel IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			UPDATE IA1
			SET strPriceLevel = IA.strPriceLevel
				,intItemUnitMeasureId = IA.intItemUnitMeasureId
				,dblUnit = IA.dblUnit
				,dtmEffectiveDate = IA.dtmEffectiveDate
				,dblMin = IA.dblMin
				,dblMax = IA.dblMax
				,strPricingMethod = IA.strPricingMethod
				,dblAmountRate = IA.dblAmountRate
				,dblUnitPrice = IA.dblUnitPrice
				,strCommissionOn = IA.strCommissionOn
				,dblCommissionRate = IA.dblCommissionRate
				,intCurrencyId = IA.intCurrencyId
				,intSort = IA.intSort
				,dtmDateChanged = IA.dtmDateChanged
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemPricingLevel IA
			JOIN tblICItemPricingLevel IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intItemLocationId = IA.intItemLocationId

			INSERT INTO tblICItemPricingLevel (
				intItemId
				,intItemLocationId
				,strPriceLevel
				,intItemUnitMeasureId
				,dblUnit
				,dtmEffectiveDate
				,dblMin
				,dblMax
				,strPricingMethod
				,dblAmountRate
				,dblUnitPrice
				,strCommissionOn
				,dblCommissionRate
				,intCurrencyId
				,intSort
				,dtmDateChanged
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intItemLocationId
				,strPriceLevel
				,intItemUnitMeasureId
				,dblUnit
				,dtmEffectiveDate
				,dblMin
				,dblMax
				,strPricingMethod
				,dblAmountRate
				,dblUnitPrice
				,strCommissionOn
				,dblCommissionRate
				,intCurrencyId
				,intSort
				,dtmDateChanged
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemPricingLevel IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemPricingLevel IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			EXEC sp_xml_removedocument @idoc

			------------------Item Special Pricing------------------------------------------------------
			DECLARE @intItemSpecialPricingId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSpecialPricingXML

			DECLARE @tblICItemSpecialPricing TABLE (
				intItemSpecialPricingId INT identity(1, 1)
				,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
				,strPromotionType NVARCHAR(50) Collate Latin1_General_CI_AS
				,dtmBeginDate DATETIME
				,dtmEndDate DATETIME
				,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblUnit NUMERIC(18, 6)
				,strDiscountBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,dblDiscount NUMERIC(18, 6)
				,dblUnitAfterDiscount NUMERIC(18, 6)
				,dblDiscountThruQty NUMERIC(18, 6)
				,dblDiscountThruAmount NUMERIC(18, 6)
				,dblAccumulatedQty NUMERIC(18, 6)
				,dblAccumulatedAmount NUMERIC(18, 6)
				,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
				)
			DECLARE @tblICFinalItemSpecialPricing TABLE (
				intItemId INT
				,intItemLocationId INT
				,strPromotionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dtmBeginDate DATETIME
				,dtmEndDate DATETIME
				,intItemUnitMeasureId INT
				,dblUnit NUMERIC(18, 6)
				,strDiscountBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dblDiscount NUMERIC(18, 6)
				,dblUnitAfterDiscount NUMERIC(18, 6)
				,dblDiscountThruQty NUMERIC(18, 6)
				,dblDiscountThruAmount NUMERIC(18, 6)
				,dblAccumulatedQty NUMERIC(18, 6)
				,dblAccumulatedAmount NUMERIC(18, 6)
				,intCurrencyId INT
				,intSort INT
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,intCreatedByUserId INT
				,intModifiedByUserId INT
				)

			INSERT INTO @tblICItemSpecialPricing (
				strLocationName
				,strPromotionType
				,dtmBeginDate
				,dtmEndDate
				,strUnitMeasure
				,dblUnit
				,strDiscountBy
				,dblDiscount
				,dblUnitAfterDiscount
				,dblDiscountThruQty
				,dblDiscountThruAmount
				,dblAccumulatedQty
				,dblAccumulatedAmount
				,strCurrency
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strLocationName
				,strPromotionType
				,dtmBeginDate
				,dtmEndDate
				,strUnitMeasure
				,dblUnit
				,strDiscountBy
				,dblDiscount
				,dblUnitAfterDiscount
				,dblDiscountThruQty
				,dblDiscountThruAmount
				,dblAccumulatedQty
				,dblAccumulatedAmount
				,strCurrency
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemSpecialPricings/vyuIPGetItemSpecialPricing', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPromotionType NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmBeginDate DATETIME
					,dtmEndDate DATETIME
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblUnit NUMERIC(18, 6)
					,strDiscountBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,dblDiscount NUMERIC(18, 6)
					,dblUnitAfterDiscount NUMERIC(18, 6)
					,dblDiscountThruQty NUMERIC(18, 6)
					,dblDiscountThruAmount NUMERIC(18, 6)
					,dblAccumulatedQty NUMERIC(18, 6)
					,dblAccumulatedAmount NUMERIC(18, 6)
					,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
					)

			SELECT @intItemSpecialPricingId = min(intItemSpecialPricingId)
			FROM @tblICItemSpecialPricing

			WHILE @intItemSpecialPricingId IS NOT NULL
			BEGIN
				SELECT @strLocationName = NULL
					,@strUnitMeasure = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@strCurrency = NULL
					,@strErrorMessage = ''

				SELECT @strLocationName = strLocationName
					,@strUnitMeasure = strUnitMeasure
					,@strCurrency = strCurrency
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemSpecialPricing
				WHERE intItemSpecialPricingId = @intItemSpecialPricingId

				SELECT @intLocationId = NULL

				SELECT @intLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE strLocationName = @strLocationName

				IF @strLocationName IS NOT NULL
					AND @intLocationId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not available.'
					END
				END

				SELECT @intItemLocationId = NULL

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intNewItemId
					AND intLocationId = @intLocationId

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE @strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intNewItemId
					AND intUnitMeasureId = @intUnitMeasureId

				IF @strUnitMeasure IS NOT NULL
					AND @intItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intCurrencyId = NULL

				SELECT @intCurrencyId = intCurrencyID
				FROM tblSMCurrency
				WHERE strCurrency = @strCurrency

				IF @strCurrency IS NOT NULL
					AND @intCurrencyId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Currency name ' + @strCurrency + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Currency name ' + @strCurrency + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemSpecialPricing (
					intItemId
					,intItemLocationId
					,strPromotionType
					,dtmBeginDate
					,dtmEndDate
					,intItemUnitMeasureId
					,dblUnit
					,strDiscountBy
					,dblDiscount
					,dblUnitAfterDiscount
					,dblDiscountThruQty
					,dblDiscountThruAmount
					,dblAccumulatedQty
					,dblAccumulatedAmount
					,intCurrencyId
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intItemLocationId
					,strPromotionType
					,dtmBeginDate
					,dtmEndDate
					,@intItemUOMId
					,dblUnit
					,strDiscountBy
					,dblDiscount
					,dblUnitAfterDiscount
					,dblDiscountThruQty
					,dblDiscountThruAmount
					,dblAccumulatedQty
					,dblAccumulatedAmount
					,@intCurrencyId
					,intSort
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,@intCreatedById
					,@intModifiedById
				FROM @tblICItemSpecialPricing
				WHERE intItemSpecialPricingId = @intItemSpecialPricingId

				SELECT @intItemSpecialPricingId = min(intItemSpecialPricingId)
				FROM @tblICItemSpecialPricing
				WHERE intItemSpecialPricingId > @intItemSpecialPricingId
			END

			DELETE IA
			FROM tblICItemSpecialPricing IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemSpecialPricing IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			UPDATE IA1
			SET strPromotionType = IA.strPromotionType
				,dtmBeginDate = IA.dtmBeginDate
				,dtmEndDate = IA.dtmEndDate
				,intItemUnitMeasureId = IA.intItemUnitMeasureId
				,dblUnit = IA.dblUnit
				,strDiscountBy = IA.strDiscountBy
				,dblDiscount = IA.dblDiscount
				,dblUnitAfterDiscount = IA.dblUnitAfterDiscount
				,dblDiscountThruQty = IA.dblDiscountThruQty
				,dblDiscountThruAmount = IA.dblDiscountThruAmount
				,dblAccumulatedQty = IA.dblAccumulatedQty
				,dblAccumulatedAmount = IA.dblAccumulatedAmount
				,intCurrencyId = IA.intCurrencyId
				,intSort = IA.intSort
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemSpecialPricing IA
			JOIN tblICItemSpecialPricing IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intItemLocationId = IA.intItemLocationId

			INSERT INTO tblICItemSpecialPricing (
				intItemId
				,intItemLocationId
				,strPromotionType
				,dtmBeginDate
				,dtmEndDate
				,intItemUnitMeasureId
				,dblUnit
				,strDiscountBy
				,dblDiscount
				,dblUnitAfterDiscount
				,dblDiscountThruQty
				,dblDiscountThruAmount
				,dblAccumulatedQty
				,dblAccumulatedAmount
				,intCurrencyId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intItemLocationId
				,strPromotionType
				,dtmBeginDate
				,dtmEndDate
				,intItemUnitMeasureId
				,dblUnit
				,strDiscountBy
				,dblDiscount
				,dblUnitAfterDiscount
				,dblDiscountThruQty
				,dblDiscountThruAmount
				,dblAccumulatedQty
				,dblAccumulatedAmount
				,intCurrencyId
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemSpecialPricing IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemSpecialPricing IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intItemLocationId = IA.intItemLocationId
					)

			DELETE
			FROM @tblICItemSpecialPricing

			DELETE
			FROM @tblICFinalItemSpecialPricing

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSubLocationXML

			SELECT @strErrorMessage = ''

			---**************************** Item SubLocation********************************
			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuIPGetItemSubLocations/vyuIPGetItemSubLocation', 2) WITH (strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
					LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
						AND IL.intItemId = @intNewItemId
					WHERE IL.intItemLocationId IS NULL
					)
			BEGIN
				SELECT @strLocationName = x.strLocationName
				FROM OPENXML(@idoc, 'vyuIPGetItemSubLocations/vyuIPGetItemSubLocation', 2) WITH (strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
				LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
					AND IL.intItemId = @intNewItemId
				WHERE IL.intItemLocationId IS NULL

				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location name ' + @strLocationName + ' is not associated with the item ' + @strItemNo + '.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not associated with the item ' + @strItemNo + '.'
				END
			END

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuIPGetItemSubLocations/vyuIPGetItemSubLocation', 2) WITH (strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblSMCompanyLocationSubLocation CL ON CL.strSubLocationName = x.strSubLocationName
					WHERE CL.intCompanyLocationSubLocationId IS NULL
					)
			BEGIN
				SELECT @strSubLocationName = x.strSubLocationName
				FROM OPENXML(@idoc, 'vyuIPGetItemSubLocations/vyuIPGetItemSubLocation', 2) WITH (strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblSMCompanyLocationSubLocation CL ON CL.strSubLocationName = x.strSubLocationName
				WHERE CL.intCompanyLocationSubLocationId IS NULL

				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Sub Location name ' + @strSubLocationName + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Sub Location name ' + @strSubLocationName + ' is not available.'
				END
			END

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			DELETE SL
			FROM tblICItemSubLocation SL
			JOIN tblICItemLocation IL ON IL.intItemLocationId = SL.intItemLocationId
			WHERE IL.intItemId = @intNewItemId

			INSERT INTO tblICItemSubLocation (
				intItemLocationId
				,intSubLocationId
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT IL.intItemLocationId
				,CSL.intCompanyLocationSubLocationId
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemPOSCategorys/vyuIPGetItemPOSCategory', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
			LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.strSubLocationName = x.strSubLocationName
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
				AND IL.intItemId = @intNewItemId

			EXEC sp_xml_removedocument @idoc

			------------------Item UOM UPC------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemUOMUpcXML

			DELETE IUUpc
			FROM tblICItemUomUpc IUUpc
			JOIN tblICItemUOM IU ON IU.intItemUOMId = IUUpc.intItemUOMId
			WHERE IU.intItemId = @intNewItemId

			INSERT INTO tblICItemUomUpc (
				intItemUOMId
				,strUpcCode
				,strLongUpcCode
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT IU.intItemUOMId
				,x.strUpcCode
				,x.strLongUpcCode
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemUomUpcs/vyuIPGetItemUomUpc', 2) WITH (
					strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,strUpcCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strLongUpcCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intNewItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId

			EXEC sp_xml_removedocument @idoc

			---******************************** Item Substitute ********************************************
			DECLARE @intItemSubstituteId INT
				,@strSubstituteItem NVARCHAR(50)
				,@intSubstituteItemId INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSubstituteXML

			DECLARE @tblICItemSubstitute TABLE (
				intItemSubstituteId INT identity(1, 1)
				,strSubstituteItem NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				,dblQuantity NUMERIC(18, 6)
				,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,dblMarkUpOrDown NUMERIC(18, 6)
				,dtmBeginDate DATETIME
				,dtmEndDate DATETIME
				,intConcurrencyId INT
				,dtmDateCreated DATETIME
				,dtmDateModified DATETIME
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strModifiedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				)
			DECLARE @tblICFinalItemSubstitute TABLE (
				intItemId INT NOT NULL
				,intSubstituteItemId INT NOT NULL
				,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				,dblQuantity NUMERIC(38, 20) NULL DEFAULT((0))
				,intItemUOMId INT NULL
				,dblMarkUpOrDown NUMERIC(38, 20) NULL DEFAULT((0))
				,dtmBeginDate DATETIME NULL
				,dtmEndDate DATETIME NULL
				,intConcurrencyId INT NULL DEFAULT((0))
				,dtmDateCreated DATETIME NULL
				,dtmDateModified DATETIME NULL
				,intCreatedByUserId INT NULL
				,intModifiedByUserId INT NULL
				)

			INSERT INTO @tblICItemSubstitute (
				strSubstituteItem
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
				)
			SELECT strSubstituteItem
				,strDescription
				,dblQuantity
				,strUnitMeasure
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,strCreatedBy
				,strModifiedBy
			FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutes/vyuIPGetItemSubstitute', 2) WITH (
					strSubstituteItem NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,dblQuantity NUMERIC(18, 6)
					,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,dblMarkUpOrDown NUMERIC(18, 6)
					,dtmBeginDate DATETIME
					,dtmEndDate DATETIME
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
					)

			SELECT @intItemSubstituteId = min(intItemSubstituteId)
			FROM @tblICItemSubstitute

			WHILE @intItemSubstituteId IS NOT NULL
			BEGIN
				SELECT @strSubstituteItem = NULL
					,@strUnitMeasure = NULL
					,@strCreatedBy = NULL
					,@strModifiedBy = NULL
					,@strErrorMessage = ''

				SELECT @strSubstituteItem = strSubstituteItem
					,@strUnitMeasure = strUnitMeasure
					,@strCreatedBy = strCreatedBy
					,@strModifiedBy = strModifiedBy
				FROM @tblICItemSubstitute
				WHERE intItemSubstituteId = @intItemSubstituteId

				SELECT @intSubstituteItemId = NULL

				SELECT @intSubstituteItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strSubstituteItem

				IF @strSubstituteItem IS NOT NULL
					AND @intSubstituteItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Substitute Item ' + @strSubstituteItem + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Substitute Item ' + @strSubstituteItem + ' is not available.'
					END
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE @strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intNewItemId
					AND intUnitMeasureId = @intUnitMeasureId

				IF @strUnitMeasure IS NOT NULL
					AND @intItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCreatedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strCreatedBy

				SELECT @intModifiedById = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strModifiedBy

				INSERT INTO @tblICFinalItemSubstitute (
					intItemId
					,intSubstituteItemId
					,strDescription
					,dblQuantity
					,intItemUOMId
					,dblMarkUpOrDown
					,dtmBeginDate
					,dtmEndDate
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @intNewItemId
					,@intSubstituteItemId
					,strDescription
					,dblQuantity
					,@intItemUOMId
					,dblMarkUpOrDown
					,dtmBeginDate
					,dtmEndDate
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,@intCreatedById
					,@intModifiedById
				FROM @tblICItemSubstitute
				WHERE intItemSubstituteId = @intItemSubstituteId

				SELECT @intItemSubstituteId = min(intItemSubstituteId)
				FROM @tblICItemSubstitute
				WHERE intItemSubstituteId > @intItemSubstituteId
			END

			DELETE IA
			FROM tblICItemSubstitute IA
			WHERE IA.intItemId = @intNewItemId
				AND NOT EXISTS (
					SELECT *
					FROM @tblICFinalItemSubstitute IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intSubstituteItemId = IA.intSubstituteItemId
					)

			UPDATE IA1
			SET strDescription = IA.strDescription
				,dblQuantity = IA.dblQuantity
				,intItemUOMId = IA.intItemUOMId
				,dblMarkUpOrDown = IA.dblMarkUpOrDown
				,dtmBeginDate = IA.dtmBeginDate
				,dtmEndDate = IA.dtmEndDate
				,intConcurrencyId = IA.intConcurrencyId
				,dtmDateCreated = IA.dtmDateCreated
				,dtmDateModified = IA.dtmDateModified
				,intCreatedByUserId = IA.intCreatedByUserId
				,intModifiedByUserId = IA.intModifiedByUserId
			FROM @tblICFinalItemSubstitute IA
			JOIN tblICItemSubstitute IA1 ON IA1.intItemId = IA.intItemId
				AND IA1.intSubstituteItemId = IA.intSubstituteItemId

			INSERT INTO tblICItemSubstitute (
				intItemId
				,intSubstituteItemId
				,strDescription
				,dblQuantity
				,intItemUOMId
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemId
				,intSubstituteItemId
				,strDescription
				,dblQuantity
				,intItemUOMId
				,dblMarkUpOrDown
				,dtmBeginDate
				,dtmEndDate
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
			FROM @tblICFinalItemSubstitute IA
			WHERE NOT EXISTS (
					SELECT *
					FROM tblICItemSubstitute IA1
					WHERE IA1.intItemId = IA.intItemId
						AND IA1.intSubstituteItemId = IA.intSubstituteItemId
					)

			DELETE
			FROM @tblICItemSubstitute

			DELETE
			FROM @tblICFinalItemSubstitute

			EXEC sp_xml_removedocument @idoc

			---**************************** Item Substitution Detail********************************
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSubstitutionDetailXML

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutionDetails/vyuIPGetItemSubstitutionDetail', 2) WITH (strSubstitutionItem NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblICItem I ON I.strItemNo = x.strSubstitutionItem
					WHERE I.intItemId IS NULL
					)
			BEGIN
				SELECT @strSubstitutionItem = x.strSubstitutionItem
				FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutionDetails/vyuIPGetItemSubstitutionDetail', 2) WITH (strSubstitutionItem NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblICItem I ON I.strItemNo = x.strSubstitutionItem
				WHERE I.intItemId IS NULL

				SELECT @strErrorMessage = 'Substitution Item ' + @strSubstitutionItem + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			DELETE ISD
			FROM tblICItemSubstitutionDetail ISD
			JOIN tblICItemSubstitution ISub ON ISub.intItemSubstitutionId = ISD.intItemSubstitutionId
			WHERE ISub.intItemId = @intNewItemId

			INSERT INTO tblICItemSubstitutionDetail (
				intItemSubstitutionId
				,intSubstituteItemId
				,dtmValidFrom
				,dtmValidTo
				,dblRatio
				,dblPercent
				,ysnYearValidationRequired
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT intItemSubstitutionId
				,I.intItemId AS intSubstituteItemId
				,dtmValidFrom
				,dtmValidTo
				,dblRatio
				,dblPercent
				,ysnYearValidationRequired
				,intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutionDetails/vyuIPGetItemSubstitutionDetail', 2) WITH (
					intItemSubstitutionId INT
					,strSubstitutionItem NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmValidFrom DATETIME
					,dtmValidTo DATETIME
					,dblRatio NUMERIC(18, 6)
					,dblPercent NUMERIC(18, 6)
					,ysnYearValidationRequired BIT
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblICItem I ON I.strItemNo = x.strSubstitutionItem

			EXEC sp_xml_removedocument @idoc

			---**************************** Item Substitution********************************
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemSubstitutionXML

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutions/vyuIPGetItemSubstitution', 2) WITH (strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
					LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
						AND IL.intItemId = @intNewItemId
					WHERE IL.intItemLocationId IS NULL
					)
			BEGIN
				SELECT @strLocationName = x.strLocationName
				FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutions/vyuIPGetItemSubstitution', 2) WITH (strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName
				LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId
					AND IL.intItemId = @intNewItemId
				WHERE IL.intItemLocationId IS NULL

				SELECT @strErrorMessage = 'Location name ' + @strLocationName + ' is not associated with the item ' + @strItemNo + '.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			DELETE
			FROM tblICItemSubstitution
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemSubstitution (
				intLocationId
				,intItemId
				,strModification
				,ysnContracted
				,strComment
				,intSort
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT CL.intCompanyLocationId
				,@intNewItemId
				,strModification
				,ysnContracted
				,strComment
				,intSort
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemSubstitutions/vyuIPGetItemSubstitution', 2) WITH (
					strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strModification NVARCHAR(50)
					,ysnContracted BIT
					,strComment NVARCHAR(MAX)
					,intSort INT
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US.strUserName = x.strModifiedBy
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strLocationName

			EXEC sp_xml_removedocument @idoc

			---**************************** Item Book ********************************
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strItemBookXML

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuIPGetItemBooks/vyuIPGetItemBook', 2) WITH (strBook NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblCTBook B ON B.strBook = x.strBook
					WHERE B.intBookId IS NULL
					)
			BEGIN
				SELECT @strBook = x.strBook
				FROM OPENXML(@idoc, 'vyuIPGetItemBooks/vyuIPGetItemBook', 2) WITH (strBook NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblCTBook B ON B.strBook = x.strBook
				WHERE B.intBookId IS NULL

				SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			DELETE
			FROM tblICItemBook
			WHERE intItemId = @intNewItemId

			INSERT INTO tblICItemBook (
				intItemId
				,intBookId
				,intSubBookId
				,intConcurrencyId
				,dtmDateCreated
				,dtmDateModified
				,intCreatedByUserId
				,intModifiedByUserId
				)
			SELECT @intNewItemId
				,B.intBookId
				,SB.intSubBookId
				,1 AS intConcurrencyId
				,x.dtmDateCreated
				,x.dtmDateModified
				,US.intEntityId AS intCreatedByUserId
				,US1.intEntityId AS intModifiedByUserId
			FROM OPENXML(@idoc, 'vyuIPGetItemBooks/vyuIPGetItemBook', 2) WITH (
					strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,intConcurrencyId INT
					,dtmDateCreated DATETIME
					,dtmDateModified DATETIME
					,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					,strModifiedBy NVARCHAR(100) Collate Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMUserSecurity US ON US.strUserName = x.strCreatedBy
			LEFT JOIN tblSMUserSecurity US1 ON US1.strUserName = x.strModifiedBy
			LEFT JOIN tblCTBook B ON B.strBook = x.strBook
			LEFT JOIN tblCTSubBook SB ON SB.strSubBook = x.strSubBook
				AND B.intBookId = SB.intBookId

			EXEC sp_xml_removedocument @idoc

			ext:

			SELECT @intItemScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'Inventory.view.Item'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewItemId
				AND intScreenId = @intItemScreenId

			IF @intTransactionRefId IS NOT NULL
				AND @intTransactionId IS NOT NULL
			BEGIN
				EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
					,@referenceTransactionId = @intTransactionId
					,@referenceCompanyId = @intCompanyId
			END

			INSERT INTO tblICItemAcknowledgementStage (
				intItemId
				,strItemNo
				,intItemRefId
				,strMessage
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewItemId
				,@strItemNo
				,@intItemId
				,'Success'
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

			UPDATE tblICItemStage
			SET strFeedStatus = 'Processed'
			WHERE intItemStageId = @intItemStageId

			-- Audit Log
			IF (@intNewItemId > 0)
			BEGIN
				IF @strRowState = 'Modified'
				BEGIN
					SELECT @strDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @strDescription
						,@fromValue = ''
						,@toValue = @strItemNo
				END
			END

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblICItemStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intItemStageId = @intItemStageId
		END CATCH

		SELECT @intItemStageId = MIN(intItemStageId)
		FROM @tblICItemStage
		WHERE intItemStageId > @intItemStageId

	END

	UPDATE tblICItemStage
	SET strFeedStatus = NULL
	WHERE intItemStageId IN (
			SELECT S.intItemStageId
			FROM @tblICItemStage S
			)
	AND IsNULL(strFeedStatus,'') = 'In-Progress'

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
