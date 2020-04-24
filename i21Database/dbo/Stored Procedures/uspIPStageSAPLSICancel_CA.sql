CREATE PROCEDURE uspIPStageSAPLSICancel_CA @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
		,@strFileName NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblLoad TABLE (
		strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCancelStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmCancelDate DATETIME
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'LSI_Cancel'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@strFileName = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
				,@strFileName = strFileName
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblLoad

			INSERT INTO @tblLoad (
				strCustomerReference
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				)
			SELECT Reference
				,[Status]
				,CASE 
					WHEN ISDATE([Timestamp]) = 0
						OR [Timestamp] = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE [Timestamp]
					END
				,'LSI_Cancel'
			FROM OPENXML(@idoc, 'Shipment', 2) WITH (
					Reference NVARCHAR(100)
					,[Status] NVARCHAR(50)
					,[Timestamp] DATETIME
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strCustomerReference, '') + ','
			FROM @tblLoad

			SELECT @strInfo2 = @strInfo2 + ISNULL(strCancelStatus, '') + ','
			FROM @tblLoad

			--Add to Staging tables
			INSERT INTO tblIPLoadStage (
				strCustomerReference
				,strCancelStatus
				,dtmCancelDate
				,strFileName
				,strTransactionType
				)
			SELECT strCustomerReference
				,strCancelStatus
				,dtmCancelDate
				,@strFileName
				,strTransactionType
			FROM @tblLoad

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,strFileName
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
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
				,strFileName
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
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
			AND strType = 'LSI_Cancel'
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
