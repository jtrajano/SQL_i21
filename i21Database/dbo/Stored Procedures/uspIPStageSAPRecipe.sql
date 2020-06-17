CREATE PROCEDURE [dbo].[uspIPStageSAPRecipe] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPRecipeName TABLE (strRecipeName NVARCHAR(250))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Recipe'

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
				,strSessionId
				,strRecipeType
				,strTransactionType
				)
			OUTPUT INSERTED.strRecipeName
			INTO @tblIPRecipeName
			SELECT DISTINCT RECIPE_NAME
				,LOCATION_NO
				,ITEM_NO
				,QUANTITY
				,QUANTITY_UOM
				,[VERSION]
				,VALID_FROM
				,VALID_TO
				,IsNULL(PROCESS_NAME, (
						SELECT TOP 1 strProcessName
						FROM tblMFManufacturingProcess
						))
				,CREATE_DATE
				,DOC_NO
				,'By Quantity'
				,MSG_TYPE
			FROM OPENXML(@idoc, 'ROOT_RECIPE/HEADER', 2) WITH (
					RECIPE_NAME NVARCHAR(250)
					,LOCATION_NO NVARCHAR(50)
					,ITEM_NO NVARCHAR(50)
					,QUANTITY NUMERIC(18, 6)
					,QUANTITY_UOM NVARCHAR(50)
					,[VERSION] INT
					,VALID_FROM NVARCHAR(50)
					,VALID_TO NVARCHAR(50)
					,PROCESS_NAME NVARCHAR(50)
					,CREATE_DATE DATETIME
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strRecipeName, '') + ','
			FROM @tblIPRecipeName

			INSERT INTO tblMFRecipeItemStage (
				[strRecipeName]
				,[strLocationName]
				--,[strRecipeHeaderItemNo]
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
				)
			SELECT RECIPE_NAME
				,LOCATION_NO
				--,HEADER_ITEM_NO
				,VERSION
				,ITEM_NO
				,QUANTITY
				,QUANTITY_UOM
				,RECIPE_ITEM_TYPE
				,LOWER_TOLERANCE
				,UPPER_TOLERANCE
				,VALID_FROM
				,VALID_TO
				,YEAR_VALIDATION
				,CONSUMPTION_METHOD
				,STORAGE_LOCATION
				,DOC_NO
				,ROW_STATE
				,SEQUENCE_NO
			FROM OPENXML(@idoc, 'ROOT_RECIPE/LINE_ITEM', 2) WITH (
					RECIPE_NAME NVARCHAR(250) '../HEADER/RECIPE_NAME'
					,LOCATION_NO NVARCHAR(50) '../HEADER/LOCATION_NO'
					--,HEADER_ITEM_NO NVARCHAR(50) '../../HEADER/HEADER_ITEM_NO'
					,VERSION INT '../HEADER/VERSION'
					,ITEM_NO NVARCHAR(50)
					,QUANTITY NUMERIC(18, 6)
					,QUANTITY_UOM NVARCHAR(50)
					,RECIPE_ITEM_TYPE NVARCHAR(50)
					,LOWER_TOLERANCE NUMERIC(18, 6)
					,UPPER_TOLERANCE NUMERIC(18, 6)
					,VALID_FROM NVARCHAR(50)
					,VALID_TO NVARCHAR(50)
					,YEAR_VALIDATION BIT
					,CONSUMPTION_METHOD NVARCHAR(50)
					,STORAGE_LOCATION NVARCHAR(50)
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,ROW_STATE NVARCHAR(50)
					,SEQUENCE_NO INT
					) x

			UPDATE RI
			SET strRecipeHeaderItemNo = R.strItemNo 
			FROM tblMFRecipeStage R
			JOIN tblMFRecipeItemStage RI ON RI.strRecipeName =R.strRecipeName and RI.strSessionId =R.strSessionId 

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
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Recipe'
	END

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
