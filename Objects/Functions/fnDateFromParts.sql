CREATE FUNCTION [fnDateFromParts]
(
    @year int,
    @month int,
    @day int
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @d datetime
	SELECT @d = CAST(CONVERT(VARCHAR, @year) + '-' + CONVERT(VARCHAR, @month) + '-' + CONVERT(VARCHAR, @day) AS DATETIME)
    RETURN  @d 
END