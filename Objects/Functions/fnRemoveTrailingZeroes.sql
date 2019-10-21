CREATE FUNCTION [dbo].[fnRemoveTrailingZeroes]
(
	@dblNumber NUMERIC(38,20)
)
RETURNS NVARCHAR(50)
AS
BEGIN
	RETURN (replace(rtrim(replace(replace(rtrim(replace(@dblNumber,'0',' ')),' ','0'),'.',' ')),' ','.'))
END
