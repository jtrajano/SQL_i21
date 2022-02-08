CREATE FUNCTION [dbo].[fnICCalculateCheckDigit] (
	@UPC NVARCHAR(MAX)
)
RETURNS INT 
AS
BEGIN 
	DECLARE @intOddTotal AS INT = 0
    DECLARE @intEvenTotal AS INT = 0
    DECLARE @intTotal AS INT = 0
	DECLARE @intCheckDigit AS INT

    IF (LEN(@UPC) = 11 AND ISNUMERIC(@UPC) = 1)
    BEGIN

        ;WITH CTE (Number) AS
        (
            SELECT 1
            UNION ALL
            SELECT Number +1 FROM CTE WHERE Number < LEN(@UPC)
        )
        SELECT 
            @intEvenTotal = SUM(CAST(Letter AS INT))
        FROM 
            CTE 
        CROSS APPLY 
        (
            SELECT SUBSTRING(@UPC,Number,1 ) 
        ) as J(Letter)
        WHERE
            CAST(Number AS INT) % 2 = 0

        ;WITH CTE (Number) AS
        (
            SELECT 1
            UNION ALL
            SELECT Number +1 FROM CTE WHERE Number < LEN(@UPC)
        )
        SELECT 
            @intOddTotal = SUM(CAST(Letter AS INT))
        FROM 
            CTE 
        CROSS APPLY 
        (
            SELECT SUBSTRING(@UPC,Number,1 ) 
        ) as J(Letter)
        WHERE
            CAST(Number AS INT) % 2 <> 0

        SET @intOddTotal = @intOddTotal * 3
        SET @intTotal = @intOddTotal + @intEvenTotal

        SET @intCheckDigit = 10 - (@intTotal % 10)
    END

	RETURN @intCheckDigit
END