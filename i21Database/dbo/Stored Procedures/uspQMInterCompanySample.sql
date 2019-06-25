CREATE PROCEDURE [dbo].[uspQMInterCompanySample] @intSampleId INT
	,@strRowState NVARCHAR(50) = NULL
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
		,@strDelete nvarchar(50)

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
		FROM tblSMInterCompanyTransactionConfiguration TC
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblQMSample S ON S.intCompanyId = TC.intFromCompanyId
			AND S.intBookId = TC.intToBookId
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
			END
		END

		IF @strInsert = 'Update'
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
			END
		END

		IF @strRowState = 'Delete'
		BEGIN
			IF @strInsert = 'Delete'
			BEGIN
				EXEC uspQMSamplePopulateStgXML @intSampleId
					,@intToEntityId
					,@intCompanyLocationId
					,@strToTransactionType
					,@intToCompanyId
					,'Delete'
					,0
					,@intToBookId
			END
		END
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
