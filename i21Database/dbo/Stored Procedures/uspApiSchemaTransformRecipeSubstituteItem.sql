CREATE PROCEDURE [dbo].[uspApiSchemaTransformRecipeSubstituteItem] (
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
FROM tblApiSchemaRecipeSubstituteItem sr
LEFT JOIN tblMFRecipe r ON r.strName = sr.strRecipeName
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND r.intRecipeId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Substitute Ratio'
    , strValue = CAST(sr.dblSubstituteRatio AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Substitute Ratio cannot be negative.'
FROM tblApiSchemaRecipeSubstituteItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblSubstituteRatio < 0

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Max Substitute Ratio'
    , strValue = CAST(sr.dblMaxSubstituteRatio AS NVARCHAR(50))
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Max Substitute Ratio cannot be negative.'
FROM tblApiSchemaRecipeSubstituteItem sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND sr.dblMaxSubstituteRatio < 0

-- Transform Data
DECLARE @intRecipeSubstituteItemId INT
DECLARE @intUserId INT = 1

DECLARE @intRecipeId INT
DECLARE @strRecipeName  NVARCHAR(100)
DECLARE @intRecipeItemId INT
DECLARE @intRecipeItemItemId INT
DECLARE @strRecipeItemItemNo NVARCHAR(100)
DECLARE @intSubstituteItemId INT
DECLARE @strSubstituteItemNo NVARCHAR(100)
DECLARE @dblSubstituteRatio NUMERIC(38, 20)
DECLARE @dblMaxSubstituteRatio NUMERIC(38, 20)
DECLARE @dblCalculatedQuantity NUMERIC(38, 20)
DECLARE @dblUpperTolerance NUMERIC(38, 20)
DECLARE @dblLowerTolerance NUMERIC(38, 20)
DECLARE @intInputItemUOMId INT
DECLARE @intLocationId INT
DECLARE @intRowNumber INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
      COALESCE(productionRecipe.intRecipeId, virtualRecipe.intRecipeId)
	, sr.strRecipeName
	, ri.intRecipeItemId as intRecipeItemId
    , i.intItemId as intRecipeItemItemId
    , i.strItemNo as strRecipeItemItemNo
    , si.intItemId as intSubstituteItemId
    , si.strItemNo as intSubstituteItemNo
	, sr.dblSubstituteRatio
	, sr.dblMaxSubstituteRatio
    , ri.dblCalculatedQuantity
    , ri.dblUpperTolerance
    , ri.dblLowerTolerance
    , uom.intItemUOMId
    , c.intCompanyLocationId
	, MIN(sr.intRowNumber)
FROM tblApiSchemaRecipeSubstituteItem sr
JOIN tblSMCompanyLocation c ON c.strLocationName = sr.strLocationName
JOIN tblICItem recipeItem ON recipeItem.strItemNo = sr.strRecipeHeaderItemNo
OUTER APPLY (
    SELECT TOP 1 intRecipeId
    FROM tblMFRecipe
    WHERE intItemId = recipeItem.intItemId
        AND intLocationId = c.intCompanyLocationId
) productionRecipe
OUTER APPLY (
    SELECT TOP 1 intRecipeId
    FROM tblMFRecipe
    WHERE strName = sr.strRecipeName
        AND intLocationId = c.intCompanyLocationId
) virtualRecipe
JOIN tblICItem i ON i.strItemNo = sr.strRecipeItemNo
JOIN tblMFRecipeItem ri ON ri.intRecipeId = COALESCE(productionRecipe.intRecipeId, virtualRecipe.intRecipeId)
    AND ri.intItemId = i.intItemId
JOIN tblICItem si ON si.strItemNo = sr.strSubstituteItemNo
CROSS APPLY (
    SELECT TOP 1 x3.intItemUOMId
    FROM tblICItemUOM x1
    JOIN tblICUnitMeasure x2 ON x1.intUnitMeasureId = x2.intUnitMeasureId
    JOIN tblICItemUOM x3 ON x3.intUnitMeasureId = x1.intUnitMeasureId
        AND x3.intItemId = si.intItemId
    WHERE x1.intItemUOMId = ri.intItemUOMId
) uom
WHERE sr.guiApiUniqueId = @guiApiUniqueId
GROUP BY
      COALESCE(productionRecipe.intRecipeId, virtualRecipe.intRecipeId)
    , ri.intRecipeItemId
    , si.intItemId
    , i.intItemId
    , si.strItemNo
    , i.strItemNo
    , ri.dblCalculatedQuantity
    , ri.dblLowerTolerance
    , ri.dblUpperTolerance
    , uom.intItemUOMId
    , sr.strRecipeName
    , sr.strSubstituteItemNo
    , sr.dblSubstituteRatio
	, sr.dblMaxSubstituteRatio
    , c.intCompanyLocationId

OPEN cur

FETCH NEXT FROM cur INTO
      @intRecipeId
    , @strRecipeName
	, @intRecipeItemId
    , @intRecipeItemItemId
    , @strRecipeItemItemNo
    , @intSubstituteItemId
    , @strSubstituteItemNo
    , @dblSubstituteRatio
    , @dblMaxSubstituteRatio
    , @dblCalculatedQuantity
    , @dblUpperTolerance
    , @dblLowerTolerance
    , @intInputItemUOMId
    , @intLocationId
    , @intRowNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @intRecipeSubstituteItemId = intRecipeItemId 
    FROM tblMFRecipeSubstituteItem
    WHERE intRecipeId = @intRecipeId
        AND intRecipeItemId = @intRecipeItemId
        AND intSubstituteItemId = @intSubstituteItemId

	IF @OverwriteExisting = 0
	BEGIN
		IF @intRecipeSubstituteItemId IS NOT NULL
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Substitute Item No'
				, strValue = @strSubstituteItemNo
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'The Substitute Item No "' + @strSubstituteItemNo + '" already exists in ' + @strRecipeName + ' recipe.'
		END
	END

	IF @intRecipeSubstituteItemId IS NULL
	BEGIN		
		INSERT INTO tblMFRecipeSubstituteItem (
			  intRecipeItemId
            , intRecipeId
            , intItemId
            , intSubstituteItemId
            , dblQuantity
            , intItemUOMId
            , dblSubstituteRatio
            , dblMaxSubstituteRatio
            , dblCalculatedUpperTolerance
            , dblCalculatedLowerTolerance
            , intRecipeItemTypeId
            , intCreatedUserId
            , dtmCreated
            , intLastModifiedUserId
            , dtmLastModified
            , intConcurrencyId
            , guiApiUniqueId
            , intRowNumber)
		SELECT
			  intRecipeItemId                   = @intRecipeItemId
            , intRecipeId                       = @intRecipeId
            , intItemId                         = @intRecipeItemItemId
            , intSubstituteItemId               = @intSubstituteItemId
            , dblQuantity                       = dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio)
            , intItemUOMId                      = @intInputItemUOMId
            , dblSubstituteRatio                = @dblSubstituteRatio
            , dblMaxSubstituteRatio             = @dblMaxSubstituteRatio
            , dblCalculatedUpperTolerance       = dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio), @dblUpperTolerance)
            , dblCalculatedLowerTolerance       = dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio), @dblLowerTolerance)
            , intRecipeItemTypeId               = 1
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
            SET  r.dblQuantity                      = dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio)
                , r.dblSubstituteRatio              = @dblSubstituteRatio
                , r.dblMaxSubstituteRatio           = @dblMaxSubstituteRatio
                , r.dblCalculatedUpperTolerance     = dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio), @dblUpperTolerance)
                , r.dblCalculatedLowerTolerance     = dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblCalculatedQuantity, @dblSubstituteRatio, @dblMaxSubstituteRatio), @dblLowerTolerance)
				, r.intLastModifiedUserId             = @intUserId
				, r.dtmLastModified                   = GETUTCDATE()
				, r.intConcurrencyId                  = 1 + ISNULL(r.intConcurrencyId, 1)
				, r.guiApiUniqueId                    = @guiApiUniqueId
				, r.intRowNumber                      = @intRowNumber
			FROM tblMFRecipeSubstituteItem r
			WHERE r.intRecipeSubstituteItemId = @intRecipeSubstituteItemId

			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, strAction, intRowNo, strMessage)
			SELECT
				NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = 'Substitute Item'
				, strValue = @strSubstituteItemNo
				, strLogLevel = 'Warning'
				, strStatus = 'Success'
				, strAction = 'Update'
				, intRowNo = @intRowNumber
				, strMessage = 'The Substitute Item "' + @strSubstituteItemNo + '" was updated in ' + @strRecipeName + ' recipe.'
		END
	END

	FETCH NEXT FROM cur INTO
        @intRecipeId
        , @strRecipeName
        , @intRecipeItemId
        , @intRecipeItemItemId
        , @strRecipeItemItemNo
        , @intSubstituteItemId
        , @strSubstituteItemNo
        , @dblSubstituteRatio
        , @dblMaxSubstituteRatio
        , @dblCalculatedQuantity
        , @dblUpperTolerance
        , @dblLowerTolerance
        , @intInputItemUOMId
        , @intLocationId
        , @intRowNumber
END

CLOSE cur
DEALLOCATE cur

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Substitute Item'
    , strValue = i.strItemNo
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = si.intRowNumber
    , strMessage = 'The Substitute Item ' + ISNULL(i.strItemNo, '') +
        ' was imported successfully to ' + ISNULL(r.strName, '') + ' recipe.'
FROM tblMFRecipeSubstituteItem si
LEFT JOIN tblMFRecipe r ON r.intRecipeId = si.intRecipeId
LEFT JOIN tblICItem i ON i.intItemId = si.intItemId
WHERE si.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblMFRecipe
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId

