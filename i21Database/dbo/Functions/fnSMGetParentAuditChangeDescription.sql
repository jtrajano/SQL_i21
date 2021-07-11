CREATE FUNCTION [dbo].[fnSMGetParentAuditChangeDescription]
(
	@strChange NVARCHAR(MAX), 
	@strAction NVARCHAR(MAX),
	@intRecordId INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	IF ISNULL(@strChange, '') = ''
	BEGIN
		RETURN (CASE WHEN (ISNULL(@strAction, '') = '') THEN 'Updated' ELSE @strAction END) + ' - Record: ' + CAST((ISNULL(@intRecordId, 0)) AS NVARCHAR(10))
	END

	RETURN @strChange
END
