﻿CREATE FUNCTION [dbo].[fnDateLessThanEquals](
	@expected AS DATETIME
	,@actual AS DATETIME
)
RETURNS BIT
AS
BEGIN 
	IF FLOOR(CAST(@expected AS FLOAT)) <= FLOOR(CAST(@actual AS FLOAT))
		RETURN 1;

	RETURN 0;
END
