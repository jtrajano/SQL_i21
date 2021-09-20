CREATE TABLE [dbo].[tblApiSchemaTransformItem] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item type. Valid values are 'Inventory', 'Non-inventory', 'Other Charges', 'Service', 'Software', 'Comment'.
	strShortName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item short name.
	strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, -- The item description.
	strManufacturer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item manufacturer.
	strCommodity NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item commodity.
	strBrand NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item brand.
	strModelNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item model number.
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The item category.
	ysnStockedItem BIT NULL, -- Check if stocked item.
	ysnDyedFuel BIT NULL, -- Check if dyed fuel.
	ysnMSDSRequired BIT NULL, -- Check if MSDS is required.
	strEPANumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The EPA number.
	ysnInboundTax BIT NULL, -- Check if inbound tax.
	ysnOutboundTax BIT NULL, -- Check if outbound tax.
	ysnRestrictedChemical BIT NULL, -- Check if restricted chemical
	ysnFuelItem BIT NULL, -- Check if fuel item.
	ysnListBundleItemsSeparately BIT NULL, -- Check if list bundle item separately.
	dblDenaturantPercentage NUMERIC(38, 20) NULL, -- The item denaturant percentage.
	ysnTonnageTax BIT NULL, -- Check if tonnage tax.
	ysnLoadTracking BIT NULL, -- Check if load tracking.
	dblMixOrder NUMERIC(38, 20) NULL, -- The item mix order.
	ysnHandAddIngredients BIT NULL, -- Check if hand add ingredients.
	ysnExtendPickTicket BIT NULL, -- Check if extend pick ticket.
	ysnExportEDI BIT NULL, -- Check if export EDI.
	ysnHazardMaterial BIT NULL, -- Check if hazard material.
	ysnMaterialFee BIT NULL, -- Check if material fee.
	ysnAutoBlend BIT NULL, -- Check if auto blend.
	dblUserGroupFeePercentage NUMERIC(38, 20) NULL, -- The item user group fee percentage.
	dblWgtTolerancePercentage NUMERIC(38, 20) NULL, -- The item weight tolerance percentage.
	dblOverReceiveTolerancePercentage NUMERIC(38, 20) NULL, -- The item over receive toler
	strMaintenanceCalculationMethod NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item maintenance calculation method.
	strWICCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  -- The item WIC code.
	ysnLandedCost BIT NULL, -- Check if landed cost.
	strLeadTime NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item lead time.
	ysnTaxable BIT NULL, -- Check if taxable.
	strKeywords NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item keywords.
	dblCaseQty NUMERIC(38, 20) NULL, -- The item case quantity.
	dtmDateShip DATETIME NULL, -- The item date ship.
	dblTaxExempt NUMERIC(38, 20) NULL, -- The item tax exempt.
	ysnDropShip BIT NULL, -- Check if drop ship.
	ysnCommissionable BIT NULL, -- Check if commissionable.
	ysnSpecialCommission BIT NULL, -- Check if special commission.
	ysnTankRequired BIT NULL, -- Check if tank required.
	ysnAvailableforTM BIT NULL, -- Check if available for TM.
	dblDefaultPercentageFull NUMERIC(38, 20) NULL, -- The item default percentage full.
	dblRate NUMERIC(38, 20) NULL, -- The item rate.
	strNACSCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item NACS category.
	ysnReceiptCommentReq BIT NULL, -- Check if receipt commend required.
	strDirectSale NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item direct sale.
	strPatronageCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item patronage category.
	strPhysicalItem NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The physical item.
	strVolumeRebateGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item volume rebate group.
	strIngredientTag NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item ingredient tag.
	strMedicationTag NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item medication tag.
	strFuelCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item fuel category.
	ysnLotWeightsRequired BIT NULL, -- Check if lot weights required.
	ysnUseWeighScales BIT NULL, -- Check if use weighing scales.
	strCountCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item count code.
	strRinRequired NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item RIN required.
	strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item status. Valid values are 'Active', 'Phased Out', 'Discontinued'
	strLotTracking NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item lot tracking. Valid values are 'Yes - Manual', 'Yes - Serial Number', 'Yes - Manual/Serial Number', 'No'
	strBarcodePrint NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item barcode print.
	strFuelInspectFee NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item fuel inspect fee.
	ysnSeparateStockForUOMs BIT NULL DEFAULT ((1)) -- Check if separate stocks for UOMs.
)