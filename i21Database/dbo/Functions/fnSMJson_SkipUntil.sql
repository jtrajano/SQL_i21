CREATE FUNCTION [dbo].[fnSMJson_SkipUntil](@json NVARCHAR(MAX),@start int,@what NVARCHAR(MAX))
returns int
as
begin
    while ((@start<=len(@json)) and (ascii(substring(@json,@start,1))<=32)) begin
        set @start=@start+1
        end
    if (@start>len(@json)) return 0
    if (substring(@json,@start,len(@what))!=@what) return 0
    return @start+1
end