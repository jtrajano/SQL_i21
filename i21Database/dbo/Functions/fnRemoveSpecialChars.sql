CREATE FUNCTION [dbo].[fnRemoveSpecialChars]
(
	@Temp NVARCHAR(1000)
)
RETURNS NVARCHAR(1000)
AS
BEGIN
    DECLARE @KeepValues AS VARCHAR(50)
    SET @KeepValues = '%[^A-Za-z0-9]%'
    WHILE PATINDEX(@KeepValues, @Temp) > 0
        SET @Temp = STUFF(@Temp, PATINDEX(@KeepValues, @Temp), 1, '')

    RETURN @Temp
End