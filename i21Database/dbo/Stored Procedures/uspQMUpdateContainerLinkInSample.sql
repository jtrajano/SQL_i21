--EXEC uspQMUpdateContainerLinkInSample 4408,'016/2727/0003',4446,2310,2611,2986,182
CREATE PROCEDURE [dbo].[uspQMUpdateContainerLinkInSample] 
(
	@intContractDetailId			INT
  , @strContainerNumber				NVARCHAR(100)
  , @intLoadContainerId				INT
  , @intLoadDetailContainerLinkId	INT
  , @intLoadId						INT
  , @intLoadDetailId				INT
  , @intUserId						INT
)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @strSampleId NVARCHAR(MAX)

	DECLARE @OldSampleDetail TABLE 
	(
		intSampleId INT
	)

	DECLARE @strDetails		NVARCHAR(MAX)
		  , @strSampleList  NVARCHAR(MAX)
		  , @strSample		NVARCHAR(MAX)
		  , @intSampleId	INT

	INSERT INTO @OldSampleDetail
	SELECT intSampleId
	FROM tblQMSample
	WHERE strContainerNumber = @strContainerNumber
		AND intTypeId = 1
		AND intContractDetailId = @intContractDetailId
		AND (intLoadDetailContainerLinkId IS NULL OR intLoadDetailContainerLinkId <> @intLoadDetailContainerLinkId);

	IF (SELECT COUNT(intSampleId) FROM @OldSampleDetail) > 0
		BEGIN
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
				AND (
					intLoadDetailContainerLinkId IS NULL
					OR intLoadDetailContainerLinkId <> @intLoadDetailContainerLinkId
					)

			UPDATE tblQMTestResult
			SET intConcurrencyId = (intConcurrencyId + 1)
				,intProductTypeId = 9 -- Container
				,intProductValueId = @intLoadDetailContainerLinkId
				,intLastModifiedUserId = @intUserId
				,dtmLastModified = GETDATE()
			WHERE intSampleId IN (SELECT intSampleId
								  FROM @OldSampleDetail)
			  AND intProductValueId <> @intLoadDetailContainerLinkId		

			IF (LEN(@strSampleId) > 0)
				BEGIN
					SET @strDetails = '{"change":"intLoadDetailId","iconCls":"small-gear","from":"","to":"' + LTRIM(@intLoadDetailId) + '","leaf":true}'

					SET @strDetails += ',{"change":"intLoadDetailContainerLinkId","iconCls":"small-gear","from":"","to":"' + LTRIM(@intLoadDetailContainerLinkId) + '","leaf":true}'

					SELECT	@intSampleId = MIN(intSampleId) 
					FROM	@OldSampleDetail;

					WHILE @intSampleId IS NOT NULL
						BEGIN
							
							EXEC uspSMAuditLog @keyValue = @intSampleId
								, @screenName = 'Quality.view.QualitySample'
								, @entityId = @intUserId
								, @actionType = 'Updated'
								, @actionIcon = 'small-tree-modified'
								, @changeDescription = 'Container Link'
								, @details = @strDetails
							
							SELECT	@intSampleId = MIN(intSampleId) 
							FROM	@OldSampleDetail
							WHERE intSampleId > @intSampleId;
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