CREATE PROCEDURE [dbo].[uspCTInventoryPlan_GenerateForItem] @intInvPlngReportMasterID INT
	,@ExistingDataXML NVARCHAR(MAX)
	,@MaterialKeyXML NVARCHAR(MAX)
	,@intMonthsToView INT
	,@ysnIncludeInventory BIT
	,@PlannedPurchasesXML VARCHAR(MAX)
	,@WeeksOfSupplyTargetXML VARCHAR(MAX)
	,@ForecastedConsumptionXML VARCHAR(MAX)
	,@ysnCalculatePlannedPurchases BIT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ExistingMonthsToView INT
		,@NewMonthsToView INT
		,@ExistingInvChk BIT

	SET @ExistingMonthsToView = 0

	SELECT @ExistingMonthsToView = intNoOfMonths
		,@ExistingInvChk = ysnIncludeInventory
	FROM dbo.tblCTInvPlngReportMaster
	WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID

	SET @NewMonthsToView = @intMonthsToView

	IF (@PlannedPurchasesXML <> '')
	BEGIN
		DECLARE @idoc INT

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@PlannedPurchasesXML

		SELECT *
		INTO #TempPlannedPurchases
		FROM OPENXML(@idoc, 'root/PlannedPurchases', 2) WITH (
				[dblQuantity] DECIMAL(24, 6)
				,[strMonth] CHAR(3)
				,[strYear] INT
				,[intItemId] INT
				)

		EXEC sp_xml_removedocument @idoc
	END

	--SELECT * FROM #TempPlannedPurchases
	IF (@WeeksOfSupplyTargetXML <> '')
	BEGIN
		DECLARE @idoc1 INT

		EXEC sp_xml_preparedocument @idoc1 OUTPUT
			,@WeeksOfSupplyTargetXML

		SELECT *
		INTO #TempWeeksOfSupplyTarget
		FROM OPENXML(@idoc1, 'root/WeeksOfSupplyTarget', 2) WITH (
				[Target] DECIMAL(24, 6)
				,[strMonth] CHAR(3)
				,[strYear] INT
				,[intItemId] INT
				)

		EXEC sp_xml_removedocument @idoc1
	END

	IF (@ForecastedConsumptionXML <> '')
	BEGIN
		DECLARE @idocFC INT

		EXEC sp_xml_preparedocument @idocFC OUTPUT
			,@ForecastedConsumptionXML

		SELECT *
		INTO #TempForecastedConsumption
		FROM OPENXML(@idocFC, 'root/ForecastedConsumption', 2) WITH (
				[FCQty] DECIMAL(24, 6)
				,[strMonth] CHAR(3)
				,[strYear] INT
				,[intItemId] INT
				)

		EXEC sp_xml_removedocument @idocFC
	END

	DECLARE @MaterialKeyTable TABLE (
		[RowNo] INT
		,[intItemId] INT
		)

	IF (@MaterialKeyXML <> '')
	BEGIN
		DECLARE @idoc2 INT

		EXEC sp_xml_preparedocument @idoc2 OUTPUT
			,@MaterialKeyXML

		INSERT INTO @MaterialKeyTable
		SELECT m.*
		FROM (
			SELECT *
			FROM OPENXML(@idoc2, 'root/Material', 2) WITH (
					[RowNo] INT
					,[intItemId] INT
					)
			) m

		EXEC sp_xml_removedocument @idoc2
	END

	--select * from #TempPlannedPurchases
	--Select * from #TempForecastedConsumption
	--select * from #TempWeeksOfSupplyTarget
	DECLARE @Cnt INT

	SET @Cnt = 1

	DECLARE @SQL VARCHAR(max)

	SET @SQL = ''

	DECLARE @intReportMasterID INT

	SELECT @intReportMasterID = intReportMasterID
	FROM tblCTReportMaster
	WHERE strReportName = 'Inventory Planning Report'

	SET @SQL = @SQL + 'DECLARE @Table table(intItemId Int, strItemNo nvarchar(200), StdUOM varchar(20), BaseUOM varchar(20), AttributeId int, strAttributeName nvarchar(50)
						, OpeningInv decimal(24,6), PastDue nvarchar(35)'

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' nvarchar(35) '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' ) '

	DECLARE @MinRowNo INT
		,@MaxRowNo INT

	SELECT @MinRowNo = MIN(RowNo)
		,@MaxRowNo = MAX(RowNo)
	FROM @MaterialKeyTable

	WHILE (@MinRowNo <= @MaxRowNo)
	BEGIN
		DECLARE @intItemId INT
			,@strItemNo NVARCHAR(100)
			,@SourceUOMKey INT
			,@SourceUOMName NVARCHAR(50)
			,@TargetUOMKey INT
			,@TargetUOMName NVARCHAR(50)

		SELECT @intItemId = intItemId
		FROM @MaterialKeyTable
		WHERE [RowNo] = @MinRowNo

		--SELECT @strItemNo = strContractItemName
		--FROM dbo.tblICItemContract
		--WHERE intItemContractId = @intItemId
		--SELECT @SourceUOMKey = UOM.intUnitMeasureId
		--	,@SourceUOMName = UOM.strUnitMeasure
		--FROM dbo.UOMConversion UOM
		--JOIN tblICItem M ON M.ReceiveUOMKey = UOM.intUnitMeasureId
		--JOIN tblICItemContract CMM ON CMM.intItemId = M.intItemId
		--WHERE CMM.intItemContractId = @intItemId
		--SELECT @TargetUOMKey = UOM2.intUnitMeasureId
		--	,@TargetUOMName = UOM2.strUnitMeasure
		--FROM tblICItemContract CMM
		--JOIN tblICItem M ON M.intItemId = CMM.intItemId
		--JOIN UOMConversion UOM1 ON UOM1.intUnitMeasureId = M.ReceiveUOMKey
		--JOIN UOMConversion UOM2 ON UOM2.intUnitMeasureId = M.StandardUOMKey
		--WHERE CMM.intItemContractId = @intItemId
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		SELECT @SourceUOMKey = UOM.intUnitMeasureId
			,@SourceUOMName = UOM.strUnitMeasure
		FROM tblICItem M
		JOIN tblICItemUOM MUOM ON MUOM.intItemId = M.intItemId
			AND MUOM.ysnStockUnit = 1
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = MUOM.intUnitMeasureId
		WHERE M.intItemId = @intItemId

		SELECT @TargetUOMKey = UOM.intUnitMeasureId
			,@TargetUOMName = UOM.strUnitMeasure
		FROM tblICItem M
		JOIN tblCTItemDefaultUOM IUOM ON IUOM.intItemId = M.intItemId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intPurchaseUOMId
		WHERE M.intItemId = @intItemId

		DECLARE @Conversion_Factor DECIMAL(24, 6)

		--SELECT @Conversion_Factor = ConversionFactorFromUnitToBase
		--FROM MaterialUOMMap
		--WHERE intItemId = @intItemId
		--	AND TargetUOMKey = @SourceUOMKey
		--IF @Conversion_Factor IS NULL
		--BEGIN
		--	SELECT @Conversion_Factor = ConversionFactorFromUnitToBase
		--	FROM dbo.UOMConversion UOM
		--	WHERE UOM.intUnitMeasureId = @SourceUOMKey
		--END
		SELECT @Conversion_Factor = dblUnitQty -- ConversionFactorFromUnitToBase
		FROM tblICItemUOM
		WHERE intItemId = @intItemId
			AND intUnitMeasureId = @TargetUOMKey

		IF @Conversion_Factor IS NULL
		BEGIN
			SELECT @Conversion_Factor = dblConversionToStock -- ConversionFactorFromUnitToBase
			FROM dbo.tblICUnitMeasureConversion
			WHERE intUnitMeasureId = @TargetUOMKey
				AND intStockUnitMeasureId = @SourceUOMKey
		END

		DECLARE @OpeningInventory DECIMAL(24, 6)

		IF @ysnIncludeInventory = 1
			SET @OpeningInventory = (
					--SELECT SUM(dblQty)
					SELECT ISNULL(SUM(CASE 
								  WHEN L.intWeightUOMId IS NOT NULL
										THEN dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, L.dblWeight)
								  ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM1.intUnitMeasureId, @TargetUOMKey, L.dblQty)
								  END), 0)
					FROM dbo.tblICLot L
					JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
						AND L.intItemId = @intItemId
					LEFT JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = L.intWeightUOMId
					JOIN dbo.tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = L.intItemUOMId
					--WHERE intItemId IN (
					--		SELECT M.intItemId
					--		FROM tblICItem M
					--		WHERE M.intItemId = @intItemId
					--			--JOIN tblICItemContract CMM ON CMM.intItemId = M.intItemId
					--			--AND CMM.intItemContractId = @intItemId
					--		)
					)
		ELSE
			SET @OpeningInventory = 0

		DECLARE @PastDueExistingPurchases DECIMAL(24, 6)

		SET @PastDueExistingPurchases = ISNULL((
					SELECT SUM(CASE 
								WHEN @TargetUOMKey = IUOM.intUnitMeasureId
									THEN SS.dblBalance
								ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, SS.dblBalance)
								END)
					FROM [dbo].[tblCTContractDetail] SS
					JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = SS.intItemUOMId
					WHERE SS.intItemId = @intItemId
						AND SS.intContractStatusId = 1
						AND SS.dtmUpdatedAvailabilityDate <= (CAST((CONVERT(VARCHAR(25), DATEADD(dd, - (DAY(GETDATE())), GETDATE()), 101)) AS DATETIME)) -- previous month last date
					), 0)

		DECLARE @PastDueIntransitPurchases DECIMAL(24, 6)

		SET @PastDueIntransitPurchases = ISNULL((
					SELECT SUM(CASE 
								WHEN @TargetUOMKey = IUOM.intUnitMeasureId
									THEN IV.dblQtyInStockUOM
								ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, IV.dblQtyInStockUOM)
								END)
					FROM [dbo].[vyuLGInventoryView] IV
					JOIN [dbo].[tblCTContractDetail] SS ON SS.intContractDetailId = IV.intContractDetailId
					JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = IV.intWeightItemUOMId
					WHERE IV.intItemId = @intItemId
						AND IV.strStatus = 'In-transit'
						AND SS.intContractStatusId = 1
						AND SS.dtmUpdatedAvailabilityDate <= (CAST((CONVERT(VARCHAR(25), DATEADD(dd, - (DAY(GETDATE())), GETDATE()), 101)) AS DATETIME)) -- previous month last date
					), 0)
		SET @strItemNo = @strItemNo + ' (' + @TargetUOMName + ' per ' + @SourceUOMName + ' --> ' + CAST(@Conversion_Factor AS NVARCHAR(30)) + ')'
		SET @SQL = @SQL + ' INSERT INTO @Table (intItemId , strItemNo , StdUOM , BaseUOM , AttributeId , strAttributeName ) 
		SELECT ' + Cast(@intItemId AS NVARCHAR(10)) + ', ''' + @strItemNo + ''', ''' + @SourceUOMName + ''', ''' + @TargetUOMName + ''', intReportAttributeID, strAttributeName 
		FROM dbo.tblCTReportAttribute WHERE intReportMasterID = ' + cast(@intReportMasterID AS NVARCHAR(10)) + ' ORDER BY intReportAttributeID'

		DECLARE @FetchExisting BIT

		SET @FetchExisting = 0

		IF (
				(@ExistingInvChk = @ysnIncludeInventory)
				AND (@intInvPlngReportMasterID > 0)
				AND (
					@intItemId IN (
						SELECT intItemId
						FROM dbo.tblCTInvPlngReportMaterial
						WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
						)
					)
				)
		BEGIN
			SET @FetchExisting = 1
		END

		IF @ForecastedConsumptionXML <> ''
			IF EXISTS (
					--additional records (months increased)
					SELECT CAST([FCQty] AS NVARCHAR(30))
						,intItemId
					FROM #TempForecastedConsumption
					WHERE intItemId = @intItemId
					
					EXCEPT
					
					SELECT strValue
						,intItemId
					FROM dbo.tblCTInvPlngReportAttributeValue
					WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
						AND intItemId = @intItemId
						AND intReportAttributeID = 8
					)
			BEGIN
				SET @FetchExisting = 0
			END

		IF @PlannedPurchasesXML <> ''
			IF EXISTS (
					SELECT CAST(dblQuantity AS NVARCHAR(30))
						,intItemId
					FROM #TempPlannedPurchases
					WHERE intItemId = @intItemId
					
					EXCEPT
					
					SELECT strValue
						,intItemId
					FROM dbo.tblCTInvPlngReportAttributeValue
					WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
						AND intItemId = @intItemId
						AND intReportAttributeID = 5
					)
			BEGIN
				SET @FetchExisting = 0
			END

		IF @WeeksOfSupplyTargetXML <> ''
			IF EXISTS (
					SELECT CAST([Target] AS NVARCHAR(30))
						,intItemId
					FROM #TempWeeksOfSupplyTarget
					WHERE intItemId = @intItemId
					
					EXCEPT
					
					SELECT strValue
						,intItemId
					FROM dbo.tblCTInvPlngReportAttributeValue
					WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
						AND intItemId = @intItemId
						AND intReportAttributeID = 11
					)
			BEGIN
				SET @FetchExisting = 0
			END

		-- Forecast based on Multiple Recipe level starts
		DECLARE @MinId INT
		DECLARE @MinBlendDemandItemId INT
		DECLARE @intItemId1 INT
		DECLARE @intBlendDemandItemId INT
		DECLARE @intBlendDemandItemRecipeId INT
		DECLARE @intRecipeId INT
		DECLARE @Count INT
		DECLARE @dblTotalRecipeItemQty NUMERIC(18, 6)

		IF OBJECT_ID('tempdb..#TempInput') IS NOT NULL
			DROP TABLE #TempInput

		CREATE TABLE #TempInput (
			Id INT IDENTITY(1, 1)
			,intBlendDemandItemId INT
			,intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intRecipeId INT
			,intRecipeItemId INT
			)

		IF OBJECT_ID('tempdb..#TempInputALL') IS NOT NULL
			DROP TABLE #TempInputALL

		CREATE TABLE #TempInputALL (
			Id INT
			,intBlendDemandItemId INT
			,intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intRecipeId INT
			,intRecipeItemId INT
			)

		IF OBJECT_ID('tempdb..#TempBlendDemandItem') IS NOT NULL
			DROP TABLE #TempBlendDemandItem

		CREATE TABLE #TempBlendDemandItem (
			Id INT IDENTITY(1, 1)
			,intItemId INT
			)

		INSERT INTO #TempBlendDemandItem
		SELECT DISTINCT intItemId
		FROM tblCTBlendDemand

		SELECT @MinBlendDemandItemId = MIN(Id)
		FROM #TempBlendDemandItem

		WHILE @MinBlendDemandItemId > 0
		BEGIN
			SET @intBlendDemandItemId = NULL
			SET @intBlendDemandItemRecipeId = NULL

			SELECT @intBlendDemandItemId = intItemId
			FROM #TempBlendDemandItem
			WHERE Id = @MinBlendDemandItemId

			SELECT @intBlendDemandItemRecipeId = intRecipeId
			FROM tblMFRecipe
			WHERE intItemId = @intBlendDemandItemId
				AND ysnActive = 1

			INSERT INTO #TempInput (
				intBlendDemandItemId
				,intItemId
				,dblQuantity
				,intRecipeId
				,intRecipeItemId
				)
			SELECT @intBlendDemandItemId
				,RI.intItemId
				,(RI.dblQuantity / R.dblQuantity)
				,RI.intRecipeId
				,RI.intRecipeItemId
			FROM tblMFRecipeItem RI
			JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
				AND ysnActive = 1
			WHERE RI.intRecipeId = @intBlendDemandItemRecipeId
				AND intRecipeItemTypeId = 1

			INSERT INTO #TempInputALL
			SELECT *
			FROM #TempInput

			SELECT @Count = COUNT(*)
			FROM #TempInput

			WHILE @Count > 0
			BEGIN
				SELECT @MinId = Min(Id)
				FROM #TempInput

				WHILE ISNULL(@MinId, 0) > 0
				BEGIN
					SET @intItemId1 = NULL
					SET @intRecipeId = NULL

					DECLARE @MaxId INT = NULL

					SET @dblTotalRecipeItemQty = NULL

					SELECT @intItemId1 = intItemId
						,@dblTotalRecipeItemQty = dblQuantity
					FROM #TempInput
					WHERE Id = @MinId

					SELECT @intRecipeId = intRecipeId
					FROM tblMFRecipe
					WHERE intItemId = @intItemId1
						AND ysnActive = 1

					SELECT @MaxId = MAX(Id)
					FROM #TempInput

					DELETE
					FROM #TempInput
					WHERE Id = @MinId

					IF @intRecipeId IS NOT NULL
					BEGIN
						DELETE
						FROM #TempInputALL
						WHERE Id = @MinId
					END

					INSERT INTO #TempInput (
						intBlendDemandItemId
						,intItemId
						,dblQuantity
						,intRecipeId
						,intRecipeItemId
						)
					SELECT @intBlendDemandItemId
						,intItemId
						,(dblQuantity * @dblTotalRecipeItemQty)
						,intRecipeId
						,intRecipeItemId
					FROM tblMFRecipeItem
					WHERE intRecipeId = @intRecipeId
						AND intRecipeItemTypeId = 1

					INSERT INTO #TempInputALL
					SELECT *
					FROM #TempInput
					WHERE Id > @MaxId

					SELECT @MinId = Min(Id)
					FROM #TempInput
					WHERE Id > @MinId
				END

				SELECT @Count = COUNT(*)
				FROM #TempInput
			END

			SELECT @MinBlendDemandItemId = Min(Id)
			FROM #TempBlendDemandItem
			WHERE Id > @MinBlendDemandItemId
		END

		--SELECT * FROM #TempInputALL
		-- Forecast based on Multiple Recipe level ends
		--If @MinReportAttributeID = 8 --Forecasted Consumption
		--BEGIN
		DECLARE @SQL_ForecastedConsumption NVARCHAR(MAX)

		SET @SQL_ForecastedConsumption = ''
		SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '
		SET @Cnt = 1

		WHILE @Cnt <= @intMonthsToView
		BEGIN
			DECLARE @ForecastedConsumption DECIMAL(24, 6) -- INT

			IF (@ForecastedConsumptionXML <> '')
			BEGIN
				IF EXISTS (
						SELECT *
						FROM #TempForecastedConsumption
						WHERE intItemId = @intItemId
							AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
							AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
						)
				BEGIN
					SET @ForecastedConsumption = (
							ISNULL((
									SELECT [FCQty]
									FROM #TempForecastedConsumption
									WHERE intItemId = @intItemId
										AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
										AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
									), 0)
							)
				END
				ELSE
				BEGIN
					--SET @ForecastedConsumption = (
					--		ISNULL((
					--				SELECT [dblQuantity]
					--				FROM tblCTForecastedConsumption
					--				WHERE [intItemId] = @intItemId
					--					AND intUnitMeasureId = @TargetUOMKey
					--					AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
					--					AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
					--				), 0)
					--		)
					--SET @ForecastedConsumption = (
					--		ISNULL((SELECT SUM(RI.dblCalculatedQuantity * BD.dblQuantity)
					--		FROM tblMFRecipeItem RI
					--		JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
					--			AND R.ysnActive = 1
					--			AND RI.intRecipeItemTypeId = 1
					--		JOIN tblCTBlendDemand BD ON BD.intItemId = R.intItemId
					--			AND RIGHT(RTRIM(LEFT(CONVERT(VARCHAR(11), BD.dtmDemandDate, 106), 7)), 3) = LEFT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
					--			AND RIGHT(CONVERT(VARCHAR(11), RTRIM(BD.dtmDemandDate), 106), 4) = RIGHT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
					--		WHERE RI.intItemId = @intItemId)
					--		,0)
					--	)
					SET @ForecastedConsumption = (
							SELECT dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @SourceUOMKey, @TargetUOMKey, ISNULL(SUM(TIA.dblQuantity * BD.dblQuantity), 0))
							FROM #TempInputALL TIA
							JOIN tblCTBlendDemand BD ON BD.intItemId = TIA.intBlendDemandItemId
								AND RIGHT(RTRIM(LEFT(CONVERT(VARCHAR(11), BD.dtmDemandDate, 106), 7)), 3) = LEFT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
								AND RIGHT(CONVERT(VARCHAR(11), RTRIM(BD.dtmDemandDate), 106), 4) = RIGHT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
							WHERE TIA.intItemId = @intItemId
							)
						--DROP TABLE #TempInput
						--DROP TABLE #TempInputALL
						--DROP TABLE #TempBlendDemandItem
				END
			END
			ELSE
			BEGIN
				--SET @ForecastedConsumption = (
				--		ISNULL((
				--				SELECT [dblQuantity]
				--				FROM tblCTForecastedConsumption
				--				WHERE [intItemId] = @intItemId
				--					AND intUnitMeasureId = @TargetUOMKey
				--					AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
				--					AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
				--				), 0)
				--		)
				--SET @ForecastedConsumption = (
				--			ISNULL((SELECT SUM(RI.dblCalculatedQuantity * BD.dblQuantity)
				--			FROM tblMFRecipeItem RI
				--			JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
				--				AND R.ysnActive = 1
				--				AND RI.intRecipeItemTypeId = 1
				--			JOIN tblCTBlendDemand BD ON BD.intItemId = R.intItemId
				--				AND RIGHT(RTRIM(LEFT(CONVERT(VARCHAR(11), BD.dtmDemandDate, 106), 7)), 3) = LEFT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
				--				AND RIGHT(CONVERT(VARCHAR(11), RTRIM(BD.dtmDemandDate), 106), 4) = RIGHT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
				--			WHERE RI.intItemId = @intItemId)
				--			,0)
				--		)
				SET @ForecastedConsumption = (
						SELECT dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @SourceUOMKey, @TargetUOMKey, ISNULL(SUM(TIA.dblQuantity * BD.dblQuantity), 0))
						FROM #TempInputALL TIA
						JOIN tblCTBlendDemand BD ON BD.intItemId = TIA.intBlendDemandItemId
							AND RIGHT(RTRIM(LEFT(CONVERT(VARCHAR(11), BD.dtmDemandDate, 106), 7)), 3) = LEFT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
							AND RIGHT(CONVERT(VARCHAR(11), RTRIM(BD.dtmDemandDate), 106), 4) = RIGHT(CONVERT(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
						WHERE TIA.intItemId = @intItemId
						)
			END

			SET @SQL_ForecastedConsumption = @SQL_ForecastedConsumption + ' DECLARE @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
			SET @SQL_ForecastedConsumption = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @ForecastedConsumption)) + ' '
			SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @ForecastedConsumption)) + ' '
			SET @Cnt = @Cnt + 1
		END

		SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 8 '
		SET @SQL = @SQL + @SQL_ForecastedConsumption

		--END
		--If @MinReportAttributeID = 5 --Planned Purchases - Bags(Standard UOM)
		--BEGIN
		DECLARE @SQL_PlannedPurchasesStd NVARCHAR(MAX)

		SET @SQL_PlannedPurchasesStd = ''
		SET @SQL = @SQL + ' Update @Table SET PastDue = PastDue '
		SET @Cnt = 1

		WHILE @Cnt <= @intMonthsToView
		BEGIN
			DECLARE @PlannedPurchase DECIMAL(24, 6) -- INT

			IF @ysnCalculatePlannedPurchases = 1
			BEGIN
				SET @PlannedPurchase = 0
			END
			ELSE
			BEGIN
				IF (@PlannedPurchasesXML <> '')
				BEGIN
					IF EXISTS (
							SELECT *
							FROM #TempPlannedPurchases
							WHERE intItemId = @intItemId
								AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
								AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
							)
					BEGIN
						SET @PlannedPurchase = (
								ISNULL((
										SELECT [dblQuantity]
										FROM #TempPlannedPurchases
										WHERE intItemId = @intItemId
											AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
											AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
										), 0)
								)
					END
					ELSE
					BEGIN
						SET @PlannedPurchase = (
								ISNULL((
										SELECT [dblQuantity]
										FROM tblCTPlannedPurchases
										WHERE [intItemId] = @intItemId
											AND intUnitMeasureId = @TargetUOMKey
											AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
											AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
										), 0)
								)
					END
				END
				ELSE
				BEGIN
					SET @PlannedPurchase = (
							ISNULL((
									SELECT [dblQuantity]
									FROM tblCTPlannedPurchases
									WHERE [intItemId] = @intItemId
										AND intUnitMeasureId = @TargetUOMKey
										AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
										AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
									), 0)
							)
				END
			END

			SET @SQL_PlannedPurchasesStd = @SQL_PlannedPurchasesStd + ' DECLARE @PlannedPurchasesStd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '
			SET @SQL_PlannedPurchasesStd = @SQL_PlannedPurchasesStd + ' SET @PlannedPurchasesStd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PlannedPurchase)) + ' '
			SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PlannedPurchase)) + ' '
			SET @Cnt = @Cnt + 1
		END

		SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 5 '
		SET @SQL = @SQL + @SQL_PlannedPurchasesStd

		--END	
		--If @MinReportAttributeID = 11 --Weeks of Supply Target
		--BEGIN
		DECLARE @SQL_WeeksOfSupplyTarget NVARCHAR(MAX)

		SET @SQL_WeeksOfSupplyTarget = ''
		SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '
		SET @Cnt = 1

		WHILE @Cnt <= @intMonthsToView
		BEGIN
			DECLARE @WeeksOfSupplyTarget DECIMAL(24, 6) -- INT

			IF (@WeeksOfSupplyTargetXML <> '')
			BEGIN
				IF EXISTS (
						SELECT *
						FROM #TempWeeksOfSupplyTarget
						WHERE intItemId = @intItemId
							AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
							AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
						)
				BEGIN
					SET @WeeksOfSupplyTarget = (
							ISNULL((
									SELECT [Target]
									FROM #TempWeeksOfSupplyTarget
									WHERE intItemId = @intItemId
										AND [strMonth] = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
										AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
									), 0)
							)
				END
				ELSE
				BEGIN
					SET @WeeksOfSupplyTarget = (
							ISNULL((
									SELECT [dblQuantity]
									FROM tblCTWeeksofSupplyTarget
									WHERE [intItemId] = @intItemId
										AND intUnitMeasureId = @TargetUOMKey
										AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
										AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
									), 0)
							)
				END
			END
			ELSE
			BEGIN
				SET @WeeksOfSupplyTarget = (
						ISNULL((
								SELECT [dblQuantity]
								FROM tblCTWeeksofSupplyTarget
								WHERE [intItemId] = @intItemId
									AND intUnitMeasureId = @TargetUOMKey
									AND left([strMonth], 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
									AND [strYear] = Right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
								), 0)
						)
			END

			SET @SQL_WeeksOfSupplyTarget = @SQL_WeeksOfSupplyTarget + ' DECLARE @WeeksOfSupplyTarget' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
			SET @SQL_WeeksOfSupplyTarget = @SQL_WeeksOfSupplyTarget + ' SET @WeeksOfSupplyTarget' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupplyTarget)) + ' '
			SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupplyTarget)) + ' '
			SET @Cnt = @Cnt + 1
		END

		SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 11 '
		SET @SQL = @SQL + @SQL_WeeksOfSupplyTarget

		--END	
		IF (@FetchExisting = 1)
		BEGIN
			--*****************If new Months to view is less than or equal to existing saved months ****************************
			SET @SQL = @SQL + ' Update @Table SET  OpeningInv = CASE WHEN ISNUMERIC(Ext.OpeningInv)=1 THEN CAST(Ext.OpeningInv AS float)  
                     ELSE NULL END, PastDue = Ext.PastDue '
			SET @Cnt = 1

			WHILE @Cnt <= @NewMonthsToView
			BEGIN
				SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = Ext.strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
				SET @Cnt = @Cnt + 1
			END

			SET @SQL = @SQL + ' FROM (
									Select * from (
									select	*
									from	tblCTInvPlngReportAttributeValue s
									 ) as st
										pivot
										(
											max(strValue)
											for strFieldName in (OpeningInv,PastDue'
			SET @Cnt = 1

			WHILE @Cnt <= @NewMonthsToView
			BEGIN
				SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
				SET @Cnt = @Cnt + 1
			END

			SET @SQL = @SQL + ')
										) p
									) Ext WHERE Ext.intInvPlngReportMasterID = ' + CAST(@intInvPlngReportMasterID AS NVARCHAR(20)) + ' AND [@Table].intItemId = ' + CAST(@intItemId AS NVARCHAR(20)) + ' AND Ext.intItemId = ' + CAST(@intItemId AS NVARCHAR(20)) + ' AND [@Table].AttributeId = Ext.intReportAttributeID  '

			IF @NewMonthsToView > @ExistingMonthsToView
			BEGIN
				SET @Cnt = @ExistingMonthsToView + 1

				WHILE @Cnt <= @intMonthsToView
				BEGIN
					DECLARE @MinReportAttributeID_Ext INT
						,@MaxReportAttributeID_Ext INT

					SELECT @MinReportAttributeID_Ext = MIN(intReportAttributeID)
						,@MaxReportAttributeID_Ext = MAX(intReportAttributeID)
					FROM dbo.tblCTReportAttribute
					WHERE intReportMasterID = @intReportMasterID

					WHILE (@MinReportAttributeID_Ext <= @MaxReportAttributeID_Ext)
					BEGIN
						IF @MinReportAttributeID_Ext = 2 --Opening Inventory
						BEGIN
							BEGIN
								SET @SQL = @SQL + ' Declare @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt - 1) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' = @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 2 '
							END
						END

						IF @MinReportAttributeID_Ext = 4 --Existing Purchases
						BEGIN
							DECLARE @SQL_ExistingPurchases_Ext NVARCHAR(MAX)

							SET @SQL_ExistingPurchases_Ext = ''
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueExistingPurchases)) + ' '
							SET @SQL_ExistingPurchases_Ext = @SQL_ExistingPurchases_Ext + ' DECLARE @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

							DECLARE @SQL_ExistingPurchases_Exec_Ext NVARCHAR(MAX)

							SET @SQL_ExistingPurchases_Exec_Ext = 'SELECT @ExistingPurchases = ' + CAST(ISNULL((
											SELECT SUM(CASE 
														WHEN @TargetUOMKey = IUOM.intUnitMeasureId
															THEN SS.dblBalance
														ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, SS.dblBalance)
														END)
											FROM [dbo].[tblCTContractDetail] SS
											JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = SS.intItemUOMId
											WHERE SS.intItemId = @intItemId
												AND SS.intContractStatusId = 1
												AND left(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate), 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
												AND right(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate, 107), 4) = right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
											), 0) AS NVARCHAR(50)) + ' '

							DECLARE @ExistingPurchases_Ext DECIMAL(24, 6)

							SET @ExistingPurchases_Ext = 0

							EXEC sp_executesql @SQL_ExistingPurchases_Exec_Ext
								,N'@ExistingPurchases decimal(24,6) out'
								,@ExistingPurchases_Ext OUT

							SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases_Ext, 0) AS NVARCHAR(50))
							SET @SQL_ExistingPurchases_Ext = @SQL_ExistingPurchases_Ext + ' SET @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases_Ext, 0) AS NVARCHAR(50))
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID_Ext AS NVARCHAR(10)) + ' '
							SET @SQL = @SQL + @SQL_ExistingPurchases_Ext

							-- Open Purchases & In-transit Purchases
							DECLARE @SQL_IntransitPurchases_Exec_Ext NVARCHAR(MAX)

							SET @SQL_IntransitPurchases_Exec_Ext = 'SELECT @IntransitPurchases = ' + CAST(ISNULL((
											SELECT SUM(CASE 
														WHEN @TargetUOMKey = IUOM.intUnitMeasureId
															THEN IV.dblQtyInStockUOM
														ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, IV.dblQtyInStockUOM)
														END)
											FROM [dbo].[vyuLGInventoryView] IV
											JOIN [dbo].[tblCTContractDetail] SS ON SS.intContractDetailId = IV.intContractDetailId
											JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = IV.intWeightItemUOMId
											WHERE IV.intItemId = @intItemId
												AND IV.strStatus = 'In-transit'
												AND SS.intContractStatusId = 1
												AND left(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate), 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
												AND right(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate, 107), 4) = right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
											), 0) AS NVARCHAR(50)) + ' '

							DECLARE @IntransitPurchases_Ext DECIMAL(24, 6)

							SET @IntransitPurchases_Ext = 0

							EXEC sp_executesql @SQL_IntransitPurchases_Exec_Ext
								,N'@IntransitPurchases decimal(24,6) out'
								,@IntransitPurchases_Ext OUT

							SET @SQL = @SQL + ' Update @Table SET PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueIntransitPurchases))
							SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@IntransitPurchases_Ext, 0) AS NVARCHAR(50))
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 14'
							SET @SQL = @SQL + ' Update @Table SET PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueExistingPurchases) - convert(DECIMAL(24, 6), @PastDueIntransitPurchases))
							SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases_Ext, 0) - ISNULL(@IntransitPurchases_Ext, 0) AS NVARCHAR(50))
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 13'
						END

						IF @MinReportAttributeID_Ext = 6 --Planned Purchases - (Convert to base UOM)
						BEGIN
							DECLARE @SQL_PlannedPurchasesBase_Ext NVARCHAR(MAX)

							SET @SQL_PlannedPurchasesBase_Ext = ''
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '

							DECLARE @SQL_PlannedPurchasesBase_Exec_Ext NVARCHAR(MAX)

							SET @SQL_PlannedPurchasesBase_Exec_Ext = ''
							SET @SQL_PlannedPurchasesBase_Ext = @SQL_PlannedPurchasesBase_Ext + ' DECLARE @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

							DECLARE @PlannedPurchasesBase_Ext DECIMAL(24, 6)

							SET @PlannedPurchasesBase_Ext = 0

							IF @ysnCalculatePlannedPurchases = 1
							BEGIN
								SET @PlannedPurchasesBase_Ext = 0
							END
							ELSE
							BEGIN
								SET @SQL_PlannedPurchasesBase_Exec_Ext = @SQL_PlannedPurchasesStd + ' SET @PlannedPurchasesStd = @PlannedPurchasesStd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

								DECLARE @PlannedPurchasesStd_Ext DECIMAL(24, 6)

								EXEC sp_executesql @SQL_PlannedPurchasesBase_Exec_Ext
									,N'@PlannedPurchasesStd decimal(24,6) out'
									,@PlannedPurchasesStd_Ext OUT

								SET @PlannedPurchasesBase_Ext = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @SourceUOMKey, @TargetUOMKey, ISNULL(@PlannedPurchasesStd_Ext, 0))
							END

							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' =  ' + CAST(ISNULL(@PlannedPurchasesBase_Ext, 0) AS NVARCHAR(50))
							SET @SQL_PlannedPurchasesBase_Ext = @SQL_PlannedPurchasesBase_Ext + ' SET @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + CAST(@PlannedPurchasesBase_Ext AS NVARCHAR(50))
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID_Ext AS NVARCHAR(10)) + ' '
							SET @SQL = @SQL + @SQL_PlannedPurchasesBase_Ext
						END

						IF @MinReportAttributeID_Ext = 7 --Total Deliveries
						BEGIN
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = (ISNULL((SELECT PastDue FROM @Table WHERE strAttributeName = ''Existing Purchases'' AND intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' ),0)) '
							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								=   @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + '
									+      
									@PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID_Ext AS NVARCHAR(10)) + ' '
						END

						IF @MinReportAttributeID_Ext = 9 --Ending Inventory
						BEGIN
							DECLARE @SQL_EndingInv_Ext NVARCHAR(MAX)

							SET @SQL_EndingInv_Ext = ''
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '

							DECLARE @EndingInv_Ext DECIMAL(24, 6)
							DECLARE @OpeningInv_Ext DECIMAL(24, 6)
							DECLARE @SQL_EndingInv_Exec_Ext NVARCHAR(MAX)

							SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' DECLARE @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '
							SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' DECLARE @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' decimal(24,6) '
							SET @SQL_EndingInv_Exec_Ext = ''
							SET @SQL_EndingInv_Exec_Ext = @SQL_ExistingPurchases_Ext + ' SET @ExistingPurchases = @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
							SET @ExistingPurchases_Ext = 0

							EXEC sp_executesql @SQL_EndingInv_Exec_Ext
								,N'@ExistingPurchases decimal(24,6) out'
								,@ExistingPurchases_Ext OUT

							SET @SQL_EndingInv_Exec_Ext = ''
							SET @SQL_EndingInv_Exec_Ext = @SQL_PlannedPurchasesBase_Ext + ' SET @PlannedPurchasesBase = @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
							SET @PlannedPurchasesBase_Ext = 0

							EXEC sp_executesql @SQL_EndingInv_Exec_Ext
								,N'@PlannedPurchasesBase decimal(24,6) out'
								,@PlannedPurchasesBase_Ext OUT

							SET @SQL_EndingInv_Exec_Ext = ''
							SET @SQL_EndingInv_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
							SET @ForecastedConsumption = 0

							EXEC sp_executesql @SQL_EndingInv_Exec_Ext
								,N'@ForecastedConsumption decimal(24,6) out'
								,@ForecastedConsumption OUT

							IF @Cnt = 1
							BEGIN
								SET @EndingInv_Ext = 0
								SET @EndingInv_Ext = ISNULL(@OpeningInventory, 0) + ISNULL(@PastDueExistingPurchases, 0) + ISNULL(@ExistingPurchases_Ext, 0) + ISNULL(@PlannedPurchasesBase_Ext, 0) - ISNULL(@ForecastedConsumption, 0)
								--If @EndingInv < 0
								--	SET @EndingInv = 0
								SET @OpeningInv_Ext = 0
								--SET @OpeningInv = ISNULL(@EndingInv,0)
								SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' SET @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @EndingInv_Ext)) + ''
								SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' SET @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @OpeningInv_Ext)) + ''
							END
							ELSE
							BEGIN
								--SET @OpeningInv = 0											
								--SET @OpeningInv = ISNULL(@EndingInv,0)
								DECLARE @SQL_OpeningInv_Exec_Ext NVARCHAR(max)

								SET @SQL_OpeningInv_Exec_Ext = ''
								SET @SQL_OpeningInv_Exec_Ext = @SQL + ' SET @OpeningInv = @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
								SET @OpeningInv_Ext = 0

								EXEC sp_executesql @SQL_OpeningInv_Exec_Ext
									,N'@OpeningInv decimal(24,6) out'
									,@OpeningInv_Ext OUT

								SET @EndingInv_Ext = 0
								SET @EndingInv_Ext = ISNULL(@OpeningInv_Ext, 0) + ISNULL(@ExistingPurchases_Ext, 0) + ISNULL(@PlannedPurchasesBase_Ext, 0) - ISNULL(@ForecastedConsumption, 0)
								SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' SET @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @EndingInv_Ext)) + ''
								SET @SQL_EndingInv_Ext = @SQL_EndingInv_Ext + ' SET @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @OpeningInv_Ext)) + ''
							END

							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = 
											CASE AttributeId WHEN 9 THEN  ''' + convert(VARCHAR, @EndingInv_Ext) + ''' '
							SET @SQL = @SQL + 'ELSE strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' END '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + '  '
							SET @SQL = @SQL + @SQL_EndingInv_Ext
						END

						IF @MinReportAttributeID_Ext = 10 --Weeks of Supply
						BEGIN
							DECLARE @SQL_WeeksOfSupply_Ext NVARCHAR(MAX)

							SET @SQL_WeeksOfSupply_Ext = ''
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '
							SET @SQL_WeeksOfSupply_Ext = @SQL_WeeksOfSupply_Ext + ' DECLARE @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '
							SET @SQL_WeeksOfSupply_Ext = @SQL_WeeksOfSupply_Ext + ' DECLARE @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '

							DECLARE @ForecastedConsumption1_Ext DECIMAL(24, 6)
							DECLARE @ForecastedConsumption2_Ext DECIMAL(24, 6)
							DECLARE @ForecastedConsumption3_Ext DECIMAL(24, 6)
							DECLARE @AvgFC_Ext DECIMAL(24, 6)
							DECLARE @WeeksOfSupply_Ext DECIMAL(24, 6)

							SET @ForecastedConsumption1_Ext = 0
							SET @ForecastedConsumption2_Ext = 0
							SET @ForecastedConsumption3_Ext = 0
							SET @AvgFC_Ext = 0
							SET @WeeksOfSupply_Ext = 0

							DECLARE @SQL_WeeksOfSupply_Exec_Ext NVARCHAR(MAX)

							IF (@Cnt + 2) >= @intMonthsToView
							BEGIN
								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption1 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + ''
								SET @ForecastedConsumption1_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption1 decimal(24,6) out'
									,@ForecastedConsumption1_Ext OUT

								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption2 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ''
								SET @ForecastedConsumption2_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption2 decimal(24,6) out'
									,@ForecastedConsumption2_Ext OUT

								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption3 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + ''
								SET @ForecastedConsumption3_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption3 decimal(24,6) out'
									,@ForecastedConsumption3_Ext OUT

								SET @AvgFC_Ext = (ISNULL(@ForecastedConsumption1_Ext, 0) + ISNULL(@ForecastedConsumption2_Ext, 0) + ISNULL(@ForecastedConsumption3_Ext, 0))

								IF @AvgFC_Ext = 0
									SET @AvgFC_Ext = 1
								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_EndingInv_Ext + ' SET @EndingInv = @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ''
								SET @EndingInv_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@EndingInv decimal(24,6) out'
									,@EndingInv_Ext OUT

								IF ISNULL(@EndingInv_Ext, 0) <> 0
									SET @WeeksOfSupply_Ext = (@EndingInv_Ext / (@AvgFC_Ext / 13))
							END
							ELSE
							BEGIN
								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption1 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + ''
								SET @ForecastedConsumption1_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption1 decimal(24,6) out'
									,@ForecastedConsumption1_Ext OUT

								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption2 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ''
								SET @ForecastedConsumption2_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption2 decimal(24,6) out'
									,@ForecastedConsumption2_Ext OUT

								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption3 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + ''
								SET @ForecastedConsumption3_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@ForecastedConsumption3 decimal(24,6) out'
									,@ForecastedConsumption3_Ext OUT

								SET @AvgFC_Ext = (ISNULL(@ForecastedConsumption1_Ext, 0) + ISNULL(@ForecastedConsumption2_Ext, 0) + ISNULL(@ForecastedConsumption3_Ext, 0))

								IF @AvgFC_Ext = 0
									SET @AvgFC_Ext = 1
								SET @SQL_WeeksOfSupply_Exec_Ext = ''
								SET @SQL_WeeksOfSupply_Exec_Ext = @SQL_EndingInv_Ext + ' SET @EndingInv = @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ''
								SET @EndingInv_Ext = 0

								EXEC sp_executesql @SQL_WeeksOfSupply_Exec_Ext
									,N'@EndingInv decimal(24,6) out'
									,@EndingInv_Ext OUT

								IF ISNULL(@EndingInv_Ext, 0) <> 0
									SET @WeeksOfSupply_Ext = (@EndingInv_Ext / (@AvgFC_Ext / 13))
							END

							SET @SQL_WeeksOfSupply_Ext = @SQL_WeeksOfSupply_Ext + ' SET @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupply_Ext)) + ' '
							SET @SQL_WeeksOfSupply_Ext = @SQL_WeeksOfSupply_Ext + ' SET @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @AvgFC_Ext)) + ' '
							SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupply_Ext)) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID_Ext AS NVARCHAR(10)) + ' '
							SET @SQL = @SQL + @SQL_WeeksOfSupply_Ext
						END

						IF @MinReportAttributeID_Ext = 12 --Short/Excess Inventory
						BEGIN
							DECLARE @SQL_ShortExcess_Ext NVARCHAR(MAX)

							SET @SQL_ShortExcess_Ext = ''
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '

							DECLARE @SQL_ShortExcess_Exec_Ext NVARCHAR(MAX)

							SET @SQL_ShortExcess_Exec_Ext = ''
							SET @SQL_ShortExcess_Ext = @SQL_ShortExcess_Ext + ' DECLARE @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

							DECLARE @ShortExcess_Ext DECIMAL(24, 6)

							SET @ShortExcess_Ext = 0
							SET @WeeksOfSupplyTarget = 0
							SET @WeeksOfSupply_Ext = 0
							SET @AvgFC_Ext = 0
							SET @SQL_ShortExcess_Exec_Ext = @SQL_WeeksOfSupplyTarget + ' SET @WeeksOfSupplyTarget = @WeeksOfSupplyTarget' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

							EXEC sp_executesql @SQL_ShortExcess_Exec_Ext
								,N'@WeeksOfSupplyTarget decimal(24,6) out'
								,@WeeksOfSupplyTarget OUT

							SET @SQL_ShortExcess_Exec_Ext = ''
							SET @SQL_ShortExcess_Exec_Ext = @SQL_WeeksOfSupply_Ext + ' SET @WeeksOfSupply = @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

							EXEC sp_executesql @SQL_ShortExcess_Exec_Ext
								,N'@WeeksOfSupply decimal(24,6) out'
								,@WeeksOfSupply_Ext OUT

							SET @SQL_ShortExcess_Exec_Ext = ''
							SET @SQL_ShortExcess_Exec_Ext = @SQL_WeeksOfSupply_Ext + ' SET @AvgFC = @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

							EXEC sp_executesql @SQL_ShortExcess_Exec_Ext
								,N'@AvgFC decimal(24,6) out'
								,@AvgFC_Ext OUT

							IF @AvgFC_Ext = 0
								SET @AvgFC_Ext = 1
							SET @ShortExcess_Ext = ((@WeeksOfSupplyTarget - @WeeksOfSupply_Ext) * (@AvgFC_Ext / 13))
							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								=  ' + CAST(@ShortExcess_Ext AS NVARCHAR(50)) + ''
							SET @SQL_ShortExcess_Ext = @SQL_ShortExcess_Ext + ' SET @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + CAST(@ShortExcess_Ext AS NVARCHAR(50))
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID_Ext AS NVARCHAR(10)) + ' '
							SET @SQL = @SQL + @SQL_ShortExcess_Ext

							IF @ysnCalculatePlannedPurchases = 1
							BEGIN
								-- 5 -  Planned Purchases Std
								SET @SQL = @SQL + ' Update @Table SET   
								PastDue = PastDue '
								SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									= convert(decimal(24,6),( CASE WHEN @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' <= 0 THEN 0
										ELSE (ABS(@ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')
										/' + convert(VARCHAR, convert(DECIMAL(24, 10), @Conversion_Factor)) + ') END ))'
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 5 '
								-- 6 - Planned Purchases Base
								SET @SQL = @SQL + ' Update @Table SET   
								PastDue = PastDue '
								SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									= convert(decimal(24,6),( dbo.fnCTConvertQuantityToTargetItemUOM(' + Cast(@intItemId AS NVARCHAR(10)) + ', 
										' + CAST(@SourceUOMKey AS NVARCHAR(5)) + '  , ' + CAST(@TargetUOMKey AS NVARCHAR(5)) + ' ,  
										ISNULL( CASE WHEN @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' <= 0 THEN 0
										ELSE (ABS(@ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')
										/' + convert(VARCHAR, convert(DECIMAL(24, 10), @Conversion_Factor)) + ') END ,0)
										) )) '
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 6 '
								-- 7 - Total Deliveries
								SET @SQL = @SQL + ' Declare @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 4 '
								SET @SQL = @SQL + ' Declare @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 6 '
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= convert(decimal(24,6),( @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' ))'
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 7 '

								-- 9 - Ending Inv
								IF @Cnt = 1
								BEGIN
									SET @SQL = @SQL + ' Update @Table SET   
									strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
									= convert(decimal(24,6),( ' + Cast(ISNULL(@OpeningInventory, 0) AS NVARCHAR(30)) + '
									+ ' + Cast(ISNULL(@PastDueExistingPurchases, 0) AS NVARCHAR(30)) + ' 
									+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									- @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' ))'
									SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
								END
								ELSE
								BEGIN
									SET @SQL = @SQL + ' Declare @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
									SET @SQL = @SQL + ' SELECT @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
									strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 2 '
									SET @SQL = @SQL + ' Update @Table SET   
									strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
									= convert(decimal(24,6),( @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									+ @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
									- @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' ))'
									SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
								END

								-- 10 - Weeks Of Supply
								SET @SQL = @SQL + ' Declare @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
								SET @AvgFC_Ext = 0

								DECLARE @EndingInvAfterCalcPurch_Exec_Ext NVARCHAR(max)

								SET @EndingInvAfterCalcPurch_Exec_Ext = ''
								SET @EndingInvAfterCalcPurch_Exec_Ext = @SQL_WeeksOfSupply_Ext + ' SET @AvgFC = @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

								EXEC sp_executesql @EndingInvAfterCalcPurch_Exec_Ext
									,N'@AvgFC decimal(24,6) out'
									,@AvgFC_Ext OUT

								IF @AvgFC_Ext = 0
									SET @AvgFC_Ext = 1
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= convert(decimal(24,6),( @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								/ (' + Cast(ISNULL(@AvgFC_Ext, 0) AS NVARCHAR(30)) + '/13) ))'
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 10 '
								SET @SQL = @SQL + ' Declare @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 10 '
								SET @SQL = @SQL + ' Declare @WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 11 '
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= convert(decimal(24,6),( (
									@WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								- @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' )
								* (' + Cast(ISNULL(@AvgFC_Ext, 0) AS NVARCHAR(30)) + '/13)
								))'
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 12 '
							END
						END

						SET @MinReportAttributeID_Ext = @MinReportAttributeID_Ext + 1
					END

					SET @Cnt = @Cnt + 1
				END
			END
					--*****************If new Months to view is greater than the existing saved months ****************************
		END
		ELSE
		BEGIN
			SET @Cnt = 1

			WHILE @Cnt <= @intMonthsToView
			BEGIN
				DECLARE @MinReportAttributeID INT
					,@MaxReportAttributeID INT

				SELECT @MinReportAttributeID = MIN(intReportAttributeID)
					,@MaxReportAttributeID = MAX(intReportAttributeID)
				FROM dbo.tblCTReportAttribute
				WHERE intReportMasterID = @intReportMasterID

				WHILE (@MinReportAttributeID <= @MaxReportAttributeID)
				BEGIN
					IF @MinReportAttributeID = 2 --Opening Inventory
					BEGIN
						IF @Cnt = 1
						BEGIN
							SET @SQL = @SQL + ' Update @Table SET   
							OpeningInv = ' + Cast(ISNULL(@OpeningInventory, 0) AS NVARCHAR(30)) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 2 '
						END
						ELSE
						BEGIN
							SET @SQL = @SQL + ' Declare @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
							SET @SQL = @SQL + ' SELECT @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
							strMonth' + CAST((@Cnt - 1) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
							SET @SQL = @SQL + ' Update @Table SET   
							strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' = @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 2 '
						END
					END

					IF @MinReportAttributeID = 4 --Existing Purchases
					BEGIN
						DECLARE @SQL_ExistingPurchases NVARCHAR(MAX)

						SET @SQL_ExistingPurchases = ''
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueExistingPurchases)) + ' '
						SET @SQL_ExistingPurchases = @SQL_ExistingPurchases + ' DECLARE @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

						DECLARE @SQL_ExistingPurchases_Exec NVARCHAR(MAX)

						SET @SQL_ExistingPurchases_Exec = 'SELECT @ExistingPurchases = ' + CAST(ISNULL((
										SELECT SUM(CASE 
													WHEN @TargetUOMKey = IUOM.intUnitMeasureId
														THEN SS.dblBalance
													ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, SS.dblBalance)
													END)
										FROM [dbo].[tblCTContractDetail] SS
										JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = SS.intItemUOMId
										WHERE SS.intItemId = @intItemId
											AND SS.intContractStatusId = 1
											AND left(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate), 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
											AND right(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate, 107), 4) = right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
										), 0) AS NVARCHAR(50)) + ' '

						DECLARE @ExistingPurchases DECIMAL(24, 6)

						SET @ExistingPurchases = 0

						EXEC sp_executesql @SQL_ExistingPurchases_Exec
							,N'@ExistingPurchases decimal(24,6) out'
							,@ExistingPurchases OUT

						SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases, 0) AS NVARCHAR(50))
						SET @SQL_ExistingPurchases = @SQL_ExistingPurchases + ' SET @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases, 0) AS NVARCHAR(50))
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID AS NVARCHAR(10)) + ' '
						SET @SQL = @SQL + @SQL_ExistingPurchases

						-- Open Purchases & In-transit Purchases
						DECLARE @SQL_IntransitPurchases_Exec NVARCHAR(MAX)

						SET @SQL_IntransitPurchases_Exec = 'SELECT @IntransitPurchases = ' + CAST(ISNULL((
										SELECT SUM(CASE 
													WHEN @TargetUOMKey = IUOM.intUnitMeasureId
														THEN IV.dblQtyInStockUOM
													ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, IUOM.intUnitMeasureId, @TargetUOMKey, IV.dblQtyInStockUOM)
													END)
										FROM [dbo].[vyuLGInventoryView] IV
										JOIN [dbo].[tblCTContractDetail] SS ON SS.intContractDetailId = IV.intContractDetailId
										JOIN [dbo].[tblICItemUOM] IUOM ON IUOM.intItemUOMId = IV.intWeightItemUOMId
										WHERE IV.intItemId = @intItemId
											AND IV.strStatus = 'In-transit'
											AND SS.intContractStatusId = 1
											AND left(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate), 3) = left(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 3)
											AND right(convert(CHAR(12), SS.dtmUpdatedAvailabilityDate, 107), 4) = right(convert(CHAR(12), DATEADD(m, (@Cnt - 1), GETDATE()), 107), 4)
										), 0) AS NVARCHAR(50)) + ' '

						DECLARE @IntransitPurchases DECIMAL(24, 6)

						SET @IntransitPurchases = 0

						EXEC sp_executesql @SQL_IntransitPurchases_Exec
							,N'@IntransitPurchases decimal(24,6) out'
							,@IntransitPurchases OUT

						SET @SQL = @SQL + ' Update @Table SET PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueIntransitPurchases))
						SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@IntransitPurchases, 0) AS NVARCHAR(50))
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 14'
						SET @SQL = @SQL + ' Update @Table SET PastDue = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @PastDueExistingPurchases) - convert(DECIMAL(24, 6), @PastDueIntransitPurchases))
						SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + Cast(ISNULL(@ExistingPurchases, 0) - ISNULL(@IntransitPurchases, 0) AS NVARCHAR(50))
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 13'
					END

					IF @MinReportAttributeID = 6 --Planned Purchases - (Convert to base UOM)
					BEGIN
						DECLARE @SQL_PlannedPurchasesBase NVARCHAR(MAX)

						SET @SQL_PlannedPurchasesBase = ''
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '

						DECLARE @SQL_PlannedPurchasesBase_Exec NVARCHAR(MAX)

						SET @SQL_PlannedPurchasesBase_Exec = ''
						SET @SQL_PlannedPurchasesBase = @SQL_PlannedPurchasesBase + ' DECLARE @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

						DECLARE @PlannedPurchasesBase DECIMAL(24, 6)

						SET @PlannedPurchasesBase = 0

						IF @ysnCalculatePlannedPurchases = 1
						BEGIN
							SET @PlannedPurchasesBase = 0
						END
						ELSE
						BEGIN
							SET @SQL_PlannedPurchasesBase_Exec = @SQL_PlannedPurchasesStd + ' SET @PlannedPurchasesStd = @PlannedPurchasesStd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

							DECLARE @PlannedPurchasesStd DECIMAL(24, 6)

							EXEC sp_executesql @SQL_PlannedPurchasesBase_Exec
								,N'@PlannedPurchasesStd decimal(24,6) out'
								,@PlannedPurchasesStd OUT

							SET @PlannedPurchasesBase = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @SourceUOMKey, @TargetUOMKey, ISNULL(@PlannedPurchasesStd, 0))
						END

						SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' =  ' + CAST(ISNULL(@PlannedPurchasesBase, 0) AS NVARCHAR(50))
						SET @SQL_PlannedPurchasesBase = @SQL_PlannedPurchasesBase + ' SET @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + CAST(@PlannedPurchasesBase AS NVARCHAR(50))
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID AS NVARCHAR(10)) + ' '
						SET @SQL = @SQL + @SQL_PlannedPurchasesBase
					END

					IF @MinReportAttributeID = 7 --Total Deliveries
					BEGIN
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = (ISNULL((SELECT PastDue FROM @Table WHERE strAttributeName = ''Existing Purchases'' AND intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' ),0)) '
						SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
							=   @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + '
								+      
								@PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID AS NVARCHAR(10)) + ' '
					END

					IF @MinReportAttributeID = 9 --Ending Inventory
					BEGIN
						DECLARE @SQL_EndingInv NVARCHAR(MAX)

						SET @SQL_EndingInv = ''
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '

						DECLARE @EndingInv DECIMAL(24, 6)
						DECLARE @OpeningInv DECIMAL(24, 6)
						DECLARE @SQL_EndingInv_Exec NVARCHAR(MAX)

						SET @SQL_EndingInv = @SQL_EndingInv + ' DECLARE @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '
						SET @SQL_EndingInv = @SQL_EndingInv + ' DECLARE @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' decimal(24,6) '
						SET @SQL_EndingInv_Exec = ''
						SET @SQL_EndingInv_Exec = @SQL_ExistingPurchases + ' SET @ExistingPurchases = @ExistingPurchases' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
						SET @ExistingPurchases = 0

						EXEC sp_executesql @SQL_EndingInv_Exec
							,N'@ExistingPurchases decimal(24,6) out'
							,@ExistingPurchases OUT

						SET @SQL_EndingInv_Exec = ''
						SET @SQL_EndingInv_Exec = @SQL_PlannedPurchasesBase + ' SET @PlannedPurchasesBase = @PlannedPurchasesBase' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
						SET @PlannedPurchasesBase = 0

						EXEC sp_executesql @SQL_EndingInv_Exec
							,N'@PlannedPurchasesBase decimal(24,6) out'
							,@PlannedPurchasesBase OUT

						SET @SQL_EndingInv_Exec = ''
						SET @SQL_EndingInv_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
						SET @ForecastedConsumption = 0

						EXEC sp_executesql @SQL_EndingInv_Exec
							,N'@ForecastedConsumption decimal(24,6) out'
							,@ForecastedConsumption OUT

						IF @Cnt = 1
						BEGIN
							SET @EndingInv = 0
							SET @EndingInv = ISNULL(@OpeningInventory, 0) + ISNULL(@PastDueExistingPurchases, 0) + ISNULL(@ExistingPurchases, 0) + ISNULL(@PlannedPurchasesBase, 0) - ISNULL(@ForecastedConsumption, 0)
							--If @EndingInv < 0
							--	SET @EndingInv = 0
							SET @OpeningInv = 0
							--SET @OpeningInv = ISNULL(@EndingInv,0)
							SET @SQL_EndingInv = @SQL_EndingInv + ' SET @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @EndingInv)) + ''
							SET @SQL_EndingInv = @SQL_EndingInv + ' SET @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @OpeningInv)) + ''
						END
						ELSE
						BEGIN
							--SET @OpeningInv = 0											
							--SET @OpeningInv = ISNULL(@EndingInv,0)
							DECLARE @SQL_OpeningInv_Exec NVARCHAR(max)

							SET @SQL_OpeningInv_Exec = ''
							SET @SQL_OpeningInv_Exec = @SQL + ' SET @OpeningInv = @OpeningInvFromEnd' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''
							SET @OpeningInv = 0

							EXEC sp_executesql @SQL_OpeningInv_Exec
								,N'@OpeningInv decimal(24,6) out'
								,@OpeningInv OUT

							SET @EndingInv = 0
							SET @EndingInv = ISNULL(@OpeningInv, 0) + ISNULL(@ExistingPurchases, 0) + ISNULL(@PlannedPurchasesBase, 0) - ISNULL(@ForecastedConsumption, 0)
							--If @EndingInv < 0
							--	SET @EndingInv = 0
							SET @SQL_EndingInv = @SQL_EndingInv + ' SET @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @EndingInv)) + ''
							SET @SQL_EndingInv = @SQL_EndingInv + ' SET @OpeningInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @OpeningInv)) + ''
						END

						SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' = 
										CASE AttributeId WHEN 9 THEN  ''' + convert(VARCHAR, @EndingInv) + ''' '
						--if (@Cnt < @intMonthsToView)
						--BEGIN
						--	SET @SQL = @SQL + ' WHEN 2 THEN	''' + convert(varchar,@OpeningInv)  + '''  '
						--END
						SET @SQL = @SQL + 'ELSE strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' END '
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + '  '
						SET @SQL = @SQL + @SQL_EndingInv
					END

					IF @MinReportAttributeID = 10 --Weeks of Supply
					BEGIN
						DECLARE @SQL_WeeksOfSupply NVARCHAR(MAX)

						SET @SQL_WeeksOfSupply = ''
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '
						SET @SQL_WeeksOfSupply = @SQL_WeeksOfSupply + ' DECLARE @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '
						SET @SQL_WeeksOfSupply = @SQL_WeeksOfSupply + ' DECLARE @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6) '

						DECLARE @ForecastedConsumption1 DECIMAL(24, 6)
						DECLARE @ForecastedConsumption2 DECIMAL(24, 6)
						DECLARE @ForecastedConsumption3 DECIMAL(24, 6)
						DECLARE @AvgFC DECIMAL(24, 6)
						DECLARE @WeeksOfSupply DECIMAL(24, 6)

						SET @ForecastedConsumption1 = 0
						SET @ForecastedConsumption2 = 0
						SET @ForecastedConsumption3 = 0
						SET @AvgFC = 0
						SET @WeeksOfSupply = 0

						DECLARE @SQL_WeeksOfSupply_Exec NVARCHAR(MAX)

						IF (@Cnt + 2) >= @intMonthsToView
						BEGIN
							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption1 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + ''
							SET @ForecastedConsumption1 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption1 decimal(24,6) out'
								,@ForecastedConsumption1 OUT

							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption2 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ''
							SET @ForecastedConsumption2 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption2 decimal(24,6) out'
								,@ForecastedConsumption2 OUT

							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption3 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + ''
							SET @ForecastedConsumption3 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption3 decimal(24,6) out'
								,@ForecastedConsumption3 OUT

							SET @AvgFC = (ISNULL(@ForecastedConsumption1, 0) + ISNULL(@ForecastedConsumption2, 0) + ISNULL(@ForecastedConsumption3, 0))

							IF @AvgFC = 0
								SET @AvgFC = 1
							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_EndingInv + ' SET @EndingInv = @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ''
							SET @EndingInv = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@EndingInv decimal(24,6) out'
								,@EndingInv OUT

							IF ISNULL(@EndingInv, 0) <> 0
								SET @WeeksOfSupply = (@EndingInv / (@AvgFC / 13))
						END
						ELSE
						BEGIN
							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption1 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + ''
							SET @ForecastedConsumption1 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption1 decimal(24,6) out'
								,@ForecastedConsumption1 OUT

							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption2 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ''
							SET @ForecastedConsumption2 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption2 decimal(24,6) out'
								,@ForecastedConsumption2 OUT

							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_ForecastedConsumption + ' SET @ForecastedConsumption3 = @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + ''
							SET @ForecastedConsumption3 = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@ForecastedConsumption3 decimal(24,6) out'
								,@ForecastedConsumption3 OUT

							SET @AvgFC = (ISNULL(@ForecastedConsumption1, 0) + ISNULL(@ForecastedConsumption2, 0) + ISNULL(@ForecastedConsumption3, 0))

							IF @AvgFC = 0
								SET @AvgFC = 1
							SET @SQL_WeeksOfSupply_Exec = ''
							SET @SQL_WeeksOfSupply_Exec = @SQL_EndingInv + ' SET @EndingInv = @EndingInv' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ''
							SET @EndingInv = 0

							EXEC sp_executesql @SQL_WeeksOfSupply_Exec
								,N'@EndingInv decimal(24,6) out'
								,@EndingInv OUT

							IF ISNULL(@EndingInv, 0) <> 0
								SET @WeeksOfSupply = (@EndingInv / (@AvgFC / 13))
						END

						SET @SQL_WeeksOfSupply = @SQL_WeeksOfSupply + ' SET @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupply)) + ' '
						SET @SQL_WeeksOfSupply = @SQL_WeeksOfSupply + ' SET @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @AvgFC)) + ' '
						SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + convert(VARCHAR, convert(DECIMAL(24, 6), @WeeksOfSupply)) + ' '
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID AS NVARCHAR(10)) + ' '
						SET @SQL = @SQL + @SQL_WeeksOfSupply
					END

					IF @MinReportAttributeID = 12 --Short/Excess Inventory
					BEGIN
						DECLARE @SQL_ShortExcess NVARCHAR(MAX)

						SET @SQL_ShortExcess = ''
						SET @SQL = @SQL + ' Update @Table SET   
						PastDue = PastDue '

						DECLARE @SQL_ShortExcess_Exec NVARCHAR(MAX)

						SET @SQL_ShortExcess_Exec = ''
						SET @SQL_ShortExcess = @SQL_ShortExcess + ' DECLARE @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

						DECLARE @ShortExcess DECIMAL(24, 6)

						SET @ShortExcess = 0
						SET @WeeksOfSupplyTarget = 0
						SET @WeeksOfSupply = 0
						SET @AvgFC = 0
						SET @SQL_ShortExcess_Exec = @SQL_WeeksOfSupplyTarget + ' SET @WeeksOfSupplyTarget = @WeeksOfSupplyTarget' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

						EXEC sp_executesql @SQL_ShortExcess_Exec
							,N'@WeeksOfSupplyTarget decimal(24,6) out'
							,@WeeksOfSupplyTarget OUT

						SET @SQL_ShortExcess_Exec = ''
						SET @SQL_ShortExcess_Exec = @SQL_WeeksOfSupply + ' SET @WeeksOfSupply = @WeeksOfSupply' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

						EXEC sp_executesql @SQL_ShortExcess_Exec
							,N'@WeeksOfSupply decimal(24,6) out'
							,@WeeksOfSupply OUT

						SET @SQL_ShortExcess_Exec = ''
						SET @SQL_ShortExcess_Exec = @SQL_WeeksOfSupply + ' SET @AvgFC = @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

						EXEC sp_executesql @SQL_ShortExcess_Exec
							,N'@AvgFC decimal(24,6) out'
							,@AvgFC OUT

						IF @AvgFC = 0
							SET @AvgFC = 1
						SET @ShortExcess = ((@WeeksOfSupplyTarget - @WeeksOfSupply) * (@AvgFC / 13))
						SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
							=  ' + CAST(@ShortExcess AS NVARCHAR(50)) + ''
						SET @SQL_ShortExcess = @SQL_ShortExcess + ' SET @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ' + CAST(@ShortExcess AS NVARCHAR(50))
						SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = ' + Cast(@MinReportAttributeID AS NVARCHAR(10)) + ' '
						SET @SQL = @SQL + @SQL_ShortExcess

						IF @ysnCalculatePlannedPurchases = 1
						BEGIN
							SET @SQL = @SQL + ' Declare @5' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' Decimal(24,2) '
							SET @SQL = @SQL + ' SET @5' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								= convert(decimal(24,6),( dbo.fnCTConvertQuantityToTargetItemUOM(' + Cast(@intItemId AS NVARCHAR(10)) + ',' + CAST(@TargetUOMKey AS NVARCHAR(5)) + '  , ' + CAST(@SourceUOMKey AS NVARCHAR(5)) + ' , CASE WHEN @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' <= 0 THEN 0 ELSE
								 ISNULL( ABS(@ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ') ,0) END ) ))'
							--SET @SQL = @SQL + ' Set @5' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + 
							--		' = convert(decimal(24,6),( CASE WHEN @ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' <= 0 THEN 0
							--		ELSE (ABS(@ShortExcess' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')
							--		/' + convert(VARCHAR, convert(DECIMAL(24, 10), @Conversion_Factor)) + ') END )) '
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '
							--SET @Cnt = 1
							--WHILE @Cnt <= @intMonthsToView
							--BEGIN
							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = @5' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							--	SET @Cnt = @Cnt + 1
							--END
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 5 '
							SET @SQL = @SQL + ' Declare @6' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' Decimal(24,2) '
							SET @SQL = @SQL + ' SET @6' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								= convert(decimal(24,6),( dbo.fnCTConvertQuantityToTargetItemUOM(' + Cast(@intItemId AS NVARCHAR(10)) + ',' + CAST(@SourceUOMKey AS NVARCHAR(5)) + '  , ' + CAST(@TargetUOMKey AS NVARCHAR(5)) + ' , ISNULL( @5' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' ,0) ) ))'
							SET @SQL = @SQL + ' Update @Table SET   
							PastDue = PastDue '
							SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' =  @6' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 6 '
							SET @SQL = @SQL + ' Declare @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
							SET @SQL = @SQL + ' SELECT @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
							strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 4 '
							--SET @SQL = @SQL + ' SELECT strMonth' + CAST((@Cnt) as nvarchar(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId as nvarchar(10)) + ' AND AttributeId = 6 '
							SET @SQL = @SQL + ' Declare @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
							SET @SQL = @SQL + ' SET @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = @6' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' Update @Table SET   
							strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
							= convert(decimal(24,6),( @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
							+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' ))'
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 7 '
							SET @SQL = @SQL + ' Declare @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'

							IF @Cnt = 1
							BEGIN
								SET @SQL = @SQL + ' SET @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								convert(decimal(24,6),( ' + Cast(ISNULL(@OpeningInventory, 0) AS NVARCHAR(30)) + '
								+ ' + Cast(ISNULL(@PastDueExistingPurchases, 0) AS NVARCHAR(30)) + '  
								+ @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								- @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' )) '
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
							END
							ELSE
							BEGIN
								SET @SQL = @SQL + ' Declare @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
								SET @SQL = @SQL + ' SELECT @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' From @Table WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 2 '
								SET @SQL = @SQL + ' SET @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								convert(decimal(24,6),( @OpeningInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								+ @ExistingPurchasesAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								+ @PlannedBaseAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								- @ForecastedConsumption' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' )) '
								SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
								SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 9 '
							END

							SET @AvgFC = 0

							DECLARE @EndingInvAfterCalcPurch_Exec NVARCHAR(max)

							SET @EndingInvAfterCalcPurch_Exec = ''
							SET @EndingInvAfterCalcPurch_Exec = @SQL_WeeksOfSupply + ' SET @AvgFC = @AvgFC' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ''

							EXEC sp_executesql @EndingInvAfterCalcPurch_Exec
								,N'@AvgFC decimal(24,6) out'
								,@AvgFC OUT

							IF @AvgFC = 0
								SET @AvgFC = 1
							SET @SQL = @SQL + ' Declare @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
							SET @SQL = @SQL + ' SET @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								convert(decimal(24,6),( @EndingInvAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								/ (' + Cast(ISNULL(@AvgFC, 0) AS NVARCHAR(30)) + '/13) )) '
							SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 10 '
							SET @SQL = @SQL + ' Declare @WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' decimal(24,6)'
							SET @SQL = @SQL + ' SELECT @WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = 
								@WeeksOfSupplyTarget' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' '
							SET @SQL = @SQL + ' Update @Table SET   
								strMonth' + CAST((@Cnt) AS NVARCHAR(5)) + ' 
								= convert(decimal(24,6),( (
									@WeeksOfSupTarAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' 
								- @WeeksOfSupAfterCalcPurch' + '_' + CAST(@MinRowNo AS NVARCHAR(5)) + '_' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' )
								* (' + Cast(ISNULL(@AvgFC, 0) AS NVARCHAR(30)) + '/13)
								))'
							SET @SQL = @SQL + ' WHERE intItemId = ' + Cast(@intItemId AS NVARCHAR(10)) + ' AND AttributeId = 12 '
						END
					END

					SET @MinReportAttributeID = @MinReportAttributeID + 1
				END

				SET @Cnt = @Cnt + 1
			END
		END

		SET @MinRowNo = @MinRowNo + 1
	END

	--Item and Source of data
	SET @SQL = @SQL + ' Update @Table SET   
		OpeningInv = NULL, PastDue = ''Past Due'' '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = ''' + (left(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 3) + ' ' + right(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 2)) + ' '' '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + '	WHERE AttributeId = 1 '

	DECLARE @SQL1 NVARCHAR(max)

	SET @SQL1 = ''
	SET @SQL1 = @SQL1 + ' Update @Table SET  
						[OpeningInv] = convert(decimal(24,2),(OpeningInv))  
						, [PastDue] = ( CASE WHEN ISNUMERIC(PastDue)=1 THEN convert(decimal(24,2),(PastDue))  ELSE NULL END )  '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL1 = @SQL1 + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = (CASE WHEN ISNUMERIC(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')=1 THEN CAST(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' as decimal(24,2))  
                     ELSE 0.0  END ) '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL1 = @SQL1 + '  WHERE AttributeId <> 1 '
	SET @SQL = @SQL + @SQL1

	DECLARE @SQL2 NVARCHAR(max)

	SET @SQL2 = ''
	SET @SQL2 = @SQL2 + ' Update @Table SET  
						[OpeningInv] = NULL  
						, [PastDue] = NULL '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL2 = @SQL2 + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = NULL '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL2 = @SQL2 + '  WHERE AttributeId = 3 '
	SET @SQL = @SQL + @SQL2
	--SET @SQL = @SQL + ' SELECT * FROM @Table ORDER By intItemId, AttributeId '
	SET @SQL = @SQL + ' SELECT T.* FROM @Table T JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = T.AttributeId ORDER By T.intItemId, RA.intDisplayOrder '
	-- ******* Plan Totals start *****************
	SET @SQL = @SQL + 'DECLARE @Table_Sum table(AttributeId int, strAttributeName nvarchar(50)
						, OpeningInv decimal(24,6), PastDue nvarchar(35)'
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' nvarchar(35) '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' ) '
	SET @SQL = @SQL + ' INSERT INTO @Table_Sum '
	SET @SQL = @SQL + ' SELECT AttributeId, strAttributeName
	,SUM( CASE WHEN ISNUMERIC(OpeningInv)=1 THEN CAST(OpeningInv AS decimal(24,2))  
                     ELSE 0 END ) [OpeningInv]
	,SUM( CASE WHEN ISNUMERIC(PastDue)=1 THEN CAST(PastDue AS decimal(24,2))  
                     ELSE 0 END ) [PastDue]'
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL = @SQL + ' ,SUM(CASE WHEN ISNUMERIC(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ')=1 THEN CAST(strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' AS decimal(24,2))  
                     ELSE 0 END ) [' + (left(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 3) + ' ' + right(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 2)) + '] '
		SET @Cnt = @Cnt + 1
	END

	--SET @SQL = @SQL + ' FROM @Table WHERE AttributeId <> 1 
	SET @SQL = @SQL + ' FROM @Table WHERE AttributeId NOT IN (1,13,14) 
						Group By AttributeId, strAttributeName 
						Order By AttributeId'
	-- Weeks Of Supply					
	SET @SQL = @SQL + ' Update @Table_Sum SET [PastDue] = [PastDue] '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		IF (@Cnt + 2) >= @intMonthsToView
		BEGIN
			SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' 
									= CAst( (CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 9) as Decimal(24,2))
										/
										( 
										(CASE WHEN (CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) =  0 Then 1 Else
										(CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + 
				' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) END)
										 /13)
									) as decimal(24,2))
									'
		END
		ELSE
		BEGIN
			SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' 
									= Cast( (CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 9) as decimal(24,2)) 
										/
										( 
										(CASE WHEN (CAST((Select strMonth' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) = 0 Then 1 Else 
										(CAST((Select strMonth' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + 
				' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) End)
										 /13)
									)  as decimal(24,2))
									'
		END

		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' Where AttributeId = 10'
	-- Weeks of Supply Target
	SET @SQL = @SQL + ' Update @Table_Sum SET [PastDue] = [PastDue] '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		IF (@Cnt + 2) >= @intMonthsToView
		BEGIN
			SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' 
									= Cast( (
										( 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 9) as Decimal(24,2))
										 +
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 12) as Decimal(24,2))
										 )
										/
										( 
										(CASE WHEN (CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + 
				' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) = 0 THEN 1 ELSE 
										(CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@intMonthsToView - 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) END)
										 /13)
									)  as decimal(24,2))
									'
		END
		ELSE
		BEGIN
			SET @SQL = @SQL + ' , strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' 
									= Cast( (
										( 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 9) as Decimal(24,2))
										 +
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 12) as Decimal(24,2))
										 ) 
										/
										( 
										(CASE WHEN (CAST((Select strMonth' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + 
				' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) = 0  Then 1 ELSE 
										(CAST((Select strMonth' + RTRIM(CAST((@Cnt + 1) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 2) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										+ 
										 CAST((Select strMonth' + RTRIM(CAST((@Cnt + 3) AS CHAR(2))) + ' From @Table_Sum Where AttributeId = 8) as Decimal(24,2))
										 ) END )
										 /13)
									)  as decimal(24,2))
									'
		END

		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' Where AttributeId = 11'

	DECLARE @SQL3 NVARCHAR(max)

	SET @SQL3 = ''
	SET @SQL3 = @SQL3 + ' Update @Table_Sum SET  
						[OpeningInv] = NULL  
						, [PastDue] = NULL '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL3 = @SQL3 + ' , strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' = NULL '
		SET @Cnt = @Cnt + 1
	END

	SET @SQL3 = @SQL3 + '  WHERE AttributeId = 3 '
	SET @SQL = @SQL + @SQL3
	SET @SQL = @SQL + ' SELECT AttributeId , strAttributeName 
						, OpeningInv , PastDue '
	SET @Cnt = 1

	WHILE @Cnt <= @intMonthsToView
	BEGIN
		SET @SQL = @SQL + ' ,strMonth' + RTRIM(CAST(@Cnt AS CHAR(2))) + ' [' + (left(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 3) + ' ' + right(convert(CHAR(12), DATEADD(m, @Cnt - 1, GETDATE()), 107), 2)) + ']'
		SET @Cnt = @Cnt + 1
	END

	SET @SQL = @SQL + ' FROM @Table_Sum ORDER By AttributeId '

	--SELECT @SQL
	EXEC (@SQL)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
