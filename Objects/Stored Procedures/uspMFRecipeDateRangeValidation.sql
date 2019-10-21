CREATE PROCEDURE uspMFRecipeDateRangeValidation @intItemId INT
	,@intLocationId INT
	,@intCustomerId INT
	,@dtmFromDate DATETIME
	,@dtmToDate DATETIME = NULL
	,@intRecipeId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strVersionNo NVARCHAR(MAX)

IF ISNULL(@intRecipeId, 0) = 0 -- New Mode
BEGIN
	SELECT @strVersionNo = COALESCE(@strVersionNo + ',', '') + CONVERT(NVARCHAR, intVersionNo)
	FROM tblMFRecipe
	WHERE intItemId = (
			CASE 
				WHEN @intItemId > 0
					THEN @intItemId
				ELSE intItemId
				END
			)
		AND intCustomerId = (
			CASE 
				WHEN @intItemId > 0
					THEN intCustomerId
				ELSE @intCustomerId
				END
			)
		AND intLocationId = @intLocationId
		AND (
			(
				ISNULL(@dtmFromDate, GETDATE()) BETWEEN dtmValidFrom
					AND ISNULL(dtmValidTo, '9999-12-31')
				)
			OR (
				@dtmToDate BETWEEN dtmValidFrom
					AND ISNULL(dtmValidTo, '9999-12-31')
				)
			OR (
				dtmValidFrom BETWEEN ISNULL(@dtmFromDate, GETDATE())
					AND ISNULL(@dtmToDate, '9999-12-31')
				)
			OR (
				dtmValidTo BETWEEN ISNULL(@dtmFromDate, GETDATE())
					AND ISNULL(@dtmToDate, '9999-12-31')
				)
			)
END
ELSE -- Edit Mode
BEGIN
	SELECT @strVersionNo = COALESCE(@strVersionNo + ',', '') + CONVERT(NVARCHAR, intVersionNo)
	FROM tblMFRecipe
	WHERE intItemId = (
			CASE 
				WHEN @intItemId > 0
					THEN @intItemId
				ELSE intItemId
				END
			)
		AND intCustomerId = (
			CASE 
				WHEN @intItemId > 0
					THEN intCustomerId
				ELSE @intCustomerId
				END
			)
		AND intLocationId = @intLocationId
		AND (
			(
				ISNULL(@dtmFromDate, GETDATE()) BETWEEN dtmValidFrom
					AND ISNULL(dtmValidTo, '9999-12-31')
				)
			OR (
				@dtmToDate BETWEEN dtmValidFrom
					AND ISNULL(dtmValidTo, '9999-12-31')
				)
			OR (
				dtmValidFrom BETWEEN ISNULL(@dtmFromDate, GETDATE())
					AND ISNULL(@dtmToDate, '9999-12-31')
				)
			OR (
				dtmValidTo BETWEEN ISNULL(@dtmFromDate, GETDATE())
					AND ISNULL(@dtmToDate, '9999-12-31')
				)
			)
		AND intRecipeId <> @intRecipeId
END

SELECT @strVersionNo
