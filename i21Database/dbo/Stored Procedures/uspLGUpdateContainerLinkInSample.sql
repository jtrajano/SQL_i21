CREATE PROCEDURE uspLGUpdateContainerLinkInSample
	@intLoadId INT,
	@intLoadDetailId INT = NULL,
	@intLoadContainerId NVARCHAR(100) = NULL,
	@intLoadDetailContainerLinkId INT = NULL
	
AS 
BEGIN
	UPDATE tblQMSample
	SET intLoadContainerId = NULL
		,intLoadDetailId = NULL
		,intLoadDetailContainerLinkId = NULL
		,intLoadId = NULL
	WHERE intLoadId = @intLoadId
		AND (@intLoadDetailId IS NULL OR intLoadDetailId = @intLoadDetailId)
		AND (@intLoadContainerId IS NULL OR intLoadContainerId = @intLoadContainerId)
		AND (@intLoadDetailContainerLinkId IS NULL OR intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId)
	
	UPDATE tblLGLoadDetailContainerLink 
	SET intLoadContainerId = NULL,
		intLoadDetailId = NULL
	WHERE intLoadId = @intLoadId
		AND (@intLoadDetailId IS NULL OR intLoadDetailId = @intLoadDetailId)
		AND (@intLoadContainerId IS NULL OR intLoadContainerId = @intLoadContainerId)
		AND (@intLoadDetailContainerLinkId IS NULL OR intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId)
END