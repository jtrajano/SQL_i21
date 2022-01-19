CREATE PROCEDURE [dbo].[uspIPStageERPRecipe] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPRecipeName TABLE (strERPRecipeNo NVARCHAR(250))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strInputItemLowerTolerance NVARCHAR(50)
		,@strInputItemUpperTolerance NVARCHAR(50)
		,@strOutputItemLowerTolerance NVARCHAR(50)
		,@strOutputItemUpperTolerance NVARCHAR(50)
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

	DELETE FROM tblMFRecipeStage WHERE intStatusId=1 AND ysnInitialAckSent =1
	DELETE FROM tblMFRecipeItemStage WHERE intStatusId=1 AND ysnInitialAckSent =1

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
			OUTPUT INSERTED.strERPRecipeNo
			INTO @tblIPRecipeName
			SELECT ItemNo
				,strLocationName
				,ItemNo
				,Quantity
				,UOM
				,[Version]
				,ValidFrom
				,ValidTo
				,MP.strProcessName
				,CreatedDate
				,CreatedBy
				,TrxSequenceNo
				,'By Quantity'
				,CASE 
					WHEN ActionId = 1
						THEN 'RECIPE_CREATE'
					WHEN ActionId = 2
						THEN 'RECIPE_UPDATE'
					WHEN ActionId = 4
						THEN 'RECIPE_DELETE'
					END
				,TrxSequenceNo
				,ERPRecipeNo
				,Active
				,StorageLocation
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6) collate Latin1_General_CI_AS
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,[Version] INT
					,ItemNo NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,UOM NVARCHAR(50)
					,ValidFrom DATETIME
					,ValidTo DATETIME
					,StorageLocation NVARCHAR(50)
					,ERPRecipeNo NVARCHAR(50)
					,ProcessName NVARCHAR(50)
					,Active INT
					) x
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLotOrigin = x.CompanyLocation
			LEFT JOIN tblICItem I ON I.strItemNo = x.ItemNo Collate Latin1_General_CI_AS
			LEFT JOIN tblIPCommodityManufacturingProcess CP ON CP.intCommodityId = I.intCommodityId
			LEFT JOIN tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = CP.intManufacturingProcessId

			SELECT @strInfo1 = @strInfo1 + ISNULL(strERPRecipeNo, '') + ','
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
				,intParentTrxSequenceNo
				,strShrinkage
				)
			SELECT NULL AS strRecipeName
				,CL.strLocationName
				,[Version] AS [Version]
				,ItemNo
				,Quantity
				,UOM
				,CASE 
					WHEN ItemType = 1
						THEN 'INPUT'
					ELSE 'OUTPUT'
					END AS RecipeItemType
				,CASE 
					WHEN ItemType = 1
						THEN @strInputItemLowerTolerance
					ELSE @strOutputItemLowerTolerance
					END AS LowerTolerance
				,CASE 
					WHEN ItemType = 1
						THEN @strInputItemUpperTolerance
					ELSE @strOutputItemUpperTolerance
					END AS UpperTolerance
				,ValidFrom
				,ValidTo
				,YearValidation
				,NULL AS ConsumptionMethod
				,NULL AS StorageLocation
				,TrxSequenceNo AS SessionId
				,CASE 
					WHEN ActionId = 1
						THEN 'C'
					WHEN ActionId = 2
						THEN 'U'
					WHEN ActionId = 4
						THEN 'D'
					END AS RowState
				,NULL AS ItemGroupName
				,TrxSequenceNo
				,parentId
				,Shrinkage
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					TrxSequenceNo BIGINT
					,[Version] INT '../Version'
					,ActionId INT
					,ItemNo NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,UOM NVARCHAR(50)
					,Shrinkage NUMERIC(18, 6)
					,ItemType INT
					,LowerTolerance NUMERIC(18, 6)
					,UpperTolerance NUMERIC(18, 6)
					,ValidFrom DATETIME
					,ValidTo DATETIME
					,YearValidation INT
					,parentId BIGINT '@parentId'
					,CompanyLocation NVARCHAR(6) Collate Latin1_General_CI_AS '../CompanyLocation'
					) x
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLotOrigin = x.CompanyLocation

			UPDATE RI
			SET strRecipeHeaderItemNo = R.strItemNo
				,strRecipeName = R.strItemNo
				,strValidFrom = R.strValidFrom
				,strValidTo = R.strValidTo
			FROM tblMFRecipeStage R
			JOIN tblMFRecipeItemStage RI ON RI.intParentTrxSequenceNo = R.intTrxSequenceNo

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

			INSERT INTO dbo.tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,4 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					)

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
