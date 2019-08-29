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
		)

	SELECT @intContainerTypeId = intContainerTypeId
		,@ysnCalculateNoOfContainerByBagQty = ysnCalculateNoOfContainerByBagQty
		,@ysnSupplyTargetbyAverage = ysnSupplyTargetbyAverage
		,@strSupplyTarget = strSupplyTarget
		,@intNoofWeeksorMonthstoCalculateSupplyTarget = IsNULL(intNoofWeeksorMonthstoCalculateSupplyTarget, 3)
		,@intNoofWeekstoCalculateSupplyTargetbyAverage = IsNULL(intNoofWeekstoCalculateSupplyTargetbyAverage, 13)
		,@ysnComputeDemandUsingRecipe = ysnComputeDemandUsingRecipe
		,@ysnDisplayDemandWithItemNoAndDescription = ysnDisplayDemandWithItemNoAndDescription
	FROM tblMFCompanyPreference

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

	IF @intInvPlngReportMasterID IS NOT NULL
	BEGIN
		SELECT @dtmDate = dtmDate
		FROM tblCTInvPlngReportMaster
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
	END
	ELSE
	BEGIN
		SELECT @dtmDate = GETDATE()
	END

	--To get a previously saved demand view
	SELECT TOP 1 @intPrevInvPlngReportMasterID = intInvPlngReportMasterID
	FROM tblCTInvPlngReportMaster
	WHERE dtmDate < @dtmDate
		AND ysnPost = 1
	ORDER BY intInvPlngReportMasterID DESC

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
			SELECT intItemId
			FROM tblICItem
			WHERE intCategoryId = @intCategoryId
		END
	END

	INSERT INTO @tblMFItemDetail (
		intItemId
		,intMainItemId
		,ysnSpecificItemDescription
		)
	SELECT DISTINCT DD.intSubstituteItemId
		,DD.intItemId
		,1
	FROM @tblMFItem I
	JOIN tblMFDemandDetail DD ON I.intItemId = DD.intSubstituteItemId
	WHERE DD.intDemandHeaderId = @intDemandHeaderId

	INSERT INTO @tblMFItemDetail (
		intItemId
		,intMainItemId
		,ysnSpecificItemDescription
		)
	SELECT IB.intBundleItemId
		,IB.intItemId
		,0
	FROM @tblMFItem I
	LEFT JOIN tblICItemBundle IB ON IB.intItemId = I.intItemId
	WHERE NOT EXISTS (
			SELECT *
			FROM @tblMFItemDetail FI
			WHERE FI.intItemId = IB.intBundleItemId
			)
		AND IB.intBundleItemId IS NOT NULL

	--INSERT INTO @tblMFItemDetail (
	--	intItemId
	--	,intMainItemId
	--	,ysnSpecificItemDescription
	--	)
	--SELECT intItemId
	--	,intItemId
	--	,0
	--FROM @tblMFItem I
	--WHERE NOT EXISTS (
	--		SELECT *
	--		FROM @tblMFItemDetail FI
	--		WHERE FI.intItemId = I.intItemId
	--		)
	UPDATE I
	SET I.intMainItemId = ID.intMainItemId
	FROM @tblMFItem I
	JOIN @tblMFItemDetail ID ON ID.intItemId = I.intItemId --and I.intItemId<>ID.intMainItemId

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
			,Replace([Name], 'strMonth', '') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/OpenPurchase', 2) WITH (
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
			,Replace([Name], 'strMonth', '') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/PlannedPurchases', 2) WITH (
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
			,Replace([Name], 'strMonth', '') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/ForecastedConsumption', 2) WITH (
				[intItemId] INT
				,[Name] NVARCHAR(50)
				,[Value] DECIMAL(24, 6)
				)

		EXEC sp_xml_removedocument @idoc
	END

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
			,Replace([Name], 'strMonth', '') AS [Name]
			,[Value]
		FROM OPENXML(@idoc, 'root/WeeksOfSupplyTarget', 2) WITH (
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

	IF OBJECT_ID('tempdb..#tblMFDemandList') IS NOT NULL
		DROP TABLE #tblMFDemandList

	CREATE TABLE #tblMFDemandList (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intAttributeId INT
		,intMonthId INT
		,intMainItemId INT
		)

	SELECT @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, Getdate()), 0)

	SELECT @intCurrentMonth = DATEDIFF(mm, 0, GETDATE())

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
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(L.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, L.dblQty)) AS dblIntrasitQty
				,2 AS intAttributeId --Opening Inventory
				,- 1 AS intMonthId
			FROM @tblMFItemDetail I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
				AND ISNULL(L.intLocationId, 0) = (
					CASE 
						WHEN @intCompanyLocationId = 0
							THEN ISNULL(L.intLocationId, 0)
						ELSE @intCompanyLocationId
						END
					)
			GROUP BY I.ysnSpecificItemDescription
				,I.intItemId
				,I.intMainItemId
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
				,strValue --Opening Inventory
				,6
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
				SELECT RI.intItemId
					,Convert(NUMERIC(18, 6), (RI.dblQuantity / R.dblQuantity) * DD.dblQuantity)
					,8 AS intAttributeId --Forecasted Consumption
					,DD.dtmDemandDate
					,0 AS intLevel
					,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
				FROM tblMFDemandDetail DD
				JOIN tblMFRecipe R ON R.intItemId = IsNULL(DD.intSubstituteItemId, DD.intItemId)
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
					,Convert(NUMERIC(18, 6), (RI.dblQuantity / R.dblQuantity) * RII.dblQuantity)
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
			SELECT intItemId
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
				,- DD.dblQuantity
				,8 AS intAttributeId --Forecasted Consumption
				,DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON IsNULL(DD.intSubstituteItemId, DD.intItemId) = I.intItemId
				AND DD.intDemandHeaderId = @intDemandHeaderId
			WHERE DD.dtmDemandDate >= @dtmStartOfMonth
		END
	END
	ELSE
	BEGIN
		MERGE #tblMFDemand AS target
		USING (
			SELECT intItemId
				,[strName]
				,[strValue]
			FROM #TempForecastedConsumption
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
	END

	IF IsNULL(@OpenPurchaseXML, '') = ''
	BEGIN
		IF @ysnRefreshContract = 1
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
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblBalance)) AS dblIntrasitQty
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
			WHERE SS.intContractStatusId = 1
				AND SS.dtmUpdatedAvailabilityDate < @dtmStartOfMonth
			GROUP BY I.ysnSpecificItemDescription
				,I.intItemId
				,I.intMainItemId

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
				,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblBalance)) AS dblIntrasitQty
				,13 AS intAttributeId --Open Purchases
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - @intCurrentMonth AS intMonthId
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
			WHERE SS.intContractStatusId = 1
				AND SS.dtmUpdatedAvailabilityDate >= @dtmStartOfMonth
			GROUP BY datename(m, SS.dtmUpdatedAvailabilityDate) + ' ' + cast(datepart(yyyy, SS.dtmUpdatedAvailabilityDate) AS VARCHAR)
				,I.ysnSpecificItemDescription
				,I.intItemId
				,I.intMainItemId
				,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate)
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
				,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
			FROM tblCTInvPlngReportAttributeValue
			WHERE intReportAttributeID = 13 --Open Purchases 
				AND intInvPlngReportMasterID = @intPrevInvPlngReportMasterID
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
					))) AS dblIntrasitQty
		,14 AS intAttributeId --In-transit Purchases
		,0 AS intMonthId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
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
		AND SS.intContractStatusId = 1
		AND ISNULL(SS.intCompanyLocationId, 0) = (
			CASE 
				WHEN @intCompanyLocationId = 0
					THEN ISNULL(SS.intCompanyLocationId, 0)
				ELSE @intCompanyLocationId
				END
			)
		AND SS.dtmUpdatedAvailabilityDate < @dtmStartOfMonth
	GROUP BY I.ysnSpecificItemDescription
		,I.intItemId
		,I.intMainItemId

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
					))) AS dblIntrasitQty
		,14 AS intAttributeId --In-transit Purchases
		,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate) + 1 - @intCurrentMonth AS intMonthId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
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
		AND SS.intContractStatusId = 1
		AND ISNULL(SS.intCompanyLocationId, 0) = (
			CASE 
				WHEN @intCompanyLocationId = 0
					THEN ISNULL(SS.intCompanyLocationId, 0)
				ELSE @intCompanyLocationId
				END
			)
		AND SS.dtmUpdatedAvailabilityDate >= @dtmStartOfMonth
	GROUP BY I.ysnSpecificItemDescription
		,I.intItemId
		,I.intMainItemId
		,DATEDIFF(mm, 0, SS.dtmUpdatedAvailabilityDate)

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
		,intMonthId
	FROM tblMFGenerateInventoryRow
		,@tblMFItem I

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT intItemId
		,NULL
		,5 AS intAttributeId --Planned Purchases
		,intMonthId
	FROM #tblMFDemand
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
		,strValue --Previous Planned Purchases
		,6
		,Replace(Replace(Replace(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
	FROM tblCTInvPlngReportAttributeValue
	WHERE intReportAttributeID = 6 --Previous Planned Purchases
		AND intInvPlngReportMasterID = @intPrevInvPlngReportMasterID

	WHILE @intMonthId <= 24
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
		SET dblQty = CASE 
				WHEN (
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
						) > 0
					THEN (
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
				ELSE 0
				END
		OUTPUT inserted.intItemId
			,inserted.dblQty
		INTO @tblMFEndInventory
		FROM #tblMFDemand D
		WHERE intAttributeId = 9 --Ending Inventory
			AND intMonthId = @intMonthId

		IF @ysnSupplyTargetbyAverage = 0
		BEGIN
			SELECT @intItemId = min(intItemId)
			FROM @tblMFEndInventory
			WHERE dblQty > 0

			WHILE @intItemId IS NOT NULL
			BEGIN
				SELECT @dblEndInventory = 0
					,@dblWeeksOfSsupply = 0

				SELECT @dblEndInventory = dblQty
				FROM @tblMFEndInventory
				WHERE intItemId = @intItemId

				IF @dblEndInventory IS NULL
					SELECT @dblEndInventory = 0

				SELECT @intConsumptionMonth = @intMonthId + 1

				WHILE @intConsumptionMonth <= 24
					AND @dblEndInventory > 0
				BEGIN
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

						IF @intConsumptionMonth = 24
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

				SELECT @intItemId = min(intItemId)
				FROM @tblMFEndInventory
				WHERE intItemId > @intItemId
					AND dblQty > 0
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
							AND D.intMonthId BETWEEN Demand.intMonthId + 1
								AND Demand.intMonthId + @intNoofWeeksorMonthstoCalculateSupplyTarget
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
									AND D.intMonthId BETWEEN Demand.intMonthId + 1
										AND Demand.intMonthId + @intNoofWeeksorMonthstoCalculateSupplyTarget
								) / @intNoofWeekstoCalculateSupplyTargetbyAverage
							)
				ELSE 0
				END
			,10 --Weeks of Supply
			,intMonthId
		FROM #tblMFDemand Demand
		WHERE intAttributeId = 2
	END

	INSERT INTO #tblMFDemand (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		)
	SELECT Demand.intItemId
		,CASE 
			WHEN (
					SELECT dblQty
					FROM #tblMFDemand D2
					WHERE D2.intItemId = Demand.intItemId
						AND D2.intAttributeId = 10
						AND D2.intMonthId = Demand.intMonthId
					) = 0
				THEN NULL
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
	WHERE intAttributeId = 2;

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
			2
			,4
			,13
			,14
			,5
			,6
			,8
			,9
			,10
			,11
			,12
			)

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
	FROM (
		SELECT I.intItemId
			,CASE 
				WHEN @ysnDisplayDemandWithItemNoAndDescription = 1
					THEN (
							CASE 
								WHEN I.intItemId = MI.intItemId
									THEN I.strItemNo + ' - ' + I.strDescription
								ELSE I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ]'
								END
							)
				ELSE (
						CASE 
							WHEN MI.intItemId is null
								THEN I.strItemNo
							ELSE I.strItemNo + ' [ ' + MI.strItemNo + ' ]'
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
				ELSE A.strAttributeName
				END AS strAttributeName
			,Convert(DECIMAL(18, 2), (
					CASE 
						WHEN A.intReportAttributeID = 5
							AND @intContainerTypeId IS NOT NULL
							AND @ysnCalculateNoOfContainerByBagQty = 1
							THEN (D.dblQty * IsNULL(UMCByBulk.dblConversionToStock, 1)) / CTCQ.dblWeight
						WHEN A.intReportAttributeID = 5
							AND @intContainerTypeId IS NOT NULL
							AND @ysnCalculateNoOfContainerByBagQty = 0
							AND CTCQ.dblBulkQuantity > 0
							THEN D.dblQty * IsNULL(UMCByWeight.dblConversionToStock, 1) / CTCQ.dblBulkQuantity
						ELSE D.dblQty
						END
					)) AS dblQty
			,DL.intMonthId
			,A.intDisplayOrder
			,DL.intMainItemId
		FROM #tblMFDemandList DL
		JOIN tblCTReportAttribute A ON A.intReportAttributeID = DL.intAttributeId
		JOIN tblICItem I ON I.intItemId = DL.intItemId
		LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CTCQ.intCommodityAttributeId = I.intOriginId
			AND CTCQ.intCommodityId = I.intCommodityId
			AND CTCQ.intContainerTypeId = @intContainerTypeId
		LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CTCQ.intContainerTypeId
		LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = @intUnitMeasureId
			AND UMCByWeight.intStockUnitMeasureId = CTCQ.intWeightUnitMeasureId
		LEFT JOIN tblICUnitMeasureConversion UMCByBulk ON UMCByBulk.intUnitMeasureId = @intUnitMeasureId
			AND UMCByBulk.intStockUnitMeasureId = CT.intWeightUnitMeasureId
		LEFT JOIN #tblMFDemand D ON D.intItemId = DL.intItemId
			AND D.intMonthId = DL.intMonthId
			AND D.intAttributeId = DL.intAttributeId
		LEFT JOIN tblICItem MI ON MI.intItemId = DL.intMainItemId
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
	ORDER BY pvt.intMainItemId
		,pvt.strItemNo
		,pvt.intDisplayOrder;
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
