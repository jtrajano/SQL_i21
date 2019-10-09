CREATE PROCEDURE uspIPProcessPreStageContract
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intToCompanyId INT
		,@intToEntityId INT
		,@strToTransactionType NVARCHAR(100)
		,@intContractPreStageId INT
		,@intContractHeaderId INT
		,@strRowState NVARCHAR(50)
		,@intCompanyLocationId INT
		,@intToBookId INT
	DECLARE @tblCTContractPreStage TABLE (
		intContractPreStageId INT
		,intContractHeaderId INT
		,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmFeedDate DATETIME
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblCTContractPreStage (
		intContractPreStageId
		,intContractHeaderId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		)
	SELECT intContractPreStageId
		,intContractHeaderId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
	FROM tblCTContractPreStage
	WHERE strFeedStatus IS NULL

	SELECT @intContractPreStageId = MIN(intContractPreStageId)
	FROM @tblCTContractPreStage

	WHILE @intContractPreStageId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strRowState = NULL
			,@intToCompanyId = NULL
			,@intToEntityId = NULL
			,@strToTransactionType = NULL
			,@intCompanyLocationId = NULL
			,@intToBookId = NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strRowState = strRowState
		FROM @tblCTContractPreStage
		WHERE intContractPreStageId = @intContractPreStageId

		SELECT @intToCompanyId = TC.intToCompanyId
			,@intToEntityId = TC.intEntityId
			,@strToTransactionType = TT1.strTransactionType
			,@intCompanyLocationId = TC.intCompanyLocationId
			,@intToBookId = TC.intToBookId
		FROM tblSMInterCompanyTransactionConfiguration TC
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblCTContractHeader CH ON CH.intCompanyId = TC.intFromCompanyId
			AND CH.intBookId = TC.intToBookId
		WHERE TT.strTransactionType = 'Sales Contract'
			AND CH.intContractHeaderId = @intContractHeaderId

		EXEC uspCTContractPopulateStgXML @intContractHeaderId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId

		UPDATE tblCTContractPreStage
		SET strFeedStatus = 'Processed'
		WHERE intContractPreStageId = @intContractPreStageId

		SELECT @intContractPreStageId = MIN(intContractPreStageId)
		FROM @tblCTContractPreStage
		WHERE intContractPreStageId > @intContractPreStageId
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
