GO
	select * into #tmpU from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='UNIQUE' and TABLE_NAME like 'tblTM%'
	while exists (select top 1 1 from #tmpU)
	begin
		declare @consName nvarchar(max)
		declare @tableName nvarchar(max)
		declare @command  nvarchar(max)
     
		select top 1 
			@consName = CONSTRAINT_NAME, @tableName = TABLE_NAME
			, @command = 'ALTER TABLE ' + TABLE_NAME + ' DROP CONSTRAINT ' + CONSTRAINT_NAME  
		from
			#tmpU
     
		exec (@command) -- executes the alter
		delete from #tmpU where CONSTRAINT_NAME = @consName and TABLE_NAME = @tableName
	end
	drop table #tmpU
GO