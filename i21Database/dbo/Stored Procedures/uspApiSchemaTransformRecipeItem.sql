CREATE PROCEDURE [dbo].[uspApiSchemaTransformRecipeItem] (
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER
)

AS

-- Retrieve Properties
DECLARE @OverwriteExisting BIT = 1
DECLARE @MinOneInputItemRequired BIT = 0

SELECT
    @OverwriteExisting = ISNULL(CAST(OverwriteExisting AS BIT), 0),
    @MinOneInputItemRequired = ISNULL(CAST(MinOneInputItemRequired AS BIT), 0)
FROM (
	SELECT tp.strPropertyName, tp.varPropertyValue
	FROM tblApiSchemaTransformProperty tp
	WHERE tp.guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		OverwriteExisting,
        MinOneInputItemRequired
	)
) AS PivotTable

-- Validations
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Recipe Name'
    , strValue = sr.strRecipeName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Recipe Name ' + ISNULL(sr.strRecipeName, '') + ' does not exists. The Recipe Item ' + 
        ISNULL(sr.strRecipeItemNo, '') + ' cannot be added.'
FROM tblApiSchemaRecipeItem sr
LEFT JOIN tblMFRecipe r ON r.strName = sr.strRecipeName
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND r.intRecipeId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Version No'
    , strValue = sr.intVersionNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Version No' + ISNULL(CAST(sr.intVersionNo AS NVARCHAR(50)), '') + ' is invalid.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.intVersionNo = 0

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
FROM tblApiSchemaRecipeItem sr
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.strType NOT IN ('Other Charge', 'Comment')
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
FROM tblApiSchemaRecipeItem sr
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = sr.strUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.strType NOT IN ('Other Charge', 'Comment')
AND u.intUnitMeasureId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Recipe Item Type'
    , strValue = sr.strRecipeItemType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Invalid Recipe Item Type (Valid values: INPUT, OUTPUT).'
FROM tblApiSchemaRecipeItem sr
LEFT JOIN tblMFRecipeItemType rt ON rt.strName = sr.strRecipeItemType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND rt.intRecipeItemTypeId IS NULL
AND NULLIF(sr.strRecipeItemType, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Upper Tolerance'
    , strValue = CAST(sr.dblUpperTolerance AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Upper Tolerance cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblUpperTolerance < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Lower Tolerance'
    , strValue = CAST(sr.dblLowerTolerance AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Lower Tolerance cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblLowerTolerance < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Shrinkage'
    , strValue = CAST(sr.dblShrinkage AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Shrinkage cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblShrinkage < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Consumption Method'
    , strValue = sr.strConsumptionMethod
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Consumption Method ' + ISNULL(sr.strConsumptionMethod, '') + ' is not valid. Valid values are: By Lot, By Location, FIFO, None.'
FROM tblApiSchemaRecipeItem sr
LEFT JOIN tblMFConsumptionMethod cm ON cm.strName = sr.strConsumptionMethod
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND cm.intConsumptionMethodId IS NULL
AND NULLIF(sr.strConsumptionMethod, '') IS NOT NULL

IF @MinOneInputItemRequired = 0
BEGIN
    INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
    SELECT
        NEWID()
        , guiApiImportLogId = @guiLogId
        , strField = 'Storage Location'
        , strValue = sr.strStorageLocation
        , strLogLevel = 'Error'
        , strStatus = 'Failed'
        , intRowNo = sr.intRowNumber
        , strMessage = 'The Storage Location ' + ISNULL(sr.strStorageLocation, '') + ' is not valid.'
    FROM tblApiSchemaRecipeItem sr
    LEFT JOIN tblICStorageLocation sl ON sl.strName = sr.strStorageLocation
    WHERE sr.guiApiUniqueId = @guiApiUniqueId
    AND sl.intStorageLocationId IS NULL
    AND NULLIF(sr.strStorageLocation, '') IS NOT NULL
END

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Scrap'
    , strValue = CAST(sr.dblScrap AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Scarp cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblScrap < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Cost Allocation'
    , strValue = CAST(sr.dblCostAllocationPercentage AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Cost Allocation Percentage cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblCostAllocationPercentage < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Margin By'
    , strValue = sr.strMarginBy
    , strLogLevel = 'Error'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Margin By ' + ISNULL(sr.strMarginBy, '') + ' is not valid.'
FROM tblApiSchemaRecipeItem sr
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
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Margin cannot be negative.'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblMargin < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Comment Type'
    , strValue = sr.strCommentType
    , strLogLevel = 'Error'
    , strStatus = 'Ignored'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Comment Type ' + ISNULL(sr.strCommentType, '') + ' is not valid.'
FROM tblApiSchemaRecipeItem sr
LEFT JOIN tblMFCommentType ct ON ct.strName = sr.strCommentType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND ct.intCommentTypeId IS NULL
AND NULLIF(sr.strCommentType, '') IS NOT NULL

--Set Default Values
UPDATE sr
SET sr.strRecipeItemType = 'INPUT'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strRecipeItemType, '') IS NULL

UPDATE sr
SET sr.strConsumptionMethod = 'By Lot'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strConsumptionMethod, '') IS NULL
AND sr.strRecipeItemType = 'INPUT'

UPDATE sr
SET sr.strCommentType = 'General'
FROM tblApiSchemaRecipeItem sr
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strCommentType, '') IS NULL
AND i.strType = 'Comment'

UPDATE sr
SET sr.strDescription = i.strDescription
FROM tblApiSchemaRecipeItem sr
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strDescription, '') IS NULL
AND i.strType = 'Comment'

UPDATE sr
SET sr.dblQuantity = 0, sr.strUOM = NULL
FROM tblApiSchemaRecipeItem sr
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.strType IN ('Other Charge', 'Comment')

UPDATE sr
SET sr.strMarginBy = 'Amount'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND NULLIF(sr.strMarginBy, '') IS NULL
AND sr.dblMargin > 0

UPDATE sr
SET sr.dtmValidFrom = CONVERT(VARCHAR, YEAR(GETDATE())) + '-01-01'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dtmValidFrom IS NULL

UPDATE sr
SET sr.dtmValidTo = CONVERT(VARCHAR, YEAR(GETDATE())) + '-12-31'
FROM tblApiSchemaRecipeItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dtmValidTo IS NULL

-- Transform Data
DECLARE @intRecipeItemId INT
DECLARE @intUserId INT = 1

DECLARE @intRecipeId INT
DECLARE @strRecipeName  NVARCHAR(100)
DECLARE @intItemId INT
DECLARE @strItemNo NVARCHAR(100)
DECLARE @strDescription NVARCHAR(50)
DECLARE @dblQuantity NUMERIC(18, 6)
DECLARE @dblCalculatedQuantity NUMERIC(18, 6)
DECLARE @intItemUOMId INT
DECLARE @intRecipeItemTypeId INT
DECLARE @strReceipItemType NVARCHAR(50)
DECLARE @strItemGroupName NVARCHAR(50)
DECLARE @dblUpperTolerance NUMERIC(18, 6)
DECLARE @dblLowerTolerance NUMERIC(18, 6)
DECLARE @dblCalculatedUpperTolerance NUMERIC(18, 6)
DECLARE @dblCalculatedLowerTolerance NUMERIC(18, 6)
DECLARE @dblShrinkage NUMERIC(18, 6)
DECLARE @ysnScaled BIT
DECLARE @intConsumptionMethodId INT
DECLARE @intStorageLocationId INT
DECLARE @dtmValidFrom DATETIME
DECLARE @dtmValidTo DATETIME
DECLARE @ysnYearValidationRequired BIT
DECLARE @ysnMinorIngredient BIT
DECLARE @ysnOutputItemMandatory BIT
DECLARE @dblScrap NUMERIC(18, 6)
DECLARE @ysnConsumptionRequired BIT
DECLARE @dblCostAllocationPercentage NUMERIC(18, 6)
DECLARE @intMarginById INT
DECLARE @dblMargin NUMERIC(18, 6)
DECLARE @ysnCostAppliedAtInvoice BIT
DECLARE @intCommentTypeId INT
DECLARE @strDocumentNo NVARCHAR(50)
DECLARE @intSequenceNo INT
DECLARE @ysnPartialFillConsumption BIT
DECLARE @intRowNumber INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
      r.intRecipeId
	, sr.strRecipeName
	, i.intItemId
    , i.strItemNo
	, CASE WHEN ct.intCommentTypeId > 0 THEN sr.strDescription ELSE '' END
	, sr.dblQuantity
	, CASE WHEN sr.strRecipeItemType = 'OUTPUT' THEN 0 
      ELSE dbo.fnMFCalculateRecipeItemQuantity(
        rt.intRecipeItemTypeId, sr.dblQuantity, ISNULL(sr.dblShrinkage, 0))
      END
    , ium.intItemUOMId
    , rt.intRecipeItemTypeId
    , rt.strName
    , sr.strItemGroupName
    , sr.dblUpperTolerance
    , sr.dblLowerTolerance
    , dbo.fnMFCalculateRecipeItemUpperTolerance(r.intRecipeTypeId, 
        sr.dblQuantity, ISNULL(sr.dblShrinkage, 0), ISNULL(sr.dblUpperTolerance, 0))
    , dbo.fnMFCalculateRecipeItemLowerTolerance(r.intRecipeTypeId, 
        sr.dblQuantity, ISNULL(sr.dblShrinkage, 0), ISNULL(sr.dblLowerTolerance, 0))
    , ISNULL(sr.dblShrinkage, 0)
    , ISNULL(sr.ysnScaled, 0)
    , CASE WHEN i.strType IN ('Other Charge', 'Comment') THEN 4 ELSE cm.intConsumptionMethodId END
    , sl.intStorageLocationId
    , sr.dtmValidFrom
    , sr.dtmValidTo
    , ISNULL(sr.ysnYearValidationRequired, 0)
    , ISNULL(sr.ysnMinorIngredient, 0)
    , ISNULL(sr.ysnOutputItemMandatory, 0)
    , ISNULL(sr.dblScrap, 0)
    , CASE WHEN i.intItemId = ih.intItemId THEN 1 ELSE ISNULL(sr.ysnConsumptionRequired, 0) END
    , ISNULL(sr.ysnConsumptionRequired, 0)
    , m.intMarginById
    , sr.dblMargin
    , ISNULL(sr.ysnCostAppliedAtInvoice, 0)
    , ct.intCommentTypeId
    , sr.strDocumentNo
    , NULL
    , ISNULL(sr.ysnPartialFillConsumption, 0)
	, MIN(sr.intRowNumber)
FROM tblApiSchemaRecipeItem sr
JOIN tblMFRecipe r ON r.strName = sr.strRecipeName
LEFT JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
LEFT JOIN tblICItem ih ON ih.strItemNo = sr.strRecipeHeaderItemNo
LEFT JOIN tblICUnitMeasure um ON um.strUnitMeasure = sr.strUOM
LEFT JOIN tblICItemUOM ium ON ium.intItemId = i.intItemId
    AND ium.intUnitMeasureId = um.intUnitMeasureId
LEFT JOIN tblMFRecipeItemType rt ON rt.strName = sr.strRecipeItemType
LEFT JOIN tblMFConsumptionMethod cm ON cm.strName = sr.strConsumptionMethod
LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = sr.strLocationName
LEFT JOIN tblICStorageLocation sl ON sl.strName = sr.strStorageLocation
    AND sl.intLocationId = cl.intCompanyLocationId
LEFT JOIN tblMFMarginBy m ON m.strName = sr.strMarginBy
LEFT JOIN tblMFCommentType ct ON ct.strName = sr.strCommentType
WHERE sr.guiApiUniqueId = @guiApiUniqueId
GROUP BY
      r.intRecipeId
    , sr.strRecipeName
    , i.intItemId
    , i.strItemNo
    , ct.intCommentTypeId
    , sr.strDescription
    , sr.dblQuantity
    , sr.strRecipeItemType
    , rt.intRecipeItemTypeId
    , sr.dblShrinkage
    , ium.intItemUOMId
    , rt.strName
    , sr.strItemGroupName
    , sr.dblUpperTolerance
    , sr.dblLowerTolerance
    , r.intRecipeTypeId
    , sr.ysnScaled
    , i.strType
    , cm.intConsumptionMethodId
    , sl.intStorageLocationId
    , sr.dtmValidFrom
    , sr.dtmValidTo
    , sr.ysnYearValidationRequired
    , sr.ysnMinorIngredient
    , sr.ysnOutputItemMandatory
    , sr.dblScrap
    , ih.intItemId
    , sr.ysnConsumptionRequired
    , m.intMarginById
    , sr.dblMargin
    , sr.ysnCostAppliedAtInvoice
    , sr.strDocumentNo
    , sr.ysnPartialFillConsumption

OPEN cur

FETCH NEXT FROM cur INTO
      @intRecipeId
    , @strRecipeName
	, @intItemId
    , @strItemNo
    , @strDescription
    , @dblQuantity
    , @dblCalculatedQuantity
    , @intItemUOMId
    , @intRecipeItemTypeId
    , @strReceipItemType
    , @strItemGroupName
    , @dblUpperTolerance
    , @dblLowerTolerance
    , @dblCalculatedUpperTolerance
    , @dblCalculatedLowerTolerance
    , @dblShrinkage
    , @ysnScaled
    , @intConsumptionMethodId
    , @intStorageLocationId
    , @dtmValidFrom
    , @dtmValidTo
    , @ysnYearValidationRequired
    , @ysnMinorIngredient
    , @ysnOutputItemMandatory
    , @dblScrap
    , @ysnConsumptionRequired
    , @dblCostAllocationPercentage
    , @intMarginById
    , @dblMargin
    , @ysnCostAppliedAtInvoice
    , @intCommentTypeId
    , @strDocumentNo
    , @intSequenceNo
    , @ysnPartialFillConsumption
    , @intRowNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @intRecipeItemId = intRecipeItemId 
    FROM tblMFRecipeItem
    WHERE intRecipeId = @intRecipeId
    AND intItemId = @intItemId
    AND intRecipeItemTypeId = @intRecipeItemTypeId

	IF @OverwriteExisting = 0
	BEGIN
		IF @intRecipeItemId IS NOT NULL
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Recipe Item No'
				, strValue = @strItemNo
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'The Recipe Item No "' + @strItemNo + '" already exists in ' + @strRecipeName + ' recipe.'
		END
	END
	
	IF @intRecipeItemId IS NULL
	BEGIN		
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
			, intConcurrencyId
            , guiApiUniqueId
            , intRowNumber)
		SELECT
			  intRecipeId                       = @intRecipeId
			, intItemId                         = @intItemId
			, strDescription                    = @strDescription
			, dblQuantity                       = ISNULL(@dblQuantity, 0)
			, dblCalculatedQuantity             = ISNULL(@dblCalculatedQuantity, 0)
			, intItemUOMId                      = @intItemUOMId
			, intRecipeItemTypeId               = @intRecipeItemTypeId
			, strItemGroupName                  = @strItemGroupName
			, dblUpperTolerance                 = ISNULL(@dblUpperTolerance, 0)
			, dblLowerTolerance                 = ISNULL(@dblLowerTolerance, 0)
			, dblCalculatedUpperTolerance       = ISNULL(@dblCalculatedUpperTolerance, 0)
			, dblCalculatedLowerTolerance       = ISNULL(@dblCalculatedLowerTolerance, 0)
			, dblShrinkage                      = ISNULL(@dblShrinkage, 0)
			, ysnScaled                         = @ysnScaled
			, intConsumptionMethodId            = @intConsumptionMethodId
			, intStorageLocationId              = @intStorageLocationId
			, dtmValidFrom                      = @dtmValidFrom
			, dtmValidTo                        = @dtmValidTo
			, ysnYearValidationRequired         = @ysnYearValidationRequired
			, ysnMinorIngredient                = @ysnMinorIngredient
			, ysnOutputItemMandatory            = @ysnOutputItemMandatory
			, dblScrap                          = ISNULL(@dblScrap, 0)
			, ysnConsumptionRequired            = @ysnConsumptionRequired
			, dblCostAllocationPercentage       = ISNULL(@dblCostAllocationPercentage, 0)
			, intMarginById                     = @intMarginById
			, dblMargin                         = ISNULL(@dblMargin, 0)
			, ysnCostAppliedAtInvoice           = @ysnCostAppliedAtInvoice
			, intCommentTypeId                  = @intCommentTypeId
			, strDocumentNo                     = @strDocumentNo
			, intSequenceNo                     = @intSequenceNo
			, ysnPartialFillConsumption         = @ysnPartialFillConsumption
			, intCreatedUserId                  = @intUserId
			, dtmCreated                        = GETUTCDATE()
			, intLastModifiedUserId             = @intUserId
			, dtmLastModified                   = GETUTCDATE()
			, intConcurrencyId                  = 1
            , guiApiUniqueId                    = @guiApiUniqueId
            , intRowNumber                      = @intRowNumber
	END
	ELSE
	BEGIN
		IF @OverwriteExisting = 1
		BEGIN
			UPDATE r
			SET   r.intRecipeId                       = @intRecipeId
				, r.intItemId                         = @intItemId
				, r.strDescription                    = @strDescription
				, r.dblQuantity                       = ISNULL(@dblQuantity, 0)
				, r.dblCalculatedQuantity             = ISNULL(@dblCalculatedQuantity, 0)
				, r.intItemUOMId                      = @intItemUOMId
				, r.intRecipeItemTypeId               = @intRecipeItemTypeId
				, r.strItemGroupName                  = @strItemGroupName
				, r.dblUpperTolerance                 = ISNULL(@dblUpperTolerance, 0)
				, r.dblLowerTolerance                 = ISNULL(@dblLowerTolerance, 0)
				, r.dblCalculatedUpperTolerance       = ISNULL(@dblCalculatedUpperTolerance, 0)
				, r.dblCalculatedLowerTolerance       = ISNULL(@dblCalculatedLowerTolerance, 0)
				, r.dblShrinkage                      = ISNULL(@dblShrinkage, 0)
				, r.ysnScaled                         = @ysnScaled
				, r.intConsumptionMethodId            = @intConsumptionMethodId
				, r.intStorageLocationId              = @intStorageLocationId
				, r.dtmValidFrom                      = @dtmValidFrom
				, r.dtmValidTo                        = @dtmValidTo
				, r.ysnYearValidationRequired         = @ysnYearValidationRequired
				, r.ysnMinorIngredient                = @ysnMinorIngredient
				, r.ysnOutputItemMandatory            = @ysnOutputItemMandatory
				, r.dblScrap                          = ISNULL(@dblScrap, 0)
				, r.ysnConsumptionRequired            = @ysnConsumptionRequired
				, r.dblCostAllocationPercentage       = ISNULL(@dblCostAllocationPercentage, 0)
				, r.intMarginById                     = @intMarginById
				, r.dblMargin                         = ISNULL(@dblMargin, 0)
				, r.ysnCostAppliedAtInvoice           = @ysnCostAppliedAtInvoice
				, r.intCommentTypeId                  = @intCommentTypeId
				, r.strDocumentNo                     = @strDocumentNo
				, r.intSequenceNo                     = @intSequenceNo
				, r.ysnPartialFillConsumption         = @ysnPartialFillConsumption
				, r.intLastModifiedUserId             = @intUserId
				, r.dtmLastModified                   = GETUTCDATE()
				, r.intConcurrencyId                  = 1 + ISNULL(r.intConcurrencyId, 1)
				, r.guiApiUniqueId                    = @guiApiUniqueId
				, r.intRowNumber                      = @intRowNumber
			FROM tblMFRecipeItem r
			WHERE r.intRecipeItemId = @intRecipeItemId

			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, strAction, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Recipe Item'
				, strValue = @strItemNo
				, strLogLevel = 'Warning'
				, strStatus = 'Success'
				, strAction = 'Update'
				, intRowNo = @intRowNumber
				, strMessage = 'The Recipe Item "' + @strItemNo + '" was updated in ' + @strRecipeName + ' recipe.'
		END
	END

    UPDATE r
    SET r.ysnActive = 1
    FROM tblMFRecipe r
    JOIN tblMFRecipeItem ri ON ri.intRecipeId = r.intRecipeId
        AND ri.intRecipeItemTypeId = 1
    WHERE r.intRecipeId = @intRecipeId
    AND r.ysnActive = 0

	FETCH NEXT FROM cur INTO
          @intRecipeId
		, @strRecipeName
		, @intItemId
		, @strItemNo
        , @strDescription
        , @dblQuantity
        , @dblCalculatedQuantity
        , @intItemUOMId
        , @intRecipeItemTypeId
        , @strReceipItemType
        , @strItemGroupName
        , @dblUpperTolerance
        , @dblLowerTolerance
        , @dblCalculatedUpperTolerance
        , @dblCalculatedLowerTolerance
        , @dblShrinkage
        , @ysnScaled
        , @intConsumptionMethodId
        , @intStorageLocationId
        , @dtmValidFrom
        , @dtmValidTo
        , @ysnYearValidationRequired
        , @ysnMinorIngredient
        , @ysnOutputItemMandatory
        , @dblScrap
        , @ysnConsumptionRequired
        , @dblCostAllocationPercentage
        , @intMarginById
        , @dblMargin
        , @ysnCostAppliedAtInvoice
        , @intCommentTypeId
        , @strDocumentNo
        , @intSequenceNo
        , @ysnPartialFillConsumption
        , @intRowNumber
END

CLOSE cur
DEALLOCATE cur

-- Execute post script
EXEC dbo.uspApiSchemaTransformRecipeFinalize

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Recipe Item'
    , strValue = i.strItemNo
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = ri.intRowNumber
    , strMessage = 'The Recipe Item ' + ISNULL(i.strItemNo, '') +
        ' was imported successfully to ' + ISNULL(r.strName, '') + ' recipe.'
FROM tblMFRecipeItem ri
JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
JOIN tblICItem i ON i.intItemId = r.intItemId
WHERE ri.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblMFRecipe
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId

