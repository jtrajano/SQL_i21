--EXEC uspQMUpdateContainerLinkInSample 4408,'016/2727/0003',4446,2310,2611,2986,182
CREATE PROCEDURE uspQMUpdateContainerLinkInSample
     @intContractDetailId INT
	,@strContainerNumber NVARCHAR(100)
	,@intLoadContainerId INT
	,@intLoadDetailContainerLinkId INT
	,@intLoadId INT
	,@intLoadDetailId INT
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
	DECLARE @OldSampleDetail TABLE (intSampleId INT)

	INSERT INTO @OldSampleDetail
	SELECT intSampleId
	FROM tblQMSample
	WHERE strContainerNumber = @strContainerNumber
		AND intContractDetailId = @intContractDetailId
		AND intLoadDetailContainerLinkId IS NULL

	SELECT @strSampleId = COALESCE(@strSampleId + ',', '') + CONVERT(NVARCHAR, intSampleId)
	FROM @OldSampleDetail

	UPDATE tblQMSample
	SET intConcurrencyId = (intConcurrencyId + 1)
		,intProductTypeId = 9 -- Container
		,intProductValueId = @intLoadDetailContainerLinkId
		,intLoadContainerId = @intLoadContainerId
		,intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId
		,intLoadId = @intLoadId
		,intLoadDetailId = @intLoadDetailId
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE strContainerNumber = @strContainerNumber
		AND intContractDetailId = @intContractDetailId
		AND intLoadDetailContainerLinkId IS NULL

	UPDATE tblQMTestResult
	SET intConcurrencyId = (intConcurrencyId + 1)
		,intProductTypeId = 9 -- Container
		,intProductValueId = @intLoadDetailContainerLinkId
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intSampleId IN (
			SELECT Item
			FROM fnSplitStringWithTrim(@strSampleId, ',')
			)

	IF (LEN(@strSampleId) > 0)
	BEGIN
		DECLARE @strDetails NVARCHAR(MAX)

		SET @strDetails = '{"change":"intLoadDetailId","iconCls":"small-gear","from":"","to":"' + LTRIM(@intLoadDetailId) + '","leaf":true}'
		SET @strDetails += ',{"change":"intLoadDetailContainerLinkId","iconCls":"small-gear","from":"","to":"' + LTRIM(@intLoadDetailContainerLinkId) + '","leaf":true}'

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
