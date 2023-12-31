﻿/*******************  BEGIN DISABLE Report Table Foreign key constraints  *******************/
	print('/*******************  BEGIN DISABLE Report Table Foreign key constraints  *******************/')
	select * into #tmpConstraints from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
	and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblRM%')

	declare @tableName nvarchar(100)
	declare @constraintName nvarchar(100)

	while exists(select top 1 1 from #tmpConstraints)
	begin
		select top 1 @tableName= TABLE_NAME, @constraintName = CONSTRAINT_NAME from #tmpConstraints
		print('alter table ' +  @tableName + ' NOCHECK CONSTRAINT [' + @constraintName + ']')
		exec ('alter table ' +  @tableName + ' NOCHECK CONSTRAINT [' + @constraintName + ']')
		delete from #tmpConstraints where CONSTRAINT_NAME = @constraintName
	end

	drop table #tmpConstraints
	print('/*******************  END DISABLE Report Table Foreign key constraints  *******************/')
	
	
/*******************  END DISABLE Report Table Foreign key constraints  *******************/
GO