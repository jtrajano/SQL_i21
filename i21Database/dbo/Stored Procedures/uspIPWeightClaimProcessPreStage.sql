CREATE PROCEDURE uspIPWeightClaimProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intWeightClaimId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intWeightClaimPreStageId INT
		,@intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblLGWeightClaim
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	DECLARE @tblLGWeightClaimPreStage TABLE (intWeightClaimPreStageId INT)

	INSERT INTO @tblLGWeightClaimPreStage (intWeightClaimPreStageId)
	SELECT PS.intWeightClaimPreStageId
	FROM dbo.tblLGWeightClaimPreStage PS
	WHERE PS.strFeedStatus IS NULL
		AND EXISTS (
			SELECT *
			FROM tblLGWeightClaim WC
			WHERE WC.intWeightClaimId = PS.intWeightClaimId
				AND WC.ysnPosted = 1
			)

	SELECT @intWeightClaimPreStageId = MIN(intWeightClaimPreStageId)
	FROM @tblLGWeightClaimPreStage

	IF @intWeightClaimPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblLGWeightClaimPreStage
	SET strFeedStatus = 'In-Progress'
	WHERE intWeightClaimPreStageId IN (
			SELECT PS.intWeightClaimPreStageId
			FROM @tblLGWeightClaimPreStage PS
			)

	WHILE @intWeightClaimPreStageId IS NOT NULL
	BEGIN
		SELECT @intWeightClaimId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intWeightClaimId = intWeightClaimId
		FROM tblLGWeightClaimPreStage
		WHERE intWeightClaimPreStageId = @intWeightClaimPreStageId

		EXEC uspIPWeightClaimPopulateStgXML @intWeightClaimId
			,'Added'

		UPDATE tblLGWeightClaimPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intWeightClaimPreStageId = @intWeightClaimPreStageId

		SELECT @intWeightClaimPreStageId = MIN(intWeightClaimPreStageId)
		FROM @tblLGWeightClaimPreStage
		WHERE intWeightClaimPreStageId > @intWeightClaimPreStageId
	END

	UPDATE tblLGWeightClaimPreStage
	SET strFeedStatus = NULL
	WHERE intWeightClaimPreStageId IN (
			SELECT PS.intWeightClaimPreStageId
			FROM @tblLGWeightClaimPreStage PS
			)
		AND IsNULL(strFeedStatus, '') = 'In-Progress'
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
