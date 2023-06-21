CREATE PROCEDURE uspCMGridClear
(
	@guidId UNIQUEIDENTIFIER,
	@strType NVARCHAR(40),
	@intRelatedId INT = null

)
AS
BEGIN
	IF (@intRelatedId IS NOT NULL)
		DELETE FROM tblCMGridSelectedRow 
		WHERE strType = @strType AND guidId = @guidId AND intRelatedId = @intRelatedId
	ELSE
		DELETE FROM tblCMGridSelectedRow 
		WHERE strType = @strType AND guidId = @guidId 
	

END