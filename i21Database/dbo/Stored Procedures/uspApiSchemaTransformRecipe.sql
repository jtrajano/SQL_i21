CREATE PROCEDURE [dbo].[uspApiSchemaTransformRecipe] (
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER
)

AS

-- Retrieve Properties
DECLARE @OverwriteExisting BIT = 0

SELECT @OverwriteExisting = ISNULL(CAST(OverwriteExisting AS BIT), 0)
FROM (
	SELECT tp.strPropertyName, tp.varPropertyValue
	FROM tblApiSchemaTransformProperty tp
	WHERE tp.guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		OverwriteExisting
	)
) AS PivotTable

-- Validations
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item No'
    , strValue = sr.strItemNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Item No. ' + ISNULL(sr.strItemNo, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
OUTER APPLY (
  SELECT TOP 1 * 
  FROM tblICItem ii
  WHERE ii.strItemNo = sr.strItemNo OR ii.strDescription = sr.strItemNo
) e
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND e.intItemId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Quantity'
    , strValue = CAST(sr.dblQuantity AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Quantity should be greater than 0.'
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND dblQuantity <= 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UOM'
    , strValue = sr.strUOM
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UOM ' + ISNULL(sr.strUOM, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = sr.strUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND u.intUnitMeasureId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location Name'
    , strValue = sr.strLocationName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Location Name ' + ISNULL(sr.strLocationName, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblSMCompanyLocation l ON l.strLocationName = sr.strLocationName
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND l.intCompanyLocationId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Version No'
    , strValue = CAST(sr.intVersionNo AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Version No ' + CAST(sr.intVersionNo AS NVARCHAR(50)) + ' is not valid.'
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.intVersionNo = 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Recipe Type'
    , strValue = sr.strRecipeType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Recipe Type ' + ISNULL(sr.strRecipeType, '') + ' is not valid.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblMFRecipeType r ON r.strName = sr.strRecipeType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND r.intRecipeTypeId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Manufacturing Process'
    , strValue = sr.strManufacturingProcess
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Manufacturing Process ' + ISNULL(sr.strManufacturingProcess, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblMFManufacturingProcess p ON p.strProcessName = sr.strManufacturingProcess
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND p.intManufacturingProcessId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer'
    , strValue = sr.strCustomer
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Customer ' + ISNULL(sr.strCustomer, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
LEFT JOIN vyuARCustomer c ON c.strName = sr.strCustomer
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND c.intEntityId IS NULL
AND NULLIF(sr.strCustomer, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Farm'
    , strValue = sr.strFarm
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Farm ' + ISNULL(sr.strFarm, '') + ' does not exist.'
FROM tblApiSchemaRecipe sr
OUTER APPLY (
	SELECT TOP 1 f.strFarmDescription, f.intFarmFieldId, f.intEntityId
	FROM tblEMEntityFarm f
	WHERE strFarmDescription = sr.strFarm OR strFarm = sr.strFarm
) f
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND f.intFarmFieldId IS NULL
AND NULLIF(sr.strFarm, '') IS NOT NULL
AND NULLIF(sr.strCustomer, '') IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Cost Type'
    , strValue = sr.strCostType
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Cost Type ' + ISNULL(sr.strCostType, '') + ' is not valid.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblMFCostType ct ON ct.strName = sr.strCostType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND ct.intCostTypeId IS NULL
AND NULLIF(sr.strCostType, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Margin By'
    , strValue = sr.strMarginBy
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Margin By ' + ISNULL(sr.strMarginBy, '') + ' is not valid.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblMFMarginBy mb ON mb.strName = sr.strMarginBy
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND mb.intMarginById IS NULL
AND NULLIF(sr.strMarginBy, '') IS NOT NULL


INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Margin'
    , strValue = CAST(sr.dblMargin AS NVARCHAR(50))
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Invalid Margin ' + ISNULL(CAST(sr.dblMargin AS NVARCHAR(50)), '') + ' / Margin cannot be negative.'
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblMargin < 0
AND sr.dblMargin IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Discount'
    , strValue = CAST(sr.dblDiscount AS NVARCHAR(50))
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Invalid Discount ' + ISNULL(CAST(sr.dblDiscount AS NVARCHAR(50)), '') + ' / Discount cannot be negative.'
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblDiscount < 0
AND sr.dblDiscount IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'One Line Print'
    , strValue = sr.strOneLinePrint
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The One Line Print ' + ISNULL(sr.strOneLinePrint, '') + ' is not valid.'
FROM tblApiSchemaRecipe sr
LEFT JOIN tblMFOneLinePrint op ON op.strName = sr.strOneLinePrint
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND op.intOneLinePrintId IS NULL
AND NULLIF(sr.strOneLinePrint, '') IS NOT NULL

--Set Default Values
UPDATE sr
SET sr.strRecipeName = strItemNo
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strRecipeName, '') IS NULL
AND NULLIF(sr.strItemNo, '') IS NOT NULL

UPDATE sr
SET sr.strRecipeType = 'By Quantity'
FROM tblApiSchemaRecipe sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strRecipeType, '') IS NULL

-- INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
-- SELECT
--       NEWID()
--     , guiApiImportLogId = @guiLogId
--     , strField = 'Valid From'
--     , strValue = sr.dtmValidFrom
--     , strLogLevel = 'Error'
--     , strStatus = 'Failed'
--     , intRowNo = sr.intRowNumber
--     , strMessage = 'The Valid From date (YYYY-MM-DD) is not valid.'
-- FROM tblApiSchemaRecipe sr
-- WHERE sr.guiApiUniqueId = @guiApiUniqueId
-- AND (sr.dtmValidFrom = CAST ('1900-01-01' AS DATETIME) OR sr.dtmValidFrom IS NULL)

-- INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
-- SELECT
--       NEWID()
--     , guiApiImportLogId = @guiLogId
--     , strField = 'Valid To'
--     , strValue = sr.dtmValidFrom
--     , strLogLevel = 'Error'
--     , strStatus = 'Failed'
--     , intRowNo = sr.intRowNumber
--     , strMessage = 'The Valid To date (YYYY-MM-DD) is not valid.'
-- FROM tblApiSchemaRecipe sr
-- WHERE sr.guiApiUniqueId = @guiApiUniqueId
-- AND (sr.dtmValidTo = CAST ('1900-01-01' AS DATETIME) OR sr.dtmValidTo IS NULL)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Farm'
    , strValue = sr.strFarm
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Farm "' + ISNULL(sr.strFarm, '') + '" does not belong to the customer "' 
		+ ISNULL(sr.strCustomer, '') + '".'
FROM tblApiSchemaRecipe sr
JOIN vyuARCustomer c ON c.strName = sr.strCustomer
OUTER APPLY (
	SELECT TOP 1 f.strFarmDescription, f.intFarmFieldId
	FROM tblEMEntityFarm f
	WHERE (strFarmDescription = sr.strFarm OR strFarm = sr.strFarm)
	AND f.intEntityId = c.intEntityId
) f
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND f.intFarmFieldId IS NULL
AND NULLIF(sr.strFarm, '') IS NOT NULL

-- Transformation

-- Execute pre-requisite
EXEC dbo.uspApiSchemaTransformRecipeInitialize

DECLARE @intUserId INT = 1

DECLARE @strRecipeName NVARCHAR(50)
DECLARE @strItemNo NVARCHAR(50)
DECLARE @dblQuantity NVARCHAR(50)
DECLARE @strUOM NVARCHAR(50)
DECLARE @strLocationName NVARCHAR(50)
DECLARE @intVersionNo INT
DECLARE @strRecipeType NVARCHAR(50)
DECLARE @strManufacturingProcess NVARCHAR(50)
DECLARE @strCustomer NVARCHAR(50)
DECLARE @strFarm NVARCHAR(50)
DECLARE @strCostType NVARCHAR(50)
DECLARE @strMarginBy NVARCHAR(50)
DECLARE @dblMargin NVARCHAR(50)
DECLARE @dblDiscount NVARCHAR(50)
DECLARE @strOneLinePrint NVARCHAR(50)
DECLARE @dtmValidFrom NVARCHAR(50)
DECLARE @dtmValidTo NVARCHAR(50)

DECLARE @intItemId INT
DECLARE @intItemUOMId INT
DECLARE @intCompanyLocationId INT
DECLARE @intRecipeTypeId INT
DECLARE @intManufacturingProcessId INT
DECLARE @intCostTypeId INT
DECLARE @intMarginById INT
DECLARE @intUnitMeasureId INT
DECLARE @intOneLinePrintId INT
DECLARE @intCustomerId INT
DECLARE @intFarmFieldId INT
DECLARE @intRowNumber INT

DECLARE @intRecipeId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
	  sr.strRecipeName
	, sr.strItemNo
	, sr.dblQuantity
	, sr.strUOM
	, sr.strLocationName
	, sr.intVersionNo
	, sr.strRecipeType
	, ISNULL(sr.strManufacturingProcess, mfp.strProcessName)
	, sr.strCustomer
	, sr.strFarm
	, sr.strCostType
	, ISNULL(sr.strMarginBy, dm.strName)
	, sr.dblMargin
	, sr.dblDiscount
	, sr.strOneLinePrint
	, sr.dtmValidFrom
	, sr.dtmValidTo
	, i.intItemId
	, iu.intItemUOMId
	, cl.intCompanyLocationId
	, rt.intRecipeTypeId
	, ISNULL(mp.intManufacturingProcessId, mfp.intManufacturingProcessId)
	, ct.intCostTypeId
	, ISNULL(m.intMarginById, dm.intMarginById)
	, um.intUnitMeasureId
	, p.intOneLinePrintId
	, cust.intEntityId
	, farm.intEntityId
	, MIN(sr.intRowNumber)
FROM tblApiSchemaRecipe sr
LEFT JOIN tblICItem i ON i.strItemNo = sr.strItemNo
LEFT JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
	AND iu.ysnStockUnit = 1
LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = sr.strLocationName
LEFT JOIN tblMFRecipeType rt ON rt.strName = sr.strRecipeType
LEFT JOIN tblMFManufacturingProcess mp ON mp.strProcessName = sr.strManufacturingProcess
LEFT JOIN tblMFCostType ct ON ct.strName = sr.strCostType
LEFT JOIN tblMFMarginBy m ON m.strName = sr.strMarginBy
OUTER APPLY (
	SELECT TOP 1 strName, intMarginById
	FROM tblMFMarginBy
	WHERE strName = 'Amount'
) dm
OUTER APPLY (
    SELECT TOP 1 strProcessName, intManufacturingProcessId
    FROM tblMFManufacturingProcess
	WHERE NOT EXISTS(SELECT * 
		FROM tblMFManufacturingProcess 
		WHERE strProcessName = sr.strManufacturingProcess)
) mfp
LEFT JOIN tblICUnitMeasure um ON um.strUnitMeasure = sr.strUOM
LEFT JOIN tblMFOneLinePrint p ON p.strName = sr.strOneLinePrint
OUTER APPLY (
	SELECT TOP 1 intEntityId
	FROM vyuARCustomer
	WHERE strName = sr.strCustomer
) cust
OUTER APPLY (
	SELECT TOP 1 intEntityId
	FROM tblEMEntityFarm
	WHERE strFarmNumber = sr.strFarm
		AND intCustomerId = cust.intEntityId
) farm
WHERE NOT EXISTS(
	SELECT *
	FROM tblApiImportLogDetail
	WHERE guiApiImportLogId = @guiLogId
		AND intRowNo = sr.intRowNumber
		AND strLogLevel = 'Error'
)
AND sr.guiApiUniqueId = @guiApiUniqueId
GROUP BY
	  sr.strRecipeName
	, sr.strItemNo
	, sr.dblQuantity
	, sr.strUOM
	, sr.strLocationName
	, sr.intVersionNo
	, sr.strRecipeType
	, sr.strManufacturingProcess
	, sr.strCustomer
	, sr.strFarm
	, sr.strCostType
	, sr.strMarginBy
	, sr.dblMargin
	, sr.dblDiscount
	, sr.strOneLinePrint
	, sr.dtmValidFrom
	, sr.dtmValidTo
	, i.intItemId
	, iu.intItemUOMId
	, cl.intCompanyLocationId
	, rt.intRecipeTypeId
	, mp.intManufacturingProcessId
	, ct.intCostTypeId
	, m.intMarginById
	, um.intUnitMeasureId
	, p.intOneLinePrintId
	, cust.intEntityId
	, farm.intEntityId
	, dm.intMarginById
	, dm.strName
	, mfp.intManufacturingProcessId
	, mfp.strProcessName

OPEN cur

FETCH NEXT FROM cur INTO
	  @strRecipeName
	, @strItemNo
	, @dblQuantity
	, @strUOM
	, @strLocationName
	, @intVersionNo
	, @strRecipeType
	, @strManufacturingProcess
	, @strCustomer
	, @strFarm
	, @strCostType
	, @strMarginBy
	, @dblMargin
	, @dblDiscount
	, @strOneLinePrint
	, @dtmValidFrom
	, @dtmValidTo
	, @intItemId
	, @intItemUOMId
	, @intCompanyLocationId
	, @intRecipeTypeId
	, @intManufacturingProcessId
	, @intCostTypeId
	, @intMarginById
	, @intUnitMeasureId
	, @intOneLinePrintId
	, @intCustomerId
	, @intFarmFieldId
	, @intRowNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @intRecipeId = intRecipeId FROM tblMFRecipe WHERE strName = @strRecipeName

	IF @OverwriteExisting = 0
	BEGIN
		IF @intRecipeId IS NOT NULL
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Recipe Name'
				, strValue = @strRecipeName
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'The recipe "' + @strRecipeName + '" already exists.'
		END
	END
	
	IF @intRecipeId IS NULL
	BEGIN
		INSERT INTO tblMFRecipe (
			strName
			, intItemId
			, dblQuantity
			, intItemUOMId
			, intLocationId
			, intVersionNo
			, intRecipeTypeId
			, intManufacturingProcessId
			, ysnActive
			, intCustomerId
			, intFarmId
			, intCostTypeId
			, intMarginById
			, dblMargin
			, dblDiscount
			, intMarginUOMId
			, intOneLinePrintId
			, intCreatedUserId
			, dtmCreated
			, intLastModifiedUserId
			, dtmLastModified
			, dtmValidFrom
			, dtmValidTo
			, intConcurrencyId
			, guiApiUniqueId
			, intRowNumber
		)
		SELECT
			strName                     = @strRecipeName
			, intItemId                   = @intItemId
			, dblQuantity                 = @dblQuantity
			, intItemUOMId                = @intItemUOMId
			, intLocationId               = @intCompanyLocationId
			, intVersionNo                = @intVersionNo
			, intRecipeTypeId             = @intRecipeTypeId
			, intManufacturingProcessId   = @intManufacturingProcessId
			, ysnActive                   = 0
			, intCustomerId               = @intCustomerId
			, intFarmId                   = @intFarmFieldId
			, intCostTypeId               = @intCostTypeId
			, intMarginById               = @intMarginById
			, dblMargin                   = @dblMargin
			, dblDiscount                 = @dblDiscount
			, intMarginUOMId              = @intUnitMeasureId
			, intOneLinePrintId           = @intOneLinePrintId
			, intCreatedUserId            = @intUserId
			, dtmCreated                  = GETUTCDATE()
			, intLastModifiedUserId       = @intUserId
			, dtmLastModified             = GETUTCDATE()
			, dtmValidFrom                = @dtmValidFrom
			, dtmValidTo                  = @dtmValidTo
			, intConcurrencyId            = 1
			, guiApiUniqueId              = @guiApiUniqueId
			, intRowNumber                = @intRowNumber

		SET @intRecipeId = SCOPE_IDENTITY()

		-- Create a default output items
		INSERT INTO tblMFRecipeItem (
			intRecipeId
			, intItemId
			, strDescription
			, dblQuantity
			, dblCalculatedQuantity
			, intItemUOMId
			, intRecipeItemTypeId
			, strItemGroupName
			, dblUpperTolerance
			, dblLowerTolerance
			, dblCalculatedUpperTolerance
			, dblCalculatedLowerTolerance
			, dblShrinkage
			, ysnScaled
			, intConsumptionMethodId
			, intStorageLocationId
			, dtmValidFrom
			, dtmValidTo
			, ysnYearValidationRequired
			, ysnMinorIngredient
			, ysnOutputItemMandatory
			, dblScrap
			, ysnConsumptionRequired
			, dblCostAllocationPercentage
			, intMarginById
			, dblMargin
			, ysnCostAppliedAtInvoice
			, intCommentTypeId
			, strDocumentNo
			, intSequenceNo
			, ysnPartialFillConsumption
			, intCreatedUserId
			, dtmCreated
			, intLastModifiedUserId
			, dtmLastModified
			, intConcurrencyId)
		SELECT
			intRecipeId                       = @intRecipeId
			, intItemId                         = @intItemId
			, strDescription                    = ''
			, dblQuantity                       = @dblQuantity
			, dblCalculatedQuantity             = 0
			, intItemUOMId                      = @intItemUOMId
			, intRecipeItemTypeId               = 2
			, strItemGroupName                  = ''
			, dblUpperTolerance                 = 0
			, dblLowerTolerance                 = 0
			, dblCalculatedUpperTolerance       = @dblQuantity
			, dblCalculatedLowerTolerance       = @dblQuantity
			, dblShrinkage                      = 0
			, ysnScaled                         = 0
			, intConsumptionMethodId            = NULL
			, intStorageLocationId              = NULL
			, dtmValidFrom                      = NULL
			, dtmValidTo                        = NULL
			, ysnYearValidationRequired         = 0
			, ysnMinorIngredient                = 0
			, ysnOutputItemMandatory            = 1
			, dblScrap                          = 0
			, ysnConsumptionRequired            = 1
			, dblCostAllocationPercentage       = 100
			, intMarginById                     = NULL
			, dblMargin                         = 0
			, ysnCostAppliedAtInvoice           = 0
			, intCommentTypeId                  = NULL
			, strDocumentNo                     = NULL
			, intSequenceNo                     = NULL
			, ysnPartialFillConsumption         = 1
			, intCreatedUserId                  = @intUserId
			, dtmCreated                        = GETUTCDATE()
			, intLastModifiedUserId             = @intUserId
			, dtmLastModified                   = GETUTCDATE()
			, intConcurrencyId                  = 1
	END
	ELSE
	BEGIN
		IF @OverwriteExisting = 1
		BEGIN
			UPDATE r
			SET r.strName = @strRecipeName
				, r.dblQuantity = @dblQuantity
				, r.intManufacturingProcessId = @intManufacturingProcessId
				, r.intCustomerId = @intCustomerId
				, r.intFarmId = @intFarmFieldId
				, r.intCostTypeId = @intCostTypeId
				, r.intMarginById = @intMarginById
				, r.dblMargin = @dblMargin
				, r.dblDiscount = @dblDiscount
				, r.intMarginUOMId = @intUnitMeasureId
				, r.intOneLinePrintId = @intOneLinePrintId
				, r.dtmLastModified = GETUTCDATE()
				, r.intLastModifiedUserId = @intUserId
				, r.dtmValidFrom = @dtmValidFrom
				, r.dtmValidTo = @dtmValidTo
				, r.intRecipeTypeId = @intRecipeTypeId
				, r.intConcurrencyId = 1 + ISNULL(r.intConcurrencyId, 1)
				 , r.guiApiUniqueId = @guiApiUniqueId
				 , r.intRowNumber = @intRowNumber
			FROM tblMFRecipe r
			WHERE r.intRecipeId = @intRecipeId

			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, strAction, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Recipe'
				, strValue = @strRecipeName
				, strLogLevel = 'Warning'
				, strStatus = 'Success'
				, strAction = 'Update'
				, intRowNo = @intRowNumber
				, strMessage = 'The Recipe "' + @strRecipeName + '" was updated.'
		END
	END

	FETCH NEXT FROM cur INTO
		  @strRecipeName
		, @strItemNo
		, @dblQuantity
		, @strUOM
		, @strLocationName
		, @intVersionNo
		, @strRecipeType
		, @strManufacturingProcess
		, @strCustomer
		, @strFarm
		, @strCostType
		, @strMarginBy
		, @dblMargin
		, @dblDiscount
		, @strOneLinePrint
		, @dtmValidFrom
		, @dtmValidTo
		, @intItemId
		, @intItemUOMId
		, @intCompanyLocationId
		, @intRecipeTypeId
		, @intManufacturingProcessId
		, @intCostTypeId
		, @intMarginById
		, @intUnitMeasureId
		, @intOneLinePrintId
		, @intCustomerId
		, @intFarmFieldId
		, @intRowNumber
END

CLOSE cur
DEALLOCATE cur

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Recipe'
    , strValue = r.strName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = r.intRowNumber
    , strMessage = 'The recipe ' + ISNULL(r.strName, '') + ' was imported successfully.'
FROM tblMFRecipe r
WHERE r.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblMFRecipe
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId

