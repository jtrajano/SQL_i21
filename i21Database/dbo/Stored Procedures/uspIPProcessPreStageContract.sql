CREATE PROCEDURE uspIPProcessPreStageContract (@ysnPopulateERPInfo BIT = 0)
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
		,@ysnApproval BIT
		,@intContractScreenId INT
	DECLARE @tblCTContractPreStage TABLE (
		intContractPreStageId INT
		,intContractHeaderId INT
		,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmFeedDate DATETIME
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,ysnApproval BIT
		)

	INSERT INTO @tblCTContractPreStage (
		intContractPreStageId
		,intContractHeaderId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		,ysnApproval
		)
	SELECT intContractPreStageId
		,intContractHeaderId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		,ysnApproval
	FROM tblCTContractPreStage
	WHERE strFeedStatus IS NULL

	SELECT @intContractPreStageId = MIN(intContractPreStageId)
	FROM @tblCTContractPreStage

	IF @intContractPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblCTContractPreStage
	SET strFeedStatus = 'In-Progress'
	WHERE intContractPreStageId IN (
			SELECT PS.intContractPreStageId
			FROM @tblCTContractPreStage PS
			)

	SELECT @intContractScreenId = NULL

	SELECT @intContractScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'ContractManagement.view.Contract'

	WHILE @intContractPreStageId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strRowState = NULL
			,@intToCompanyId = NULL
			,@intToEntityId = NULL
			,@strToTransactionType = NULL
			,@intCompanyLocationId = NULL
			,@intToBookId = NULL
			,@ysnApproval = NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strRowState = strRowState
			,@ysnApproval = ysnApproval
		FROM @tblCTContractPreStage
		WHERE intContractPreStageId = @intContractPreStageId

		IF @ysnApproval = 0
		BEGIN
			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM dbo.tblSMTransaction
					WHERE strApprovalStatus IN (
							'Approved'
							,'Approved with Modifications'
							,'No Need for Approval'
							)
						AND intRecordId = @intContractHeaderId
						AND intScreenId = @intContractScreenId
					)
			BEGIN
				UPDATE dbo.tblCTContractPreStage
				SET strFeedStatus = 'IGNORE'
				WHERE intContractPreStageId = @intContractPreStageId

				GOTO NextContract
			END
		END

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
			,@ysnApproval
			,@ysnPopulateERPInfo

		UPDATE tblCTContractPreStage
		SET strFeedStatus = 'Processed'
		WHERE intContractPreStageId = @intContractPreStageId

		NextContract:

		SELECT @intContractPreStageId = MIN(intContractPreStageId)
		FROM @tblCTContractPreStage
		WHERE intContractPreStageId > @intContractPreStageId
	END

	UPDATE tblCTContractPreStage
	SET strFeedStatus = NULL
	WHERE intContractPreStageId IN (
			SELECT PS.intContractPreStageId
			FROM @tblCTContractPreStage PS
			)
		AND strFeedStatus = 'In-Progress'
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
