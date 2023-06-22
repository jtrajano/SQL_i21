CREATE PROCEDURE uspCMGridClear
(
	@guidId UNIQUEIDENTIFIER,
	@strType NVARCHAR(40),
	@intRelatedId INT = null

)
AS
BEGIN
	IF ISNULL(@intRelatedId,0) = 0
		DELETE FROM tblCMGridSelectedRow 
		WHERE strType = @strType 
	ELSE
		DELETE FROM tblCMGridSelectedRow 
		WHERE strType = @strType AND guidId = @guidId AND intRelatedId = @intRelatedId
		
END