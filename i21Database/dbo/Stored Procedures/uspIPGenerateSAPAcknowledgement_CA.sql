CREATE PROCEDURE uspIPGenerateSAPAcknowledgement_CA @strMsgType NVARCHAR(50)
	,@ysnUpdateFeedStatusOnRead BIT = 0
	,@strImportStatus NVARCHAR(50) = ''
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strSQL NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX)
	DECLARE @intMinRowNo INT
		,@intId INT
		,@strMesssageType NVARCHAR(50)
		,@strStatus NVARCHAR(50)
		,@strStatusDesc NVARCHAR(MAX)
		,@strRefNo NVARCHAR(100)
		,@strFileName NVARCHAR(200)
		,@dtmDate DATETIME
		,@strTableName NVARCHAR(100)
		,@strColumnName NVARCHAR(100)
		,@strStatusColumnName NVARCHAR(100)
		,@strInfo1 NVARCHAR(MAX)
		,@strInfo2 NVARCHAR(MAX)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intId INT
		,strMesssageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStatusDesc NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strFileName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmDate DATETIME
		,strTableName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strColumnName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strStatusColumnName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strInfo1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strInfo2 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strIds NVARCHAR(MAX)
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(MAX)
		,strInfo2 NVARCHAR(MAX)
		)

	UPDATE tblIPLoadError
	SET strAckStatus = 'Ack Sent'
	WHERE ISNULL(strAckStatus, '') <> 'Ack Sent'
		AND ISNULL(strErrorMessage, '') LIKE '%deadlock%'

	IF @strMsgType = 'LSI'
	BEGIN
		IF @strImportStatus = 'Success'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'200'
				,''
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadArchive'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadArchive
			WHERE ISNULL(strTransactionType, '') = 'ShippingInstruction'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
		ELSE IF @strImportStatus = 'Failure'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'400'
				,ISNULL(strErrorMessage, '')
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadError'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadError
			WHERE ISNULL(strTransactionType, '') = 'ShippingInstruction'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
	END
	ELSE IF @strMsgType = 'LS'
	BEGIN
		IF @strImportStatus = 'Success'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'200'
				,''
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadArchive'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadArchive
			WHERE ISNULL(strTransactionType, '') = 'Shipment'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
		ELSE IF @strImportStatus = 'Failure'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'400'
				,ISNULL(strErrorMessage, '')
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadError'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadError
			WHERE ISNULL(strTransactionType, '') = 'Shipment'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
	END
	ELSE IF @strMsgType = 'LSI_Cancel'
	BEGIN
		IF @strImportStatus = 'Success'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'200'
				,''
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadArchive'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadArchive
			WHERE ISNULL(strTransactionType, '') = 'LSI_Cancel'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
		ELSE IF @strImportStatus = 'Failure'
		BEGIN
			INSERT INTO @tblAcknowledgement (
				intId
				,strMesssageType
				,strStatus
				,strStatusDesc
				,strRefNo
				,strFileName
				,dtmDate
				,strTableName
				,strColumnName
				,strStatusColumnName
				,strInfo1
				,strInfo2
				)
			SELECT intStageLoadId
				,strTransactionType
				,'400'
				,ISNULL(strErrorMessage, '')
				,strCustomerReference
				,strFileName
				,GETDATE()
				,'tblIPLoadError'
				,'intStageLoadId'
				,'strAckStatus'
				,strCustomerReference
				,strLoadNumber
			FROM tblIPLoadError
			WHERE ISNULL(strTransactionType, '') = 'LSI_Cancel'
				AND ISNULL(strAckStatus, '') <> 'Ack Sent'
		END
	END

	SELECT @intMinRowNo = MIN(intRowNo)
	FROM @tblAcknowledgement

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @intId = intId
			,@strMesssageType = strMesssageType
			,@strStatus = strStatus
			,@strStatusDesc = strStatusDesc
			,@strRefNo = strRefNo
			,@strFileName = strFileName
			,@dtmDate = dtmDate
			,@strTableName = strTableName
			,@strColumnName = strColumnName
			,@strStatusColumnName = strStatusColumnName
			,@strInfo1 = strInfo1
			,@strInfo2 = strInfo2
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		BEGIN
			SELECT @strXML = '<Acknowledgement>'

			SELECT @strXML = @strXML + '<code>' + @strStatus + '</code>'

			SELECT @strXML = @strXML + '<description>' + @strStatusDesc + '</description>'

			SELECT @strXML = @strXML + '<reference>' + @strRefNo + '</reference>'

			SELECT @strXML = @strXML + '<messageId>' + @strFileName + '</messageId>'

			SELECT @strXML = @strXML + '<timestamp>' + CONVERT(VARCHAR(30), @dtmDate, 126) + '</timestamp>'

			SELECT @strXML = @strXML + '</Acknowledgement>'
		END

		IF @strXML IS NOT NULL
		BEGIN
			INSERT INTO @tblOutput (
				strIds
				,strRowState
				,strXML
				,strInfo1
				,strInfo2
				)
			VALUES (
				@intId
				,@strMesssageType
				,@strXML
				,ISNULL(@strInfo1, '')
				,ISNULL(@strInfo2, '')
				)

			IF @ysnUpdateFeedStatusOnRead = 1
			BEGIN
				SET @strSQL = 'Update ' + @strTableName + ' Set ' + @strStatusColumnName + '=''Ack Sent'' Where ' + @strColumnName + ' IN (' + CONVERT(VARCHAR, @intId) + ')'

				EXEC sp_executesql @strSQL
			END
		END

		IF EXISTS (
				SELECT 1
				FROM @tblOutput
				)
		BEGIN
			BREAK
		END

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblAcknowledgement
		WHERE intRowNo > @intMinRowNo
	END

	SELECT IsNULL(strIds, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strInfo1, '') AS strInfo1
		,IsNULL(strInfo2, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
