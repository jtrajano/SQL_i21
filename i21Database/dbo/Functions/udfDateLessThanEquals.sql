CREATE FUNCTION [dbo].[udfDateLessThanEquals](
	@actual AS DATETIME
	,@expected AS DATETIME	
)
RETURNS TABLE 
AS
RETURN 
	SELECT result = CAST(1 AS BIT) 
	WHERE FLOOR(CAST(@actual AS FLOAT)) <= FLOOR(CAST(@expected AS FLOAT))