CREATE PROCEDURE uspMFGetVirtualAndActualRecipe @strVirtualRecipe NVARCHAR(MAX)
	,@strMarketBasisXML NVARCHAR(MAX)
	,@strCostXML NVARCHAR(MAX) = NULL
	,@intCurrencyId INT = NULL
	,@intUnitMeasureId INT = NULL
	,@intLocationId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @MarketBasis TABLE (
		intItemId INT
		,dblTotalCost NUMERIC(18, 6)
		)
	DECLARE @Cost TABLE (
		intRecipeId INT
		,intItemId INT
		,dblCost1 NUMERIC(18, 6)
		,dblCost2 NUMERIC(18, 6)
		,dblCost3 NUMERIC(18, 6)
		,dblCost4 NUMERIC(18, 6)
		,dblCost5 NUMERIC(18, 6)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strMarketBasisXML

	DELETE
	FROM @MarketBasis

	INSERT INTO @MarketBasis (
		intItemId
		,dblTotalCost
		)
	SELECT intItemId
		,dblTotalCost
	FROM OPENXML(@idoc, 'root/MarketBasis', 2) WITH (
			intItemId INT
			,dblTotalCost NUMERIC(18, 6)
			)

	EXEC sp_xml_removedocument @idoc

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strCostXML

	DELETE
	FROM @Cost

	INSERT INTO @Cost (
		intRecipeId
		,intItemId
		,dblCost1
		,dblCost2
		,dblCost3
		,dblCost4
		,dblCost5
		)
	SELECT intRecipeId
		,intItemId
		,dblCost1
		,dblCost2
		,dblCost3
		,dblCost4
		,dblCost5
	FROM OPENXML(@idoc, 'root/Cost', 2) WITH (
			intRecipeId INT
			,intItemId INT
			,dblCost1 NUMERIC(18, 6)
			,dblCost2 NUMERIC(18, 6)
			,dblCost3 NUMERIC(18, 6)
			,dblCost4 NUMERIC(18, 6)
			,dblCost5 NUMERIC(18, 6)
			)

	EXEC sp_xml_removedocument @idoc

	SELECT ROW_NUMBER() OVER (
			ORDER BY VRI.intRecipeId
				,VRI.intRecipeItemId
			) intRowNumber
		,VRI.intRecipeId AS intVirtualRecipeId
		,VRI.intRecipeItemId AS intVirtualRecipeItemId
		,ARI.intRecipeId AS intActualRecipeId
		,ARI.intRecipeItemId AS intActualRecipeItemId
		,CASE 
			WHEN VRI.intRecipeItemTypeId = 2
				THEN VI.strItemNo
			ELSE NULL
			END AS strVirtualOutputItemNo
		,CASE 
			WHEN VRI.intRecipeItemTypeId = 1
				THEN VI.strItemNo
			ELSE NULL
			END AS strVirtualInputItemNo
		,CASE 
			WHEN ARI.intRecipeItemTypeId = 2
				THEN AI.strItemNo
			ELSE NULL
			END AS strActualOutputItemNo
		,CASE 
			WHEN ARI.intRecipeItemTypeId = 1
				THEN AI.strItemNo
			ELSE NULL
			END AS strActualInputItemNo
		,VRI.dblCalculatedQuantity AS dblVirtualPercentage
		,ARI.dblCalculatedQuantity AS dblActualPercentage
		,VB.dblTotalCost * VRI.dblCalculatedQuantity / 100 AS dblVirtualBasis
		,AB.dblTotalCost * ARI.dblCalculatedQuantity / 100 AS dblActualBasis
		,(VB.dblTotalCost * VRI.dblCalculatedQuantity / 100) - (AB.dblTotalCost * ARI.dblCalculatedQuantity / 100) AS dblMargin
		,C.dblCost1 AS dblCost1
		,C.dblCost2 AS dblCost2
		,C.dblCost3 AS dblCost3
		,C.dblCost4 AS dblCost4
		,C.dblCost5 AS dblCost5
		,(VB.dblTotalCost * VRI.dblCalculatedQuantity / 100) + IsNULL(C.dblCost1, 0) + IsNULL(C.dblCost2, 0) + IsNULL(C.dblCost3, 0) + IsNULL(C.dblCost4, 0) + IsNULL(C.dblCost5, 0) AS dblVirtualTotalCost
		,(AB.dblTotalCost * ARI.dblCalculatedQuantity / 100) AS dblActualTotalCost
	FROM tblMFVirtualRecipeMap VA
	JOIN tblMFRecipeItem VRI ON VRI.intRecipeId = VA.intVirtualRecipeId
	JOIN tblICItem VI ON VI.intItemId = VRI.intItemId
	FULL OUTER JOIN tblMFRecipeItem ARI ON ARI.intRecipeId = VA.intRecipeId
		AND ARI.intItemId = VRI.intItemId
	LEFT JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
	LEFT JOIN @MarketBasis VB ON VB.intItemId = VI.intItemId
	LEFT JOIN @MarketBasis AB ON AB.intItemId = AI.intItemId
	LEFT JOIN @Cost C ON C.intRecipeId = VA.intVirtualRecipeId
		AND C.intItemId = ISNULL(VI.intItemId, AI.intItemId)
END TRY

BEGIN CATCH
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
