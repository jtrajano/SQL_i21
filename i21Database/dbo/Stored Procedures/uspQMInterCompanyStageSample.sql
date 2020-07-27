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
		,@intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblQMSample
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	UPDATE ST1
	SET ST1.strFeedStatus = 'HOLD'
	FROM tblQMSamplePreStage ST
	JOIN tblQMSamplePreStage ST1 ON ST1.intSampleId = ST.intSampleId
		AND ISNULL(ST1.strFeedStatus, '') = ''
	WHERE ISNULL(ST.strFeedStatus, '') = 'Awt Ack'
		--AND UPPER(ST.strRowState) = 'ADDED'

	UPDATE ST1
	SET ST1.strFeedStatus = NULL
	FROM tblQMSamplePreStage ST
	JOIN tblQMSamplePreStage ST1 ON ST1.intSampleId = ST.intSampleId
		AND ISNULL(ST1.strFeedStatus, '') = 'HOLD'
	WHERE ISNULL(ST.strFeedStatus, '') = 'Ack Rcvd'
		--AND UPPER(ST.strRowState) = 'ADDED'

	DECLARE @tblQMSamplePreStage TABLE (intSamplePreStageId INT)

	INSERT INTO @tblQMSamplePreStage (intSamplePreStageId)
	SELECT intSamplePreStageId
	FROM tblQMSamplePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intSamplePreStageId = MIN(intSamplePreStageId)
	FROM @tblQMSamplePreStage

	IF @intSamplePreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMSamplePreStage t
	JOIN @tblQMSamplePreStage pt ON pt.intSamplePreStageId = t.intSamplePreStageId

	WHILE @intSamplePreStageId IS NOT NULL
	BEGIN
		SELECT @intSampleId = NULL
			,@strRowState = NULL

		SELECT @intSampleId = intSampleId
			,@strRowState = strRowState
		FROM tblQMSamplePreStage WITH (NOLOCK)
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
				FROM tblSMInterCompanyTransactionConfiguration TC WITH (NOLOCK)
				JOIN tblSMInterCompanyTransactionType TT WITH (NOLOCK) ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
				JOIN tblSMInterCompanyTransactionType TT1 WITH (NOLOCK) ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
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
				,@intToBookId = CASE 
					WHEN S.ysnParent = 0
						THEN TC.intFromBookId
					ELSE TC.intToBookId
					END
				,@strFromCompanyName = MC.strCompanyName
			FROM tblSMInterCompanyTransactionConfiguration TC WITH (NOLOCK)
			JOIN tblSMInterCompanyTransactionType TT WITH (NOLOCK) ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
			JOIN tblSMInterCompanyTransactionType TT1 WITH (NOLOCK) ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
			JOIN tblQMSample S WITH (NOLOCK) ON S.intCompanyId = TC.intFromCompanyId
				AND S.intBookId = CASE 
					WHEN S.ysnParent = 0
						THEN TC.intFromBookId
					ELSE TC.intToBookId
					END
			JOIN tblSMMultiCompany MC WITH (NOLOCK) ON MC.intMultiCompanyId = CASE 
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
						FROM tblQMSample WITH (NOLOCK)
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
						FROM tblQMSample WITH (NOLOCK)
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
		SET strFeedStatus = 'Awt Ack'
			,strMessage = 'Success'
		WHERE intSamplePreStageId = @intSamplePreStageId

		SELECT @intSamplePreStageId = MIN(intSamplePreStageId)
		FROM @tblQMSamplePreStage
		WHERE intSamplePreStageId > @intSamplePreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMSamplePreStage t
	JOIN @tblQMSamplePreStage pt ON pt.intSamplePreStageId = t.intSamplePreStageId
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
