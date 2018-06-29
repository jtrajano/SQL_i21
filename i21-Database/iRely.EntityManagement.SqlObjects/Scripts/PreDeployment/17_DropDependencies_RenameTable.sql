GO
PRINT 'Create a temp recur procedure'
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspTempRecur')
BEGIN
	EXEC ('DROP PROCEDURE uspTempRecur')
END

EXEC('
CREATE PROCEDURE uspTempRecur
	@ObjectName NVARCHAR(MAX)
AS
BEGIN
	set nocount on
	DECLARE @ObjectList TABLE(
		name nvarchar(max)
	)
	DECLARE @CurrentObject NVARCHAR(MAX)
	insert into @ObjectList
	select distinct o.name as ObjName
		from sys.sql_dependencies d
			join sys.objects o on o.object_id=d.object_id
			join sys.objects r on r.object_id=d.referenced_major_id
		where d.class=1
		AND r.name = @ObjectName

	while exists(select top 1 1 from @ObjectList)
	begin
		select top 1 @CurrentObject = name from @ObjectList

		if exists(select distinct o.name as ObjName
		from sys.sql_dependencies d
			join sys.objects o on o.object_id=d.object_id
			join sys.objects r on r.object_id=d.referenced_major_id
		where d.class=1
		AND r.name = @CurrentObject)
		begin
			print ''going recursive for object '' + @CurrentObject
			exec uspTempRecur @CurrentObject
		end

		if exists(select top 1 1 from sys.objects where name = @CurrentObject)
		begin
			print ''droping element '' + @CurrentObject
			exec(''drop view '' + @CurrentObject)
		end


		delete from @ObjectList where name = @CurrentObject
	end
END

')

PRINT 'RENAME ALL THE TABLES'
IF EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'tblEntity')
BEGIN
	EXEC('CREATE TABLE tblEntityTempForDelete (ID INT)')
	if exists(SELECT TOP 1 1 FROM sys.objects where name = 'vwcusmst')
	begin
		EXEC('DROP VIEW vwcusmst')
	end

	

	declare @EntityTable table(
		name nvarchar(max)
	)
	declare @DeleteView Table(
		name nvarchar(max)
	)

	insert into @EntityTable
	select name from sys.objects where name like 'tblEntity%'

	declare @CurrentTable nvarchar(max)
	declare @Command nvarchar(max)
	while exists(select top 1 1 from @EntityTable)
	begin
		select top 1 @CurrentTable = name from @EntityTable
		if exists(select top 1 1 from sys.objects where name = @CurrentTable)
		begin
		
			exec uspTempRecur @CurrentTable

			set @Command = N'
			sp_rename ''' + @CurrentTable + ''',''' + replace(@CurrentTable, 'tblEntity', 'tblEMEntity') + '''
			'
			exec (@Command)
		end
		delete from @EntityTable where name = @CurrentTable
	end

	
END


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspTempRecur')
BEGIN
	EXEC ('DROP PROCEDURE uspTempRecur')
END

GO