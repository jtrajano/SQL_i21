﻿CREATE FUNCTION [dbo].[fnGetGLAccountIdFromCategory]
(
	@intItemId INT
	,@intLocationId INT
	,@intType INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	-- TODO: Get the G/L account id from the category table. 
	
	RETURN @intGLAccountId 
END
GO