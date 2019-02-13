CREATE FUNCTION [dbo].[fnSMParseJson_Name](@start int,@json NVARCHAR(MAX))
RETURNS @hierarchy table
(
  kind nvarchar(5),name nvarchar(max),pend int
)
AS BEGIN
    declare @p1 int
    declare @name nvarchar(max)

    set @p1 = dbo.fnSMJson_SkipUntil(@json,@start,'"')
    if (@p1=0) begin
            insert into @hierarchy(kind,name,pend) values('ERROR','Expected ["] in property name and have: '+substring(@json,@start,10),@start)
            return;
            end
    select @name=value,@start=p2 from dbo.fnSMJson_String(@json,@p1)
    if (@start=-1) begin
            insert into @hierarchy(kind,name,pend) values('ERROR',@name,@p1)
            return;
            end
    set @p1 = dbo.fnSMJson_SkipUntil(@json,@start,':')
    if (@p1=0) begin
            insert into @hierarchy(kind,name,pend) values('ERROR','Expected [:] after name and have: '+substring(@json,@start,10),@start)
            return;
            end

    set @start = dbo.fnSMJson_Skip(@json,@p1)
    if (@start=0) begin
            insert into @hierarchy(kind,name,pend) values('ERROR','Expected a value after [:] and have: '++substring(@json,@p1,10),@p1)
            return;
            end
    insert into @hierarchy(kind,name,pend) values('OK',@name,@start)
    return
END
