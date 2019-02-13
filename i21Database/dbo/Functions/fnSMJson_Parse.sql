CREATE FUNCTION [dbo].[fnSMJson_Parse](@json nvarchar(max))
RETURNS @data TABLE
    (
    id int NOT NULL,
    parent int NOT NULL,
    name nvarchar(100) NOT NULL,
    kind nvarchar(10) NOT NULL,
    value nvarchar(MAX) NOT NULL)
AS
BEGIN
    declare @start int = 1
    set @start = dbo.fnSMJson_Skip(@json,@start)

    insert into @data(id,parent,name,kind,value)
    select id,parent,name,kind,value from dbo.fnSMParseJson_Item(1,0,@start,@json,0)
    return
END