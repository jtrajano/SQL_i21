CREATE PROCEDURE uspIPGenerateSAPRecipeIDOC
AS
BEGIN
	DECLARE @intRecipeStageId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strTransactionType NVARCHAR(50)
		,@strXml NVARCHAR(MAX)
		,@strRecipeName NVARCHAR(250)
		,@strItemNo NVARCHAR(50)
		,@strSessionId NVARCHAR(50)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strContractFeedIds NVARCHAR(MAX)
		,strRowState NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		,strContractNo NVARCHAR(100)
		,strPONo NVARCHAR(100)
		)

	SELECT @intRecipeStageId = MIN(intRecipeStageId)
	FROM dbo.tblMFRecipeStage
	WHERE strMessage IS NULL

	WHILE @intRecipeStageId IS NOT NULL
	BEGIN
		SELECT @strHeaderXML = NULL

		SELECT @strDetailXML = ''

		SELECT @strRecipeName = ''

		SELECT @strItemNo = ''

		SELECT @strTransactionType = ''

		SELECT @strSessionId = ''

		SELECT @strRecipeName = strRecipeName
			,@strItemNo = strItemNo
			,@strTransactionType = strTransactionType
			,@strSessionId = strSessionId
		FROM dbo.tblMFRecipeStage
		WHERE intRecipeStageId = @intRecipeStageId

		IF @strTransactionType IN (
				'RECIPE_UPDATE'
				,'RECIPE_DELETE'
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblMFRecipeStage
				WHERE strRecipeName = @strRecipeName
					AND strItemNo = @strItemNo
					AND strTransactionType = 'RECIPE_CREATE'
					AND strMessage = 'Success'
				)
		BEGIN
			GOTO NextRecipe
		END

		SELECT @strHeaderXML = '<ROOT><CTRL_POINT>' + '<DOC_NO>' + Ltrim(@intRecipeStageId) + '</DOC_NO>' + '<MSG_TYPE>' + Ltrim(strTransactionType) + '</MSG_TYPE>' + '<SENDER>i21</SENDER>' + '<RECEIVER>ERP</RECEIVER>' + '</CTRL_POINT>' + '<HEADER>' + '<RECIPE_NAME>' + IsNULL(strRecipeName, '') + '</RECIPE_NAME>' + '<LOCATION_NO>' + IsNULL(strLocationName, '') + '</LOCATION_NO>' + '<ITEM_NO>' + strItemNo + '</ITEM_NO>' + '<QUANTITY>' + strQuantity + '</QUANTITY>' + '<QUANTITY_UOM>' + strUOM + '</QUANTITY_UOM>' + '<VERSION>' + strVersionNo + '</VERSION>' + '<VALID_FROM>' + IsNULL(Convert(CHAR, strValidFrom, 112), '') + '</VALID_FROM>' + '<VALID_TO>' + IsNULL(Convert(CHAR, strValidTo, 112), '') + '</VALID_TO>' + '<PROCESS_NAME>' + IsNULL(strManufacturingProcess, '') + '</PROCESS_NAME>' + '<CREATE_DATE>' + IsNULL(Convert(CHAR, dtmCreated, 112), '') + '</CREATE_DATE>' + '<CREATED_BY>' + IsNULL(strCreatedBy, '') + '</CREATED_BY>' + '<TRACKING_NO>' + IsNULL(strSessionId, '') + '</TRACKING_NO>' + '</HEADER>'
		FROM dbo.tblMFRecipeStage
		WHERE strSessionId = @strSessionId

		SELECT @strDetailXML = @strDetailXML + '<LINE_ITEMS><LINE_ITEM><SEQUENCE_NO>' + IsNULL(strItemGroupName, '') + '</SEQUENCE_NO>' + '<ITEM_NO>' + strRecipeItemNo + '</ITEM_NO>' + '<QUANTITY>' + strQuantity + '</QUANTITY>' + '<QUANTITY_UOM>' + strUOM + '</QUANTITY_UOM>' + '<RECIPE_ITEM_TYPE>' + strRecipeItemType + '</RECIPE_ITEM_TYPE>' + '<LOWER_TOLERANCE>' + IsNULL(strLowerTolerance, '') + '</LOWER_TOLERANCE>' + '<UPPER_TOLERANCE>' + IsNULL(strUpperTolerance, '') + '</UPPER_TOLERANCE>' + '<VALID_FROM>' + IsNULL(strValidFrom, '') + '</VALID_FROM>' + '<VALID_TO>' + IsNULL(strValidTo, '') + '</VALID_TO>' + '<YEAR_VALIDATION>' + IsNULL(strYearValidationRequired, 0) + '</YEAR_VALIDATION>' + '<CONSUMPTION_METHOD>' + IsNULL(strConsumptionMethod, '') + '</CONSUMPTION_METHOD>' + '<STORAGE_LOCATION>' + IsNULL(strStorageLocation, '') + '</STORAGE_LOCATION>' + '<ROW_STATE>' + strRowState + '</ROW_STATE>' + '<TRACKING_NO>' + IsNULL(strSessionId, '') + '</TRACKING_NO>' + '</LINE_ITEM></LINE_ITEMS>'
		FROM dbo.tblMFRecipeItemStage
		WHERE strSessionId = @strSessionId

		SELECT @strXml = @strHeaderXML + @strDetailXML + '</ROOT>'

		INSERT INTO @tblOutput (
			strContractFeedIds
			,strRowState
			,strXml
			,strContractNo
			,strPONo
			)
		VALUES (
			@intRecipeStageId
			,@strTransactionType
			,@strXml
			,ISNULL(@strRecipeName, '')
			,ISNULL(@strItemNo, '')
			)

		UPDATE tblMFRecipeStage
		SET strMessage = 'Success'
		WHERE strSessionId = @strSessionId

		UPDATE tblMFRecipeItemStage
		SET strMessage = 'Success'
		WHERE strSessionId = @strSessionId

		IF EXISTS (
				SELECT *
				FROM @tblOutput
				)
		BEGIN
			BREAK
		END

		NextRecipe:

		SELECT @intRecipeStageId = MIN(intRecipeStageId)
		FROM dbo.tblMFRecipeStage
		WHERE strMessage IS NULL
			AND intRecipeStageId > @intRecipeStageId
	END

	SELECT IsNULL(strContractFeedIds, '0') AS id
		,IsNULL(strXml, '') AS strXml
		,IsNULL(strContractNo, '') AS strInfo1
		,IsNULL(strPONo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
END
