CREATE PROCEDURE uspIPGenerateInitialAck_ERP @strCompany NVARCHAR(50) = ''
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
		,@intTrxSequenceNo INT
		,@strCompanyLocation NVARCHAR(6)
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@intMessageTypeId INT
		,@intStatusId INT
		,@strStatusText NVARCHAR(MAX)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intInitialAckId INT
		,intTrxSequenceNo INT
		,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
		,dtmCreatedDate DATETIME
		,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intMessageTypeId INT
		,intStatusId INT
		,strStatusText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		)

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
		)
	SELECT intInitialAckId
		,intTrxSequenceNo
		,strCompanyLocation
		,dtmCreatedDate
		,strCreatedBy
		,intMessageTypeId
		,intStatusId
		,strStatusText
	FROM tblIPInitialAck
	WHERE strFeedStatus IS NULL
		AND strCompanyLocation = @strCompany

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

		SELECT @intInitialAckId = intInitialAckId
			,@intTrxSequenceNo = intTrxSequenceNo
			,@strCompanyLocation = strCompanyLocation
			,@dtmCreatedDate = dtmCreatedDate
			,@strCreatedBy = strCreatedBy
			,@intMessageTypeId = intMessageTypeId
			,@intStatusId = intStatusId
			,@strStatusText = strStatusText
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		BEGIN
			SELECT @strXML += '<header>'

			SELECT @strXML += '<TrxSequenceNo>' + ISNULL(CONVERT(VARCHAR, @intTrxSequenceNo), '') + '</TrxSequenceNo>'

			SELECT @strXML += '<CompanyLocation>' + @strCompanyLocation + '</CompanyLocation>'

			SELECT @strXML += '<i21CreatedDate>' + CONVERT(VARCHAR(30), GETDATE(), 126) + '</i21CreatedDate>'

			SELECT @strXML += '<i21CreatedBy>' + @strCreatedBy + '</i21CreatedBy>'

			SELECT @strXML += '<MessageTypeId>' + ISNULL(CONVERT(VARCHAR, @intMessageTypeId), '') + '</MessageTypeId>'

			SELECT @strXML += '<StatusId>' + ISNULL(CONVERT(VARCHAR, @intStatusId), '') + '</StatusId>'

			SELECT @strXML += '<StatusText>' + @strStatusText + '</StatusText>'

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
	END

	SELECT @strFinalXML AS strMessage
		,@strInfo1 AS strInfo1
		,''
		,'' AS strOnFailureCallbackSql
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
