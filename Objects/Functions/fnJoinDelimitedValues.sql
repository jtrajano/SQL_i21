/*
    This functions joins row values to form a single delimited string.
*/
CREATE FUNCTION dbo.fnJoinDelimitedValues(@Values JointDelimitedValues READONLY, @Delimiter VARCHAR(10) = ',')
RETURNS
NVARCHAR(MAX)
AS
BEGIN

DECLARE @str NVARCHAR(MAX)

SET @Delimiter = LTRIM(RTRIM(@Delimiter)) + ' '

SELECT @str = COALESCE(@str + @Delimiter, '') + CAST(v.varValue AS NVARCHAR(MAX))
FROM @Values v

RETURN RTRIM(LTRIM(@str))

END

GO