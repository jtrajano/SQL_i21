-- 1. Drop Report Tables
	select TABLE_NAME into #tmpTable from INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME in ('Configurations', 'CriteriaFields', 'CriteriaFieldSelections', 'Datasources', 'DesignParameters', 'FieldSelectionFilters', 'Filters', 'Options', 'Reports', 'Sorts', 'SubreportSettings', 'CompanyInformations', 'Connections', 'Users')

	declare @tableName nvarchar(100)

	while exists(select top 1 1 from #tmpTable )
	BEGIN
		select top 1 @tableName= TABLE_NAME from #tmpTable
		select @tableName
		exec('drop table [' + @tableName + ']')
		delete from #tmpTable where TABLE_NAME = @tableName
	END

	drop table #tmpTable

GO
-- 2. Drop GL tables

	select TABLE_NAME into #tmpTable from INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'tblGL%' 

	declare @tableName nvarchar(100)

	while exists(select top 1 1 from #tmpTable )
	BEGIN
		select top 1 @tableName= TABLE_NAME from #tmpTable
		select @tableName
		exec('drop table [' + @tableName + ']')
		delete from #tmpTable where TABLE_NAME = @tableName
	END

	drop table #tmpTable

GO


-- 2. Drop TM tables

	select TABLE_NAME into #tmpTable from INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'tblTM%' 

	declare @tableName nvarchar(100)

	while exists(select top 1 1 from #tmpTable )
	BEGIN
		select top 1 @tableName= TABLE_NAME from #tmpTable
		select @tableName
		exec('drop table [' + @tableName + ']')
		delete from #tmpTable where TABLE_NAME = @tableName
	END

	drop table #tmpTable

GO



-- 3. Drop Temp tables

	select TABLE_NAME into #tmpTable from INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'tblTemp%' 

	declare @tableName nvarchar(100)

	while exists(select top 1 1 from #tmpTable )
	BEGIN
		select top 1 @tableName= TABLE_NAME from #tmpTable
		select @tableName
		exec('drop table [' + @tableName + ']')
		delete from #tmpTable where TABLE_NAME = @tableName
	END

	drop table #tmpTable

GO


