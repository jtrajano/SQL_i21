CREATE PROCEDURE [dbo].[uspIPStageERPRecipe_EK] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPRecipeName TABLE (strBlendCode NVARCHAR(250))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strInputItemLowerTolerance NVARCHAR(50)
		,@strInputItemUpperTolerance NVARCHAR(50)
		,@strOutputItemLowerTolerance NVARCHAR(50)
		,@strOutputItemUpperTolerance NVARCHAR(50)
		,@strIgnoreShrinkageCommodity NVARCHAR(50)
		,@intCommodityId int
		,@dtmCurrentDate date

	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Recipe'
	AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	Select 	@dtmCurrentDate=GETDATE()

	UPDATE S
	SET S.intStatusId = -1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	SELECT @strInputItemLowerTolerance = dbo.[fnIPGetSAPIDOCTagValue]('Recipe', 'Input Item Lower Tolerance')

	SELECT @strInputItemUpperTolerance = dbo.[fnIPGetSAPIDOCTagValue]('Recipe', 'Input Item Upper Tolerance')

	SELECT @strOutputItemLowerTolerance = dbo.[fnIPGetSAPIDOCTagValue]('Recipe', 'Output Item Lower Tolerance')

	SELECT @strOutputItemUpperTolerance = dbo.[fnIPGetSAPIDOCTagValue]('Recipe', 'Output Item Upper Tolerance')

	IF @strInputItemLowerTolerance IS NULL
		OR @strInputItemLowerTolerance = ''
		OR isNUmeric(@strInputItemLowerTolerance) = 0
	BEGIN
		SELECT @strInputItemLowerTolerance = 0
	END

	IF @strInputItemUpperTolerance IS NULL
		OR @strInputItemUpperTolerance = ''
		OR isNUmeric(@strInputItemUpperTolerance) = 0
	BEGIN
		SELECT @strInputItemUpperTolerance = 0
	END

	IF @strOutputItemLowerTolerance IS NULL
		OR @strOutputItemLowerTolerance = ''
		OR isNUmeric(@strOutputItemLowerTolerance) = 0
	BEGIN
		SELECT @strOutputItemLowerTolerance = 0
	END

	IF @strOutputItemUpperTolerance IS NULL
		OR @strOutputItemUpperTolerance = ''
		OR isNUmeric(@strOutputItemUpperTolerance) = 0
	BEGIN
		SELECT @strOutputItemUpperTolerance = 0
	END

	DELETE FROM tblMFRecipeStage WHERE intStatusId=1 
	DELETE FROM tblMFRecipeItemStage WHERE intStatusId=1 

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblIPRecipeName

			INSERT INTO tblMFRecipeStage (
				strRecipeName
				,strLocationName
				,strItemNo
				,strQuantity
				,strUOM
				,strVersionNo
				,strValidFrom
				,strValidTo
				,strManufacturingProcess
				,dtmCreated
				,strCreatedBy
				,strSessionId
				,strRecipeType
				,strTransactionType
				,intTrxSequenceNo
				,strERPRecipeNo
				,intActive
				,strSubLocationName
				)
			OUTPUT INSERTED.strItemNo 
			INTO @tblIPRecipeName
			SELECT BlendCode
				,strLocationName
				,BlendCode
				,100 AS Quantity
				,OrderQuantityUOM
				,1 AS [Version]
				,WeekCommencing
				,WeekCommencing+6 ValidTo
				,MP.strProcessName
				,@dtmCurrentDate AS CreatedDate
				,NULL CreatedBy
				,DocNo AS TrxSequenceNo
				,'By Quantity'
				,1 AS ActionId
				,DocNo AS TrxSequenceNo
				,NULL ERPRecipeNo
				,1 Active
				,NULL StorageLocation
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,LocationCode NVARCHAR(6) collate Latin1_General_CI_AS
					,BlendCode NVARCHAR(50)	  collate Latin1_General_CI_AS
					,OrderQuantityUOM NVARCHAR(50)	  collate Latin1_General_CI_AS
					,WeekCommencing DATETIME
					) x
			LEFT JOIN tblSMCompanyLocation CL ON CL.strVendorRefNoPrefix = x.LocationCode
				AND strLocationType = 'Plant'
			LEFT JOIN tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = 1

			SELECT @strInfo1 = @strInfo1 + ISNULL(strBlendCode, '') + ','
			FROM @tblIPRecipeName

			INSERT INTO tblMFRecipeItemStage (
				[strRecipeName]
				,[strLocationName]
				,[strVersionNo]
				,strRecipeItemNo
				,strQuantity
				,strUOM
				,strRecipeItemType
				,strLowerTolerance
				,strUpperTolerance
				,strValidFrom
				,strValidTo
				,strYearValidationRequired
				,strConsumptionMethod
				,strStorageLocation
				,strSessionId
				,strRowState
				,strItemGroupName
				,intTrxSequenceNo
				,strRecipeHeaderItemNo
				)
			SELECT BlendCode AS strRecipeName
				,CL.strLocationName
				,1 AS [Version]
				,ItemCode AS ItemNo
				,ItemPercentage AS Quantity
				,ItemQuantityUOM AS UOM
				,CASE 
					WHEN BlendCode = ItemCode
						THEN 'OUTPUT'
					ELSE 'INPUT'
					END AS RecipeItemType
				,CASE 
					WHEN BlendCode = ItemCode
						THEN IsNULL(dblSanitizationOrderOutputQtyTolerancePercentage,@strOutputItemLowerTolerance)
					ELSE @strInputItemLowerTolerance
					END AS LowerTolerance
				,CASE 
					WHEN BlendCode = ItemCode
						THEN IsNULL(dblSanitizationOrderOutputQtyTolerancePercentage,@strOutputItemUpperTolerance)
					ELSE @strInputItemUpperTolerance
					END AS UpperTolerance
				,WeekCommencing AS ValidFrom
				,WeekCommencing+6 AS ValidTo
				,1 AS YearValidation
				,NULL AS ConsumptionMethod
				,NULL AS StorageLocation
				,DocNo AS SessionId
				,'C' AS RowState
				,NULL AS ItemGroupName
				,DocNo
				,BlendCode
			FROM OPENXML(@idoc, 'root/Header/Line', 2) WITH (
					DocNo BIGINT '../../DocNo'
					,ItemCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,ItemPercentage NUMERIC(18, 6)
					,ItemQuantityUOM NVARCHAR(50)
					,WeekCommencing DATETIME '../WeekCommencing'
					,BlendCode NVARCHAR(50) Collate Latin1_General_CI_AS '../BlendCode'
					,LocationCode NVARCHAR(6) Collate Latin1_General_CI_AS '../LocationCode'
					) x
			LEFT JOIN tblSMCompanyLocation CL ON CL.strVendorRefNoPrefix = x.LocationCode
				AND strLocationType = 'Plant'

			INSERT INTO tblMFProductionOrderStage (
				strOrderNo
				,strLocationCode
				,dblOrderQuantity 
				,strOrderQuantityUOM 
				,dblNoOfMixes 
				--,dtmPlanDate
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,intDocNo
				,dblTeaTaste
				,dblTeaHue
				,dblTeaIntensity
				,dblTeaMouthFeel
				,dblTeaAppearance
				,dblTeaVolume
				)
			SELECT OrderNo
				,LocationCode
				,OrderQuantity 
				,OrderQuantityUOM 
				,NoOfMixes 
				--,PlanDate
				,BatchId
				,NoOfPack
				,NoOfPackUOM
				,Weight
				,WeightUOM
				,DocNo
				,TAverage
				,HAverage
				,IAverage
				,MAverage
				,AAverage
				,VAverage
			FROM OPENXML(@idoc, 'root/Header/Line/Batch', 2) WITH (
					DocNo BIGINT '../../../DocNo'
					,OrderNo NVARCHAR(50) collate Latin1_General_CI_AS '../../OrderNo'
					,LocationCode NVARCHAR(50) collate Latin1_General_CI_AS '../../LocationCode'
					,OrderQuantity numeric(38,20)'../../OrderQuantity'
					,OrderQuantityUOM NVARCHAR(50) collate Latin1_General_CI_AS '../../OrderQuantityUOM'
					,NoOfMixes numeric(38,20)'../../NoOfMixes'
					--,PlanDate DateTime'../PlanDate'
					,BatchId NVARCHAR(50) collate Latin1_General_CI_AS
					,NoOfPack NUMERIC(38,20)
					,NoOfPackUOM NVARCHAR(50) collate Latin1_General_CI_AS
					,Weight NVARCHAR(50)
					,WeightUOM NVARCHAR(50) collate Latin1_General_CI_AS
					,TAverage  NUMERIC(38,20)'../../TAverage'
					,HAverage NUMERIC(38,20)'../../HAverage'
					,IAverage NUMERIC(38,20)'../../IAverage'
					,MAverage NUMERIC(38,20)'../../MAverage'
					,AAverage NUMERIC(38,20)'../../AAverage'
					,VAverage NUMERIC(38,20)'../../VAverage'
					) x
			LEFT JOIN tblSMCompanyLocation CL ON CL.strVendorRefNoPrefix = x.LocationCode
				AND strLocationType = 'Plant'
			WHERE x.BatchId<>'NoN' AND isNumeric(Weight)=1

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
