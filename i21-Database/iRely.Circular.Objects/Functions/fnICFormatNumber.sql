--https://stackoverflow.com/a/30497618/8706362
CREATE FUNCTION [dbo].[fnICFormatNumber] (@number NUMERIC(38,20))

RETURNS NVARCHAR(50)

BEGIN
    -- remove minus sign before applying thousands seperator
    DECLARE @negative bit
    SET @negative = CASE WHEN @number < 0 THEN 1 ELSE 0 END
    SET @number = ABS(@number)

    -- add thousands seperator for every 3 digits to the left of the decimal place
    DECLARE @pos int, @result varchar(50) = CAST(@number AS varchar(50))
    SELECT @pos = CHARINDEX('.', @result)
    WHILE @pos > 4
    BEGIN
        SET @result = STUFF(@result, @pos-3, 0, ',')
        SELECT @pos = CHARINDEX(',', @result)
    END

    -- remove trailing zeros
    WHILE RIGHT(@result, 1) = '0'
        SET @result = LEFT(@result, LEN(@result)-1)
    -- remove decimal place if not required
    IF RIGHT(@result, 1) = '.'
        SET @result = LEFT(@result, LEN(@result)-1)

    IF @negative = 1
        SET @result = '-' + @result

    RETURN @result
END