﻿CREATE PROCEDURE uspIPStageSAPStock_ST @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblLot TABLE (
		strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblNetWeight NUMERIC(38, 20)
		,strNetWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblCost NUMERIC(38, 20)
		,strCostUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCostCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSessionId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'Stock'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblLot

			INSERT INTO @tblLot (
				strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSessionId
				,strTransactionType
				)
			SELECT ITEM_NO
				,LOCATION_NO
				,SUB_LOCATION
				,STORAGE_LOCATION
				,CASE 
					WHEN ISNUMERIC(QUANTITY) = 0
						THEN NULL
					ELSE QUANTITY
					END
				,QUANTITY_UOM
				,CASE 
					WHEN ISNUMERIC(NET_WEIGHT) = 0
						THEN NULL
					ELSE NET_WEIGHT
					END
				,NET_WEIGHT_UOM
				,LOT_NO
				,CASE 
					WHEN ISNUMERIC(COST) = 0
						THEN NULL
					ELSE COST
					END
				,COST_UOM
				,COST_CURRENCY
				,DOC_NO
				,MSG_TYPE
			FROM OPENXML(@idoc, 'ROOT_STOCK/LINE_ITEM', 2) WITH (
					ITEM_NO NVARCHAR(50)
					,LOCATION_NO NVARCHAR(50)
					,SUB_LOCATION NVARCHAR(50)
					,STORAGE_LOCATION NVARCHAR(50)
					,QUANTITY NVARCHAR(50)
					,QUANTITY_UOM NVARCHAR(50)
					,NET_WEIGHT NVARCHAR(50)
					,NET_WEIGHT_UOM NVARCHAR(50)
					,LOT_NO NVARCHAR(50)
					,COST NVARCHAR(50)
					,COST_UOM NVARCHAR(50)
					,COST_CURRENCY NVARCHAR(50)
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ' / ' + ISNULL(strLotNumber, '') + ','
				,@strInfo2 = @strInfo2 + ISNULL(strStorageLocationName, '') + ','
			FROM @tblLot

			--Add to Staging tables
			INSERT INTO tblIPLotStage (
				strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSessionId
				,strTransactionType
				)
			SELECT strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strLotNumber
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSessionId
				,strTransactionType
			FROM @tblLot

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
		FROM tblIPIDOCXMLStage WITH (NOLOCK)
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Stock'
	END

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF (ISNULL(@strInfo2, '')) <> ''
		SELECT @strInfo2 = LEFT(@strInfo2, LEN(@strInfo2) - 1)

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
