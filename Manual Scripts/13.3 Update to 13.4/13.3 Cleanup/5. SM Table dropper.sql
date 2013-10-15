-- SM Table dropper
-- SPECIFIC for 13.3 to 13.4 


select TABLE_NAME into #tmpTable from INFORMATION_SCHEMA.TABLES 
where TABLE_NAME like 'tblSM%' and TABLE_NAME not in ('tblSMMenu', 'tblSMMenu_bak', 'tblSMUserRole', 'tblSMUserSecurity', 'tblSMActiveScreen')

	declare @tableName nvarchar(100)

	while exists(select top 1 1 from #tmpTable )
	BEGIN
		select top 1 @tableName= TABLE_NAME from #tmpTable
		select @tableName
		exec('drop table [' + @tableName + ']')
		delete from #tmpTable where TABLE_NAME = @tableName
	END

	drop table #tmpTable


