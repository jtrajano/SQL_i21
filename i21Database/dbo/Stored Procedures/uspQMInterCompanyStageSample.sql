CREATE PROCEDURE [dbo].[uspQMInterCompanyStageSample] @intParent INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strInsert NVARCHAR(100)
	DECLARE @strUpdate NVARCHAR(100)
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@strDelete NVARCHAR(50)
		,@intSampleId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intSamplePreStageId INT
		,@strFromCompanyName NVARCHAR(150)
	DECLARE @tblQMSamplePreStage TABLE (intSamplePreStageId INT)

	INSERT INTO @tblQMSamplePreStage (intSamplePreStageId)
	SELECT intSamplePreStageId
	FROM tblQMSamplePreStage
	WHERE strFeedStatus = ''

	SELECT @intSamplePreStageId = MIN(intSamplePreStageId)
	FROM @tblQMSamplePreStage

	WHILE @intSamplePreStageId IS NOT NULL
	BEGIN
		SELECT @intSampleId = NULL
			,@strRowState = NULL

		SELECT @intSampleId = intSampleId
			,@strRowState = strRowState
		FROM tblQMSamplePreStage
		WHERE intSamplePreStageId = @intSamplePreStageId

		IF ISNULL(@intParent, 0) = 0
		BEGIN
			UPDATE tblQMSample
			SET ysnParent = 0
			WHERE intSampleId = @intSampleId
				AND ysnParent = 1
		END
		ELSE
		BEGIN
			UPDATE tblQMSample
			SET ysnParent = 1
			WHERE intSampleId = @intSampleId
				AND ysnParent = 0
		END

		IF EXISTS (
				SELECT 1
				FROM tblSMInterCompanyTransactionConfiguration TC
				JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
				JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
				WHERE TT.strTransactionType = 'Quality Sample'
					AND TT1.strTransactionType = 'Quality Sample'
				)
		BEGIN
			SELECT @intToCompanyId = TC.intToCompanyId
				,@intToEntityId = TC.intEntityId
				,@strInsert = TC.strInsert
				,@strUpdate = TC.strUpdate
				,@strDelete = TC.strDelete
				,@strToTransactionType = TT1.strTransactionType
				,@intCompanyLocationId = TC.intCompanyLocationId
				,@intToBookId = TC.intToBookId
				,@strFromCompanyName = MC.strCompanyName
			FROM tblSMInterCompanyTransactionConfiguration TC
			JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
			JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
			JOIN tblQMSample S ON S.intCompanyId = TC.intFromCompanyId
				AND S.intBookId = CASE 
					WHEN S.ysnParent = 0
						THEN TC.intFromBookId
					ELSE TC.intToBookId
					END
			JOIN tblSMMultiCompany MC ON MC.intMultiCompanyId = CASE 
					WHEN S.ysnParent = 0
						THEN TC.intFromCompanyId
					ELSE TC.intToCompanyId
					END
			WHERE TT.strTransactionType = 'Quality Sample'
				AND S.intSampleId = @intSampleId

			IF @strInsert = 'Insert'
			BEGIN
				DELETE
				FROM tblQMSampleStage
				WHERE IsNULL(strFeedStatus, '') = ''
					AND intSampleId = @intSampleId

				IF EXISTS (
						SELECT 1
						FROM tblQMSample
						WHERE intSampleId = @intSampleId
							AND intConcurrencyId = 1
						)
				BEGIN
					EXEC uspQMSamplePopulateStgXML @intSampleId
						,@intToEntityId
						,@intCompanyLocationId
						,@strToTransactionType
						,@intToCompanyId
						,'Added'
						,0
						,@intToBookId
						,@strFromCompanyName
				END
			END

			IF @strUpdate = 'Update'
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblQMSample
						WHERE intSampleId = @intSampleId
							AND intConcurrencyId > 1
						)
				BEGIN
					EXEC uspQMSamplePopulateStgXML @intSampleId
						,@intToEntityId
						,@intCompanyLocationId
						,@strToTransactionType
						,@intToCompanyId
						,'Modified'
						,0
						,@intToBookId
						,@strFromCompanyName
				END
			END

			IF @strRowState = 'Delete'
			BEGIN
				IF @strDelete = 'Delete'
				BEGIN
					EXEC uspQMSamplePopulateStgXML @intSampleId
						,@intToEntityId
						,@intCompanyLocationId
						,@strToTransactionType
						,@intToCompanyId
						,'Delete'
						,0
						,@intToBookId
						,@strFromCompanyName
				END
			END
		END

		UPDATE tblQMSamplePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intSamplePreStageId = @intSamplePreStageId
			AND strFeedStatus = ''

		SELECT @intSamplePreStageId = MIN(intSamplePreStageId)
		FROM @tblQMSamplePreStage
		WHERE intSamplePreStageId > @intSamplePreStageId
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
