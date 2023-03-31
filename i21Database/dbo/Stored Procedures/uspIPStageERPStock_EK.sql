CREATE PROCEDURE uspIPStageERPStock_EK @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
		,@dtmCurrentDate DATETIME
	DECLARE @tblIPLot TABLE (strLotNumber NVARCHAR(50))
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Stock'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	SELECT @dtmCurrentDate = GETDATE()

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
			FROM @tblIPLot

			INSERT INTO tblIPLotStage (
				intTrxSequenceNo
				,dtmCreatedDate
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,strLotNumber
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,dblAllocatedQty
				)
			OUTPUT INSERTED.strLotNumber
			INTO @tblIPLot
			SELECT DocNo
				,@dtmCurrentDate
				,[Location]
				,StorageLocation
				,StorageUnit
				,BatchId
				,ItemNo
				,Quantity
				,Case When Location='1711' and IsNULL(QuantityUOM,'')='' Then 'LB' When Location<>'1711' and IsNULL(QuantityUOM,'')='' Then 'KG'Else QuantityUOM End
				,NetWeight
				,Case When Location='1711' and IsNULL(NetWeightUOM,'')='' Then 'LB' When Location<>'1711' and IsNULL(NetWeightUOM,'')='' Then 'KG'Else NetWeightUOM End
				,Cost
				,Case When Location='1711' and IsNULL(CostUOM,'')='' Then 'LB' When Location<>'1711' and IsNULL(CostUOM,'')='' Then 'KG'Else CostUOM End
				,Case When IsNULL(CostCurrency,'')='' Then 'USD' Else CostCurrency End
				,AllocatedQty
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,[Location] NVARCHAR(50)
					,StorageLocation NVARCHAR(50)
					,StorageUnit NVARCHAR(50)
					,BatchId NVARCHAR(50)
					,ItemNo NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,QuantityUOM NVARCHAR(50)
					,NetWeight NUMERIC(18, 6)
					,NetWeightUOM NVARCHAR(50)
					,Cost NUMERIC(18, 6)
					,CostUOM NVARCHAR(50)
					,CostCurrency NVARCHAR(40)
					,AllocatedQty NUMERIC(18, 6)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strLotNumber, '') + ','
			FROM @tblIPLot

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
