CREATE PROCEDURE uspICImportItemsFromStaging @strIdentifier NVARCHAR(100)
AS

INSERT INTO tblICItem(
	  strItemNo
	, strType
	, strDescription
	, strStatus
	, intLifeTime
	, strShortName
	, strLotTracking
	, ysnLotWeightsRequired
	, ysnUseWeighScales
	, strBarcodePrint
	, intManufacturerId
	, intCommodityId
	, intBrandId
	, strModelNo
	, intCategoryId
	, ysnStockedItem
	, ysnDyedFuel
	, ysnMSDSRequired
	, strEPANumber
	, ysnInboundTax
	, ysnRestrictedChemical
	, ysnFuelItem
	, ysnListBundleSeparately
	, dblDenaturantPercent
	, ysnTonnageTax
	, ysnLoadTracking
	, dblMixOrder
	, ysnHandAddIngredient
	, ysnExtendPickTicket
	, ysnExportEDI
	, ysnHazardMaterial
	, ysnMaterialFee
	, ysnAutoBlend
	, dblUserGroupFee
	, dblWeightTolerance
	, dblOverReceiveTolerance
	, ysnLandedCost
	, strLeadTime
	, ysnTaxable
	, strKeywords
	, dblCaseQty
	, dtmDateShip
	, dblTaxExempt
	, ysnDropShip
	, ysnCommisionable
	, ysnSpecialCommission
	, ysnTankRequired
	, ysnAvailableTM
	, dblDefaultFull
	, dblMaintenanceRate
	, strNACSCategory
	, ysnReceiptCommentRequired
	, intPatronageCategoryDirectId
	, intPatronageCategoryId
	, intPhysicalItem
	, strVolumeRebateGroup
	, intIngredientTag
	, intMedicationTag
	, intRINFuelTypeId
	, strFuelInspectFee
	, dtmDateCreated
	, intCreatedByUserId
)
SELECT
	  strItemNo						= s.strItemNo
	, strType						= COALESCE(invTypes.strType, 'Inventory')
	, strDescription				= ISNULL(s.strDescription, s.strItemNo)
	, strStatus						= COALESCE(statuses.strStatus, 'Active')
	, intLifeTime					= 1
	, strShortName					= s.strShortName
	, strLotTracking				= COALESCE(lotTrackTypes.strLotTracking, 'No')
	, ysnLotWeightsRequired			= s.ysnLotWeightsRequired
	, ysnUseWeighScales				= s.ysnUseWeighScales
	, strBarcodePrint				= s.strBarcodePrint
	, intManufacturerId				= m.intManufacturerId
	, intCommodityId				= cm.intCommodityId
	, intBrandId					= b.intBrandId
	, strModelNo					= s.strModelNo
	, intCategoryId					= c.intCategoryId
	, ysnStockedItem				= s.ysnStockedItem
	, ysnDyedFuel					= s.ysnDyedFuel
	, ysnMSDSRequired				= s.ysnMSDSRequired
	, strEPANumber					= s.strEPANumber
	, ysnInboundTax					= s.ysnInboundTax
	, ysnRestrictedChemical			= s.ysnRestrictedChemical
	, ysnFuelItem					= s.ysnFuelItem
	, ysnListBundleSeparately		= s.ysnListBundleItemsSeparately
	, dblDenaturantPercent			= s.dblDefaultPercentageFull
	, ysnTonnageTax					= s.ysnTonnageTax
	, ysnLoadTracking				= s.ysnLoadTracking
	, dblMixOrder					= s.dblMixOrder
	, ysnHandAddIngredient			= s.ysnHandAddIngredients
	, ysnExtendPickTicket			= s.ysnExtendPickTicket
	, ysnExportEDI					= s.ysnExportEDI
	, ysnHazardMaterial				= s.ysnHazardMaterial
	, ysnMaterialFee				= s.ysnMaterialFee
	, ysnAutoBlend					= s.ysnAutoBlend
	, dblUserGroupFee				= s.dblUserGroupFeePercentage
	, dblWeightTolerance			= s.dblWgtTolerancePercentage
	, dblOverReceiveTolerance		= s.dblOverReceiveTolerancePercentage
	, ysnLandedCost					= s.ysnLandedCost
	, strLeadTime					= s.strLeadTime
	, ysnTaxable					= s.ysnTaxable
	, strKeywords					= s.strKeywords
	, dblCaseQty					= s.dblCaseQty
	, dtmDateShip					= s.dtmDateShip					
	, dblTaxExempt					= s.dblTaxExempt					
	, ysnDropShip					= s.ysnDropShip					
	, ysnCommisionable				= s.ysnCommissionable				
	, ysnSpecialCommission			= s.ysnSpecialCommission			
	, ysnTankRequired				= s.ysnTankRequired				
	, ysnAvailableTM				= s.ysnAvailableforTM				
	, dblDefaultFull				= s.dblDefaultPercentageFull				
	, dblMaintenanceRate			= s.dblRate			
	, strNACSCategory				= s.strNACSCategory				
	, ysnReceiptCommentRequired		= s.ysnReceiptCommentReq		
	, intPatronageCategoryDirectId	= ds.intPatronageCategoryId
	, intPatronageCategoryId		= p.intPatronageCategoryId
	, intPhysicalItem				= ph.intItemId		
	, strVolumeRebateGroup			= s.strVolumeRebateGroup			
	, intIngredientTag				= ing.intTagId
	, intMedicationTag				= med.intTagId
	, intRINFuelTypeId				= rin.intRinFuelCategoryId
	, strFuelInspectFee				= s.strFuelInspectFee
	, dtmDateCreated				= s.dtmDateCreated
	, intCreatedByUserId			= s.intCreatedByUserId
FROM tblICImportStagingItem s
	OUTER APPLY (
		SElECT strType
		FROM (
			SELECT 'Bundle' strType UNION
			SELECT 'Inventory' strType UNION
			SELECT 'Kit' strType UNION
			SELECT 'Finished Good' strType UNION
			SELECT 'Other Charge' strType UNION
			SELECT 'Raw Material' strType UNION
			SELECT 'Service' strType UNION
			SELECT 'Software' strType UNION
			SELECT 'Comment' strType
		) x WHERE LOWER(x.strType) = LTRIM(RTRIM(LOWER(s.strType)))
	) invTypes
	OUTER APPLY (
		SELECT strStatus
		FROM (
			SELECT 'Active' strStatus UNION
			SELECT 'Phased Out' strStatus UNION
			SELECT 'Discontinued' strStatus
		) x WHERE LOWER(x.strStatus) = LTRIM(RTRIM(LOWER(s.strStatus)))
	) statuses
	OUTER APPLY (
		SELECT strLotTracking
		FROM (
			SELECT 'No' strLotTracking UNION
			SELECT 'Yes - Manual' strLotTracking UNION
			SELECT 'Yes - Serial Number' strLotTracking UNION
			SELECT 'Yes - Manual/Serial Number' strLotTracking
		) x WHERE LOWER(x.strLotTracking) = RTRIM(LTRIM(LOWER(s.strLotTracking)))
	) lotTrackTypes
	LEFT OUTER JOIN tblICManufacturer m ON LOWER(m.strManufacturer) = LTRIM(RTRIM(LOWER(s.strManufacturer)))
	LEFT OUTER JOIN tblICCategory c ON LOWER(c.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strCategory)))
	LEFT OUTER JOIN tblICCommodity cm ON LOWER(cm.strCommodityCode) = LTRIM(RTRIM(LOWER(s.strCommodity)))
	LEFT OUTER JOIN tblICBrand b ON LOWER(b.strBrandCode) = LTRIM(RTRIM(LOWER(s.strBrand)))
	LEFT OUTER JOIN tblPATPatronageCategory p ON LOWER(p.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strPatronageCategory)))
	LEFT OUTER JOIN tblPATPatronageCategory ds ON LOWER(ds.strCategoryCode) = LTRIM(RTRIM(LOWER(s.strDirectSale)))
	LEFT OUTER JOIN tblICItem ph ON LOWER(ph.strItemNo) = LTRIM(RTRIM(LOWER(s.strPhysicalItem)))
	LEFT OUTER JOIN tblICTag med ON med.strTagNumber = s.strMedicationTag AND med.strType = 'Medication Tag'
	LEFT OUTER JOIN tblICTag ing ON ing.strTagNumber = s.strIngredientTag AND ing.strType = 'Ingredient Tag'
	LEFT OUTER JOIN tblICRinFuelCategory rin ON rin.strRinFuelCategoryCode = LTRIM(RTRIM(LOWER(s.strFuelCategory)))
WHERE s.strImportIdentifier = @strIdentifier
	AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICItem
		WHERE LTRIM(RTRIM(strItemNo)) = LTRIM(RTRIM(s.strItemNo))
	)

UPDATE l
SET l.intRowsImported = @@ROWCOUNT
FROM tblICImportLog l
WHERE l.strUniqueId = @strIdentifier

DELETE FROM tblICImportStagingItem WHERE strImportIdentifier = @strIdentifier
