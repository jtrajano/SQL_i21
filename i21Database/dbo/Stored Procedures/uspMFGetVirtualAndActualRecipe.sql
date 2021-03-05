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

	SELECT intRowNumber
		,intVirtualRecipeId
		,intVirtualRecipeItemId
		,intVirtualItemId
		,intActualRecipeId
		,intActualRecipeItemId
		,intActualItemId
		,strVirtualOutputItemNo
		,strVirtualInputItemNo
		,strActualOutputItemNo
		,strActualInputItemNo
		,dblVirtualPercentage
		,dblActualPercentage
		,(
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN dblVirtualBasis
				ELSE SUM(dblVirtualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) AS dblVirtualBasis
		,(
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN dblActualBasis
				ELSE SUM(dblActualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) AS dblActualBasis
		,(
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN NULL
				ELSE SUM(dblVirtualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) - (
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN NULL
				ELSE SUM(dblActualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) dblMargin
		,dblCost1
		,dblCost2
		,dblCost3
		,dblCost4
		,dblCost5
		,(
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN NULL
				ELSE SUM(dblVirtualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) + ISNULL(dblCost1, 0) + ISNULL(dblCost2, 0) + ISNULL(dblCost3, 0) + ISNULL(dblCost4, 0) + ISNULL(dblCost5, 0) dblVirtualTotalCost
		,(
			CASE 
				WHEN intRecipeItemTypeId = 1
					THEN NULL
				ELSE SUM(dblActualBasis) OVER (
						PARTITION BY intVirtualRecipeId
						,intActualRecipeId
						)
				END
			) AS dblActualTotalCost
		,intRecipeItemTypeId
		,'' AS strItemProductType
	FROM (
		SELECT ROW_NUMBER() OVER (
				ORDER BY VRI.intRecipeId
					,VRI.intRecipeItemId
				) intRowNumber
			,VRI.intRecipeId AS intVirtualRecipeId
			,VRI.intRecipeItemId AS intVirtualRecipeItemId
			,VRI.intItemId AS intVirtualItemId
			,ARI.intRecipeId AS intActualRecipeId
			,ARI.intRecipeItemId AS intActualRecipeItemId
			,ARI.intItemId AS intActualItemId
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
			,C.dblCost1 AS dblCost1
			,C.dblCost2 AS dblCost2
			,C.dblCost3 AS dblCost3
			,C.dblCost4 AS dblCost4
			,C.dblCost5 AS dblCost5
			,ISNULL(VRI.intRecipeItemTypeId, ARI.intRecipeItemTypeId) AS intRecipeItemTypeId
		FROM dbo.tblMFVirtualRecipeMap VA
		JOIN dbo.tblMFRecipeItem VRI ON VRI.intRecipeId = VA.intVirtualRecipeId
		JOIN dbo.tblICItem VI ON VI.intItemId = VRI.intItemId
		FULL OUTER JOIN dbo.tblMFRecipeItem ARI ON ARI.intRecipeId = VA.intRecipeId
			AND ARI.intItemId = VRI.intItemId
		LEFT JOIN dbo.tblICItem AI ON AI.intItemId = ARI.intItemId
		LEFT JOIN @MarketBasis VB ON VB.intItemId = VI.intItemId
		LEFT JOIN @MarketBasis AB ON AB.intItemId = AI.intItemId
		LEFT JOIN @Cost C ON C.intRecipeId = VA.intVirtualRecipeId
			AND C.intItemId = ISNULL(VI.intItemId, AI.intItemId)
		WHERE VA.intVirtualRecipeId IN (
				SELECT Item COLLATE Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strVirtualRecipe, ',')
				)
		) AS DT
	ORDER BY ISNULL(DT.intVirtualRecipeId, DT.intActualRecipeId)
		,DT.intRecipeItemTypeId DESC
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
