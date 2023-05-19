
CREATE function fnRemoveManyComma (@n nvarchar(max))
returns nvarchar(max)
as
begin
declare @n1 nvarchar(max)
select @n1 = replace(@n, ',,' ,',') 
select @n1 = replace(@n1, ',,,' ,',') 
select @n1 = replace(@n1, ',,,,' ,',') 
select @n1 = replace(@n1, ',,,,,' ,',') 
select @n1 = replace(@n1, ',,,,,,' ,',') 
select @n1 = replace(@n1, ',,,,,,,' ,',') 
return @n1
end
