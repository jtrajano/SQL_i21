CREATE FUNCTION [dbo].[fnCTChangeNumericScale]
(
	@dblValue NUMERIC(18,6),
	@intScale INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @col NVARCHAR(MAX);
 
	SELECT @col = STR(@dblValue, 18, @intScale)

	RETURN LTRIM(RTRIM(@col))
END