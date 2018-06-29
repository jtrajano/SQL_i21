CREATE FUNCTION [dbo].[fnDateLessThanEquals](
	@actual AS DATETIME
	,@expected AS DATETIME	
)
RETURNS BIT
AS
BEGIN 
	IF FLOOR(CAST(@actual AS FLOAT)) <= FLOOR(CAST(@expected AS FLOAT))
		RETURN 1;

	RETURN 0;
END
