﻿CREATE FUNCTION [dbo].[fnRemoveTimeOnDate](
	@date AS DATETIME
)
RETURNS DATETIME 
AS
BEGIN 
	RETURN CAST(FLOOR(CAST(@date AS FLOAT)) AS DATETIME)
END