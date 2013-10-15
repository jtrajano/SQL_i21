


-- Report Constraint Cleaner


declare @RPRec int
	select @RPRec = 
	( select count(*) from Configurations )
	+ (select count(*) from  CriteriaFields)
	+ (select count(*) from  CriteriaFieldSelections )
	+ (select count(*) from  Datasources )
	+ (select count(*) from  DesignParameters )
	+ (select count(*) from  FieldSelectionFilters )
	+ (select count(*) from  Filters )
	+ (select count(*) from  Options )
	+ (select count(*) from  Reports )
	+ (select count(*) from  Sorts )
	+ (select count(*) from  SubreportSettings )
	+ (select count(*) from  CompanyInformations )
	+ (select count(*) from  Connections )


select [Report Record Count] = @RPRec

if (@RPRec = 0)
BEGIN
	--get all Report constraints and drop it all
	select * into #tmpConstraints from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
	and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_NAME in ('Configurations', 'CriteriaFields', 'CriteriaFieldSelections', 'Datasources', 'DesignParameters', 'FieldSelectionFilters', 'Filters', 'Options', 'Reports', 'Sorts', 'SubreportSettings', 'CompanyInformations', 'Connections', 'Users'))

	declare @tableName nvarchar(100)
	declare @constraintName nvarchar(100)

	while exists(select top 1 1 from #tmpConstraints)
	begin
		select top 1 @tableName= TABLE_NAME, @constraintName = CONSTRAINT_NAME from #tmpConstraints
		exec ('alter table ' +  @tableName + ' drop constraint [' + @constraintName + ']')
		delete from #tmpConstraints where CONSTRAINT_NAME = @constraintName
	end

	drop table #tmpConstraints
END
ELSE
	BEGIN
		-- raise error and tell the installer that we cannot just drop the tables
		RAISERROR('Reports has some records.', 16, 1)
	END
