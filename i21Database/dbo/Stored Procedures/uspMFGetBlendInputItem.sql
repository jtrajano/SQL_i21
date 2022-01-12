CREATE PROCEDURE uspMFGetBlendInputItem (
	@intLocationId INT
	,@intItemId INT
	,@dblQtyToProduce NUMERIC(18, 6)
	,@intQtyItemUOMId INT
	,@intInputItemId INT = NULL
	)
AS
BEGIN
	DECLARE @intDayOfYear INT
	DECLARE @dtmDate DATETIME
	DECLARE @intRecipeId INT

	SELECT @dtmDate = Convert(DATE, GetDate())

	SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

	SELECT @intRecipeId = intRecipeId
	FROM tblMFRecipe
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

	IF @intInputItemId IS NULL
	BEGIN
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) dblQty
			,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblLowerToleranceQty
			,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblUpperToleranceQty
			,u.strUnitMeasure AS strUOM
			,ri.intRecipeItemId
			,@intRecipeId AS intRecipeId
			,ri.intItemId AS intTaskId
			,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), (ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)))) + ' ' + u.strUnitMeasure + '<br />' AS strTask
			,i.strItemNo
			,i.strDescription
			,iu.intItemUOMId
			,iu.strLongUPCCode
			,iu.strUpcCode AS strShortUpcCode
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure u ON iu.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblICItem i ON ri.intItemId = i.intItemId
			AND i.strType <> 'Other Charge'
		WHERE r.intRecipeId = @intRecipeId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND NOT EXISTS (
				SELECT 1
				FROM tblMFWODetail WOD
				WHERE WOD.intItemId = ri.intItemId
					AND WOD.ysnProcessed = 0
					AND WOD.intTransactionTypeId = 8
				)
		
		UNION
		
		SELECT rs.intSubstituteItemId
			,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity))
			,(rs.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblLowerToleranceQty
			,(rs.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblUpperToleranceQty
			,u.strUnitMeasure
			,rs.intRecipeItemId
			,@intRecipeId
			,rs.intSubstituteItemId AS intTaskId
			,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), (rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)))) + ' ' + u.strUnitMeasure + '<br />' AS strTask
			,i.strItemNo
			,i.strDescription
			,iu.intItemUOMId
			,iu.strLongUPCCode
			,iu.strUpcCode AS strShortUpcCode
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		JOIN tblICItemUOM iu ON rs.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure u ON iu.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblICItem i ON rs.intSubstituteItemId = i.intItemId
		WHERE r.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1
			AND NOT EXISTS (
				SELECT 1
				FROM tblMFWODetail WOD
				WHERE WOD.intItemId = rs.intSubstituteItemId
					AND WOD.ysnProcessed = 0
					AND WOD.intTransactionTypeId = 8
				)
	END
	ELSE
	BEGIN
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) dblQty
			,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblLowerToleranceQty
			,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblUpperToleranceQty
			,u.strUnitMeasure AS strUOM
			,ri.intRecipeItemId
			,@intRecipeId AS intRecipeId
			,ri.intItemId AS intTaskId
			,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), (ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)))) + ' ' + u.strUnitMeasure + '<br />' AS strTask
			,i.strItemNo
			,i.strDescription
			,iu.intItemUOMId
			,iu.strLongUPCCode
			,iu.strUpcCode AS strShortUpcCode
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure u ON iu.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblICItem i ON ri.intItemId = i.intItemId
			AND i.strType <> 'Other Charge'
		WHERE r.intRecipeId = @intRecipeId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND NOT EXISTS (
				SELECT 1
				FROM tblMFWODetail WOD
				WHERE WOD.intItemId = ri.intItemId
					AND WOD.ysnProcessed = 0
					AND WOD.intTransactionTypeId = 8
				)
			AND ri.intItemId = @intInputItemId
		
		UNION
		
		SELECT rs.intSubstituteItemId
			,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity))
			,(rs.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblLowerToleranceQty
			,(rs.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblUpperToleranceQty
			,u.strUnitMeasure
			,rs.intRecipeItemId
			,@intRecipeId
			,rs.intSubstituteItemId AS intTaskId
			,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), (rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)))) + ' ' + u.strUnitMeasure + '<br />' AS strTask
			,i.strItemNo
			,i.strDescription
			,iu.intItemUOMId
			,iu.strLongUPCCode
			,iu.strUpcCode AS strShortUpcCode
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		JOIN tblICItemUOM iu ON rs.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure u ON iu.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblICItem i ON rs.intSubstituteItemId = i.intItemId
		WHERE r.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1
			AND NOT EXISTS (
				SELECT 1
				FROM tblMFWODetail WOD
				WHERE WOD.intItemId = rs.intSubstituteItemId
					AND WOD.ysnProcessed = 0
					AND WOD.intTransactionTypeId = 8
				)
			AND rs.intSubstituteItemId = @intInputItemId
	END
END
