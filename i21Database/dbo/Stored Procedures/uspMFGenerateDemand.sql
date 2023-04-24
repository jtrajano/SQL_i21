CREATE PROCEDURE [dbo].[uspMFGenerateDemand] 
(
	@intInvPlngReportMasterID		INT = NULL
  , @ExistingDataXML				NVARCHAR(MAX) = NULL
  , @MaterialKeyXML					NVARCHAR(MAX) = NULL
  , @intMonthsToView				INT = 12
  , @ysnIncludeInventory			BIT = 1
  , @intCompanyLocationId			INT = NULL
  , @intUnitMeasureId				INT
  , @intDemandHeaderId				INT
  , @ysnTest						BIT = 0
  , @ysnAllItem						BIT = 0
  , @intCategoryId					INT
  , @PlannedPurchasesXML			VARCHAR(MAX) = NULL
  , @WeeksOfSupplyTargetXML			VARCHAR(MAX) = NULL
  , @ForecastedConsumptionXML		VARCHAR(MAX) = NULL
  , @OpenPurchaseXML				VARCHAR(MAX) = NULL
  , @ysnCalculatePlannedPurchases	BIT = 0
  , @ysnCalculateEndInventory		BIT = 0
  , @ysnRefreshContract				BIT = 0
  , @ysnRefreshStock				BIT = 0
  , @strRefreshItemStock			NVARCHAR(MAX) = ''
  , @ShortExcessXML					VARCHAR(MAX) = NULL
  , @AdditionalForecastedConsumptionXML VARCHAR(MAX) = NULL
  , @strExternalGroup				NVARCHAR(50) = NULL
  , @InventoryTransferXML			VARCHAR(MAX) = NULL
)
AS
BEGIN TRY

	DECLARE @dtmStartOfMonth				DATETIME
		  , @ysnFGDemand					BIT
		  , @intCurrentMonth				INT
		  , @intMonthId						INT = 1
		  , @intReportMasterID				INT
		  , @idoc							INT
		  , @dtmDate						DATETIME
		  , @intPrevInvPlngReportMasterID	INT
		  , @ysnWeekOfSupply				BIT = 0
		  , @ysnCalculateNoOfContainerByBagQty BIT = 0
		  , @intContainerTypeId				INT
		  , @intItemId						INT
		  , @dblEndInventory				NUMERIC(18, 6)
		  , @intConsumptionMonth			INT
		  , @dblConsumptionQty				NUMERIC(18, 6)
		  , @dblWeeksOfSsupply				NUMERIC(18, 6)
		  , @ysnSupplyTargetbyAverage		BIT
		  , @strSupplyTarget				NVARCHAR(50)
		  , @intNoofWeeksorMonthstoCalculateSupplyTarget	INT
		  , @intNoofWeekstoCalculateSupplyTargetbyAverage	INT
		  , @ysnComputeDemandUsingRecipe    BIT
		  , @ysnDisplayDemandWithItemNoAndDescription BIT
		  , @ysnDemandViewForBlend			BIT
		  , @strContainerType				NVARCHAR(50)
		  , @ysnDisplayRestrictedBookInDemandView BIT
		  , @dblRemainingConsumptionQty		NUMERIC(18, 6)
		  , @dblSupplyTarget				NUMERIC(18, 6)
		  , @dblDecimalPart					NUMERIC(18, 6)
		  , @intIntegerPart					INT
		  , @dblTotalConsumptionQty			NUMERIC(18, 6)
		  , @intConsumptionAvlMonth			INT
		  , @intPrevUnitMeasureId			INT
		  , @intBookId						INT
		  , @intSubBookId					INT
		  , @intDemandAnalysisMonthlyCutOffDay INT
		  , @intLocationId					INT
		  , @intRecordId					INT
		  , @ysnForecastedConsumptionByRemainingDays BIT
		  , @ysnConsiderBookInDemandView	INT
		  , @intPositionByETA				INT

	DECLARE @tblMFContainerWeight TABLE 
	(
		intItemId				INT
	  , dblWeight				NUMERIC(18, 6)
	  , intWeightUnitMeasureId	INT
	);

	DECLARE @tblMFItemBook TABLE 
	(
		intId		INT IDENTITY(1, 1)
	  , intItemId	INT
	  , strBook		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	);

	DECLARE @intItemBookId		INT
		  , @intId				INT
		  , @strBook			NVARCHAR(MAX)
		  , @intRemainingDay	INT
		  , @intNoOfDays		INT

	DECLARE @tblMFItem TABLE 
	(
		intItemId		INT
	  , intMainItemId	INT
	);

	DECLARE @tblMFEndInventory TABLE 
	(
		intRecordId		INT IDENTITY(1, 1)
	  , intItemId		INT
	  , dblQty			NUMERIC(18, 6)
	  , intLocationId	INT
	);

	DECLARE @tblMFItemDetail TABLE 
	(
		intItemId					INT
	  , intMainItemId				INT
	  , ysnSpecificItemDescription	BIT
	  , dblRatio					NUMERIC(18, 6)
	);

	DECLARE @tblSMCompanyLocation TABLE 
	(
		intCompanyLocationId INT
	);

	INSERT INTO @tblSMCompanyLocation (intCompanyLocationId)
	SELECT intCompanyLocationId
	FROM tblSMCompanyLocation

	IF (SELECT COUNT(*) FROM @tblSMCompanyLocation) > 1
		BEGIN
			INSERT INTO @tblSMCompanyLocation (intCompanyLocationId)
			SELECT 9999 AS intCompanyLocationId
		END

	SELECT @intRemainingDay = DATEDIFF(DAY, GETDATE(), DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0))) + 1

	SELECT @intNoOfDays = DATEDIFF(dd, GETDATE(), DATEADD(mm, 1, GETDATE()))

	SELECT @intContainerTypeId								= intContainerTypeId
		 , @ysnCalculateNoOfContainerByBagQty				= ysnCalculateNoOfContainerByBagQty
		 , @ysnSupplyTargetbyAverage						= ysnSupplyTargetbyAverage
		 , @strSupplyTarget									= strSupplyTarget
		 , @intNoofWeeksorMonthstoCalculateSupplyTarget		= ISNULL(intNoofWeeksorMonthstoCalculateSupplyTarget, 3)
		 , @intNoofWeekstoCalculateSupplyTargetbyAverage	= ISNULL(intNoofWeekstoCalculateSupplyTargetbyAverage, 13)
		 , @ysnComputeDemandUsingRecipe						= ysnComputeDemandUsingRecipe
		 , @ysnDisplayDemandWithItemNoAndDescription		= ysnDisplayDemandWithItemNoAndDescription
		 , @ysnDisplayRestrictedBookInDemandView			= ISNULL(ysnDisplayRestrictedBookInDemandView, 0)
		 , @intDemandAnalysisMonthlyCutOffDay				= (CASE WHEN ISNULL(intDemandAnalysisMonthlyCutOffDay, 0) = 0 THEN 32
																	ELSE intDemandAnalysisMonthlyCutOffDay
															   END)
		 , @ysnForecastedConsumptionByRemainingDays			= ysnForecastedConsumptionByRemainingDays
		 , @ysnConsiderBookInDemandView						= ISNULL(ysnConsiderBookInDemandView, 1)
		 , @intPositionByETA								= ISNULL(intPositionByETADemandReport, 2)
	FROM tblMFCompanyPreference

	SELECT @strContainerType = strContainerType
	FROM tblLGContainerType
	WHERE intContainerTypeId = @intContainerTypeId

	/* Contract Configuration - Demand View Recipe by FG. */
	SELECT @ysnDemandViewForBlend = ysnDemandViewForBlend
	FROM tblCTCompanyPreference

	IF @intNoofWeekstoCalculateSupplyTargetbyAverage = 0
		BEGIN
			SET @intNoofWeekstoCalculateSupplyTargetbyAverage = 13;
		END

	IF OBJECT_ID('tempdb..#TempOpenPurchase') IS NOT NULL
		BEGIN
			DROP TABLE #TempOpenPurchase;
		END

	CREATE TABLE #TempOpenPurchase 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	IF OBJECT_ID('tempdb..#TempPlannedPurchases') IS NOT NULL
		BEGIN
			DROP TABLE #TempPlannedPurchases;
		END

	CREATE TABLE #TempPlannedPurchases 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	IF OBJECT_ID('tempdb..#TempForecastedConsumption') IS NOT NULL
		BEGIN
			DROP TABLE #TempForecastedConsumption;
		END

	CREATE TABLE #TempForecastedConsumption 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	IF OBJECT_ID('tempdb..#TempAdditionalForecastedConsumption') IS NOT NULL
		BEGIN
			DROP TABLE #TempAdditionalForecastedConsumption;
		END

	CREATE TABLE #TempAdditionalForecastedConsumption 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	IF OBJECT_ID('tempdb..#TempWeeksOfSupplyTarget') IS NOT NULL
		BEGIN
			DROP TABLE #TempWeeksOfSupplyTarget;
		END

	CREATE TABLE #TempWeeksOfSupplyTarget 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	IF OBJECT_ID('tempdb..#TempInventoryTransfer') IS NOT NULL
		BEGIN
			DROP TABLE #TempInventoryTransfer;
		END

	CREATE TABLE #TempInventoryTransfer 
	(
		intItemId		INT
	  , strName			NVARCHAR(50)
	  , strValue		DECIMAL(24, 6)
	  , intLocationId	INT
	)

	SELECT @intReportMasterID = intReportMasterID
	FROM tblCTReportMaster
	WHERE strReportName = 'Inventory Planning Report'

	IF @intInvPlngReportMasterID > 0
		BEGIN
			SELECT @dtmDate = dtmDate
			FROM tblCTInvPlngReportMaster
			WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID;

			SET @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, @dtmDate), 0);

			SET @intCurrentMonth = DATEDIFF(mm, 0, @dtmDate);
		END
	ELSE
		BEGIN
			SET @dtmDate = GETDATE();

			SET @dtmStartOfMonth = DATEADD(month, DATEDIFF(month, 0, @dtmDate), 0);

			SET @intCurrentMonth = DATEDIFF(mm, 0, @dtmDate);
		END

	SELECT @intBookId		= intBookId
		 , @intSubBookId	= intSubBookId
	FROM tblMFDemandHeader
	WHERE intDemandHeaderId = @intDemandHeaderId

	/* Retrieve last demand saved. */
	IF @intBookId = 0 OR @intBookId IS NULL
		BEGIN
			SELECT TOP 1 @intPrevInvPlngReportMasterID	= intInvPlngReportMasterID
					   , @intPrevUnitMeasureId			= intUnitMeasureId
			FROM tblCTInvPlngReportMaster
			WHERE ysnPost = 1 
			  AND dtmDate <= @dtmDate
			  AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
			ORDER BY intInvPlngReportMasterID DESC
		END
	ELSE
		BEGIN
			IF @intSubBookId = 0 OR @intSubBookId IS NULL
				BEGIN
					SELECT TOP 1 @intPrevInvPlngReportMasterID	= intInvPlngReportMasterID
							   , @intPrevUnitMeasureId			= intUnitMeasureId
					FROM tblCTInvPlngReportMaster
					WHERE ysnPost = 1
					  AND dtmDate <= @dtmDate
					  AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
					  AND intBookId = @intBookId
					ORDER BY intInvPlngReportMasterID DESC
				END
			ELSE
				BEGIN
					SELECT TOP 1 @intPrevInvPlngReportMasterID	= intInvPlngReportMasterID
							   , @intPrevUnitMeasureId			= intUnitMeasureId
					FROM tblCTInvPlngReportMaster
					WHERE ysnPost = 1
					  AND dtmDate <= @dtmDate
					  AND intInvPlngReportMasterID <> @intInvPlngReportMasterID
					  AND intBookId = @intBookId
					  AND intSubBookId = @intSubBookId
					ORDER BY intInvPlngReportMasterID DESC
				END
		END
	/* End of Retrieve last demand saved. */

	IF @intCompanyLocationId = 0
		BEGIN
			SET @intCompanyLocationId = NULL
		END

	IF @intCategoryId = 0
		BEGIN
			SELECT @intCategoryId = NULL
		END


	/* List of Item to be generated (Item Combobox Value from Demand Analysis) / Material Key */
	IF @MaterialKeyXML <> ''
		BEGIN
			/* Staging item id based on combobox. */
			IF @ysnAllItem = 0
				BEGIN
					EXEC sp_xml_preparedocument @idoc OUTPUT
											  , @MaterialKeyXML

					INSERT INTO @tblMFItem (intItemId)
					SELECT intItemId
					FROM OPENXML(@idoc, 'root/Material', 2) WITH (intItemId INT)

					EXEC sp_xml_removedocument @idoc
				END
			/* End of Staging item id based on combobox. */
			ELSE
				BEGIN
					/* If Category (Category Combobox Value from Demand Analysis) is not empty.*/
					IF @intCategoryId IS NOT NULL
						BEGIN
							INSERT INTO @tblMFItem (intItemId)
							SELECT I.intItemId
							FROM tblICItem I
							WHERE I.intCategoryId = @intCategoryId
								AND I.strStatus = 'Active'
								AND NOT EXISTS (SELECT *
												FROM tblMFItemExclude IE /* No Screen for this table, data here are manual encode or script executed from database (JIRA:MFG-4220). */
												WHERE IE.intItemId = I.intItemId
												  AND IE.ysnExcludeInDemandView = 1
												  AND NOT EXISTS (SELECT *
																  FROM tblMFDemandDetail DD
																  WHERE IE.intItemId = ISNULL(DD.intSubstituteItemId, DD.intItemId)
																	AND DD.intDemandHeaderId = @intDemandHeaderId))
						END
					/* End If Category (Category Combobox Value from Demand Analysis) is not empty. */
					ELSE
						BEGIN
							INSERT INTO @tblMFItem (intItemId)
							SELECT I.intItemId
							FROM tblICItem I
							WHERE I.strExternalGroup = @strExternalGroup /* Group Combobox Value from Demand Analysis */
						END
				END
		END
	/* End of Material Key */


	/* Retrieve Item that will be generated. */
	IF @ysnDemandViewForBlend = 1
		BEGIN
			INSERT INTO @tblMFItemDetail 
			(
				intItemId	  /* Bundle Item Id */
			  , intMainItemId /* Bundle Item Id */
			  , ysnSpecificItemDescription
			  , dblRatio
			)
			SELECT DISTINCT R.intItemId
						  , RI.intItemId
						  , 0
						  , RI.dblCalculatedQuantity / (CASE WHEN R.intRecipeTypeId = 1 THEN R.dblQuantity
															 ELSE 1
														END)
			FROM @tblMFItem I
			JOIN tblMFRecipeItem RI ON RI.intItemId = I.intItemId AND RI.intRecipeItemTypeId = 1
			JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId 
							  AND R.ysnActive = 1
							  AND R.intLocationId = IsNULL(@intCompanyLocationId, R.intLocationId)
		END
	ELSE
		BEGIN
			/* Retrieve first substitute item from Demand maintenance. */
			INSERT INTO @tblMFItemDetail 
			(
				intItemId
			  , intMainItemId /* Bundle Item Id */
			  , ysnSpecificItemDescription
			  , dblRatio
			)
			SELECT DISTINCT DD.intSubstituteItemId
						  , DD.intItemId
						  , 1
						  , 1
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON I.intItemId = DD.intSubstituteItemId
			WHERE DD.intDemandHeaderId = @intDemandHeaderId
			/* End of Retrieve first substitute item from Demand maintenance. */

			/* Stage substitute item where main item does not exists yet on staging. */
			UNION ALL

			SELECT DISTINCT DD.intItemId
						  , DD.intItemId
						  , 0
						  , 1
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON I.intItemId = DD.intSubstituteItemId
			WHERE DD.intDemandHeaderId = @intDemandHeaderId AND NOT EXISTS (SELECT *
																			FROM @tblMFItemDetail FI
																			WHERE FI.intItemId = DD.intItemId)
			/* End of Stage substitute item where main item does not exists yet on staging. */

			/* Stage substitute item where substitute item is not empty from demand. */
			UNION ALL

			SELECT DISTINCT DD.intSubstituteItemId
						  , DD.intItemId
						  , 1
						  , 1
			FROM @tblMFItem I
			JOIN tblMFDemandDetail DD ON I.intItemId = DD.intItemId
			WHERE DD.intDemandHeaderId = @intDemandHeaderId AND DD.intSubstituteItemId IS NOT NULL;
			/* End of Stage substitute item where substitute item is not empty from demand. */

			/* Add substitute item to the list of item that will be generated. */
			INSERT INTO @tblMFItem (intItemId)
			SELECT ID.intItemId
			FROM @tblMFItemDetail ID
			WHERE NOT EXISTS (SELECT *
							  FROM @tblMFItem I
							  WHERE I.intItemId = ID.intItemId)
			/* End of Add substitute item to the list of item that will be generated. */

			/* Add bundle's detail item id to staging item */
			INSERT INTO @tblMFItemDetail 
			(
				intItemId	  /* Item Id */
			  , intMainItemId /* Bundle Item Id */
			  , ysnSpecificItemDescription
			  , dblRatio
			)
			SELECT IB.intBundleItemId
				 , IB.intItemId
				 , 0
				 , 1
			FROM @tblMFItem I
			LEFT JOIN tblICItemBundle IB ON IB.intItemId = I.intItemId
			WHERE NOT EXISTS (SELECT *
							  FROM @tblMFItemDetail FI
							  WHERE FI.intItemId = IB.intBundleItemId)
				  AND IB.intBundleItemId IS NOT NULL
			/* End of Add bundle's detail item id to staging item */

			/* Add stage item that does not exists to the list of item that will be generated. */
			UNION ALL

			SELECT intItemId
				 , intItemId
				 , (CASE WHEN EXISTS (SELECT 1 FROM tblICItemBundle IB WHERE IB.intItemId = I.intItemId) THEN 0
						 ELSE 1
					END)
				 , 1
			FROM @tblMFItem I
			WHERE NOT EXISTS (SELECT *
							  FROM @tblMFItemDetail ID
							  WHERE ID.intItemId = I.intItemId)
			/* End of Add stage item that does not exists to the list of item that will be generated. */


			INSERT INTO @tblMFContainerWeight 
			(
				intItemId
			  , dblWeight
			  , intWeightUnitMeasureId
			)
			SELECT ID.intMainItemId
				 , AVG((CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.dblWeight
							 ELSE CTCQ.dblBulkQuantity
						END) * ISNULL(UMCByWeight.dblConversionToStock, 1))
				 , MIN(CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.intWeightUnitMeasureId
							ELSE CT.intWeightUnitMeasureId
					   END)
			FROM @tblMFItemDetail ID
			JOIN tblICItem I ON I.intItemId = ID.intItemId
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId AND CA.intCommodityAttributeId = I.intOriginId
			LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CTCQ.intCommodityAttributeId	= I.intOriginId
														 AND CTCQ.intCommodityId			= I.intCommodityId
														 AND CTCQ.intContainerTypeId		= @intContainerTypeId
														 AND CA.intDefaultPackingUOMId		= CTCQ.intUnitMeasureId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CTCQ.intContainerTypeId
			LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = (CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.intWeightUnitMeasureId
																									 ELSE CT.intWeightUnitMeasureId
																								END) --From Unit
															AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId -- To Unit
			WHERE ID.ysnSpecificItemDescription = 0 AND ID.intItemId <> ID.intMainItemId
			GROUP BY ID.intMainItemId

			INSERT INTO @tblMFContainerWeight 
			(
				intItemId
			  , dblWeight
			  , intWeightUnitMeasureId
			)
			SELECT DISTINCT ID.intItemId
						  , (CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.dblWeight
								  ELSE CTCQ.dblBulkQuantity
							 END) * ISNULL(UMCByWeight.dblConversionToStock, 1)
						  , (CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.intWeightUnitMeasureId
								  ELSE CT.intWeightUnitMeasureId
							 END)
			FROM @tblMFItemDetail ID
			JOIN tblICItem I ON I.intItemId = ID.intItemId
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
			LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CTCQ.intCommodityAttributeId	= I.intOriginId
														 AND CTCQ.intCommodityId			= I.intCommodityId
														 AND CTCQ.intContainerTypeId		= @intContainerTypeId
														 AND CA.intDefaultPackingUOMId		= CTCQ.intUnitMeasureId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CTCQ.intContainerTypeId
			LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId = (CASE WHEN @ysnCalculateNoOfContainerByBagQty = 1 THEN CTCQ.intWeightUnitMeasureId
																									 ELSE CT.intWeightUnitMeasureId
																								END) --From Unit
														    AND UMCByWeight.intStockUnitMeasureId = @intUnitMeasureId -- To Unit
			WHERE ID.ysnSpecificItemDescription = 1
		END

	DELETE FROM @tblMFContainerWeight WHERE dblWeight IS NULL;

	UPDATE I
	SET I.intMainItemId = ID.intMainItemId
	FROM @tblMFItem I
	JOIN @tblMFItemDetail ID ON ID.intItemId = I.intItemId;

	IF @ysnDisplayRestrictedBookInDemandView = 1
		BEGIN
			INSERT INTO @tblMFItemBook (intItemId)
			SELECT DISTINCT intItemId
			FROM @tblMFItem
			WHERE intItemId <> ISNULL(intMainItemId, intItemId)

			SELECT @intId = MIN(intId)
			FROM @tblMFItemBook

			WHILE @intId IS NOT NULL
			BEGIN
				SELECT @intItemBookId	= NULL
					 , @strBook			= ''

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
					BEGIN
						SELECT @strBook = '';
					END

				IF len(@strBook) > 0
					BEGIN
						SELECT @strBook = LEFT(@strBook, LEN(@strBook) - 1)

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
									  , @OpenPurchaseXML

			INSERT INTO #TempOpenPurchase 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , [Value]
				 , LId
			FROM OPENXML(@idoc, 'root/OP', 2) 
			WITH 
			(
				[intItemId]	INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			)

			EXEC sp_xml_removedocument @idoc
		END

	IF @PlannedPurchasesXML <> ''
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
									  , @PlannedPurchasesXML

			INSERT INTO #TempPlannedPurchases 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , [Value]
				 , LId
			FROM OPENXML(@idoc, 'root/PP', 2) 
			WITH 
			(
				[intItemId] INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			);

			EXEC sp_xml_removedocument @idoc
		END

	IF @ForecastedConsumptionXML <> ''
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
									  , @ForecastedConsumptionXML

			INSERT INTO #TempForecastedConsumption 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , -SUM([Value])
				 , LId
			FROM OPENXML(@idoc, 'root/FC', 2) 
			WITH 
			(
				[intItemId] INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			)
			GROUP BY [intItemId]
				   , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0')
				   , LId

			EXEC sp_xml_removedocument @idoc
		END

	IF @AdditionalForecastedConsumptionXML <> ''
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
									  , @AdditionalForecastedConsumptionXML

			INSERT INTO #TempAdditionalForecastedConsumption 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , SUM([Value])
				 , LId
			FROM OPENXML(@idoc, 'root/AFC', 2) 
			WITH 
			(
				[intItemId] INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			)
			GROUP BY [intItemId]
				   , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0')
				   , LId

			EXEC sp_xml_removedocument @idoc
		END

	IF @WeeksOfSupplyTargetXML <> ''
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
									  , @WeeksOfSupplyTargetXML

			INSERT INTO #TempWeeksOfSupplyTarget 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , [Value]
				 , LId
			FROM OPENXML(@idoc, 'root/WST', 2) 
			WITH 
			(
				[intItemId] INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			)

			EXEC sp_xml_removedocument @idoc
		END

	IF @InventoryTransferXML <> ''
		BEGIN
			EXEC sp_xml_preparedocument @idoc OUTPUT
									  , @InventoryTransferXML

			INSERT INTO #TempInventoryTransfer 
			(
				intItemId
			  , strName
			  , strValue
			  , intLocationId
			)
			SELECT [intItemId]
				 , REPLACE(REPLACE([Name], 'strMonth', ''), 'PastDue', '0') AS [Name]
				 , [Value]
				 , LId
			FROM OPENXML(@idoc, 'root/IT', 2) 
			WITH 
			(
				[intItemId] INT
			  , [Name]		NVARCHAR(50)
			  , [Value]		DECIMAL(24, 6)
			  , LId			INT
			)

			EXEC sp_xml_removedocument @idoc
		END

	IF OBJECT_ID('tempdb..#tblMFDemand') IS NOT NULL
		BEGIN
			DROP TABLE #tblMFDemand;
		END

	CREATE TABLE #tblMFDemand 
	(
		intItemId		INT
	  , dblQty			NUMERIC(18, 6)
	  , intAttributeId	INT
	  , intMonthId		INT
	  , intLocationId	INT
	);

	IF OBJECT_ID('tempdb..#tblMFTempDemand') IS NOT NULL
		BEGIN
			DROP TABLE #tblMFTempDemand;
		END

	CREATE TABLE #tblMFTempDemand 
	(
		intItemId		INT
	  , dblQty			NUMERIC(18, 6)
	  , intAttributeId	INT
	  , intMonthId		INT
	  , intLocationId	INT
	);

	IF OBJECT_ID('tempdb..#tblMFInventory') IS NOT NULL
		BEGIN
			DROP TABLE #tblMFInventory;
		END

	CREATE TABLE #tblMFInventory 
	(
		intItemId		INT
	  , dblQty			NUMERIC(18, 6)
	  , intAttributeId	INT
	  , intMonthId		INT
	  , intLocationId	INT
	);

	IF OBJECT_ID('tempdb..#tblMFDemandList') IS NOT NULL
		BEGIN
			DROP TABLE #tblMFDemandList;
		END

	CREATE TABLE #tblMFDemandList 
	(
		intItemId		INT
	  , dblQty			NUMERIC(18, 6)
	  , intAttributeId	INT
	  , intMonthId		INT
	  , intMainItemId	INT
	  , intLocationId	INT
	);

	DECLARE @tblMFRefreshtemStock TABLE (intItemId INT)

	INSERT INTO @tblMFRefreshtemStock
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@strRefreshItemStock, ',')

	DELETE FROM @tblMFRefreshtemStock WHERE intItemId = 0;

	IF NOT EXISTS (SELECT * FROM @tblMFRefreshtemStock)
		BEGIN
			INSERT INTO @tblMFRefreshtemStock
			SELECT DISTINCT intItemId
			FROM @tblMFItemDetail
		END

	/* Retrieve Opening Inventory. */
	IF @ysnIncludeInventory = 1
		BEGIN
			IF @ysnRefreshStock = 1
				BEGIN
					INSERT INTO #tblMFInventory 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								ELSE I.intMainItemId
						   END AS intItemId
						 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(L.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																																 ELSE L.dblWeight
																															END)) * I.dblRatio) AS dblIntrasitQty
						 , 2	AS intAttributeId --Opening Inventory
						 , -1	AS intMonthId
						 , L.intLocationId
					FROM @tblMFItemDetail I
					JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
					JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId) AND L.intLocationId = ISNULL(@intCompanyLocationId, L.intLocationId)
					WHERE EXISTS (SELECT *
								  FROM @tblMFRefreshtemStock EI
								  WHERE EI.intItemId = I.intItemId)
							 AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(L.intBookId, 0)
									   ELSE ISNULL(@intBookId, 0)
								  END) = ISNULL(@intBookId, 0)
							 AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(L.intSubBookId, 0)
									   ELSE ISNULL(@intSubBookId, 0)
								  END) = ISNULL(@intSubBookId, 0)
					GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								  ELSE I.intMainItemId
							 END
						   , L.intLocationId

					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT intItemId
						 , SUM(dblQty)
						 , intAttributeId
						 , intMonthId
						 , intLocationId
					FROM #tblMFInventory
					GROUP BY intItemId
						   , intAttributeId
						   , intMonthId
						   , intLocationId

					UNION ALL

					SELECT intItemId
						 , CASE WHEN strValue = '' THEN NULL
								ELSE strValue
							END --Opening Inventory
						 , 2
						 , REPLACE(REPLACE(REPLACE(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') AS intMonthId
						 , AV.intLocationId
					FROM tblCTInvPlngReportAttributeValue AV
					WHERE intReportAttributeID		= 2 --Opening Inventory
					  AND intInvPlngReportMasterID	= @intInvPlngReportMasterID
					  AND NOT EXISTS (SELECT *
									  FROM @tblMFRefreshtemStock EI
									  WHERE EI.intItemId = AV.intItemId);
				END
			ELSE
				BEGIN
					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT intItemId
						 , CASE WHEN strValue = '' THEN NULL
								ELSE strValue
						   END --Opening Inventory
						 , 2
						 , REPLACE(REPLACE(REPLACE(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
						 , intLocationId
					FROM tblCTInvPlngReportAttributeValue
					WHERE intReportAttributeID		= 2 --Opening Inventory
					  AND intInvPlngReportMasterID	= @intInvPlngReportMasterID
				END
		END
	ELSE
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , dblQty
			  , intAttributeId
			  , intMonthId
			)
			SELECT I.intItemId
				 , 0
				 , 2	AS intAttributeId --Opening Inventory
				 , -1	AS intMonthId
			FROM @tblMFItem I
			INNER JOIN @tblSMCompanyLocation L ON 1 = 1
			WHERE L.intCompanyLocationId = ISNULL(@intCompanyLocationId, L.intCompanyLocationId)
		END
	/* End Retrieve Opening Inventory. */

	/* Retrieve Forecast / Demand Data. */
	IF ISNULL(@ForecastedConsumptionXML, '') = ''
		BEGIN
			IF @ysnComputeDemandUsingRecipe = 1
				BEGIN
					WITH tblMFGetRecipeInputItem 
					(
						intItemId
					  , dblQuantity
					  , intAttributeId
					  , dtmDemandDate
					  , intLevel
					  , intMonthId
					  , intLocationId
					) AS (SELECT ISNULL(DD.intSubstituteItemId, RI.intItemId)
							   , Convert(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
							   , 8 AS intAttributeId	--Forecasted Consumption
							   , DD.dtmDemandDate
							   , 0 AS intLevel
							   , DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
							   , R.intLocationId
						  FROM tblMFDemandDetail DD
						  JOIN tblMFRecipe R ON R.intItemId = DD.intItemId 
										  AND DD.intDemandHeaderId = @intDemandHeaderId 
										  AND R.ysnActive = 1 
										  AND R.intLocationId = ISNULL(@intCompanyLocationId, R.intLocationId)
						  JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
						  JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId AND IU.intUnitMeasureId = @intUnitMeasureId
						  WHERE intRecipeItemTypeId = 1
						  	  AND 
						  	  (
						  	  	  (RI.ysnYearValidationRequired = 1 AND DD.dtmDemandDate BETWEEN RI.dtmValidFrom AND RI.dtmValidTo)
						  	   OR (RI.ysnYearValidationRequired = 0 AND DATEPART(dy, DD.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom) AND DATEPART(dy, RI.dtmValidTo))
						  	  )
						  	  AND DD.dtmDemandDate >= @dtmStartOfMonth
				
						UNION ALL
				
						SELECT RI.intItemId
							 , CONVERT(NUMERIC(18, 6), (RI.dblCalculatedQuantity / R.dblQuantity) * RII.dblQuantity)
							 , 8 AS intAttributeId --Forecasted Consumption
							 , RII.dtmDemandDate
							 , RII.intLevel + 1
							 , DATEDIFF(mm, 0, RII.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
							 , RII.intLocationId
						FROM tblMFGetRecipeInputItem RII
						JOIN tblMFRecipe R ON R.intItemId = RII.intItemId
										  AND R.ysnActive = 1
										  AND R.intLocationId = ISNULL(@intCompanyLocationId, R.intLocationId)
						JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
						WHERE intRecipeItemTypeId = 1
							AND 
							(
								(RI.ysnYearValidationRequired = 1 AND RII.dtmDemandDate BETWEEN RI.dtmValidFrom AND RI.dtmValidTo)
							 OR (RI.ysnYearValidationRequired = 0 AND DATEPART(dy, RII.dtmDemandDate) BETWEEN DATEPART(dy, RI.dtmValidFrom) AND DATEPART(dy, RI.dtmValidTo))
							)
							AND RII.intLevel <= 5
					)

					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT DISTINCT intItemId
								  , CASE WHEN @ysnForecastedConsumptionByRemainingDays = 1 AND intMonthId = 1 THEN - (dblQuantity * @intRemainingDay) / @intNoOfDays
								  		 ELSE - dblQuantity
								  	END
								  , intAttributeId
								  , intMonthId
								  , intLocationId
					FROM tblMFGetRecipeInputItem
				END
			ELSE
				BEGIN
					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT ISNULL(DD.intSubstituteItemId, DD.intItemId)
						 , CASE WHEN @ysnForecastedConsumptionByRemainingDays = 1 AND DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth = 1 THEN - (SUM(dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity)) * @intRemainingDay) / @intNoOfDays
								ELSE - SUM(dbo.fnMFConvertQuantityToTargetItemUOM(DD.intItemUOMId, IU.intItemUOMId, DD.dblQuantity))
							END
						 , 8 AS intAttributeId --Forecasted Consumption
						 , DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth AS intMonthId
						 , DD.intCompanyLocationId
					FROM @tblMFItem I
					JOIN tblMFDemandDetail DD ON ISNULL(DD.intSubstituteItemId, DD.intItemId)	= I.intItemId
											 AND DD.intDemandHeaderId							= @intDemandHeaderId
											 AND ISNULL(DD.intCompanyLocationId, ISNULL(@intCompanyLocationId, 0)) = ISNULL(@intCompanyLocationId, ISNULL(DD.intCompanyLocationId, 0))
					JOIN tblICItemUOM IU ON IU.intItemId = DD.intItemId AND IU.intUnitMeasureId = @intUnitMeasureId
					WHERE DD.dtmDemandDate >= @dtmStartOfMonth
					GROUP BY ISNULL(DD.intSubstituteItemId, DD.intItemId)
						   , DATEDIFF(mm, 0, DD.dtmDemandDate) + 1 - @intCurrentMonth
						   , DD.intCompanyLocationId
				END
		END
	ELSE
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , intMonthId
			  , dblQty
			  , intAttributeId
			  , intLocationId
			)
			SELECT intItemId
				 , strName
				 , strValue
				 , 8
				 , intLocationId
			FROM #TempForecastedConsumption FC
		END
	/* End of Retrieve Forecast / Demand Data. */

	/* Retrieve Addtional Forecast */

	IF @AdditionalForecastedConsumptionXML <> ''
		BEGIN
			/* Manual Inputted by user. */
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , intMonthId
			  , dblQty
			  , intAttributeId
			  , intLocationId
			)
			SELECT intItemId
				 , strName
				 , strValue
				 , 15	-- Additional Forecast consumption
				 , intLocationId
			FROM #TempAdditionalForecastedConsumption FC
		END
	ELSE
		BEGIN
			/* Based on recipe forecast. */
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , intMonthId
			  , dblQty
			  , intAttributeId
			  , intLocationId
			)
			SELECT intItemId
				 , intMonthId
				 , 0	AS dblQty
				 , 15	AS intAttributeId
				 , intLocationId
			FROM #tblMFDemand
			WHERE intAttributeId = 8
		END
	/* End of Retrieve Addtional Forecast */


	/* Retrieval of Purchase / Contracts / Logistics. (Critical Part of Generating Demand). */
	IF ISNULL(@OpenPurchaseXML, '') = ''
		BEGIN
			IF @ysnRefreshContract = 1
				BEGIN
					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								ELSE I.intMainItemId
						   END AS intItemId
						 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (SS.dblBalance - ISNULL(SS.dblScheduleQty, 0))) * I.dblRatio) AS dblIntrasitQty
						 , 13 AS intAttributeId --Open Purchases
						 , 0 AS intMonthId
						 , SS.intCompanyLocationId
					FROM @tblMFItemDetail I
					JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
					JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
					WHERE SS.intContractStatusId IN (1, 4)
					  AND (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
								ELSE SS.dtmUpdatedAvailabilityDate
						   END) < @dtmStartOfMonth
					  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
								ELSE ISNULL(@intBookId, 0)
						   END) = ISNULL(@intBookId, 0)
					  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intSubBookId, 0)
								ELSE ISNULL(@intSubBookId, 0)
						   END) = ISNULL(@intSubBookId, 0)
					GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								  ELSE I.intMainItemId
							 END
						   , SS.intCompanyLocationId

					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								ELSE I.intMainItemId
						   END AS intItemId
						 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblBalance - ISNULL(SS.dblScheduleQty, 0)) * I.dblRatio) AS dblIntrasitQty
						 , 13 AS intAttributeId --Open Purchases
						 , DATEDIFF(mm, 0, (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
												 ELSE SS.dtmUpdatedAvailabilityDate
											END)) + 1 - @intCurrentMonth AS intMonthId
						 , SS.intCompanyLocationId
					FROM @tblMFItemDetail I
					JOIN dbo.tblCTContractDetail SS ON SS.intItemId = I.intItemId
					JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
					WHERE SS.intContractStatusId IN (1, 4)
					  AND (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
								ELSE SS.dtmUpdatedAvailabilityDate
						   END) >= @dtmStartOfMonth
					  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
								ELSE ISNULL(@intBookId, 0)
						   END) = ISNULL(@intBookId, 0)
					  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intSubBookId, 0)
								ELSE ISNULL(@intSubBookId, 0)
						   END) = ISNULL(@intSubBookId, 0)
					GROUP BY DATENAME(m, (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
											   ELSE SS.dtmUpdatedAvailabilityDate
										  END)) + ' ' + CAST(DATEPART(yyyy, (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
																				  ELSE SS.dtmUpdatedAvailabilityDate
																			 END)) AS VARCHAR)
						   , CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
								  ELSE I.intMainItemId
							 END
						   , DATEDIFF(mm, 0, (CASE WHEN DAY(SS.dtmUpdatedAvailabilityDate) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, SS.dtmUpdatedAvailabilityDate)
												   ELSE SS.dtmUpdatedAvailabilityDate
											  END))
						   , SS.intCompanyLocationId
				END
			ELSE
				BEGIN
					INSERT INTO #tblMFDemand 
					(
						intItemId
					  , dblQty
					  , intAttributeId
					  , intMonthId
					  , intLocationId
					)
					SELECT intItemId
						 , CASE WHEN strValue = '' THEN NULL
								ELSE strValue
						   END
						 , 13 --Open Purchases 
						 , REPLACE(REPLACE(REPLACE(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') intMonthId
						 , intLocationId
					FROM tblCTInvPlngReportAttributeValue
					WHERE intReportAttributeID = 13 --Open Purchases 
					  AND intInvPlngReportMasterID = @intInvPlngReportMasterID
				END
		END
	ELSE
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
				,dblQty
				,intAttributeId
				,intMonthId
				,intLocationId
			)
			SELECT intItemId
					, strValue
					, 13 /* Open Purchase */
					, [strName] AS intMonthId
					, intLocationId
			FROM #TempOpenPurchase
		END

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				ELSE I.intMainItemId
		   END AS intItemId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - 
					(CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
						  ELSE LD.dblDeliveredQuantity
					 END)
			   ) * I.dblRatio) AS dblIntrasitQty
		 , (CASE WHEN @intPositionByETA = 2 THEN 14
				 ELSE 13
			END) AS intAttributeId --Open
		 , 0 AS intMonthId
		 , SS.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
						   AND L.intPurchaseSale = 1
						   AND L.intShipmentType = 1
						   AND ISNULL(L.ysnPosted, 0) = 0
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblSMCity C ON C.strCity = L.strDestinationPort
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
														   ELSE LD.dblDeliveredQuantity
													  END) > 0
	  AND SS.intContractStatusId IN (1, 4)
	  AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
	  AND (CASE WHEN DAY((CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
							   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
						  END)) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																							  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																						 END))
				ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
						   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
					  END)
		   END) < @dtmStartOfMonth
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
				ELSE ISNULL(@intBookId, 0)
		   END) = ISNULL(@intBookId, 0)
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN IsNULL(SS.intSubBookId, 0)
				ELSE IsNULL(@intSubBookId, 0)
		   END) = ISNULL(@intSubBookId, 0)
	GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				  ELSE I.intMainItemId
			 END
		   , SS.intCompanyLocationId

	IF (ISNULL(@intInvPlngReportMasterID, 0) = 0 AND @ysnCalculateEndInventory <> 1) OR (@ysnRefreshContract = 1 AND @ysnCalculateEndInventory <> 1)
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , dblQty
			  , intAttributeId
			  , intMonthId
			  , intLocationId
			)
			SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
						ELSE I.intMainItemId
				   END AS intItemId
				 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (
							CASE 
								WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL)
									THEN ISNULL(LDCL.dblReceivedQty, 0)
								ELSE LD.dblDeliveredQuantity
								END
							)) * I.dblRatio) AS dblIntrasitQty
				 , (CASE WHEN @intPositionByETA = 2 THEN 14
						 ELSE 13
					END) AS intAttributeId --Open
				 , DATEDIFF(mm, 0, (CASE WHEN DAY((CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
														ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
												   END)) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																													   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																												  END))
										 ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
													ELSE ISNULL(DATEADD(DAY, IsNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
											   END)
									END)) + 1 - @intCurrentMonth AS intMonthId
				 , SS.intCompanyLocationId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
								   AND L.intPurchaseSale = 1
								   AND L.intShipmentType = 1
								   AND IsNULL(L.ysnPosted, 0) = 0
			JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
			JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
			JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
			LEFT JOIN tblSMCity C ON C.strCity = L.strDestinationPort
			WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
																   ELSE LD.dblDeliveredQuantity
															  END) > 0
			  AND SS.intContractStatusId IN (1, 4)
			  AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
			  AND (CASE WHEN DAY((CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
									   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
								  END)) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																									  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																								 END))
						ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
								   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
							  END)
				   END) >= @dtmStartOfMonth
			  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
						ELSE ISNULL(@intBookId, 0)
				   END) = ISNULL(@intBookId, 0)
				AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intSubBookId, 0)
						  ELSE ISNULL(@intSubBookId, 0)
					 END) = ISNULL(@intSubBookId, 0)
			GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
						  ELSE I.intMainItemId
					 END
				   , DATEDIFF(mm, 0, (CASE WHEN DAY((CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
														  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
													 END)) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																														 ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																													END))
										   ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
													  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
												 END)
									  END))
				   , SS.intCompanyLocationId
		END

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				ELSE I.intMainItemId
		   END AS intItemId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
																																							 ELSE LD.dblDeliveredQuantity
																																						END)) * I.dblRatio) AS dblIntrasitQty
		 , 14 AS intAttributeId --In-transit Purchases
		 , 0 AS intMonthId
		 , SS.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
						   AND L.intPurchaseSale = 1
						   AND L.intShipmentType = 1
						   AND L.ysnPosted = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblSMCity C ON C.strCity = L.strDestinationPort
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
														   ELSE LD.dblDeliveredQuantity
													  END) > 0
	  AND SS.intContractStatusId IN (1, 4)
	  AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
	  AND (CASE WHEN DAY(CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
							  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
						 END) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																							ELSE IsNULL(DateAdd(day, IsNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																					   END))
				ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
						   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
					  END)
		   END) < @dtmStartOfMonth
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
				ELSE ISNULL(@intBookId, 0)
		   END) = ISNULL(@intBookId, 0)
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intSubBookId, 0)
				ELSE ISNULL(@intSubBookId, 0)
		   END) = ISNULL(@intSubBookId, 0)
	GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				  ELSE I.intMainItemId
			 END
		   , SS.intCompanyLocationId

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				ELSE I.intMainItemId
		   END AS intItemId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
																																							 ELSE LD.dblDeliveredQuantity
																																						END)) * I.dblRatio) AS dblIntrasitQty
		 , 14 AS intAttributeId --In-transit Purchases
		 , DATEDIFF(mm, 0, (CASE WHEN DAY(CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
											   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
										  END) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																											 ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																										END))
								 ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
											ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
									   END)
							END)) + 1 - @intCurrentMonth AS intMonthId
		 , SS.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
						   AND L.intPurchaseSale = 1
						   AND L.intShipmentType = 1
						   AND L.ysnPosted = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItemDetail I ON I.intItemId = SS.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblSMCity C ON C.strCity = L.strDestinationPort
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0)
														   ELSE LD.dblDeliveredQuantity
													  END) > 0
	  AND SS.intContractStatusId IN (1, 4)
	  AND SS.intCompanyLocationId = ISNULL(@intCompanyLocationId, SS.intCompanyLocationId)
	  AND (CASE WHEN DAY(CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
							  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
						 END) > @intDemandAnalysisMonthlyCutOffDay THEN DateAdd(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																							ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																					   END))
				ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
						   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
					  END)
		   END) >= @dtmStartOfMonth
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intBookId, 0)
				ELSE ISNULL(@intBookId, 0)
		   END) = ISNULL(@intBookId, 0)
	  AND (CASE WHEN @ysnConsiderBookInDemandView = 1 THEN ISNULL(SS.intSubBookId, 0)
				ELSE ISNULL(@intSubBookId, 0)
		   END) = ISNULL(@intSubBookId, 0)
	GROUP BY CASE WHEN I.ysnSpecificItemDescription = 1 THEN I.intItemId
				  ELSE I.intMainItemId
			 END
		   , DATEDIFF(mm, 0, (CASE WHEN DAY(CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
												 ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
											END) > @intDemandAnalysisMonthlyCutOffDay THEN DATEADD(m, 1, (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
																											   ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
																										  END))
								   ELSE (CASE WHEN @intPositionByETA = 1 THEN SS.dtmUpdatedAvailabilityDate
											  ELSE ISNULL(DATEADD(DAY, ISNULL(C.intLeadTime, 0), L.dtmETAPOD), SS.dtmUpdatedAvailabilityDate)
										 END)
							  END))
		   , SS.intCompanyLocationId
	/* Retrieval of Purchase / Contracts / Logistics. (Critical Part of Generating Demand). */

	/* Stage the Contract / Logitics / Purchase. */
	INSERT INTO #tblMFTempDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT intItemId
		 , dblQty
		 , intAttributeId
		 , intMonthId
		 , intLocationId
	FROM #tblMFDemand
	WHERE intAttributeId IN 
	(
		13 /* Open Purchase */
	  , 14 /* In-transit Purchases */
	);
	/* End of Stage the Contract / Logitics / Purchase. */

	/* Clear Stage Demand. */
	DELETE FROM #tblMFDemand
	WHERE intAttributeId IN 
	(
		13 /* Open Purchase */
	  , 14 /* In-transit Purchases*/
	)
	/* End of Clear Stage Demand. */

	/* Aggregate Data and Stage again the Contract / Logitics / Purchase. */
	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT intItemId
		 , SUM(dblQty)
		 , intAttributeId AS intAttributeId 
		 , intMonthId
		 , intLocationId
	FROM #tblMFTempDemand
	WHERE intAttributeId IN 
	(
		13 /* Open Purchase */
	  , 14 /* In-transit Purchases*/
	)
	GROUP BY intItemId
		   , intAttributeId
		   , intMonthId
		   , intLocationId;
	/* End of Aggregate Data and Stage again the Contract / Logitics / Purchase. */

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT intItemId
		 , SUM(dblQty)
		 , 4 AS intAttributeId /* Existing Purchases*/
		 , intMonthId
		 , intLocationId
	FROM #tblMFDemand
	WHERE intAttributeId IN 
	(
		13 /* Open Purchase */
	  , 14 /* In-transit Purchases*/
	)
	GROUP BY intItemId
		   , intMonthId
		   , intLocationId;

	WITH tblMFGenerateInventoryRow (intMonthId) AS 
	(
		SELECT 1 AS intMonthId
		
		UNION ALL
		
		SELECT intMonthId + 1
		FROM tblMFGenerateInventoryRow
		WHERE intMonthId + 1 <= @intMonthsToView
	)
	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT I.intItemId
		 , NULL
		 , 2 /* Opening Inventory */
		 , M.intMonthId
		 , L.intCompanyLocationId
	FROM tblMFGenerateInventoryRow M
	INNER JOIN @tblMFItem I ON 1 = 1
	INNER JOIN @tblSMCompanyLocation L ON 1 = 1
	WHERE NOT EXISTS (SELECT *
					  FROM #tblMFDemand D
					  WHERE D.intItemId			= I.intItemId
						AND D.intMonthId		= M.intMonthId
						AND D.intAttributeId	= 2
						AND D.intLocationId		= L.intCompanyLocationId)
		  AND L.intCompanyLocationId = ISNULL(@intCompanyLocationId, L.intCompanyLocationId)

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT D.intItemId
		 , CASE WHEN @ysnCalculatePlannedPurchases = 0 AND @ysnCalculateEndInventory = 0 AND @intContainerTypeId IS NOT NULL THEN ISNULL(IL.dblMinOrder * ISNULL(UMCByWeight.dblConversionToStock, 1), 0)
				ELSE 0
		   END
		 , 5 AS intAttributeId /* Planned Purchases */
		 , D.intMonthId
		 , D.intLocationId
	FROM #tblMFDemand D
	LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = D.intItemId
	LEFT JOIN tblICUnitMeasureConversion UMCByWeight ON UMCByWeight.intUnitMeasureId		= CW.intWeightUnitMeasureId --From Unit
													AND UMCByWeight.intStockUnitMeasureId	= @intUnitMeasureId -- To Unit
	LEFT JOIN tblICItemLocation IL ON IL.intItemId = D.intItemId 
								  AND IL.intLocationId = D.intLocationId
	WHERE intAttributeId = 2 /* Opening Inventory */
	  AND intMonthId > 0

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT intItemId
		 , NULL
		 , 9 /* Ending Inventory */
		 , intMonthId
		 , intLocationId
	FROM #tblMFDemand
	WHERE intAttributeId = 2 /* Opening Inventory */
	  AND intMonthId > 0

	IF @PlannedPurchasesXML <> ''
		BEGIN
			UPDATE D
			SET dblQty = Purchase.[strValue]
			FROM #tblMFDemand D
			JOIN #TempPlannedPurchases Purchase ON Purchase.intItemId = D.intItemId
											   AND Purchase.[strName] = D.intMonthId
											   AND Purchase.intLocationId = D.intLocationId
			WHERE intAttributeId = 5 /* Planned Purchases */
			  AND intMonthId > 0
		END

	IF @WeeksOfSupplyTargetXML <> ''
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , dblQty
			  , intAttributeId
			  , intMonthId
			  , intLocationId
			)
			SELECT intItemId
				 , strValue
				 , 11 /* Weeks of Supply Target */
				 , [strName] AS intMonthId
				 , intLocationId
			FROM #TempWeeksOfSupplyTarget
		END

	IF @InventoryTransferXML <> ''
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , dblQty
			  , intAttributeId
			  , intMonthId
			  , intLocationId
			)
			SELECT intItemId
				 , strValue
				 , 16 /* Inventory Transfer */
				 , [strName] AS intMonthId
				 , intLocationId
			FROM #TempInventoryTransfer
		END

	INSERT INTO #tblMFDemand 
	(
		intItemId
	  , dblQty
	  , intAttributeId
	  , intMonthId
	  , intLocationId
	)
	SELECT intItemId
		 , CASE WHEN strValue = '' THEN NULL
		  		ELSE dbo.fnCTConvertQuantityToTargetItemUOM(intItemId, @intPrevUnitMeasureId, @intUnitMeasureId, strValue)
		   END 
		 , 6 /* Previous Planned Purchases */
		 , REPLACE(REPLACE(REPLACE(strFieldName, 'strMonth', ''), 'OpeningInv', '-1'), 'PastDue', '0') AS intMonthId
		 , ISNULL(intLocationId, @intCompanyLocationId)
	FROM tblCTInvPlngReportAttributeValue
	WHERE intReportAttributeID		= 5 /* Planned Purchases */
	  AND intInvPlngReportMasterID	= @intPrevInvPlngReportMasterID

	IF @ysnCalculatePlannedPurchases = 0 AND @ysnCalculateEndInventory = 0 AND @intContainerTypeId IS NOT NULL AND IsNULL(@WeeksOfSupplyTargetXML, '') = ''
		BEGIN
			INSERT INTO #tblMFDemand 
			(
				intItemId
			  , dblQty
			  , intAttributeId
			  , intMonthId
			  , intLocationId
			)
			SELECT D.intItemId
				 , ISNULL(IL.dblLeadTime, 0)
				 , 11 /* Weeks of Supply Target */
				 , D.intMonthId
				 , D.intLocationId
			FROM #tblMFDemand D
			LEFT JOIN tblICItemLocation IL ON IL.intItemId = D.intItemId AND IL.intLocationId = D.intLocationId
			WHERE intAttributeId = 2 /* Opening Inventory */
			  AND intMonthId > 0
		END

	IF EXISTS (SELECT * FROM @tblSMCompanyLocation WHERE intCompanyLocationId = 9999)
		BEGIN
			DELETE FROM #tblMFDemand WHERE intLocationId = 9999;

			INSERT INTO #tblMFDemand
			SELECT intItemId
				 , SUM(dblQty)
				 , intAttributeId
				 , intMonthId
				 , 9999
			FROM #tblMFDemand
			GROUP BY intItemId
				   , intAttributeId
				   , intMonthId
		END

	WHILE @intMonthId <= @intMonthsToView
		BEGIN
			IF @ysnSupplyTargetbyAverage = 1
				BEGIN
					UPDATE D
					SET dblQty = CASE WHEN @intMonthId = 1 THEN (SELECT sum(OpenInv.dblQty)
																 FROM #tblMFDemand OpenInv
																 WHERE OpenInv.intItemId = D.intItemId
																   AND OpenInv.intLocationId = D.intLocationId
																   AND intMonthId IN 
																   (
																		-1 /* Opening Inventory */
																	  , 0  /* Past Due */
																   )
																   AND intAttributeId IN 
																   (
																		2 --Opening Inventory
																	  , 13 --Open Purchases
																	  , 14 --In-transit Purchases
																 ))
									  ELSE (SELECT SUM(OpenInv.dblQty)
											FROM #tblMFDemand OpenInv
											WHERE OpenInv.intItemId = D.intItemId
											  AND OpenInv.intLocationId = D.intLocationId
											  AND intMonthId = @intMonthId - 1
											  AND intAttributeId = 9) --Ending Inventory
									
								 END
					FROM #tblMFDemand D
					WHERE intAttributeId = 2 --Opening Inventory
					  AND intMonthId	 = @intMonthId

					IF @ysnCalculatePlannedPurchases = 1
						BEGIN
							UPDATE D
							SET dblQty = (
									CASE 
										WHEN (
												SELECT sum(OpenInv.dblQty)
												FROM #tblMFDemand OpenInv
												WHERE OpenInv.intItemId = D.intItemId
													AND OpenInv.intLocationId = D.intLocationId
													AND OpenInv.intMonthId = @intMonthId
													AND (
														intAttributeId IN (
															2
															,4
															,8
															,15
															,16
															) --Opening Inventory, Existing Purchases,Forecasted Consumption
														)
												) < 0
											THEN (
													SELECT sum(OpenInv.dblQty)
													FROM #tblMFDemand OpenInv
													WHERE OpenInv.intItemId = D.intItemId
														AND OpenInv.intLocationId = D.intLocationId
														AND OpenInv.intMonthId = @intMonthId
														AND (
															intAttributeId IN (
																2
																,4
																,8
																,15
																,16
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

					DELETE FROM @tblMFEndInventory;

					UPDATE D
					SET dblQty = (
							SELECT sum(OpenInv.dblQty)
							FROM #tblMFDemand OpenInv
							WHERE OpenInv.intItemId = D.intItemId
								AND OpenInv.intLocationId = D.intLocationId
								AND OpenInv.intMonthId = @intMonthId
								AND (
									intAttributeId IN (
										2
										,4
										,5
										,8
										,15
										,16
										) --Opening Inventory,Existing Purchases,Planned Purchases - ,Forecasted Consumption
									)
							)
					OUTPUT inserted.intItemId
						,inserted.dblQty
						,inserted.intLocationId
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
											AND OpenInv.intLocationId = D.intLocationId
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
										AND OpenInv.intLocationId = D.intLocationId
										AND intMonthId = @intMonthId - 1
										AND intAttributeId = 9 --Ending Inventory
									)
							END
					OUTPUT inserted.intItemId
						,inserted.dblQty
						,inserted.intLocationId
					INTO @tblMFEndInventory
					FROM #tblMFDemand D
					WHERE intAttributeId = 2 --Opening Inventory
						AND intMonthId = @intMonthId

					SELECT @intRecordId = NULL

					SELECT @intRecordId = min(intRecordId)
					FROM @tblMFEndInventory

					WHILE @intRecordId IS NOT NULL
					BEGIN
						SELECT @dblEndInventory = 0
							,@dblWeeksOfSsupply = 0

						--Calculate Excess or shortage
						SELECT @dblSupplyTarget = NULL
							,@dblDecimalPart = NULL
							,@intIntegerPart = NULL
							,@dblTotalConsumptionQty = NULL
							,@intLocationId = NULL
							,@intItemId = NULL

						SELECT @intItemId = intItemId
							,@intLocationId = intLocationId
						FROM @tblMFEndInventory
						WHERE intRecordId = @intRecordId

						SELECT @dblSupplyTarget = dblQty
						FROM #tblMFDemand
						WHERE intItemId = @intItemId
							AND intAttributeId = 11 --Weeks of Supply Target
							AND intMonthId = @intMonthId
							AND intLocationId = @intLocationId

						SELECT @dblDecimalPart = @dblSupplyTarget % 1

						SELECT @intIntegerPart = @dblSupplyTarget - @dblDecimalPart

						IF @intIntegerPart = 0
						BEGIN
							IF @dblDecimalPart > 0
							BEGIN
								SELECT @dblTotalConsumptionQty = ABS(SUM(dblQty)) * @dblDecimalPart
								FROM #tblMFDemand
								WHERE intItemId = @intItemId
									AND intMonthId = @intMonthId + 1
									AND intAttributeId IN (
										8
										,15
										)
									AND intLocationId = @intLocationId
							END
						END
						ELSE
						BEGIN
							SELECT @dblTotalConsumptionQty = ABS(SUM(CASE 
											WHEN intAttributeId = 16
												AND dblQty > 0
												THEN 0
											ELSE dblQty
											END))
							FROM #tblMFDemand
							WHERE intItemId = @intItemId
								AND intMonthId BETWEEN @intMonthId + 1
									AND @intMonthId + @intIntegerPart
								AND intAttributeId IN (
									8
									,15
									,16
									)
								AND intLocationId = @intLocationId

							IF @dblDecimalPart > 0
							BEGIN
								SELECT @dblTotalConsumptionQty = isNULL(@dblTotalConsumptionQty, 0) + (
										ABS(SUM(CASE 
													WHEN intAttributeId = 16
														AND dblQty > 0
														THEN 0
													ELSE dblQty
													END)) * @dblDecimalPart
										)
								FROM #tblMFDemand
								WHERE intItemId = @intItemId
									AND intMonthId = @intMonthId + @intIntegerPart + 1
									AND intAttributeId IN (
										8
										,15
										,16
										)
									AND intLocationId = @intLocationId
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
													,15
													,16
													) --Opening Inventory, Existing Purchases,Forecasted Consumption
												)
											AND intLocationId = @intLocationId
										HAVING (sum(OpenInv.dblQty) - IsNULL(@dblTotalConsumptionQty, 0)) < 0
										), 0)
							FROM #tblMFDemand D
							WHERE intAttributeId = 5 --Planned Purchases -
								AND intMonthId = @intMonthId
								AND intItemId = @intItemId
								AND intLocationId = @intLocationId
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
											,15
											,16
											) --Opening Inventory,Existing Purchases,Planned Purchases - ,Forecasted Consumption
										)
									AND intLocationId = @intLocationId
								)
						FROM #tblMFDemand D
						WHERE intAttributeId = 9 --Ending Inventory
							AND intMonthId = @intMonthId
							AND intItemId = @intItemId
							AND intLocationId = @intLocationId

						---************************************
						---************************************
						---************************************
						SELECT @dblEndInventory = dblQty
						FROM #tblMFDemand D
						WHERE intAttributeId = 9 --Ending Inventory
							AND intMonthId = @intMonthId
							AND intItemId = @intItemId
							AND intLocationId = @intLocationId

						IF @dblEndInventory IS NULL
							SELECT @dblEndInventory = 0

						SELECT @intConsumptionMonth = @intMonthId + 1

						INSERT INTO #tblMFDemand (
							intItemId
							,dblQty
							,intAttributeId
							,intMonthId
							,intLocationId
							)
						SELECT @intItemId
							,@dblEndInventory - IsNULL(@dblTotalConsumptionQty, 0)
							,12 --Short/Excess Inventory
							,@intMonthId
							,@intLocationId

						SELECT @intConsumptionAvlMonth = 0

						SELECT @intConsumptionAvlMonth = Count(*)
						FROM #tblMFDemand
						WHERE intItemId = @intItemId
							AND (
								intAttributeId IN (
									8
									,15
									)
								OR (
									intAttributeId = 16
									AND dblQty < 0
									)
								)
							AND intLocationId = @intLocationId

						IF @intConsumptionAvlMonth IS NULL
							SELECT @intConsumptionAvlMonth = @intMonthsToView

						WHILE @intConsumptionMonth <= 12
							AND @dblEndInventory > 0
						BEGIN
							SELECT @dblRemainingConsumptionQty = NULL

							SELECT @dblRemainingConsumptionQty = ABS(SUM(CASE 
											WHEN intAttributeId = 16
												AND dblQty > 0
												THEN 0
											ELSE dblQty
											END))
							FROM #tblMFDemand
							WHERE intItemId = @intItemId
								AND intMonthId >= @intConsumptionMonth
								AND intAttributeId IN (
									8
									,15
									,16
									)
								AND intLocationId = @intLocationId

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
											AND intLocationId = @intLocationId
										)
								BEGIN
									INSERT INTO #tblMFDemand (
										intItemId
										,dblQty
										,intAttributeId
										,intMonthId
										,intLocationId
										)
									SELECT @intItemId
										,999
										,10 --Weeks of Supply
										,@intMonthId
										,@intLocationId
								END
								ELSE
								BEGIN
									INSERT INTO #tblMFDemand (
										intItemId
										,dblQty
										,intAttributeId
										,intMonthId
										,intLocationId
										)
									SELECT @intItemId
										,0
										,10 --Weeks of Supply
										,@intMonthId
										,@intLocationId
								END

								GOTO NextItem
							END

							SELECT @dblConsumptionQty = 0

							SELECT @dblConsumptionQty = ABS(SUM(CASE 
											WHEN intAttributeId = 16
												AND dblQty > 0
												THEN 0
											ELSE dblQty
											END))
							FROM #tblMFDemand
							WHERE intItemId = @intItemId
								AND intMonthId = @intConsumptionMonth
								AND intAttributeId IN (
									8
									,15
									,16
									)
								AND intLocationId = @intLocationId

							IF @dblConsumptionQty IS NULL
								SELECT @dblConsumptionQty = 0

							IF @dblEndInventory > @dblConsumptionQty
							BEGIN
								SELECT @dblEndInventory = @dblEndInventory - @dblConsumptionQty

								SELECT @dblWeeksOfSsupply = @dblWeeksOfSsupply + 1

								IF NOT EXISTS (
										SELECT 1
										FROM #tblMFDemand
										WHERE intItemId = @intItemId
											AND intMonthId > @intConsumptionMonth
											AND intAttributeId IN (
												8
												,15
												,16
												)
											AND intLocationId = @intLocationId
										HAVING ABS(SUM(CASE 
														WHEN intAttributeId = 16
															AND dblQty > 0
															THEN 0
														ELSE dblQty
														END)) > 0
										)
								BEGIN
									INSERT INTO #tblMFDemand (
										intItemId
										,dblQty
										,intAttributeId
										,intMonthId
										,intLocationId
										)
									SELECT @intItemId
										,@dblWeeksOfSsupply
										,10 --Weeks of Supply
										,@intMonthId
										,@intLocationId

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
									,intLocationId
									)
								SELECT @intItemId
									,@dblWeeksOfSsupply
									,10 --Weeks of Supply
									,@intMonthId
									,@intLocationId
							END

							SELECT @intConsumptionMonth = @intConsumptionMonth + 1
						END

						--END
						NextItem:

						SELECT @intRecordId = min(intRecordId)
						FROM @tblMFEndInventory
						WHERE intRecordId > @intRecordId
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
			,intLocationId
			)
		SELECT Demand.intItemId
			,CASE 
				WHEN (
						SELECT ABS(SUM(CASE 
										WHEN intAttributeId = 16
											AND dblQty > 0
											THEN 0
										ELSE dblQty
										END))
						FROM #tblMFDemand D
						WHERE D.intItemId = Demand.intItemId
							AND D.intAttributeId IN (
								8
								,15
								,16
								)
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
							AND intLocationId = @intLocationId
						) > 0
					THEN (
							SELECT dblQty
							FROM #tblMFDemand D
							WHERE D.intItemId = Demand.intItemId
								AND D.intAttributeId = 9
								AND D.intMonthId = Demand.intMonthId
								AND D.intLocationId = Demand.intLocationId
							) / (
							(
								SELECT SUM(abs(CASE 
												WHEN intAttributeId = 16
													AND dblQty > 0
													THEN 0
												ELSE dblQty
												END))
								FROM #tblMFDemand D
								WHERE D.intItemId = Demand.intItemId
									AND D.intAttributeId IN (
										8
										,15
										,16
										)
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
									AND D.intLocationId = Demand.intLocationId
								) / @intNoofWeekstoCalculateSupplyTargetbyAverage
							)
				ELSE 0
				END
			,10 --Weeks of Supply
			,intMonthId
			,Demand.intLocationId
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
			,intLocationId
			)
		SELECT Demand.intItemId
			,CASE 
				WHEN IsNULL((
							SELECT dblQty
							FROM #tblMFDemand D2
							WHERE D2.intItemId = Demand.intItemId
								AND D2.intAttributeId = 10
								AND D2.intMonthId = Demand.intMonthId
								AND D2.intLocationId = Demand.intLocationId
							), 0) = 0
					THEN (
							SELECT dblQty
							FROM #tblMFDemand D1
							WHERE D1.intItemId = Demand.intItemId
								AND D1.intAttributeId = 9 --Ending Inventory
								AND D1.intMonthId = Demand.intMonthId
								AND D1.intLocationId = Demand.intLocationId
							)
				ELSE (
						(
							SELECT dblQty
							FROM #tblMFDemand D1
							WHERE D1.intItemId = Demand.intItemId
								AND D1.intAttributeId = 9 --Ending Inventory
								AND D1.intMonthId = Demand.intMonthId
								AND D1.intLocationId = Demand.intLocationId
							) / (
							SELECT dblQty
							FROM #tblMFDemand D2
							WHERE D2.intItemId = Demand.intItemId
								AND D2.intAttributeId = 10 --Weeks of Supply
								AND D2.intMonthId = Demand.intMonthId
								AND D2.intLocationId = Demand.intLocationId
							)
						) * (
						(
							IsNULL((
									SELECT dblQty
									FROM #tblMFDemand D3
									WHERE D3.intItemId = Demand.intItemId
										AND D3.intAttributeId = 10 --Weeks of Supply 
										AND D3.intMonthId = Demand.intMonthId
										AND D3.intLocationId = Demand.intLocationId
									), 0)
							) - IsNULL((
								SELECT dblQty
								FROM #tblMFDemand D4
								WHERE D4.intItemId = Demand.intItemId
									AND D4.intAttributeId = 11 --Weeks of Supply Target
									AND D4.intMonthId = Demand.intMonthId
									AND D4.intLocationId = Demand.intLocationId
								), 0)
						)
				END
			,12 --Short/Excess Inventory
			,intMonthId
			,intLocationId
		FROM #tblMFDemand Demand
		WHERE intAttributeId = 2;--Opening Inventory
	END

	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		,intLocationId
		)
	SELECT I.intItemId
		,NULL
		,2 AS intAttributeId --Opening Inventory
		,- 1 AS intMonthId
		,I.intMainItemId
		,L.intCompanyLocationId
	FROM @tblMFItem I
	INNER JOIN @tblSMCompanyLocation L ON 1 = 1
	WHERE L.intCompanyLocationId = IsNULL(@intCompanyLocationId, L.intCompanyLocationId)

	INSERT INTO #tblMFDemandList (
		intItemId
		,dblQty
		,intAttributeId
		,intMonthId
		,intMainItemId
		,intLocationId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID AS intAttributeId
		,0 AS intMonthId
		,I.intMainItemId
		,L.intCompanyLocationId
	FROM @tblMFItem I
	INNER JOIN tblCTReportAttribute A ON 1 = 1
	INNER JOIN @tblSMCompanyLocation L ON 1 = 1
	WHERE A.intReportAttributeID IN (
			4 --Existing Purchases
			,13 --Open Purchases
			,14 --In-transit Purchases
			)
		AND A.intReportMasterID = @intReportMasterID
		AND L.intCompanyLocationId = IsNULL(@intCompanyLocationId, L.intCompanyLocationId)
		AND A.ysnVisible = 1;

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
		,intLocationId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID
		,intMonthId
		,I.intMainItemId
		,L.intCompanyLocationId
	FROM tblMFGenerateDemandData
	INNER JOIN @tblMFItem I ON 1 = 1
	INNER JOIN tblCTReportAttribute A ON 1 = 1
	INNER JOIN @tblSMCompanyLocation L ON 1 = 1
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
			,16 --Inventory Transfer
			)
		AND L.intCompanyLocationId = IsNULL(@intCompanyLocationId, L.intCompanyLocationId)
		AND A.ysnVisible = 1;

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
		,intLocationId
		)
	SELECT I.intItemId
		,NULL
		,A.intReportAttributeID
		,intMonthId
		,I.intMainItemId
		,L.intCompanyLocationId
	FROM tblMFGenerateDemandData
	INNER JOIN @tblMFItem I ON 1 = 1
	INNER JOIN tblCTReportAttribute A ON 1 = 1
	INNER JOIN @tblSMCompanyLocation L ON 1 = 1
	WHERE A.intReportAttributeID IN (
			8
			,15
			) --Forecasted Consumption
		AND L.intCompanyLocationId = IsNULL(@intCompanyLocationId, L.intCompanyLocationId)
		AND A.ysnVisible = 1

	IF @intInvPlngReportMasterID > 0
		BEGIN
			SELECT strMonth1
				 , strMonth2
				 , strMonth3
				 , strMonth4
				 , strMonth5
				 , strMonth6
				 , strMonth7
				 , strMonth8
				 , strMonth9
				 , strMonth10
				 , strMonth11
				 , strMonth12
				 , strMonth13
				 , strMonth14
				 , strMonth15
				 , strMonth16
				 , strMonth17
				 , strMonth18
				 , strMonth19
				 , strMonth20
				 , strMonth21
				 , strMonth22
				 , strMonth23
				 , strMonth24
				 , 0 AS intMainItemId
			FROM 
			(
				SELECT strFieldName
					 , strValue
				FROM tblCTInvPlngReportAttributeValue
				WHERE intInvPlngReportMasterID = @intInvPlngReportMasterID
				  AND intReportAttributeID = 1
			) AS src
			PIVOT(MAX(src.strValue) FOR src.strFieldName IN 
			(
				strMonth1
			  , strMonth2
			  , strMonth3
			  , strMonth4
			  , strMonth5
			  , strMonth6
			  , strMonth7
			  , strMonth8
			  , strMonth9
			  , strMonth10
			  , strMonth11
			  , strMonth12
			  , strMonth13
			  , strMonth14
			  , strMonth15
			  , strMonth16
			  , strMonth17
			  , strMonth18
			  , strMonth19
			  , strMonth20
			  , strMonth21
			  , strMonth22
			  , strMonth23
			  , strMonth24
			)) AS pvt
		END
	ELSE
		BEGIN
			DECLARE @intNoOfMonth INT

			SELECT @intNoOfMonth = DATEDIFF(mm, 0, GETDATE()) + 24;

			WITH tblMFGenerateMonth 
			(
				intPositionId
			  , intMonthId
			)
			AS 
			(
				SELECT DATEDIFF(mm, 0, GETDATE()) + 1 AS intPositionId
					 , 1 AS intMonthId
			
				UNION ALL
			
				SELECT intPositionId + 1
					 , intMonthId + 1
				FROM tblMFGenerateMonth
				WHERE intPositionId + 1 <= @intNoOfMonth
			)
			SELECT [1]	AS strMonth1
				 , [2]	AS strMonth2
				 , [3]	AS strMonth3
				 , [4]	AS strMonth4
				 , [5]	AS strMonth5
				 , [6]	AS strMonth6
				 , [7]	AS strMonth7
				 , [8]	AS strMonth8
				 , [9]	AS strMonth9
				 , [10] AS strMonth10
				 , [11] AS strMonth11
				 , [12] AS strMonth12
				 , [13] AS strMonth13
				 , [14] AS strMonth14
				 , [15] AS strMonth15
				 , [16] AS strMonth16
				 , [17] AS strMonth17
				 , [18] AS strMonth18
				 , [19] AS strMonth19
				 , [20] AS strMonth20
				 , [21] AS strMonth21
				 , [22] AS strMonth22
				 , [23] AS strMonth23
				 , [24] AS strMonth24
				 , 0	AS intMainItemId
			FROM 
			(
				SELECT intMonthId
					 , LEFT(DATENAME(MONTH, DATEADD(MONTH, intPositionId, - 1)), 3) + ' ' + RIGHT(DATENAME(YEAR, DATEADD(MONTH, intPositionId, - 1)), 2) AS strMonth
				FROM tblMFGenerateMonth
			) AS  src
			PIVOT(MAX(src.strMonth) FOR src.intMonthId IN 
			(
				[-1]
			  , [0]
			  , [1]
			  , [2]
			  , [3]
			  , [4]
			  , [5]
			  , [6]
			  , [7]
			  , [8]
			  , [9]
			  , [10]
			  , [11]
			  , [12]
			  , [13]
			  , [14]
			  , [15]
			  , [16]
			  , [17]
			  , [18]
			  , [19]
			  , [20]
			  , [21]
			  , [22]
			  , [23]
			  , [24]
			)) AS pvt
		END

	SELECT intItemId
		 , strItemNo
		 , intReportAttributeID AS AttributeId
		 , strAttributeName
		 , [-1] AS OpeningInv
		 , [0] AS PastDue
		 , [1] AS strMonth1
		 , [2] AS strMonth2
		 , [3] AS strMonth3
		 , [4] AS strMonth4
		 , [5] AS strMonth5
		 , [6] AS strMonth6
		 , [7] AS strMonth7
		 , [8] AS strMonth8
		 , [9] AS strMonth9
		 , [10] AS strMonth10
		 , [11] AS strMonth11
		 , [12] AS strMonth12
		 , [13] AS strMonth13
		 , [14] AS strMonth14
		 , [15] AS strMonth15
		 , [16] AS strMonth16
		 , [17] AS strMonth17
		 , [18] AS strMonth18
		 , [19] AS strMonth19
		 , [20] AS strMonth20
		 , [21] AS strMonth21
		 , [22] AS strMonth22
		 , [23] AS strMonth23
		 , [24] AS strMonth24
		 , CASE WHEN intItemId = intMainItemId THEN NULL
				ELSE intMainItemId
		   END AS intMainItemId
		 , strGroupByColumn
		 , intLocationId
		 , strLocationName
		 , ysnEditable
	FROM 
	(
		SELECT I.intItemId
			 , CASE WHEN @ysnDisplayRestrictedBookInDemandView = 0 AND ISNULL(strBook, '') = '' THEN (CASE WHEN @ysnDisplayDemandWithItemNoAndDescription = 1 THEN (CASE WHEN I.intItemId = MI.intItemId OR MI.intItemId IS NULL THEN I.strItemNo + ' - ' + I.strDescription + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																																										 ELSE I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ]' + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																																									END)
																									  ELSE (CASE WHEN I.intItemId = MI.intItemId OR MI.intItemId IS NULL THEN I.strItemNo + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																												 ELSE I.strItemNo + ' [ ' + MI.strItemNo + ' ]' + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																											END)
																									  END)
					ELSE (CASE WHEN @ysnDisplayDemandWithItemNoAndDescription = 1 THEN (CASE WHEN I.intItemId = MI.intItemId OR MI.intItemId IS NULL THEN I.strItemNo + ' - ' + I.strDescription + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																							 WHEN I.intItemId <> MI.intItemId AND strBook IS NULL THEN I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ]' + ' [ ' + IsNULL(L.strLocationName, 'All') + ' ]'
																							 ELSE I.strItemNo + ' - ' + I.strDescription + ' [ ' + MI.strItemNo + ' - ' + MI.strDescription + ' ] Restricted [' + strBook + ']' + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
																						END)
							   ELSE (CASE WHEN I.intItemId = MI.intItemId OR MI.intItemId IS NULL THEN I.strItemNo + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
										  WHEN I.intItemId <> MI.intItemId AND strBook IS NULL THEN I.strItemNo + ' [ ' + MI.strItemNo + ' ]' + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
										  ELSE I.strItemNo + ' [ ' + MI.strItemNo + ' ] Restricted [' + strBook + ']' + ' [ ' + ISNULL(L.strLocationName, 'All') + ' ]'
									 END)
						  END)
			   END AS strItemNo
			 , A.intReportAttributeID
			 , CASE WHEN A.intReportAttributeID = 10 AND @strSupplyTarget = 'Monthly' THEN 'Months of Supply'
					WHEN A.intReportAttributeID = 11 AND @strSupplyTarget = 'Monthly' THEN 'Months of Supply Target'
					WHEN A.intReportAttributeID IN (5) AND @intContainerTypeId IS NOT NULL THEN A.strAttributeName + ' [' + @strContainerType + ']'
					ELSE A.strAttributeName
			   END AS strAttributeName
			 , (CASE WHEN DL.intMonthId IN (- 1, 0) AND A.intReportAttributeID IN (2, 4, 13, 14) THEN ISNULL(D.dblQty, 0)
					 WHEN DL.intMonthId IN (- 1, 0) THEN D.dblQty
					 WHEN A.intReportAttributeID IN (8) AND DL.intMonthId <= @intMonthsToView THEN ABS(ISNULL(D.dblQty, 0))
					 WHEN A.intReportAttributeID IN (8, 16) AND DL.intMonthId > @intMonthsToView THEN ABS(D.dblQty)
					 ELSE ISNULL(D.dblQty, 0)
				END) AS dblQty
			 , DL.intMonthId
			 , A.intDisplayOrder
			 , DL.intMainItemId
			 , MI.strItemNo AS strMainItemNo
			 , CASE WHEN I.intItemId = MI.intItemId OR MI.intItemId IS NULL THEN I.strItemNo + ' [ ' + ISNULL(L.strLocationName, 'ZZZZ') + ' ]'
					ELSE MI.strItemNo + ' [ ' + I.strItemNo + ' ]' + ' [ ' + ISNULL(L.strLocationName, 'ZZZZ') + ' ]'
			   END AS strGroupByColumn
			 , ISNULL(L.intCompanyLocationId, 9999) intLocationId
			 , ISNULL(L.strLocationName, 'All') AS strLocationName
			 , A.ysnEditable
		FROM #tblMFDemandList DL
		JOIN tblCTReportAttribute A ON A.intReportAttributeID = DL.intAttributeId
		JOIN tblICItem I ON I.intItemId = DL.intItemId
		LEFT JOIN @tblMFContainerWeight CW ON CW.intItemId = DL.intItemId
		LEFT JOIN #tblMFDemand D ON D.intItemId			= DL.intItemId
								AND D.intMonthId		= DL.intMonthId
								AND D.intAttributeId	= DL.intAttributeId
								AND D.intLocationId		= DL.intLocationId
		LEFT JOIN tblICItem MI ON MI.intItemId = DL.intMainItemId
		LEFT JOIN @tblMFItemBook IB ON IB.intItemId = DL.intItemId
		LEFT JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = DL.intLocationId
	) AS src
	PIVOT(MAX(src.dblQty) FOR src.intMonthId IN 
	(
		[-1]
	  , [0]
	  , [1]
	  , [2]
	  , [3]
	  , [4]
	  , [5]
	  , [6]
	  , [7]
	  , [8]
	  , [9]
	  , [10]
	  , [11]
	  , [12]
	  , [13]
	  , [14]
	  , [15]
	  , [16]
	  , [17]
	  , [18]
	  , [19]
	  , [20]
	  , [21]
	  , [22]
	  , [23]
	  , [24]
	)) AS pvt
	ORDER BY intLocationId
		   , ISNULL(strMainItemNo, strItemNo)
		   , strItemNo
		   , intDisplayOrder;

	SELECT @intRemainingDay AS intRemainingDay;

END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR 
	(
		@ErrMsg
	  , 16
	  , 1
	  , 'WITH NOWAIT'
	)
END CATCH
