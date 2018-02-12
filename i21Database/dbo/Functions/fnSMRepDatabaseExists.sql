
--this should be use in parent database
CREATE FUNCTION dbo.fnSMRepDatabaseExists(@dbname nvarchar(128))
RETURNS bit
AS
BEGIN
    declare @result bit = 0 
    SELECT @result = CAST(
        CASE WHEN db_id(@dbname) is not null THEN 1
        ELSE 0
        END 
    AS BIT)
    return @result
END
GO