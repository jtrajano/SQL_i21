CREATE PROCEDURE uspARProcessPreStageInvoice
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intToCompanyId INT
		,@intToEntityId INT
		,@strToTransactionType NVARCHAR(100)
		,@intInvoicePreStageId INT
		,@intInvoiceId INT
		,@strRowState NVARCHAR(50)
		,@intCompanyLocationId INT
		,@intToBookId INT
		,@ysnApproval BIT
		,@intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblARInvoice
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	UPDATE tblARInvoicePreStage
	SET strFeedStatus = 'IGNORE'
	WHERE strFeedStatus IS NULL
		AND strRowState <> 'Posted'

	UPDATE tblARInvoicePreStage
	SET strFeedStatus = 'IGNORE'
	WHERE strFeedStatus IS NULL
		AND strRowState = 'Posted'
		AND intInvoiceId IN (
			SELECT PS.intInvoiceId
			FROM tblARInvoicePreStage PS
			WHERE strFeedStatus IS NOT NULL
				AND strRowState = 'Posted'
			)

	UPDATE tblARInvoicePreStage
	SET strFeedStatus = 'IGNORE'
	WHERE strFeedStatus IS NULL
		AND intInvoiceId IN (
			SELECT intInvoiceId
			FROM tblARInvoice
			WHERE ysnPosted = 1
				AND (
					strTransactionType NOT IN (
						'Invoice'
						,'Credit Memo'
						)
					OR intOriginalInvoiceId IS NOT NULL
					)
			)

	DECLARE @tblARInvoicePreStage TABLE (
		intInvoicePreStageId INT
		,intInvoiceId INT
		,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmFeedDate DATETIME
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblARInvoicePreStage (
		intInvoicePreStageId
		,intInvoiceId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		)
	SELECT intInvoicePreStageId
		,intInvoiceId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
	FROM tblARInvoicePreStage
	WHERE strFeedStatus IS NULL

	SELECT @intInvoicePreStageId = MIN(intInvoicePreStageId)
	FROM @tblARInvoicePreStage

	IF @intInvoicePreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET strFeedStatus = 'In-Progress'
	FROM tblARInvoicePreStage S
	JOIN @tblARInvoicePreStage TS ON TS.intInvoicePreStageId = S.intInvoicePreStageId

	WHILE @intInvoicePreStageId IS NOT NULL
	BEGIN
		SELECT @intInvoiceId = NULL
			,@strRowState = NULL
			,@intToCompanyId = NULL
			,@intToEntityId = NULL
			,@strToTransactionType = NULL
			,@intCompanyLocationId = NULL
			,@intToBookId = NULL

		SELECT @intInvoiceId = intInvoiceId
			,@strRowState = strRowState
		FROM @tblARInvoicePreStage
		WHERE intInvoicePreStageId = @intInvoicePreStageId

		SELECT @intToCompanyId = TC.intToCompanyId
			,@intToEntityId = TC.intEntityId
			,@strToTransactionType = TT1.strTransactionType
			,@intCompanyLocationId = TC.intCompanyLocationId
			,@intToBookId = TC.intToBookId
		FROM tblSMInterCompanyTransactionConfiguration TC
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblARInvoice IV ON IV.intCompanyId = TC.intFromCompanyId
			AND IV.intBookId = TC.intToBookId
		WHERE TT.strTransactionType = 'Sales Invoice'
			AND IV.intInvoiceId = @intInvoiceId

		EXEC dbo.uspARInvoicePopulateStgXML @intInvoiceId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,@intToBookId

		UPDATE tblARInvoicePreStage
		SET strFeedStatus = 'Processed'
		WHERE intInvoicePreStageId = @intInvoicePreStageId

		SELECT @intInvoicePreStageId = MIN(intInvoicePreStageId)
		FROM @tblARInvoicePreStage
		WHERE intInvoicePreStageId > @intInvoicePreStageId
	END

	UPDATE S
	SET strFeedStatus = NULL
	FROM tblARInvoicePreStage S
	JOIN @tblARInvoicePreStage TS ON TS.intInvoicePreStageId = S.intInvoicePreStageId
	WHERE S.strFeedStatus = 'In-Progress'
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
