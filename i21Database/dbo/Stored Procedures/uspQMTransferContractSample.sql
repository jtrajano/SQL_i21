--EXEC uspQMTransferContractSample 2,1,1
CREATE PROCEDURE uspQMTransferContractSample
     @intOldContractDetailId INT
	,@intNewContractDetailId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @strSampleId NVARCHAR(MAX)
		,@intOldContractSeq INT
		,@intNewContractSeq INT
		,@strOldContractNumber NVARCHAR(50)
		,@strNewContractNumber NVARCHAR(50)
	DECLARE @OldSampleDetail TABLE (intSampleId INT)

	INSERT INTO @OldSampleDetail
	SELECT intSampleId
	FROM dbo.tblQMSample
	WHERE intContractDetailId = @intOldContractDetailId

	SELECT @intOldContractSeq = intContractSeq
		,@strOldContractNumber = strContractNumber
	FROM dbo.vyuCTContractDetailView
	WHERE intContractDetailId = @intOldContractDetailId

	SELECT @intNewContractSeq = intContractSeq
		,@strNewContractNumber = strContractNumber
	FROM dbo.vyuCTContractDetailView
	WHERE intContractDetailId = @intNewContractDetailId

	-- Contract Available Places
	UPDATE dbo.tblQMSample
	SET intContractDetailId = @intNewContractDetailId
		,intConcurrencyId = (intConcurrencyId + 1)
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intContractDetailId = @intOldContractDetailId

	-- Contract Samples
	UPDATE dbo.tblQMSample
	SET intProductValueId = @intNewContractDetailId
	WHERE intProductTypeId = 8
		AND intProductValueId = @intOldContractDetailId

	UPDATE dbo.tblQMTestResult
	SET intProductValueId = @intNewContractDetailId
		,intConcurrencyId = (intConcurrencyId + 1)
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intProductTypeId = 8
		AND intProductValueId = @intOldContractDetailId

	SELECT @strSampleId = COALESCE(@strSampleId + ',', '') + CONVERT(NVARCHAR, intSampleId)
	FROM @OldSampleDetail

	IF (LEN(@strSampleId) > 0)
	BEGIN
		DECLARE @strDetails NVARCHAR(MAX)

		SET @strDetails = '{"change":"strContractNumber","iconCls":"small-gear","from":"' + @strOldContractNumber + '","to":"' + @strNewContractNumber + '","leaf":true}'
		SET @strDetails += ',{"change":"intContractSeq","iconCls":"small-gear","from":"' + LTRIM(@intOldContractSeq) + '","to":"' + LTRIM(@intNewContractSeq) + '","leaf":true}'
		SET @strDetails += ',{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intOldContractDetailId) + '","to":"' + LTRIM(@intNewContractDetailId) + '","leaf":true}'

		EXEC uspSMAuditLog @keyValue = @strSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intUserId
			,@actionType = 'Updated'
			,@actionIcon = 'small-tree-modified'
			,@details = @strDetails
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
