CREATE FUNCTION [dbo].[fnSMParseJson_Natural](@json NVARCHAR(MAX),@start int)
RETURNS NVARCHAR(MAX)
AS BEGIN
    declare @value NVARCHAR(MAX)=''
    while SUBSTRING(@json,@start,1) >= '0' AND SUBSTRING(@json,@start,1) <= '9' BEGIN
        set @value=@value +SUBSTRING(@json,@start,1)
        set @start=@start+1
        end
    return @value
END