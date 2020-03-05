CREATE PROCEDURE uspIPStageSAPShipmentStatus_ST @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @tblShipmentStatus TABLE (
		strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intContractSeq INT
		,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dtmArrivedInPort DATETIME
		,dtmCustomsReleased DATETIME
		,dtmETA DATETIME
		,strSessionId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'ShipmentStatus'

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
			FROM @tblShipmentStatus

			INSERT INTO @tblShipmentStatus (
				strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strSessionId
				,strTransactionType
				)
			SELECT CONTRACT_NO
				,SEQUENCE_NO
				,BL_NO
				,SHIPMENT_STATUS
				,CASE 
					WHEN ISDATE(ARRIVED_IN_PORT_DATE) = 0
						OR ARRIVED_IN_PORT_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE ARRIVED_IN_PORT_DATE
					END
				,CASE 
					WHEN ISDATE(CUSTOMS_RELEASED_DATE) = 0
						OR CUSTOMS_RELEASED_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CUSTOMS_RELEASED_DATE
					END
				,CASE 
					WHEN ISDATE(ETA_DATE) = 0
						OR ETA_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE ETA_DATE
					END
				,DOC_NO
				,MSG_TYPE
			FROM OPENXML(@idoc, 'ROOT/HEADER', 2) WITH (
					CONTRACT_NO NVARCHAR(50)
					,SEQUENCE_NO INT
					,BL_NO NVARCHAR(100)
					,SHIPMENT_STATUS NVARCHAR(100)
					,ARRIVED_IN_PORT_DATE DATETIME
					,CUSTOMS_RELEASED_DATE DATETIME
					,ETA_DATE DATETIME
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strBLNumber, '') + ','
			FROM @tblShipmentStatus

			--Add to Staging tables
			INSERT INTO tblIPShipmentStatusStage (
				strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strSessionId
				,strTransactionType
				)
			SELECT strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strSessionId
				,strTransactionType
			FROM @tblShipmentStatus

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
			AND strType = 'ShipmentStatus'
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
