CREATE PROCEDURE uspIPProcesBulkSAPAcknowledgement (
	@strProcessDeadLockEntry CHAR(1) = 'N'
	,@strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
	)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@strMessageType NVARCHAR(50)
	--,@strInfo1 NVARCHAR(50)
	--,@strInfo2 NVARCHAR(50)
	DECLARE @tblMessage AS TABLE (
		id INT identity(1, 1)
		,strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		)

	IF @strProcessDeadLockEntry = 'Y'
	BEGIN
		INSERT INTO tblIPAcknowledgementStage (
			strXml
			,intDeadLock
			,strType
			,stri21ReferenceNo
			,strERPReferenceNo
			)
		SELECT strXml
			,intDeadLock
			,strType
			,stri21ReferenceNo
			,strERPReferenceNo
		FROM tblIPAcknowledgementError WITH (NOLOCK)
		WHERE intDeadLock BETWEEN 1
				AND 5

		DELETE
		FROM tblIPAcknowledgementError
		WHERE intDeadLock BETWEEN 1
				AND 5
	END

	SELECT @intRowNo = MIN(intAcknowledgementStageId)
	FROM tblIPAcknowledgementStage WITH (NOLOCK)

	WHILE @intRowNo IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strXml = NULL

			SELECT @strMessageType = NULL

			SELECT @strMessage = NULL

			SELECT @strInfo1 = NULL

			SELECT @strInfo2 = NULL

			SELECT @strXml = strXml
			FROM tblIPAcknowledgementStage WITH (NOLOCK)
			WHERE intAcknowledgementStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC [dbo].[uspIPProcessFinalSAPAcknowledgement] @strXml = @strXml
				,@strMessageType = @strMessageType OUTPUT
				,@strMessage = @strMessage OUTPUT
				,@strInfo1 = @strInfo1 OUTPUT
				,@strInfo2 = @strInfo2 OUTPUT

			INSERT INTO @tblMessage (
				strMessageType
				,strMessage
				,strInfo1
				,strInfo2
				,strXml
				)
			VALUES (
				@strMessageType
				,@strMessage
				,@strInfo1
				,@strInfo2
				,@strXml
				)

			--Move to Archive
			INSERT INTO tblIPAcknowledgementArchive (
				strXml
				,strType
				,dtmCreatedDate
				,stri21ReferenceNo
				,strERPReferenceNo
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
				,stri21ReferenceNo
				,strERPReferenceNo
			FROM tblIPAcknowledgementStage WITH (NOLOCK)
			WHERE intAcknowledgementStageId = @intRowNo

			DELETE
			FROM tblIPAcknowledgementStage
			WHERE intAcknowledgementStageId = @intRowNo
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			--Move to Error
			INSERT INTO tblIPAcknowledgementError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				,intDeadLock
				,stri21ReferenceNo
				,strERPReferenceNo
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
				,(
					CASE 
						WHEN ERROR_NUMBER() = 1205
							THEN IsNull(intDeadLock,0) + 1
						ELSE 0
						END
					)
				,stri21ReferenceNo
				,strERPReferenceNo
			FROM tblIPAcknowledgementStage WITH (NOLOCK)
			WHERE intAcknowledgementStageId = @intRowNo

			DELETE
			FROM tblIPAcknowledgementStage
			WHERE intAcknowledgementStageId = @intRowNo

			INSERT INTO @tblMessage (
				strMessageType
				,strMessage
				,strInfo1
				,strInfo2
				,strXml
				)
			VALUES (
				@strMessageType
				,@strMessage
				,@strInfo1
				,@strInfo2
				,@strXml
				)
		END CATCH

		SELECT @intRowNo = MIN(intAcknowledgementStageId)
		FROM tblIPAcknowledgementStage WITH (NOLOCK)
		WHERE intAcknowledgementStageId > @intRowNo
	END

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + IsNULL(strInfo1, '') + ','
		,@strInfo2 = @strInfo2 + ISNULL(strInfo2, '') + ','
	FROM @tblMessage

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF (ISNULL(@strInfo2, '')) <> ''
		SELECT @strInfo2 = LEFT(@strInfo2, LEN(@strInfo2) - 1)

	IF Len(@strInfo1) > 0
		OR Len(@strInfo2) > 0
	BEGIN
		SELECT @intNoOfRowsAffected = 1
	END
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
