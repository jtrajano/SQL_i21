CREATE FUNCTION [dbo].[fnSMParseJson_Message](@json NVARCHAR(MAX),@start int)
RETURNS NVARCHAR(MAX)
AS
    BEGIN
        set @start=dbo.fnSMJson_Skip(@json,@start)
        if (@start=0) return '** END OF TEXT **'
        return substring(@json,@start,30)
    end
