﻿CREATE PROCEDURE uspMFGenerateDemand (
	@intInvPlngReportMasterID INT = NULL
	,@ExistingDataXML NVARCHAR(MAX) = NULL
	,@MaterialKeyXML NVARCHAR(MAX) = NULL
	,@intMonthsToView INT = 12
	,@ysnIncludeInventory BIT = 1
	,@intCompanyLocationId INT = NULL
	,@intUnitMeasureId INT
	,@intDemandHeaderId INT
	,@ysnTest BIT = 0
	,@ysnAllItem BIT = 0
	,@intCategoryId INT
	,@PlannedPurchasesXML VARCHAR(MAX) = NULL
	,@WeeksOfSupplyTargetXML VARCHAR(MAX) = NULL
	,@ForecastedConsumptionXML VARCHAR(MAX) = NULL
	,@OpenPurchaseXML VARCHAR(MAX) = NULL
	,@ysnCalculatePlannedPurchases BIT = 0
	,@ysnCalculateEndInventory BIT = 0
	,@ysnRefreshContract BIT = 0
	,@ysnRefreshStock BIT = 0
	,@strRefreshItemStock NVARCHAR(MAX) = ''
	,@ShortExcessXML VARCHAR(MAX) = NULL
	)
AS
BEGIN TRY
	DECLARE @dtmStartOfMonth DATETIME
		,@ysnFGDemand BIT
		,@intCurrentMonth INT
		,@intMonthId INT = 1
		,@intReportMasterID INT
		,@idoc INT
		,@dtmDate DATETIME
		,@intPrevInvPlngReportMasterID INT
		,@ysnWeekOfSupply BIT = 0
		,@ysnCalculateNoOfContainerByBagQty BIT = 0
		,@intContainerTypeId INT
		--,@strContainerType NVARCHAR(50) 
		,@intItemId INT
		,@dblEndInventory NUMERIC(18, 6)
		,@intConsumptionMonth INT
		,@dblConsumptionQty NUMERIC(18, 6)
		,@dblWeeksOfSsupply NUMERIC(18, 6)
		,@ysnSupplyTargetbyAverage BIT
		,@strSupplyTarget NVARCHAR(50)
		,@intNoofWeeksorMonthstoCalculateSupplyTarget INT
		,@intNoofWeekstoCalculateSupplyTargetbyAverage INT
		,@ysnComputeDemandUsingRecipe BIT
		,@ysnDisplayDemandWithItemNoAndDescription BIT
		,@ysnDemandViewForBlend BIT
		,@strContainerType NVARCHAR(50)
		,@ysnDisplayRestrictedBookInDemandView BIT
		,@dblRemainingConsumptionQty NUMERIC(18, 6)
		,@dblSupplyTarget NUMERIC(18, 6)
		,@dblDecimalPart NUMERIC(18, 6)
		,@intIntegerPart INT
		,@dblTotalConsumptionQty NUMERIC(18, 6)
		,@intConsumptionAvlMonth INT
		,@intPrevUnitMeasureId INT
		,@intBookId INT
		,@intSubBookId INT
		,@intDemandAnalysisMonthlyCutOffDay INT
	DECLARE @tblMFContainerWeight TABLE (
		intItemId INT
		,dblWeight NUMERIC(18, 6)
		,intWeightUnitMeasureId INT
		)
	DECLARE @tblMFItemBook TABLE (
		intId INT identity(1, 1)
		,intItemId INT
		,strBook NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		)
	DECLARE @intItemBookId INT
		,@intId INT
		,@strBook NVARCHAR(MAX)
	DECLARE @tblMFItem TABLE (
		intItemId INT
		,intMainItemId INT
		)
	DECLARE @tblMFEndInventory TABLE (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		)
	DECLARE @tblMFItemDetail TABLE (
		intItemId INT
		,intMainItemId INT
		,ysnSpecificItemDescription BIT
		,dblRatio NUMERIC(18, 6)
		)

	SELECT @intContainerTypeId = intContainerTypeId
		,@ysnCalculateNoOfContainerByBagQty = ysnCalculateNoOfContainerByBagQty
		,@ysnSupplyTargetbyAverage = ysnSupplyTargetbyAverage
		,@strSupplyTarget = strSupplyTarget
		,@intNoofWeeksorMonthstoCalculateSupplyTarget = IsNULL(intNoofWeeksorMonthstoCalculateSupplyTarget, 3)
		,@intNoofWeekstoCalculateSupplyTargetbyAverage = IsNULL(intNoofWeekstoCalculateSupplyTargetbyAverage, 13)
		,@ysnComputeDemandUsingRecipe = ysnComputeDemandUsingRecipe
		,@ysnDisplayDemandWithItemNoAndDescription = ysnDisplayDemandWithItemNoAndDescription
		,@ysnDisplayRestrictedBookInDemandView = IsNULL(ysnDisplayRestrictedBookInDemandView, 0)
		,@intDemandAnalysisMonthlyCutOffDay = (Case When IsNULL(intDemandAnalysisMonthlyCutOffDay, 0)=0 then 32 Else intDemandAnalysisMonthlyCutOffDay End)
	FROM tblMFCompanyPreference

	SELECT @strContainerType = strContainerType
	FROM tblLGContainerType
	WHERE intContainerTypeId = @intContainerTypeId

	SELECT @ysnDemandViewForBlend = ysnDemandViewForBlend
	FROM tblCTCompanyPreference

	IF @intNoofWeekstoCalculateSupplyTargetbyAverage = 0
		SELECT @intNoofWeekstoCalculateSupplyTargetbyAverage = 13

	IF OBJECT_ID('tempdb..#TempOpenPurchase') IS NOT NULL
		DROP TABLE #TempOpenPurchase

	CREATE TABLE #TempOpenPurchase (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	IF OBJECT_ID('tempdb..#TempPlannedPurchases') IS NOT NULL
		DROP TABLE #TempPlannedPurchases

	CREATE TABLE #TempPlannedPurchases (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	IF OBJECT_ID('tempdb..#TempForecastedConsumption') IS NOT NULL
		DROP TABLE #TempForecastedConsumption

	CREATE TABLE #TempForecastedConsumption (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	IF OBJECT_ID('tempdb..#TempShortExcess') IS NOT NULL
		DROP TABLE #TempShortExcess

	CREATE TABLE #TempShortExcess (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	IF OBJECT_ID('tempdb..#TempFinalShortExcess') IS NOT NULL
		DROP TABLE #TempFinalShortExcess

	CREATE TABLE #TempFinalShortExcess (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	IF OBJECT_ID('tempdb..#TempWeeksOfSupplyTarget') IS NOT NULL
		DROP TABLE #TempWeeksOfSupplyTarget

	CREATE TABLE #TempWeeksOfSupplyTarget (
		[intItemId] INT
		,[strName] NVARCHAR(50)
		,[strValue] DECIMAL(24, 6)
		)

	SELECT @intReportMasterID = intReportMasterID
	FROM tblCTReportMaster
	WHERE strReportName = 'Inventory Planning Report'

	IF @intInvPlngReportMasterID > 0
	BEGIN
		SELECT @dtmDate = dtmDate
		FROM tblCTInvPlngReportMaster
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

		SELECT @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, @dtmDate), 0)

		SELECT @intCurrentMonth = DATEDIFF(mm, 0, @dtmDate)
	END
	ELSE
	BEGIN
		SELECT @dtmDate = GETDATE()

		SELECT @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, @dtmDate), 0)

		SELECT @intCurrentMonth = DATEDIFF(mm, 0, @dtmDate)
	END

	SELECT @intBookId = intBookId
		,@intSubBookId = intSubBookId
	FROM tblMFDemandHeader
	WHERE intDemandHeaderId = @intDemandHeaderId

	--To get a previously saved demand view
	IF @intBookId = 0
		OR @intBookId IS NULL
	BEGIN
		SELECT TOP 1 @intPrevInvPlngReportMasterID = intInvPlngReportMasterID
		FROM tblCTInvPlngReportMaster
		WHERE ysnPost = 1
			AND dtmDate <= @dtmDate
			AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
		ORDER BY intInvPlngReportMasterID DESC
	END
	ELSE
	BEGIN
		IF @intSubBookId = 0
			OR @intSubBookId IS NULL
		BEGIN
			SELECT TOP 1 @intPrevInvPlngReportMasterID = intInvPlngReportMasterID
			FROM tblCTInvPlngReportMaster
			WHERE ysnPost = 1
				AND dtmDate <= @dtmDate
				AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
				AND intBookId = @intBookId
			ORDER BY intInvPlngReportMasterID DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @intPrevInvPlngReportMasterID = intInvPlngReportMasterID
			FROM tblCTInvPlngReportMaster
			WHERE ysnPost = 1
				AND dtmDate <= @dtmDate
				AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
				AND intBookId = @intBookId
				AND intSubBookId = @intSubBookId
			ORDER BY intInvPlngReportMasterID DESC
		END
	END

	IF @intCompanyLocationId IS NULL
		SELECT @intCompanyLocationId = 0

	IF @MaterialKeyXML <> ''
	BEGIN
		IF @ysnAllItem = 0
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@MaterialKeyXML

			INSERT INTO @tblMFItem (intItemId)
			SELECT intItemId
			FROM OPENXML(@idoc, 'root/Material', 2) WITH (intItemId INT)

			EXEC sp_xml_removedocument @idoc
		END
		ELSE
		BEGIN
			INSERT INTO @tblMFItem (intItemId)
			SELECT I.intItemId
			FROM tblICItem I
			WHERE I.intCategoryId = @intCategoryId
				AND NOT EXISTS (
					SELECT *
					FROM tblMFItemExclude IE
					WHERE IE.intItemId = I.intItemId
						AND IE.ysnExcludeInDemandView = 1
						AND NOT EXISTS (
							SELECT *
							FROM tblMFDemandDetail DD
							WHERE IE.intItemId = IsNULL(DD.intSubstituteItemId, DD.intItemId)
								AND DD.intDemandHeaderId = @intDemandHeaderId
							)
					)
		END
	END

	IF @ysnDemandViewForBlend = 1
	BEGIN
		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT DISTINCT R.intItemId
			,RI.intItemId
			,0
			,RI.dblCalculatedQuantity / (
				CASE 
					WHEN R.intRecipeTypeId = 1
						THEN R.dblQuantity
					ELSE 1
					END
				)
		FROM @tblMFItem I
		JOIN tblMFRecipeItem RI ON RI.intItemId = I.intItemId
			AND RI.intRecipeItemTypeId = 1
		JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
			AND R.ysnActive = 1
			AND ISNULL(R.intLocationId, 0) = (
				CASE 
					WHEN @intCompanyLocationId = 0
						THEN ISNULL(R.intLocationId, 0)
					ELSE @intCompanyLocationId
					END
				)
			--IF EXISTS (
			--		SELECT *
			--		FROM @tblMFItem I
			--		WHERE NOT EXISTS (
			--				SELECT *
			--				FROM @tblMFItemDetail ID
			--				WHERE ID.intItemId = I.intItemId
			--				)
			--		)
			--BEGIN
			--	RAISERROR (
			--			'There is no matching recipe found.'
			--			,16
			--			,1
			--			,'WITH NOWAIT'
			--			)
			--	RETURN
			--END
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT DISTINCT DD.intSubstituteItemId
			,DD.intItemId
			,1
			,1
		FROM @tblMFItem I
		JOIN tblMFDemandDetail DD ON I.intItemId = DD.intSubstituteItemId
		WHERE DD.intDemandHeaderId = @intDemandHeaderId

		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT DISTINCT DD.intItemId
			,DD.intItemId
			,0
			,1
		FROM @tblMFItem I
		JOIN tblMFDemandDetail DD ON I.intItemId = DD.intSubstituteItemId
		WHERE DD.intDemandHeaderId = @intDemandHeaderId
			AND NOT EXISTS (
				SELECT *
				FROM @tblMFItemDetail FI
				WHERE FI.intItemId = DD.intItemId
				)

		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT DISTINCT DD.intSubstituteItemId
			,DD.intItemId
			,1
			,1
		FROM @tblMFItem I
		JOIN tblMFDemandDetail DD ON I.intItemId = DD.intItemId
		WHERE DD.intDemandHeaderId = @intDemandHeaderId
			AND DD.intSubstituteItemId IS NOT NULL

		INSERT INTO @tblMFItem (intItemId)
		SELECT ID.intItemId
		FROM @tblMFItemDetail ID
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblMFItem I
				WHERE I.intItemId = ID.intItemId
				)

		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT IB.intBundleItemId
			,IB.intItemId
			,0
			,1
		FROM @tblMFItem I
		LEFT JOIN tblICItemBundle IB ON IB.intItemId = I.intItemId
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblMFItemDetail FI
				WHERE FI.intItemId = IB.intBundleItemId
				)
			AND IB.intBundleItemId IS NOT NULL

		INSERT INTO @tblMFItemDetail (
			intItemId
			,intMainItemId
			,ysnSpecificItemDescription
			,dblRatio
			)
		SELECT intItemId
			,intItemId
			,(
				CASE 
					WHEN EXISTS (
							SELECT 1
							FROM tblICItemBundle IB
							WHERE IB.intItemId = I.intItemId
							)
						THEN 0
					ELSE 1
					END
				)
			,1
		FROM @tblMFItem I
		WHERE NOT EXISTS (
				SELECT *
				FROM @tblMFItemDetail ID
				WHERE ID.intItemId = I.intItemId
				)

		INSERT INTO @tblMFContainerWeight (
			intItemId
			,dblWeight
			,intWeightUnitMeasureId
			)
		SELECT ID.intMainItemId
			,AVG((
					CASE 
						WHEN @ysnCalculateNoOfContainerByBagQty = 1
							THEN CTCQ.dblWeight
						ELSE CTCQ.dblBulkQuantity
						END
					) * IsNULL(UMCByWeight.dblConversionToStock, 1))
			,MIN(CASE 
					WHEN @ysnCalculateNoOfContainerByBagQty = 1
						THEN CTCQ.intWeightUnitMeasureId
					ELSE CT.intWeightUnitMeasureId
					END)
		FROM @tblMFItemDetail ID
		JOIN tblICItem I ON I.intItemId = ID.intItemId
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
			AND CA.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CTCQ.intCommodityAttributeId = I.intOriginId
			AND CTCQ.intCommodityId = I.intCommodityId
			AND CTCQ.intContainerTypeId = @intContainerTypeId
			AND CA.intDefaultPackingUOMId = CTCQ.intUnitMeasureId
		LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CTCQ.intContainerTypeId
		LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = (
				CASE 
					WHEN @ysnCalculateNoOfContainerByBagQty = 1
						THEN CTCQ.intWeightUnitMeasureId
					ELSE CT.intWeightUnitMeasureId
					END
				) --From Unit
			AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId -- To Unit
		WHERE ID.ysnSpecificItemDescription = 0
			AND ID.intItemId <> ID.intMainItemId
		GROUP BY ID.intMainItemId

		INSERT INTO @tblMFContainerWeight (
			intItemId
			,dblWeight
			,intWeightUnitMeasureId
			)
		SELECT DISTINCT ID.intItemId
			,(
				CASE 
					WHEN @ysnCalculateNoOfContainerByBagQty = 1
						THEN CTCQ.dblWeight
					ELSE CTCQ.dblBulkQuantity
					END
				) * IsNULL(UMCByWeight.dblConversionToStock, 1)
			,(
				CASE 
					WHEN @ysnCalculateNoOfContainerByBagQty = 1
						THEN CTCQ.intWeightUnitMeasureId
					ELSE CT.intWeightUnitMeasureId
					END
				)
		FROM @tblMFItemDetail ID
		JOIN tblICItem I ON I.intItemId = ID.intItemId
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
		LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CTCQ.intCommodityAttributeId = I.intOriginId
			AND CTCQ.intCommodityId = I.intCommodityId
			AND CTCQ.intContainerTypeId = @intContainerTypeId
			AND CA.intDefaultPackingUOMId = CTCQ.intUnitMeasureId
		LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CTCQ.intContainerTypeId
		LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = (
				CASE 
					WHEN @ysnCalculateNoOfContainerByBagQty = 1
						THEN CTCQ.intWeightUnitMeasureId
					ELSE CT.intWeightUnitMeasureId
					END
				) --From Unit
			AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId -- To Unit
		WHERE ID.ysnSpecificItemDescription = 1
	END

	DELETE
	FROM @tblMFContainerWeight
	WHERE dblWeight IS NULL

	UPDATE I
	SET I.intMainItemId = ID.intMainItemId
	FROM @tblMFItem I
	JOIN @tblMFItemDetail ID ON ID.intItemId = I.intItemId --and I.intItemId<>ID.intMainItemId

	IF @ysnDisplayRestrictedBookInDemandView = 1
	BEGIN
		INSERT INTO @tblMFItemBook (intItemId)
		SELECT DISTINCT intItemId
		FROM @tblMFItem
		WHERE intItemId <> IsNULL(intMainItemId, intItemId)

		SELECT @intId = MIN(intId)
		FROM @tblMFItemBook

		WHILE @intId IS NOT NULL
		BEGIN
			SELECT @intItemBookId = NULL
				,@strBook = ''

			SELECT @intItemBookId = intItemId
			FROM @tblMFItemBook
			WHERE intId = @intId

			SELECT @strBook = @strBook + strBook + ','
			FROM tblCTBook B
			WHERE NOT EXISTS (
					SELECT intBookId
					FROM tblICItemBook IB
					WHERE IB.intItemId = @intItemBookId
						AND IB.intBookId = B.intBookId
					)

			IF @strBook IS NULL
				SELECT @strBook = ''

			IF len(@strBook) > 0
			BEGIN
				SELECT @strBook = left(@strBook, Len(@strBook) - 1)

				UPDATE @tblMFItemBook
				SET strBook = @strBook
				WHERE intId = @intId
			END

			SELECT @intId = MIN(intId)
			FROM @tblMFItemBook
			WHERE intId > @intId
		END
	END

	IF @OpenPurchaseXML <> ''
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@OpenPurchaseXML

		INSERT INTO #TempOpenPurchase (
			[intItemId]
			,[strName]
			,[strValue]
			)
		SELECT [intItemId]
			,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/OP', 2) WITH (
				[intItemId] INT
				,[Name] NVARCHAR(50)
				,[Value] DECIMAL(24, 6)
				)

		EXEC sp_xml_removedocument @idoc
	END

	IF @PlannedPurchasesXML <> ''
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@PlannedPurchasesXML

		INSERT INTO #TempPlannedPurchases (
			[intItemId]
			,[strName]
			,[strValue]
			)
		SELECT [intItemId]
			,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/PP', 2) WITH (
				[intItemId] INT
				,[Name] NVARCHAR(50)
				,[Value] DECIMAL(24, 6)
				)

		EXEC sp_xml_removedocument @idoc
	END

	IF @ForecastedConsumptionXML <> ''
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@ForecastedConsumptionXML

		INSERT INTO #TempForecastedConsumption (
			[intItemId]
			,[strName]
			,[strValue]
			)
		SELECT [intItemId]
			,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
			,- SUM([Value])
		FROM OPENXML(@idoc, 'root/FC', 2) WITH (
				[intItemId] INT
				,[Name] NVARCHAR(50)
				,[Value] DECIMAL(24, 6)
				)
		GROUP BY [intItemId]
			,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0')

		EXEC sp_xml_removedocument @idoc
	END

	--IF @ShortExcessXML <> ''
	--	AND @ysnCalculatePlannedPurchases = 1
	--BEGIN
	--	EXEC sp_xml_preparedocument @idoc OUTPUT
	--		,@ShortExcessXML
	--	INSERT INTO #TempShortExcess (
	--		[intItemId]
	--		,[strName]
	--		,[strValue]
	--		)
	--	SELECT [intItemId]
	--		,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
	--		,[Value]
	--	FROM OPENXML(@idoc, 'root/SE', 2) WITH (
	--			[intItemId] INT
	--			,[Name] NVARCHAR(50)
	--			,[Value] DECIMAL(24, 6)
	--			)
	--	WHERE [Value] < 0
	--	INSERT INTO #TempFinalShortExcess (
	--		[intItemId]
	--		,[strName]
	--		,[strValue]
	--		)
	--	SELECT DT.[intItemId]
	--		,DT.[strName]
	--		,CASE 
	--			WHEN IsNULL(CW.dblWeight, 0) <> 0
	--				THEN Floor(DT.strValue / CW.dblWeight) * CW.dblWeight
	--			ELSE DT.strValue
	--			END
	--	FROM (
	--		SELECT [intItemId]
	--			,[strName]
	--			,[strValue] - IsNULL((
	--					SELECT TOP 1 [strValue]
	--					FROM #TempShortExcess b
	--					WHERE b.intItemId = a.intItemId
	--						AND b.strName < a.strName
	--					ORDER BY b.strName DESC
	--					), 0) [strValue]
	--		FROM #TempShortExcess a
	--		) AS DT
	--	LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = DT.intItemId
	--	EXEC sp_xml_removedocument @idoc
	--END
	IF @WeeksOfSupplyTargetXML <> ''
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@WeeksOfSupplyTargetXML

		INSERT INTO #TempWeeksOfSupplyTarget (
			[intItemId]
			,[strName]
			,[strValue]
			)
		SELECT [intItemId]
			,Replace(Replace([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/WST', 2) WITH (
				[intItemId] INT
				,[Name] NVARCHAR(50)
				,[Value] DECIMAL(24, 6)
				)

		EXEC sp_xml_removedocument @idoc
	END

	IF OBJECT_ID('tempdb..#tblMFDemand') IS NOT NULL
		DROP TABLE #tblMFDemand

	CREATE TABLE #tblMFDemand (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intAttributeId INT
		,intMonthId INT
		)

	--IF OBJECT_ID('tempdb..#tblMFContractDetail') IS NOT NULL
	--	DROP TABLE #tblMFContractDetail

	--CREATE TABLE #tblMFContractDetail (intContractDetailId INT)

	IF OBJECT_ID('tempdb..#tblMFDemandList') IS NOT NULL
		DROP TABLE #tblMFDemandList

	CREATE TABLE #tblMFDemandList (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intAttributeId INT
		,intMonthId INT
		,intMainItemId INT
		)

	DECLARE @tblMFRefreshtemStock TABLE (intItemId INT)

	INSERT INTO @tblMFRefreshtemStock
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@strRefreshItemStock, ',')

	DELETE
	FROM @tblMFRefreshtemStock
	WHERE intItemId = 0

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFRefreshtemStock
			)
	BEGIN
		INSERT INTO @tblMFRefreshtemStock
		SELECT DISTINCT intItemId
		FROM @tblMFItemDetail
	END

	IF @ysnIncludeInventory = 1
	BEGIN
		IF @ysnRefreshStock = 1
		BEGIN
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END AS intItemId
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(L.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End)) * I.dblRatio) AS dblIntrasitQty
				,2 AS intAttributeId --Opening Inventory
				,- 1 AS intMonthId
			FROM @tblMFItemDetail I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = IsNULL(L.intWeightUOMId, L.intItemUOMId)
				AND ISNULL(L.intLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(L.intLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			WHERE EXISTS (
					SELECT *
					FROM @tblMFRefreshtemStock EI
					WHERE EI.intItemId = I.intItemId
					)
				AND IsNULL(L.intBookId, 0) = IsNULL(@intBookId, 0)
				AND IsNULL(L.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			GROUP BY CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT intItemId
				,CASE 
					WHEN strValue = ''
						THEN NULL
					ELSE strValue
					END --Opening Inventory
				,2
				,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
			FROM tblCTInvPlngReportAttributeValue AV
			WHERE intReportAttributeID = 2 --Opening Inventory
				AND intInvPlngReportMasterID = @intInvPlngReportMasterID
				AND NOT EXISTS (
					SELECT *
					FROM @tblMFRefreshtemStock EI
					WHERE EI.intItemId = AV.intItemId
					)
		END
		ELSE
		BEGIN
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT intItemId
				,CASE 
					WHEN strValue = ''
						THEN NULL
					ELSE strValue
					END --Opening Inventory
				,2
				,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 2 --Opening Inventory
				AND intInvPlngReportMasterID = @intInvPlngReportMasterID
		END
	END
	ELSE
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT I.intItemId
			,0
			,2 AS intAttributeId --Opening Inventory
			,- 1 AS intMonthId
		FROM @tblMFItem I
	END

	IF IsNULL(@ForecastedConsumptionXML, '') = ''
	BEGIN
		IF @ysnComputeDemandUsingRecipe = 1
		BEGIN
			WITH tblMFGetRecipeInputItem (
				intItemId
				,dblQuantity
				,intAttributeId
				,dtmDemandDate
				,intLevel
				,intMonthId
				)
			AS (
				SELECT IsNULL(DD.intSubstituteItemId, DD.intItemId)
					,Convert(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
					,8 AS intAttributeId --Forecasted Consumption
					,DD.dtmDemandDate
					,0 AS intLevel
					,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
				FROM tblMFDemandDetail DD
				JOIN tblMFRecipe R ON R.intItemId = DD.intItemId
					AND DD.intDemandHeaderId = @intDemandHeaderId
					AND R.ysnActive = 1
					AND ISNULL(R.intLocationId, 0) = (
						CASE 
							WHEN @intCompanyLocationId = 0
								THEN ISNULL(R.intLocationId, 0)
							ELSE @intCompanyLocationId
							END
						)
				JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId
					AND IU.intUnitMeasureId = @intUnitMeasureId
				WHERE intRecipeItemTypeId = 1
					AND (
						(
							RI.ysnYearValidationRequired = 1
							AND DD.dtmDemandDate BETWEEN RI.dtmValidFrom
								AND RI.dtmValidTo
							)
						OR (
							RI.ysnYearValidationRequired = 0
							AND DATEPART(dy, DD.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom)
								AND DATEPART(dy, RI.dtmValidTo)
							)
						)
					AND DD.dtmDemandDate >= @dtmStartOfMonth
				
				UNION ALL
				
				SELECT RI.intItemId
					,Convert(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * RII.dblQuantity)
					,8 AS intAttributeId --Forecasted Consumption
					,RII.dtmDemandDate
					,RII.intLevel + 1
					,DATEDIFF(mm, 0, RII.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
				FROM tblMFGetRecipeInputItem RII
				JOIN tblMFRecipe R ON R.intItemId = RII.intItemId
					AND R.ysnActive = 1
					AND ISNULL(R.intLocationId, 0) = (
						CASE 
							WHEN @intCompanyLocationId = 0
								THEN ISNULL(R.intLocationId, 0)
							ELSE @intCompanyLocationId
							END
						)
				JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				WHERE intRecipeItemTypeId = 1
					AND (
						(
							RI.ysnYearValidationRequired = 1
							AND RII.dtmDemandDate BETWEEN RI.dtmValidFrom
								AND RI.dtmValidTo
							)
						OR (
							RI.ysnYearValidationRequired = 0
							AND DATEPART(dy, RII.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom)
								AND DATEPART(dy, RI.dtmValidTo)
							)
						)
					AND RII.intLevel <= 5
				)
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT DISTINCT intItemId
				,- dblQuantity
				,intAttributeId
				,intMonthId
			FROM tblMFGetRecipeInputItem
		END
		ELSE
		BEGIN
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT IsNULL(DD.intSubstituteItemId, DD.intItemId)
				,- SUM(dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
				,8 AS intAttributeId --Forecasted Consumption
				,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON IsNULL(DD.intSubstituteItemId, DD.intItemId) = I.intItemId
				AND DD.intDemandHeaderId = @intDemandHeaderId
				AND IsNULL(DD.intCompanyLocationId, IsNULL(@intCompanyLocationId, 0)) = IsNULL(@intCompanyLocationId, IsNULL(DD.intCompanyLocationId, 0))
			JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId
			WHERE DD.dtmDemandDate >= @dtmStartOfMonth
			GROUP BY IsNULL(DD.intSubstituteItemId, DD.intItemId)
				,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth
		END
	END
	ELSE
	BEGIN
		/*MERGE #tblMFDemand AS target
		USING (
			SELECT intItemId
				,[strName]
				,[strValue]
			FROM #TempForecastedConsumption FC
			WHERE NOT EXISTS (
					SELECT *
					FROM @tblMFRefreshtemStock EI
					WHERE EI.intItemId = FC.intItemId
					)
			) AS source(intItemId, [strName], [strValue])
			ON (
					target.intItemId = source.intItemId
					AND target.intMonthId = source.[strName]
					AND target.intAttributeId = 8
					AND target.intMonthId > 0
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET target.dblQty = source.[strValue]
		WHEN NOT MATCHED
			THEN
				INSERT (
					intItemId
					,intMonthId
					,dblQty
					,intAttributeId
					)
				VALUES (
					source.intItemId
					,source.[strName]
					,source.[strValue]
					,8
					);

		IF @ysnComputeDemandUsingRecipe = 1
		BEGIN
			WITH tblMFGetRecipeInputItem (
				intItemId
				,dblQuantity
				,intAttributeId
				,dtmDemandDate
				,intLevel
				,intMonthId
				)
			AS (
				SELECT IsNULL(DD.intSubstituteItemId, DD.intItemId)
					,Convert(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
					,8 AS intAttributeId --Forecasted Consumption
					,DD.dtmDemandDate
					,0 AS intLevel
					,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
				FROM tblMFDemandDetail DD
				JOIN tblMFRecipe R ON R.intItemId = DD.intItemId
					AND DD.intDemandHeaderId = @intDemandHeaderId
					AND R.ysnActive = 1
					AND ISNULL(R.intLocationId, 0) = (
						CASE 
							WHEN @intCompanyLocationId = 0
								THEN ISNULL(R.intLocationId, 0)
							ELSE @intCompanyLocationId
							END
						)
				JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId
					AND IU.intUnitMeasureId = @intUnitMeasureId
				WHERE intRecipeItemTypeId = 1
					AND (
						(
							RI.ysnYearValidationRequired = 1
							AND DD.dtmDemandDate BETWEEN RI.dtmValidFrom
								AND RI.dtmValidTo
							)
						OR (
							RI.ysnYearValidationRequired = 0
							AND DATEPART(dy, DD.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom)
								AND DATEPART(dy, RI.dtmValidTo)
							)
						)
					AND DD.dtmDemandDate >= @dtmStartOfMonth
					AND EXISTS (
						SELECT *
						FROM @tblMFRefreshtemStock EI
						WHERE EI.intItemId = DD.intItemId
						)
				
				UNION ALL
				
				SELECT RI.intItemId
					,Convert(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * RII.dblQuantity)
					,8 AS intAttributeId --Forecasted Consumption
					,RII.dtmDemandDate
					,RII.intLevel + 1
					,DATEDIFF(mm, 0, RII.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
				FROM tblMFGetRecipeInputItem RII
				JOIN tblMFRecipe R ON R.intItemId = RII.intItemId
					AND R.ysnActive = 1
					AND ISNULL(R.intLocationId, 0) = (
						CASE 
							WHEN @intCompanyLocationId = 0
								THEN ISNULL(R.intLocationId, 0)
							ELSE @intCompanyLocationId
							END
						)
				JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				WHERE intRecipeItemTypeId = 1
					AND (
						(
							RI.ysnYearValidationRequired = 1
							AND RII.dtmDemandDate BETWEEN RI.dtmValidFrom
								AND RI.dtmValidTo
							)
						OR (
							RI.ysnYearValidationRequired = 0
							AND DATEPART(dy, RII.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom)
								AND DATEPART(dy, RI.dtmValidTo)
							)
						)
					AND RII.intLevel <= 5
				)
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT DISTINCT intItemId
				,- dblQuantity
				,intAttributeId
				,intMonthId
			FROM tblMFGetRecipeInputItem
		END
		ELSE
		BEGIN
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT IsNULL(DD.intSubstituteItemId, DD.intItemId)
				,- SUM(dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
				,8 AS intAttributeId --Forecasted Consumption
				,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON IsNULL(DD.intSubstituteItemId, DD.intItemId) = I.intItemId
				AND DD.intDemandHeaderId = @intDemandHeaderId
				AND IsNULL(DD.intCompanyLocationId, IsNULL(@intCompanyLocationId, 0)) = IsNULL(@intCompanyLocationId, IsNULL(DD.intCompanyLocationId, 0))
			JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId
			WHERE DD.dtmDemandDate >= @dtmStartOfMonth
				AND EXISTS (
					SELECT *
					FROM @tblMFRefreshtemStock EI
					WHERE EI.intItemId = I.intItemId
					)
					group by IsNULL(DD.intSubstituteItemId, DD.intItemId),DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth 
		END*/
		INSERT INTO #tblMFDemand (
			intItemId
			,intMonthId
			,dblQty
			,intAttributeId
			)
		SELECT intItemId
			,[strName]
			,[strValue]
			,8
		FROM #TempForecastedConsumption FC
			--WHERE EXISTS (
			--		SELECT *
			--		FROM @tblMFRefreshtemStock EI
			--		WHERE EI.intItemId = FC.intItemId
			--		)
	END

	IF IsNULL(@OpenPurchaseXML, '') = ''
	BEGIN
		IF @ysnRefreshContract = 1
		BEGIN
			--INSERT INTO #tblMFContractDetail (intContractDetailId)
			--SELECT SS.intContractDetailId
			--FROM tblLGLoad L
			--JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			--	AND L.intPurchaseSale = 1
			--	AND L.ysnPosted = 1
			--JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
			--JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
			--JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
			--JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
			--LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
			--WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
			--		CASE 
			--			WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
			--				THEN ISNULL(LDCL.dblReceivedQty, 0)
			--			ELSE LD.dblDeliveredQuantity
			--			END
			--		) > 0
			--	AND SS.intContractStatusId = 1
			--	AND ISNULL(SS.intCompanyLocationId, 0) = (
			--		CASE 
			--			WHEN @intCompanyLocationId = 0
			--				THEN ISNULL(SS.intCompanyLocationId, 0)
			--			ELSE @intCompanyLocationId
			--			END
			--		)
			--	AND IsNULL(SS.intBookId, 0) = IsNULL(@intBookId, 0)
			--	AND IsNULL(SS.intSubBookId, 0) = IsNULL(@intSubBookId, 0)

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END AS intItemId
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (SS.dblBalance-IsNULL(SS.dblScheduleQty,0))) * I.dblRatio) AS dblIntrasitQty
				,13 AS intAttributeId --Open Purchases
				,0 AS intMonthId
			FROM @tblMFItemDetail I
			JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
				AND ISNULL(SS.intCompanyLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(SS.intCompanyLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			WHERE SS.intContractStatusId IN (1,4)
				AND (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					) < @dtmStartOfMonth
				--AND NOT EXISTS (
				--	SELECT *
				--	FROM #tblMFContractDetail CD
				--	WHERE CD.intContractDetailId = SS.intContractDetailId
				--	)
				AND IsNULL(SS.intBookId, 0) = IsNULL(@intBookId, 0)
				AND IsNULL(SS.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			GROUP BY CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END

			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END AS intItemId
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (SS.dblBalance-IsNULL(SS.dblScheduleQty,0))) * I.dblRatio) AS dblIntrasitQty
				,13 AS intAttributeId --Open Purchases
				,DATEDIFF(mm, 0, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					)) + 1 - @intCurrentMonth AS intMonthId
			FROM @tblMFItemDetail I
			JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
				AND ISNULL(SS.intCompanyLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(SS.intCompanyLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			WHERE SS.intContractStatusId in (1,4)
				AND (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					) >= @dtmStartOfMonth
				--AND NOT EXISTS (
				--	SELECT *
				--	FROM #tblMFContractDetail CD
				--	WHERE CD.intContractDetailId = SS.intContractDetailId
				--	)
				AND IsNULL(SS.intBookId, 0) = IsNULL(@intBookId, 0)
				AND IsNULL(SS.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			GROUP BY datename(m, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					)) + ' ' + cast(datepart(yyyy, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					)) AS VARCHAR)
				,CASE 
					WHEN I.ysnSpecificItemDescription = 1
						THEN I.intItemId
					ELSE I.intMainItemId
					END
				,DATEDIFF(mm, 0, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					))
		END
		ELSE
		BEGIN
			INSERT INTO #tblMFDemand (
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				)
			SELECT intItemId
				,CASE 
					WHEN strValue = ''
						THEN NULL
					ELSE strValue
					END
				,13 --Open Purchases 
				,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 13 --Open Purchases 
				AND intInvPlngReportMasterID = @intInvPlngReportMasterID
		END
	END
	ELSE
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT intItemId
			,strValue
			,13 --Open Purchases 
			,[strName] AS intMonthId
		FROM #TempOpenPurchase
	END

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT CASE 
			WHEN I.ysnSpecificItemDescription = 1
				THEN I.intItemId
			ELSE I.intMainItemId
			END AS intItemId
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
					CASE 
						WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
							THEN ISNULL(LDCL.dblReceivedQty, 0)
						ELSE LD.dblDeliveredQuantity
						END
					)) * I.dblRatio) AS dblIntrasitQty
		,14 AS intAttributeId --In-transit Purchases
		,0 AS intMonthId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.ysnPosted = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
			CASE 
				WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
					THEN ISNULL(LDCL.dblReceivedQty, 0)
				ELSE LD.dblDeliveredQuantity
				END
			) > 0
		AND SS.intContractStatusId IN (1,4)
		AND ISNULL(SS.intCompanyLocationId, 0) = (
			CASE 
				WHEN @intCompanyLocationId = 0
					THEN ISNULL(SS.intCompanyLocationId, 0)
				ELSE @intCompanyLocationId
				END
			)
		AND (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					) < @dtmStartOfMonth
		AND IsNULL(SS.intBookId, 0) = IsNULL(@intBookId, 0)
		AND IsNULL(SS.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
	GROUP BY CASE 
			WHEN I.ysnSpecificItemDescription = 1
				THEN I.intItemId
			ELSE I.intMainItemId
			END

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT CASE 
			WHEN I.ysnSpecificItemDescription = 1
				THEN I.intItemId
			ELSE I.intMainItemId
			END AS intItemId
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
					CASE 
						WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
							THEN ISNULL(LDCL.dblReceivedQty, 0)
						ELSE LD.dblDeliveredQuantity
						END
					)) * I.dblRatio) AS dblIntrasitQty
		,14 AS intAttributeId --In-transit Purchases
		,DATEDIFF(mm, 0, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					)) + 1 - @intCurrentMonth AS intMonthId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.ysnPosted = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
			CASE 
				WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
					THEN ISNULL(LDCL.dblReceivedQty, 0)
				ELSE LD.dblDeliveredQuantity
				END
			) > 0
		AND SS.intContractStatusId IN (1,4)
		AND ISNULL(SS.intCompanyLocationId, 0) = (
			CASE 
				WHEN @intCompanyLocationId = 0
					THEN ISNULL(SS.intCompanyLocationId, 0)
				ELSE @intCompanyLocationId
				END
			)
		AND (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					) >= @dtmStartOfMonth
		AND IsNULL(SS.intBookId, 0) = IsNULL(@intBookId, 0)
		AND IsNULL(SS.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
	GROUP BY CASE 
			WHEN I.ysnSpecificItemDescription = 1
				THEN I.intItemId
			ELSE I.intMainItemId
			END
		,DATEDIFF(mm, 0, (
					CASE 
						WHEN Day(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay
							THEN DateAdd(m, 1, SS.dtmUpdatedAvailabilityDate)
						ELSE SS.dtmUpdatedAvailabilityDate
						END
					))

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT intItemId
		,SUM(dblQty)
		,4 AS intAttributeId --Existing Purchases
		,intMonthId
	FROM #tblMFDemand
	WHERE intAttributeId IN (
			13 --Open Purchases
			,14 --In-transit Purchases
			)
	GROUP BY intItemId
		,intMonthId;

	WITH tblMFGenerateInventoryRow (intMonthId)
	AS (
		SELECT 1 AS intMonthId
		
		UNION ALL
		
		SELECT intMonthId + 1
		FROM tblMFGenerateInventoryRow
		WHERE intMonthId + 1 <= @intMonthsToView
		)
	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT I.intItemId
		,NULL
		,2 --Opening Inventory
		,M.intMonthId
	FROM tblMFGenerateInventoryRow M
		,@tblMFItem I
	WHERE NOT EXISTS (
			SELECT *
			FROM #tblMFDemand D
			WHERE D.intItemId = I.intItemId
				AND D.intMonthId = M.intMonthId
				AND D.intAttributeId = 2
			)

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT D.intItemId
		,CASE 
			WHEN @ysnCalculatePlannedPurchases = 0
				AND @ysnCalculateEndInventory = 0
				AND @intContainerTypeId IS NOT NULL
				THEN IsNULL(IL.dblMinOrder * IsNULL(UMCByWeight.dblConversionToStock, 1), 0)
			ELSE 0
			END
		,5 AS intAttributeId --Planned Purchases
		,D.intMonthId
	FROM #tblMFDemand D
	LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = D.intItemId
	LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = CW.intWeightUnitMeasureId --From Unit
		AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId -- To Unit
	LEFT JOIN tblICItemLocation IL ON IL.intItemId = D.intItemId
		AND IL.intLocationId = @intCompanyLocationId
	WHERE intAttributeId = 2 --Opening Inventory
		AND intMonthId > 0

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT intItemId
		,NULL
		,9 --Ending Inventory
		,intMonthId
	FROM #tblMFDemand
	WHERE intAttributeId = 2 --Opening Inventory
		AND intMonthId > 0

	IF @PlannedPurchasesXML <> ''
	BEGIN
		UPDATE D
		SET dblQty = Purchase.[strValue]
		FROM #tblMFDemand D
		JOIN #TempPlannedPurchases Purchase ON Purchase.intItemId = D.intItemId
			AND Purchase.[strName] = D.intMonthId
		WHERE intAttributeId = 5 --Planned Purchases -
			AND intMonthId > 0
	END

	IF @WeeksOfSupplyTargetXML <> ''
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT intItemId
			,strValue
			,11 --Weeks of Supply Target
			,[strName] AS intMonthId
		FROM #TempWeeksOfSupplyTarget
	END

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT intItemId
		,CASE 
			WHEN strValue = ''
				THEN NULL
			ELSE dbo.fnCTConvertQuantityToTargetItemUOM(intItemId, @intPrevUnitMeasureId, @intUnitMeasureId, strValue)
			END --Previous Planned Purchases
		,6
		,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
	FROM tblCTInvPlngReportAttributeValue
	WHERE intReportAttributeID = 5 --Planned Purchases
		AND intInvPlngReportMasterID = @intPrevInvPlngReportMasterID

	IF @ysnCalculatePlannedPurchases = 0
		AND @ysnCalculateEndInventory = 0
		AND @intContainerTypeId IS NOT NULL
		AND IsNULL(@WeeksOfSupplyTargetXML, '') = ''
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT D.intItemId
			,IsNULL(IL.dblLeadTime, 0)
			,11 --Weeks of Supply Target
			,D.intMonthId
		FROM #tblMFDemand D
		LEFT JOIN tblICItemLocation IL ON IL.intItemId = D.intItemId
			AND IL.intLocationId = @intCompanyLocationId
		WHERE intAttributeId = 2 --Opening Inventory
			AND intMonthId > 0
	END

	WHILE @intMonthId <= @intMonthsToView
	BEGIN
		IF @ysnSupplyTargetbyAverage = 1
		BEGIN
			UPDATE D
			SET dblQty = CASE 
					WHEN @intMonthId = 1
						THEN (
								SELECT sum(OpenInv.dblQty)
								FROM #tblMFDemand OpenInv
								WHERE OpenInv.intItemId = D.intItemId
									AND intMonthId IN (
										- 1 --Opening Inventory
										,0 --Past Due
										)
									AND intAttributeId IN (
										2 --Opening Inventory
										,13 --Open Purchases
										,14 --In-transit Purchases
										)
								)
					ELSE (
							SELECT sum(OpenInv.dblQty)
							FROM #tblMFDemand OpenInv
							WHERE OpenInv.intItemId = D.intItemId
								AND intMonthId = @intMonthId - 1
								AND intAttributeId = 9 --Ending Inventory
							)
					END
			FROM #tblMFDemand D
			WHERE intAttributeId = 2 --Opening Inventory
				AND intMonthId = @intMonthId

			IF @ysnCalculatePlannedPurchases = 1
			BEGIN
				UPDATE D
				SET dblQty = (
						CASE 
							WHEN (
									SELECT sum(OpenInv.dblQty)
									FROM #tblMFDemand OpenInv
									WHERE OpenInv.intItemId = D.intItemId
										AND OpenInv.intMonthId = @intMonthId
										AND (
											intAttributeId IN (
												2
												,4
												,8
												) --Opening Inventory, Existing Purchases,Forecasted Consumption
											)
									) < 0
								THEN (
										SELECT sum(OpenInv.dblQty)
										FROM #tblMFDemand OpenInv
										WHERE OpenInv.intItemId = D.intItemId
											AND OpenInv.intMonthId = @intMonthId
											AND (
												intAttributeId IN (
													2
													,4
													,8
													) --Opening Inventory, Existing Purchases,Forecasted Consumption
												)
										) * - 1
							ELSE 0
							END
						)
				FROM #tblMFDemand D
				WHERE intAttributeId = 5 --Planned Purchases -
					AND intMonthId = @intMonthId
			END

			DELETE
			FROM @tblMFEndInventory

			UPDATE D
			SET dblQty = (
					SELECT sum(OpenInv.dblQty)
					FROM #tblMFDemand OpenInv
					WHERE OpenInv.intItemId = D.intItemId
						AND OpenInv.intMonthId = @intMonthId
						AND (
							intAttributeId IN (
								2
								,4
								,5
								,8
								) --Opening Inventory,Existing Purchases,Planned Purchases - ,Forecasted Consumption
							)
					)
			OUTPUT inserted.intItemId
				,inserted.dblQty
			INTO @tblMFEndInventory
			FROM #tblMFDemand D
			WHERE intAttributeId = 9 --Ending Inventory
				AND intMonthId = @intMonthId
		END
		ELSE
		BEGIN
			DELETE
			FROM @tblMFEndInventory

			UPDATE D
			SET dblQty = CASE 
					WHEN @intMonthId = 1
						THEN (
								SELECT sum(OpenInv.dblQty)
								FROM #tblMFDemand OpenInv
								WHERE OpenInv.intItemId = D.intItemId
									AND intMonthId IN (
										- 1 --Opening Inventory
										,0 --Past Due
										)
									AND intAttributeId IN (
										2 --Opening Inventory
										,13 --Open Purchases
										,14 --In-transit Purchases
										)
								)
					ELSE (
							SELECT sum(OpenInv.dblQty)
							FROM #tblMFDemand OpenInv
							WHERE OpenInv.intItemId = D.intItemId
								AND intMonthId = @intMonthId - 1
								AND intAttributeId = 9 --Ending Inventory
							)
					END
			OUTPUT inserted.intItemId
				,inserted.dblQty
			INTO @tblMFEndInventory
			FROM #tblMFDemand D
			WHERE intAttributeId = 2 --Opening Inventory
				AND intMonthId = @intMonthId

			SELECT @intItemId = min(intItemId)
			FROM @tblMFEndInventory

			WHILE @intItemId IS NOT NULL
			BEGIN
				SELECT @dblEndInventory = 0
					,@dblWeeksOfSsupply = 0

				--Calculate Excess or shortage
				SELECT @dblSupplyTarget = NULL
					,@dblDecimalPart = NULL
					,@intIntegerPart = NULL
					,@dblTotalConsumptionQty = NULL

				SELECT @dblSupplyTarget = dblQty
				FROM #tblMFDemand
				WHERE intItemId = @intItemId
					AND intAttributeId = 11 --Weeks of Supply Target
					AND intMonthId = @intMonthId

				SELECT @dblDecimalPart = @dblSupplyTarget % 1

				SELECT @intIntegerPart = @dblSupplyTarget - @dblDecimalPart

				IF @intIntegerPart = 0
				BEGIN
					IF @dblDecimalPart > 0
					BEGIN
						SELECT @dblTotalConsumptionQty = ABS(dblQty) * @dblDecimalPart
						FROM #tblMFDemand
						WHERE intItemId = @intItemId
							AND intMonthId = @intMonthId + 1
							AND intAttributeId = 8
					END
				END
				ELSE
				BEGIN
					SELECT @dblTotalConsumptionQty = ABS(SUM(dblQty))
					FROM #tblMFDemand
					WHERE intItemId = @intItemId
						AND intMonthId BETWEEN @intMonthId + 1
							AND @intMonthId + @intIntegerPart
						AND intAttributeId = 8

					IF @dblDecimalPart > 0
					BEGIN
						SELECT @dblTotalConsumptionQty = isNULL(@dblTotalConsumptionQty, 0) + (ABS(dblQty) * @dblDecimalPart)
						FROM #tblMFDemand
						WHERE intItemId = @intItemId
							AND intMonthId = @intMonthId + @intIntegerPart + 1
							AND intAttributeId = 8
					END
				END

				---************************************
				---************************************
				---************************************
				IF @ysnCalculatePlannedPurchases = 1
				BEGIN
					UPDATE D
					SET dblQty = IsNULL((
								SELECT CASE 
										WHEN Max(IsNULL(CW.dblWeight, 0)) > 0
											THEN Ceiling(abs((sum(OpenInv.dblQty) - IsNULL(@dblTotalConsumptionQty, 0)) / Max(CW.dblWeight))) * Max(CW.dblWeight)
										ELSE abs(sum(OpenInv.dblQty) - IsNULL(@dblTotalConsumptionQty, 0))
										END
								FROM #tblMFDemand OpenInv
								LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = OpenInv.intItemId
								WHERE OpenInv.intItemId = D.intItemId
									AND OpenInv.intMonthId = @intMonthId
									AND (
										intAttributeId IN (
											2
											,4
											,8
											) --Opening Inventory, Existing Purchases,Forecasted Consumption
										)
								HAVING (sum(OpenInv.dblQty) - IsNULL(@dblTotalConsumptionQty, 0)) < 0
								), 0)
					FROM #tblMFDemand D
					WHERE intAttributeId = 5 --Planned Purchases -
						AND intMonthId = @intMonthId
						AND intItemId = @intItemId
				END

				UPDATE D
				SET dblQty = (
						SELECT sum(OpenInv.dblQty)
						FROM #tblMFDemand OpenInv
						WHERE OpenInv.intItemId = D.intItemId
							AND OpenInv.intMonthId = @intMonthId
							AND (
								intAttributeId IN (
									2
									,4
									,5
									,8
									) --Opening Inventory,Existing Purchases,Planned Purchases - ,Forecasted Consumption
								)
						)
				FROM #tblMFDemand D
				WHERE intAttributeId = 9 --Ending Inventory
					AND intMonthId = @intMonthId
					AND intItemId = @intItemId

				---************************************
				---************************************
				---************************************
				SELECT @dblEndInventory = dblQty
				FROM #tblMFDemand D
				WHERE intAttributeId = 9 --Ending Inventory
					AND intMonthId = @intMonthId
					AND intItemId = @intItemId

				IF @dblEndInventory IS NULL
					SELECT @dblEndInventory = 0

				SELECT @intConsumptionMonth = @intMonthId + 1

				INSERT INTO #tblMFDemand (
					intItemId
					,dblQty
					,intAttributeId
					,intMonthId
					)
				SELECT @intItemId
					,@dblEndInventory - IsNULL(@dblTotalConsumptionQty, 0)
					,12 --Short/Excess Inventory
					,@intMonthId

				--IF @intMonthId = @intMonthsToView
				--BEGIN
				--	INSERT INTO #tblMFDemand (
				--		intItemId
				--		,dblQty
				--		,intAttributeId
				--		,intMonthId
				--		)
				--	SELECT @intItemId
				--		,1
				--		,10 --Weeks of Supply
				--		,@intMonthId
				--END
				--ELSE
				--BEGIN
				SELECT @intConsumptionAvlMonth = 0

				SELECT @intConsumptionAvlMonth = Count(*)
				FROM #tblMFDemand
				WHERE intItemId = @intItemId
					AND intAttributeId = 8

				IF @intConsumptionAvlMonth IS NULL
					SELECT @intConsumptionAvlMonth = @intMonthsToView

				WHILE @intConsumptionMonth <= 12
					AND @dblEndInventory > 0
				BEGIN
					SELECT @dblRemainingConsumptionQty = NULL

					SELECT @dblRemainingConsumptionQty = ABS(SUM(dblQty))
					FROM #tblMFDemand
					WHERE intItemId = @intItemId
						AND intMonthId >= @intConsumptionMonth
						AND intAttributeId = 8

					IF @dblRemainingConsumptionQty IS NULL
						SELECT @dblRemainingConsumptionQty = 0

					IF (
							@dblRemainingConsumptionQty = 0
							--OR @dblEndInventory > @dblRemainingConsumptionQty
							)
						AND @intConsumptionMonth = @intMonthId + 1
					BEGIN
						IF NOT EXISTS (
								SELECT *
								FROM #tblMFDemand
								WHERE intItemId = @intItemId
									AND intAttributeId = 10
									AND dblQty = 999
								)
						BEGIN
							INSERT INTO #tblMFDemand (
								intItemId
								,dblQty
								,intAttributeId
								,intMonthId
								)
							SELECT @intItemId
								,999
								,10 --Weeks of Supply
								,@intMonthId
						END
						ELSE
						BEGIN
							INSERT INTO #tblMFDemand (
								intItemId
								,dblQty
								,intAttributeId
								,intMonthId
								)
							SELECT @intItemId
								,0
								,10 --Weeks of Supply
								,@intMonthId
						END

						GOTO NextItem
					END

					SELECT @dblConsumptionQty = 0

					SELECT @dblConsumptionQty = ABS(dblQty)
					FROM #tblMFDemand
					WHERE intItemId = @intItemId
						AND intMonthId = @intConsumptionMonth
						AND intAttributeId = 8

					IF @dblConsumptionQty IS NULL
						SELECT @dblConsumptionQty = 0

					IF @dblEndInventory > @dblConsumptionQty
					BEGIN
						SELECT @dblEndInventory = @dblEndInventory - @dblConsumptionQty

						SELECT @dblWeeksOfSsupply = @dblWeeksOfSsupply + 1

						IF NOT EXISTS (
								SELECT *
								FROM #tblMFDemand
								WHERE intItemId = @intItemId
									AND intMonthId > @intConsumptionMonth
									AND intAttributeId = 8
									AND ABS(dblQty) > 0
								)
						BEGIN
							INSERT INTO #tblMFDemand (
								intItemId
								,dblQty
								,intAttributeId
								,intMonthId
								)
							SELECT @intItemId
								,@dblWeeksOfSsupply
								,10 --Weeks of Supply
								,@intMonthId

							SELECT @dblEndInventory = 0
						END
					END
					ELSE
					BEGIN
						SELECT @dblWeeksOfSsupply = @dblWeeksOfSsupply + (@dblEndInventory / @dblConsumptionQty)

						SELECT @dblEndInventory = 0

						INSERT INTO #tblMFDemand (
							intItemId
							,dblQty
							,intAttributeId
							,intMonthId
							)
						SELECT @intItemId
							,@dblWeeksOfSsupply
							,10 --Weeks of Supply
							,@intMonthId
					END

					SELECT @intConsumptionMonth = @intConsumptionMonth + 1
				END

				--END
				NextItem:

				SELECT @intItemId = min(intItemId)
				FROM @tblMFEndInventory
				WHERE intItemId > @intItemId
					--AND dblQty > 0
			END
		END

		SELECT @intMonthId = @intMonthId + 1
	END

	IF @ysnSupplyTargetbyAverage = 1
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT Demand.intItemId
			,CASE 
				WHEN (
						SELECT SUM(ABS(dblQty))
						FROM #tblMFDemand D
						WHERE D.intItemId = Demand.intItemId
							AND D.intAttributeId = 8
							AND (
								(
									Demand.intMonthId <= @intMonthsToView - @intNoofWeeksorMonthstoCalculateSupplyTarget
									AND D.intMonthId BETWEEN Demand.intMonthId + 1
										AND Demand.intMonthId + @intNoofWeeksorMonthstoCalculateSupplyTarget
									)
								OR (
									Demand.intMonthId > @intMonthsToView - @intNoofWeeksorMonthstoCalculateSupplyTarget
									AND D.intMonthId BETWEEN @intMonthsToView + 1 - @intNoofWeeksorMonthstoCalculateSupplyTarget
										AND @intMonthsToView
									)
								)
						) > 0
					THEN (
							SELECT dblQty
							FROM #tblMFDemand D
							WHERE D.intItemId = Demand.intItemId
								AND D.intAttributeId = 9
								AND D.intMonthId = Demand.intMonthId
							) / (
							(
								SELECT SUM(abs(dblQty))
								FROM #tblMFDemand D
								WHERE D.intItemId = Demand.intItemId
									AND D.intAttributeId = 8
									AND (
										(
											Demand.intMonthId <= @intMonthsToView - @intNoofWeeksorMonthstoCalculateSupplyTarget
											AND D.intMonthId BETWEEN Demand.intMonthId + 1
												AND Demand.intMonthId + @intNoofWeeksorMonthstoCalculateSupplyTarget
											)
										OR (
											Demand.intMonthId > @intMonthsToView - @intNoofWeeksorMonthstoCalculateSupplyTarget
											AND D.intMonthId BETWEEN @intMonthsToView + 1 - @intNoofWeeksorMonthstoCalculateSupplyTarget
												AND @intMonthsToView
											)
										)
								) / @intNoofWeekstoCalculateSupplyTargetbyAverage
							)
				ELSE 0
				END
			,10 --Weeks of Supply
			,intMonthId
		FROM #tblMFDemand Demand
		WHERE intAttributeId = 2 --Opening Inventory
	END

	IF @ysnSupplyTargetbyAverage = 1
	BEGIN
		INSERT INTO #tblMFDemand (
			intItemId
			,dblQty
			,intAttributeId
			,intMonthId
			)
		SELECT Demand.intItemId
			,CASE 
				WHEN IsNULL((
							SELECT dblQty
							FROM #tblMFDemand D2
							WHERE D2.intItemId = Demand.intItemId
								AND D2.intAttributeId = 10
								AND D2.intMonthId = Demand.intMonthId
							), 0) = 0
					THEN (
							SELECT dblQty
							FROM #tblMFDemand D1
							WHERE D1.intItemId = Demand.intItemId
								AND D1.intAttributeId = 9 --Ending Inventory
								AND D1.intMonthId = Demand.intMonthId
							)
				ELSE (
						(
							SELECT dblQty
							FROM #tblMFDemand D1
							WHERE D1.intItemId = Demand.intItemId
								AND D1.intAttributeId = 9 --Ending Inventory
								AND D1.intMonthId = Demand.intMonthId
							) / (
							SELECT dblQty
							FROM #tblMFDemand D2
							WHERE D2.intItemId = Demand.intItemId
								AND D2.intAttributeId = 10 --Weeks of Supply
								AND D2.intMonthId = Demand.intMonthId
							)
						) * (
						(
							IsNULL((
									SELECT dblQty
									FROM #tblMFDemand D3
									WHERE D3.intItemId = Demand.intItemId
										AND D3.intAttributeId = 10 --Weeks of Supply 
										AND D3.intMonthId = Demand.intMonthId
									), 0)
							) - IsNULL((
								SELECT dblQty
								FROM #tblMFDemand D4
								WHERE D4.intItemId = Demand.intItemId
									AND D4.intAttributeId = 11 --Weeks of Supply Target
									AND D4.intMonthId = Demand.intMonthId
								), 0)
						)
				END
			,12 --Short/Excess Inventory
			,intMonthId
		FROM #tblMFDemand Demand
		WHERE intAttributeId = 2;--Opening Inventory
	END

	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		)
	SELECT I.intItemId
		,NULL
		,2 AS intAttributeId --Opening Inventory
		,- 1 AS intMonthId
		,I.intMainItemId
	FROM @tblMFItem I

	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID AS intAttributeId
		,0 AS intMonthId
		,I.intMainItemId
	FROM @tblMFItem I
		,tblCTReportAttribute A
	WHERE A.intReportAttributeID IN (
			4 --Existing Purchases
			,13 --Open Purchases
			,14 --In-transit Purchases
			)
		AND A.intReportMasterID = @intReportMasterID;

	WITH tblMFGenerateDemandData (intMonthId)
	AS (
		SELECT 1 AS intMonthId
		
		UNION ALL
		
		SELECT intMonthId + 1
		FROM tblMFGenerateDemandData
		WHERE intMonthId + 1 <= @intMonthsToView
		)
	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID
		,intMonthId
		,I.intMainItemId
	FROM tblMFGenerateDemandData
		,@tblMFItem I
		,tblCTReportAttribute A
	WHERE A.intReportAttributeID IN (
			2 --Opening Inventory
			,4 --Existing Purchases
			,13 --Open Purchases
			,14 --In-transit Purchases
			,5 --Planned Purchases
			,6 --Previous Planned Purchases
			,9 --Ending Inventory
			,10 --Weeks of Supply
			,11 --Weeks of Supply Target
			,12 --Short/Excess Inventory
			);

	WITH tblMFGenerateDemandData (intMonthId)
	AS (
		SELECT 1 AS intMonthId
		
		UNION ALL
		
		SELECT intMonthId + 1
		FROM tblMFGenerateDemandData
		WHERE intMonthId + 1 <= 12
		)
	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID
		,intMonthId
		,I.intMainItemId
	FROM tblMFGenerateDemandData
		,@tblMFItem I
		,tblCTReportAttribute A
	WHERE A.intReportAttributeID = 8 --Forecasted Consumption

	DECLARE @intNoOfMonth INT

	SELECT @intNoOfMonth = DATEDIFF(mm, 0, GETDATE()) + 24;

	WITH tblMFGenerateMonth (
		intPositionId
		,intMonthId
		)
	AS (
		SELECT DATEDIFF(mm, 0, GETDATE()) + 1 AS intPositionId
			,1 AS intMonthId
		
		UNION ALL
		
		SELECT intPositionId + 1
			,intMonthId + 1
		FROM tblMFGenerateMonth
		WHERE intPositionId + 1 <= @intNoOfMonth
		)
	SELECT [1] AS strMonth1
		,[2] AS strMonth2
		,[3] AS strMonth3
		,[4] AS strMonth4
		,[5] AS strMonth5
		,[6] AS strMonth6
		,[7] AS strMonth7
		,[8] AS strMonth8
		,[9] AS strMonth9
		,[10] AS strMonth10
		,[11] AS strMonth11
		,[12] AS strMonth12
		,[13] AS strMonth13
		,[14] AS strMonth14
		,[15] AS strMonth15
		,[16] AS strMonth16
		,[17] AS strMonth17
		,[18] AS strMonth18
		,[19] AS strMonth19
		,[20] AS strMonth20
		,[21] AS strMonth21
		,[22] AS strMonth22
		,[23] AS strMonth23
		,[24] AS strMonth24
		,0 AS intMainItemId
	FROM (
		SELECT intMonthId
			,LEFT(DATENAME(month, DateAdd(month, intPositionId, - 1)), 3) + ' ' + Right(DATENAME(Year, DateAdd(month, intPositionId, - 1)), 2) AS strMonth
		FROM tblMFGenerateMonth
		) src
	PIVOT(MAX(src.strMonth) FOR src.intMonthId IN (
				[-1]
				,[0]
				,[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				,[13]
				,[14]
				,[15]
				,[16]
				,[17]
				,[18]
				,[19]
				,[20]
				,[21]
				,[22]
				,[23]
				,[24]
				)) AS pvt

	SELECT intItemId
		,strItemNo
		,intReportAttributeID AS AttributeId
		,strAttributeName
		,[-1] AS OpeningInv
		,[0] AS PastDue
		,[1] AS strMonth1
		,[2] AS strMonth2
		,[3] AS strMonth3
		,[4] AS strMonth4
		,[5] AS strMonth5
		,[6] AS strMonth6
		,[7] AS strMonth7
		,[8] AS strMonth8
		,[9] AS strMonth9
		,[10] AS strMonth10
		,[11] AS strMonth11
		,[12] AS strMonth12
		,[13] AS strMonth13
		,[14] AS strMonth14
		,[15] AS strMonth15
		,[16] AS strMonth16
		,[17] AS strMonth17
		,[18] AS strMonth18
		,[19] AS strMonth19
		,[20] AS strMonth20
		,[21] AS strMonth21
		,[22] AS strMonth22
		,[23] AS strMonth23
		,[24] AS strMonth24
		,CASE 
			WHEN intItemId = intMainItemId
				THEN NULL
			ELSE intMainItemId
			END AS intMainItemId
		,strGroupByColumn
	FROM (
		SELECT I.intItemId
			,CASE 
				WHEN @ysnDisplayRestrictedBookInDemandView = 0
					AND IsNULL(strBook, '') = ''
					THEN (
							CASE 
								WHEN @ysnDisplayDemandWithItemNoAndDescription = 1
									THEN (
											CASE 
												WHEN I.intItemId = MI.intItemId
													OR MI.intItemId IS NULL
													THEN I.strItemNo + ' - ' + I.strDescription
												ELSE I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ]'
												END
											)
								ELSE (
										CASE 
											WHEN I.intItemId = MI.intItemId
												OR MI.intItemId IS NULL
												THEN I.strItemNo
											ELSE I.strItemNo + ' [ ' + MI.strItemNo + ' ]'
											END
										)
								END
							)
				ELSE (
						CASE 
							WHEN @ysnDisplayDemandWithItemNoAndDescription = 1
								THEN (
										CASE 
											WHEN I.intItemId = MI.intItemId
												OR MI.intItemId IS NULL
												THEN I.strItemNo + ' - ' + I.strDescription
											WHEN I.intItemId <> MI.intItemId
												AND strBook IS NULL
												THEN I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ]'
											ELSE I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ] Restricted [' + strBook + ']'
											END
										)
							ELSE (
									CASE 
										WHEN I.intItemId = MI.intItemId
											OR MI.intItemId IS NULL
											THEN I.strItemNo
										WHEN I.intItemId <> MI.intItemId
											AND strBook IS NULL
											THEN I.strItemNo + ' [ ' + MI.strItemNo + ' ]'
										ELSE I.strItemNo + ' [ ' + MI.strItemNo + ' ] Restricted [' + strBook + ']'
										END
									)
							END
						)
				END AS strItemNo
			,A.intReportAttributeID
			,CASE 
				WHEN A.intReportAttributeID = 10
					AND @strSupplyTarget = 'Monthly'
					THEN 'Months of Supply'
				WHEN A.intReportAttributeID = 11
					AND @strSupplyTarget = 'Monthly'
					THEN 'Months of Supply Target'
				WHEN A.intReportAttributeID IN (
						5
						,6
						)
					AND @intContainerTypeId IS NOT NULL
					THEN A.strAttributeName + ' [' + @strContainerType + ']'
				ELSE A.strAttributeName
				END AS strAttributeName
			,(
				CASE 
					--WHEN A.intReportAttributeID = 5
					--	AND @intContainerTypeId IS NOT NULL
					--	AND IsNULL(CW.dblWeight, 0) > 0
					--	THEN Floor(IsNULL(D.dblQty / CW.dblWeight, 0)) * CW.dblWeight
					WHEN DL.intMonthId IN (
							- 1
							,0
							)
						AND A.intReportAttributeID IN (
							2
							,4
							,13
							,14
							)
						THEN IsNULL(D.dblQty, 0)
					WHEN DL.intMonthId IN (
							- 1
							,0
							)
						THEN D.dblQty
					WHEN A.intReportAttributeID = 8
						AND DL.intMonthId <= @intMonthsToView
						THEN ABS(IsNULL(D.dblQty, 0))
					WHEN A.intReportAttributeID = 8
						AND DL.intMonthId > @intMonthsToView
						THEN ABS(D.dblQty)
					ELSE IsNULL(D.dblQty, 0)
					END
				) AS dblQty
			,DL.intMonthId
			,A.intDisplayOrder
			,DL.intMainItemId
			,MI.strItemNo AS strMainItemNo
			,CASE 
				WHEN I.intItemId = MI.intItemId
					OR MI.intItemId IS NULL
					THEN I.strItemNo
				ELSE MI.strItemNo + ' [ ' + I.strItemNo + ' ]'
				END AS strGroupByColumn
		FROM #tblMFDemandList DL
		JOIN tblCTReportAttribute A ON A.intReportAttributeID = DL.intAttributeId
		JOIN tblICItem I ON I.intItemId = DL.intItemId
		LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = DL.intItemId
		LEFT JOIN #tblMFDemand D ON D.intItemId = DL.intItemId
			AND D.intMonthId = DL.intMonthId
			AND D.intAttributeId = DL.intAttributeId
		LEFT JOIN tblICItem MI ON MI.intItemId = DL.intMainItemId
		LEFT JOIN @tblMFItemBook IB ON IB.intItemId = DL.intItemId
		) src
	PIVOT(MAX(src.dblQty) FOR src.intMonthId IN (
				[-1]
				,[0]
				,[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				,[13]
				,[14]
				,[15]
				,[16]
				,[17]
				,[18]
				,[19]
				,[20]
				,[21]
				,[22]
				,[23]
				,[24]
				)) AS pvt
	ORDER BY IsNULL(strMainItemNo, strItemNo)
		,strItemNo
		,intDisplayOrder;
END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
