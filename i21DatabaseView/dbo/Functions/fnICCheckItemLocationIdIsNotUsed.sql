-- Used in tblICItemLocation > [CK_ItemLocation_IS_NOT_USED] CONSTRAINT. 
-- It will check if the item location already has a transaction. 
CREATE FUNCTION [dbo].[fnICCheckItemLocationIdIsNotUsed](
	@intItemLocationId AS INT,
	@intLocationId AS INT
)
RETURNS BIT
AS
BEGIN

	IF(@intLocationId IS NOT NULL
		AND(
			EXISTS(SELECT TOP 1 1 FROM tblICInventoryTransaction WHERE intItemLocationId = @intItemLocationId 
				AND ysnIsUnposted <> 1)
		)
	)
	BEGIN
		RETURN 1;
	END

	RETURN 0;
END