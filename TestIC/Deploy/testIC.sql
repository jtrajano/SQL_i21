if not exists (select * from sys.schemas where name = 'testIC')
begin
	exec sp_executesql N'CREATE SCHEMA [testIC]
'
end
