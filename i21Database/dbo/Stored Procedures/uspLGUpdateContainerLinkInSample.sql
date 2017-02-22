CREATE PROCEDURE uspLGUpdateContainerLinkInSample
	@intLoadContainerId NVARCHAR(100),
	@intLoadDetailContainerLinkId INT,
	@intLoadId INt
AS 
BEGIN
	UPDATE tblQMSample
	SET intLoadContainerId = NULL
		,intLoadDetailId = NULL
		,intLoadDetailContainerLinkId = NULL
		,intLoadId = NULL
	WHERE intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId
	
	UPDATE tblLGLoadDetailContainerLink 
	SET intLoadContainerId = NULL,
		intLoadDetailId = NULL
	WHERE intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId
END