CREATE FUNCTION fnAllowItemTypeChange (
	@intItemId AS INT 
	,@strType AS NVARCHAR(50) 
)
RETURNS BIT
AS
BEGIN
	IF (
		@intItemId IS NOT NULL 
		AND (
			EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransaction t WHERE t.intItemId = @intItemId AND ISNULL(t.ysnIsUnposted,0) = 0) 
		)
	)
	BEGIN 
		RETURN 0
	END 

	RETURN 1
END