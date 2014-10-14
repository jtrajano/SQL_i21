
-- Returns the account ids that can be used in item costing. 
CREATE FUNCTION [dbo].[fnGetItemGLAccounts] (
	@intItemId INT
	,@intLocationId INT
)
RETURNS @returntable TABLE
(
	intGLAccountId int,
	intGLType int
)
AS
BEGIN
	DECLARE @InventoryType AS INT = 1
	DECLARE @COGSType AS INT = 2
	DECLARE @WriteOffType AS INT = 3
	DECLARE @RevalueType AS INT = 4
	DECLARE @AutoNegativeType AS INT = 5

	-- TODO: Replace it with the correct business rule 
	-- See: http://www.inet.irelyserver.com/display/INV/Category+%28GL+Accounts%29+tab?focusedCommentId=38209047#comment-38209047

	INSERT INTO @returntable
	SELECT	TOP 1 
			intGLAccountId = CAST(NULL AS INT) 
			,intGLType = @InventoryType 
	FROM	tblICItemLocationStore
	WHERE	intItemId = @intItemId
			AND intLocationId = intLocationId
			-- TODO: Add in the where clause the filter to know if an account is an inventory account. 

	UNION ALL 
	SELECT	TOP 1 
			intGLAccountId = CAST(NULL AS INT) 
			,intGLType = @COGSType 
	FROM	tblICItemLocationStore
	WHERE	intItemId = @intItemId
			AND intLocationId = intLocationId
			-- TODO: Add in the where clause the filter to know if an account is a COGS account. 
	
	RETURN
END
