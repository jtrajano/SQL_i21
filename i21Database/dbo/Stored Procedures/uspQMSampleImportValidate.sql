CREATE PROCEDURE uspQMSampleImportValidate
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleImportId INT
		,@dtmSampleReceivedDate DATETIME
		,@strSampleNumber NVARCHAR(30)
		,@strItemShortName NVARCHAR(50)
		,@strSampleTypeName NVARCHAR(50)
		,@strVendorName NVARCHAR(100)
		,@strContractNumber NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strMarks NVARCHAR(100)
		,@dblSequenceQuantity NUMERIC(18, 6)
		,@strSampleStatus NVARCHAR(30)
		,@strPropertyName NVARCHAR(100)
		,@strPropertyValue NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@strResult NVARCHAR(20)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @strPreviousErrMsg NVARCHAR(MAX) = ''
		,@strSampleRefNo NVARCHAR(30)

	DELETE
	FROM tblQMSampleImportError

	SELECT @intSampleImportId = MIN(intSampleImportId)
	FROM tblQMSampleImport

	WHILE (ISNULL(@intSampleImportId, 0) > 0)
	BEGIN
		SELECT @dtmSampleReceivedDate = NULL
			,@strSampleNumber = NULL
			,@strItemShortName = NULL
			,@strSampleTypeName = NULL
			,@strVendorName = NULL
			,@strContractNumber = NULL
			,@strContainerNumber = NULL
			,@strMarks = NULL
			,@dblSequenceQuantity = NULL
			,@strSampleStatus = NULL
			,@strPropertyName = NULL
			,@strPropertyValue = NULL
			,@strComment = NULL
			,@strResult = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@strSampleRefNo = NULL

		SELECT @dtmSampleReceivedDate = CONVERT(DATETIME, dtmSampleReceivedDate, 101)
			,@strSampleNumber = strSampleNumber
			,@strSampleRefNo = strSampleNumber
			,@strItemShortName = strItemShortName
			,@strSampleTypeName = strSampleTypeName
			,@strVendorName = strVendorName
			,@strContractNumber = strContractNumber
			,@strContainerNumber = strContainerNumber
			,@strMarks = strMarks
			,@dblSequenceQuantity = dblSequenceQuantity
			,@strSampleStatus = strSampleStatus
			,@strPropertyName = strPropertyName
			,@strPropertyValue = strPropertyValue
			,@strComment = strComment
			,@strResult = strResult
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM tblQMSampleImport
		WHERE intSampleImportId = @intSampleImportId

		SELECT @strPreviousErrMsg = ''

		IF ISNULL(@strSampleRefNo, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Sample No. '
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblQMSample
					WHERE strSampleRefNo = @strSampleRefNo
					)
			BEGIN
				SELECT @strPreviousErrMsg += 'Sample No already exists. '
			END
		END

		-- After all validation, insert / update the error
		IF ISNULL(@strPreviousErrMsg, '') <> ''
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblQMSampleImportError
					WHERE intSampleImportId = @intSampleImportId
					)
			BEGIN
				INSERT INTO tblQMSampleImportError (
					intSampleImportId
					,intConcurrencyId
					,dtmSampleReceivedDate
					,strSampleNumber
					,strItemShortName
					,strSampleTypeName
					,strVendorName
					,strContractNumber
					,strContainerNumber
					,strMarks
					,dblSequenceQuantity
					,strSampleStatus
					,strPropertyName
					,strPropertyValue
					,strComment
					,strResult
					,strErrorMsg
					,intCreatedUserId
					,dtmCreated
					)
				SELECT intSampleImportId
					,intConcurrencyId
					,CONVERT(DATETIME, dtmSampleReceivedDate, 101)
					,strSampleNumber
					,strItemShortName
					,strSampleTypeName
					,strVendorName
					,strContractNumber
					,strContainerNumber
					,strMarks
					,dblSequenceQuantity
					,strSampleStatus
					,strPropertyName
					,strPropertyValue
					,strComment
					,strResult
					,@strPreviousErrMsg
					,intCreatedUserId
					,dtmCreated
				FROM tblQMSampleImport
				WHERE intSampleImportId = @intSampleImportId
			END
			ELSE
			BEGIN
				UPDATE tblQMSampleImportError
				SET strErrorMsg = strErrorMsg + @strPreviousErrMsg
				WHERE intSampleImportId = @intSampleImportId
			END
		END

		SELECT @intSampleImportId = MIN(intSampleImportId)
		FROM tblQMSampleImport
		WHERE intSampleImportId > @intSampleImportId
	END

	SELECT intSampleImportErrorId
		,intSampleImportId
		,intConcurrencyId
		,CONVERT(DATETIME, dtmSampleReceivedDate, 101) dtmSampleReceivedDate
		,strSampleNumber
		,strItemShortName
		,strSampleTypeName
		,strVendorName
		,strContractNumber
		,strContainerNumber
		,strMarks
		,dblSequenceQuantity
		,strSampleStatus
		,strPropertyName
		,strPropertyValue
		,strComment
		,strResult
		,strErrorMsg
		,intCreatedUserId
		,dtmCreated
	FROM tblQMSampleImportError
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
