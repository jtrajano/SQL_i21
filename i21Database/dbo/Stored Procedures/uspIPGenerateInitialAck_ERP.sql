CREATE PROCEDURE uspIPGenerateInitialAck_ERP @strCompany NVARCHAR(50) = ''
	,@intMessageType INT = NULL
	,@ysnUpdateFeedStatus BIT = 0
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX) = ''
	DECLARE @strFinalXML NVARCHAR(MAX) = ''
		,@strInfo1 NVARCHAR(MAX) = ''
	DECLARE @intMinRowNo INT
		,@intInitialAckId INT
		,@intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@intMessageTypeId INT
		,@intStatusId INT
		,@strStatusText NVARCHAR(MAX)
		,@strReceiptNo	NVARCHAR(50) 
		,@strAdjustmentNo	NVARCHAR(50) 
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intInitialAckId INT
		,intTrxSequenceNo BIGINT
		,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
		,dtmCreatedDate DATETIME
		,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intMessageTypeId INT
		,intStatusId INT
		,strStatusText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strReceiptNo	NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strAdjustmentNo	NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intInitialAckId INT
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(100)
		,strInfo2 NVARCHAR(100)
		)

	DELETE
	FROM @tblOutput

	DELETE
	FROM @tblAcknowledgement

	INSERT INTO @tblAcknowledgement (
		intInitialAckId
		,intTrxSequenceNo
		,strCompanyLocation
		,dtmCreatedDate
		,strCreatedBy
		,intMessageTypeId
		,intStatusId
		,strStatusText
		,strReceiptNo
		,strAdjustmentNo
		)
	SELECT TOP 1000 intInitialAckId
		,intTrxSequenceNo
		,strCompanyLocation
		,dtmCreatedDate
		,strCreatedBy
		,intMessageTypeId
		,intStatusId
		,strStatusText
		,strReceiptNo
		,strAdjustmentNo
	FROM tblIPInitialAck
	WHERE strFeedStatus IS NULL
		AND strCompanyLocation = @strCompany
		AND intMessageTypeId = @intMessageType

	SELECT @intMinRowNo = MIN(intRowNo)
	FROM @tblAcknowledgement

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @intInitialAckId = NULL
			,@intTrxSequenceNo = NULL
			,@strCompanyLocation = NULL
			,@dtmCreatedDate = NULL
			,@strCreatedBy = NULL
			,@intMessageTypeId = NULL
			,@intStatusId = NULL
			,@strStatusText = NULL
			,@strReceiptNo = NULL
			,@strAdjustmentNo = NULL
			 
		SELECT @intInitialAckId = intInitialAckId
			,@intTrxSequenceNo = intTrxSequenceNo
			,@strCompanyLocation = strCompanyLocation
			,@dtmCreatedDate = dtmCreatedDate
			,@strCreatedBy = strCreatedBy
			,@intMessageTypeId = intMessageTypeId
			,@intStatusId = intStatusId
			,@strStatusText = strStatusText
			,@strReceiptNo = strReceiptNo
			,@strAdjustmentNo = strAdjustmentNo
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		BEGIN
			SELECT @strXML += '<header id="' + LTRIM(@intTrxSequenceNo) + '">'

			SELECT @strXML += '<TrxSequenceNo>' + ISNULL(CONVERT(VARCHAR, @intTrxSequenceNo), '') + '</TrxSequenceNo>'

			SELECT @strXML += '<CompanyLocation>' + @strCompanyLocation + '</CompanyLocation>'

			SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(30), GETDATE(), 126) + '</CreatedDate>'

			SELECT @strXML += '<CreatedByUser>' + ISNULL(@strCreatedBy, '') + '</CreatedByUser>'

			SELECT @strXML += '<MessageTypeId>' + ISNULL(CONVERT(VARCHAR, @intMessageTypeId), '') + '</MessageTypeId>'

			SELECT @strXML += '<StatusId>' + ISNULL(CONVERT(VARCHAR, @intStatusId), '') + '</StatusId>'

			IF @intStatusId = 1
				SELECT @strStatusText = ''

			SELECT @strXML += '<StatusText>' + @strStatusText + '</StatusText>'
			SELECT @strXML += '<ReceiptNo>' + IsNULL(@strReceiptNo,'') + '</ReceiptNo>'
			SELECT @strXML += '<AdjustmentNo>' + IsNULL(@strAdjustmentNo,'') + '</AdjustmentNo>'

			SELECT @strXML += '</header>'
		END

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblIPInitialAck
			SET strFeedStatus = 'Ack Sent'
			WHERE intInitialAckId = @intInitialAckId
		END

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblAcknowledgement
		WHERE intRowNo > @intMinRowNo
	END

	IF ISNULL(@strXML, '') <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strXML + '</data></root>'

		SELECT @strInfo1 = 'Initial Ack'

		INSERT INTO @tblOutput (
			intInitialAckId
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intInitialAckId
			,@strFinalXML
			,ISNULL(@strInfo1, '')
			,''
			)
	END

	SELECT IsNULL(intInitialAckId, '0') AS id
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
