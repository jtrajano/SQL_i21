CREATE PROCEDURE uspIPOptionsPnSProcessStgXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intOptionsMatchPnSHeaderStageId INT
		,@intOptionsMatchPnSHeaderId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
		,@strTransactionType NVARCHAR(MAX)
	DECLARE @intLastModifiedUserId INT
		,@intNewOptionsMatchPnSHeaderId INT
		,@intOptionsMatchPnSHeaderRefId INT
	DECLARE @strOptionsMatchPnSXML NVARCHAR(MAX)
		,@intMatchOptionsPnSId INT
	DECLARE @strOptionsPnSExpiredXML NVARCHAR(MAX)
		,@intOptionsPnSExpiredId INT
	DECLARE @intTransactionId INT
		,@intCompanyId INT
		,@intScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblRKOptionsMatchPnSHeaderStage TABLE (intOptionsMatchPnSHeaderStageId INT)

	INSERT INTO @tblRKOptionsMatchPnSHeaderStage (intOptionsMatchPnSHeaderStageId)
	SELECT intOptionsMatchPnSHeaderStageId
	FROM tblRKOptionsMatchPnSHeaderStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	SELECT @intOptionsMatchPnSHeaderStageId = MIN(intOptionsMatchPnSHeaderStageId)
	FROM @tblRKOptionsMatchPnSHeaderStage

	IF @intOptionsMatchPnSHeaderStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKOptionsMatchPnSHeaderStage t
	JOIN @tblRKOptionsMatchPnSHeaderStage pt ON pt.intOptionsMatchPnSHeaderStageId = t.intOptionsMatchPnSHeaderStageId

	WHILE @intOptionsMatchPnSHeaderStageId > 0
	BEGIN
		SELECT @intOptionsMatchPnSHeaderId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strTransactionType = NULL
			,@strUserName = NULL
			,@strOptionsMatchPnSXML = NULL
			,@strOptionsPnSExpiredXML = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intScreenId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intOptionsMatchPnSHeaderId = intOptionsMatchPnSHeaderId
			,@strHeaderXML = strHeaderXML
			,@strOptionsMatchPnSXML = strOptionsMatchPnSXML
			,@strOptionsPnSExpiredXML = strOptionsPnSExpiredXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strTransactionType = strTransactionType
			,@strUserName = strUserName
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblRKOptionsMatchPnSHeaderStage
		WHERE intOptionsMatchPnSHeaderStageId = @intOptionsMatchPnSHeaderStageId

		BEGIN TRY
			SELECT @intOptionsMatchPnSHeaderRefId = @intOptionsMatchPnSHeaderId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblRKOptionsMatchPnSHeader
						WHERE intOptionsMatchPnSHeaderRefId = @intOptionsMatchPnSHeaderRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewOptionsMatchPnSHeaderId = intOptionsMatchPnSHeaderId
				FROM tblRKOptionsMatchPnSHeader
				WHERE intOptionsMatchPnSHeaderRefId = @intOptionsMatchPnSHeaderRefId

				DELETE
				FROM tblRKOptionsMatchPnS
				WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

				DELETE
				FROM tblRKOptionsPnSExpired
				WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

				DELETE
				FROM tblRKOptionsMatchPnSHeader
				WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKOptionsMatchPnSHeader (
					intConcurrencyId
					,intOptionsMatchPnSHeaderRefId
					)
				SELECT 1
					,@intOptionsMatchPnSHeaderRefId
				FROM OPENXML(@idoc, 'tblRKOptionsMatchPnSHeaders/tblRKOptionsMatchPnSHeader', 2) WITH (intOptionsMatchPnSHeaderRefId INT)

				SELECT @intNewOptionsMatchPnSHeaderId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKOptionsMatchPnSHeader
				SET intConcurrencyId = intConcurrencyId + 1
				FROM OPENXML(@idoc, 'tblRKOptionsMatchPnSHeaders/tblRKOptionsMatchPnSHeader', 2) WITH (intOptionsMatchPnSHeaderRefId INT) x
				WHERE tblRKOptionsMatchPnSHeader.intOptionsMatchPnSHeaderRefId = @intOptionsMatchPnSHeaderRefId

				SELECT @intNewOptionsMatchPnSHeaderId = intOptionsMatchPnSHeaderId
				FROM tblRKOptionsMatchPnSHeader
				WHERE intOptionsMatchPnSHeaderRefId = @intOptionsMatchPnSHeaderRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Match PnS--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strOptionsMatchPnSXML

			DECLARE @tblRKOptionsMatchPnS TABLE (intMatchOptionsPnSId INT)

			INSERT INTO @tblRKOptionsMatchPnS (intMatchOptionsPnSId)
			SELECT intMatchOptionsPnSId
			FROM OPENXML(@idoc, 'vyuIPGetOptionsMatchPnSs/vyuIPGetOptionsMatchPnS', 2) WITH (intMatchOptionsPnSId INT)

			SELECT @intMatchOptionsPnSId = MIN(intMatchOptionsPnSId)
			FROM @tblRKOptionsMatchPnS

			DECLARE @strLongInternalTradeNo NVARCHAR(10)
				,@strShortInternalTradeNo NVARCHAR(10)
				,@intLFutOptTransactionId INT
				,@intSFutOptTransactionId INT

			DELETE
			FROM tblRKOptionsMatchPnS
			WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

			WHILE @intMatchOptionsPnSId IS NOT NULL
			BEGIN
				SELECT @strLongInternalTradeNo = NULL
					,@strShortInternalTradeNo = NULL

				SELECT @strLongInternalTradeNo = strLongInternalTradeNo
					,@strShortInternalTradeNo = strShortInternalTradeNo
				FROM OPENXML(@idoc, 'vyuIPGetOptionsMatchPnSs/vyuIPGetOptionsMatchPnS', 2) WITH (
						strLongInternalTradeNo NVARCHAR(10) Collate Latin1_General_CI_AS
						,strShortInternalTradeNo NVARCHAR(10) Collate Latin1_General_CI_AS
						,intMatchOptionsPnSId INT
						) SD
				WHERE intMatchOptionsPnSId = @intMatchOptionsPnSId

				IF @strLongInternalTradeNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFutOptTransaction t
						WHERE t.strInternalTradeNo = @strLongInternalTradeNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Long Trade No. ' + @strLongInternalTradeNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strShortInternalTradeNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFutOptTransaction t
						WHERE t.strInternalTradeNo = @strShortInternalTradeNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Short Trade No. ' + @strShortInternalTradeNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intLFutOptTransactionId = NULL
					,@intSFutOptTransactionId = NULL

				SELECT @intLFutOptTransactionId = t.intFutOptTransactionId
				FROM tblRKFutOptTransaction t
				WHERE t.strInternalTradeNo = @strLongInternalTradeNo

				SELECT @intSFutOptTransactionId = t.intFutOptTransactionId
				FROM tblRKFutOptTransaction t
				WHERE t.strInternalTradeNo = @strShortInternalTradeNo

				INSERT INTO tblRKOptionsMatchPnS (
					intOptionsMatchPnSHeaderId
					,strTranNo
					,dtmMatchDate
					,dblMatchQty
					,intLFutOptTransactionId
					,intSFutOptTransactionId
					,intConcurrencyId
					,ysnPost
					,dtmPostDate
					,intMatchNo
					,intMatchOptionsPnSRefId
					)
				SELECT @intNewOptionsMatchPnSHeaderId
					,strTranNo
					,dtmMatchDate
					,dblMatchQty
					,@intLFutOptTransactionId
					,@intSFutOptTransactionId
					,1
					,ysnPost
					,dtmPostDate
					,intMatchNo
					,@intMatchOptionsPnSId
				FROM OPENXML(@idoc, 'vyuIPGetOptionsMatchPnSs/vyuIPGetOptionsMatchPnS', 2) WITH (
						strTranNo NVARCHAR(50)
						,dtmMatchDate DATETIME
						,dblMatchQty NUMERIC(18, 6)
						,ysnPost BIT
						,dtmPostDate DATETIME
						,intMatchNo INT
						,intMatchOptionsPnSId INT
						) x
				WHERE x.intMatchOptionsPnSId = @intMatchOptionsPnSId

				SELECT @intMatchOptionsPnSId = MIN(intMatchOptionsPnSId)
				FROM @tblRKOptionsMatchPnS
				WHERE intMatchOptionsPnSId > @intMatchOptionsPnSId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Options Pns Expired--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strOptionsPnSExpiredXML

			DECLARE @tblRKOptionsPnSExpired TABLE (intOptionsPnSExpiredId INT)

			INSERT INTO @tblRKOptionsPnSExpired (intOptionsPnSExpiredId)
			SELECT intOptionsPnSExpiredId
			FROM OPENXML(@idoc, 'vyuIPGetOptionsPnSExpireds/vyuIPGetOptionsPnSExpired', 2) WITH (intOptionsPnSExpiredId INT)

			SELECT @intOptionsPnSExpiredId = MIN(intOptionsPnSExpiredId)
			FROM @tblRKOptionsPnSExpired

			DECLARE @strInternalTradeNo NVARCHAR(10)
				,@intFutOptTransactionId INT

			DELETE
			FROM tblRKOptionsPnSExpired
			WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

			WHILE @intOptionsPnSExpiredId IS NOT NULL
			BEGIN
				SELECT @strInternalTradeNo = NULL

				SELECT @strInternalTradeNo = strInternalTradeNo
				FROM OPENXML(@idoc, 'vyuIPGetOptionsPnSExpireds/vyuIPGetOptionsPnSExpired', 2) WITH (
						strInternalTradeNo NVARCHAR(10) Collate Latin1_General_CI_AS
						,intOptionsPnSExpiredId INT
						) SD
				WHERE intOptionsPnSExpiredId = @intOptionsPnSExpiredId

				IF @strInternalTradeNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFutOptTransaction t
						WHERE t.strInternalTradeNo = @strInternalTradeNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Trade No. ' + @strInternalTradeNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intFutOptTransactionId = NULL

				SELECT @intFutOptTransactionId = t.intFutOptTransactionId
				FROM tblRKFutOptTransaction t
				WHERE t.strInternalTradeNo = @strInternalTradeNo

				INSERT INTO tblRKOptionsPnSExpired (
					intOptionsMatchPnSHeaderId
					,strTranNo
					,dtmExpiredDate
					,dblLots
					,intFutOptTransactionId
					,intOptionsPnSExpiredRefId
					,intConcurrencyId
					)
				SELECT @intNewOptionsMatchPnSHeaderId
					,strTranNo
					,dtmExpiredDate
					,dblLots
					,@intFutOptTransactionId
					,@intOptionsPnSExpiredId
					,1
				FROM OPENXML(@idoc, 'vyuIPGetOptionsPnSExpireds/vyuIPGetOptionsPnSExpired', 2) WITH (
						strTranNo NVARCHAR(50)
						,dtmExpiredDate DATETIME
						,dblLots NUMERIC(18, 6)
						,intOptionsPnSExpiredId INT
						) x
				WHERE x.intOptionsPnSExpiredId = @intOptionsPnSExpiredId

				SELECT @intOptionsPnSExpiredId = MIN(intOptionsPnSExpiredId)
				FROM @tblRKOptionsPnSExpired
				WHERE intOptionsPnSExpiredId > @intOptionsPnSExpiredId
			END

			ext:

			EXEC sp_xml_removedocument @idoc

			SELECT @intCompanyRefId = intCompanyId
			FROM tblRKOptionsMatchPnSHeader
			WHERE intOptionsMatchPnSHeaderId = @intNewOptionsMatchPnSHeaderId

			UPDATE tblRKOptionsMatchPnSHeaderStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intOptionsMatchPnSHeaderStageId = @intOptionsMatchPnSHeaderStageId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblRKOptionsMatchPnSHeaderStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intOptionsMatchPnSHeaderStageId = @intOptionsMatchPnSHeaderStageId
		END CATCH

		SELECT @intOptionsMatchPnSHeaderStageId = MIN(intOptionsMatchPnSHeaderStageId)
		FROM @tblRKOptionsMatchPnSHeaderStage
		WHERE intOptionsMatchPnSHeaderStageId > @intOptionsMatchPnSHeaderStageId
			--AND ISNULL(strFeedStatus, '') = ''
			--AND intMultiCompanyId = @intToCompanyId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKOptionsMatchPnSHeaderStage t
	JOIN @tblRKOptionsMatchPnSHeaderStage pt ON pt.intOptionsMatchPnSHeaderStageId = t.intOptionsMatchPnSHeaderStageId
		AND t.strFeedStatus = 'In-Progress'
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
