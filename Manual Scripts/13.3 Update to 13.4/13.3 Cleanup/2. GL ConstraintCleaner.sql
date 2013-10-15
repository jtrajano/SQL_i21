--select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
--select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblGL%'

-- GL Cleaner


declare @GLRec int
	select @GLRec = 
	( select count(*) from tblGLJournal )
	+ (select count(*) from  tblGLFiscalYearPeriod)
	+ (select count(*) from  tblGLJournalRecurring )
	+ (select count(*) from  tblGLCOAAdjustmentDetail )
	+ (select count(*) from  tblGLSummary )
	+ (select count(*) from  tblGLJournalRecurringDetail )
	+ (select count(*) from  tblGLJournalDetail )
	+ (select count(*) from  tblGLDetail )
	+ (select count(*) from  tblGLCOACrossReference )
	+ (select count(*) from  tblGLAccountTemplateDetail )
	+ (select count(*) from  tblGLBudget )
	+ (select count(*) from  tblGLAccountSegmentMapping )
	+ (select count(*) from  tblGLAccountReallocationDetail )
	+ (select count(*) from  tblGLAccountAllocationDetail )
	+ (select count(*) from  tblGLAccountDefaultDetail )
	+ (select count(*) from  tblGLRecurringHistory )
	+ (select count(*) from  tblGLPreferenceCompany )
	+ (select count(*) from  tblGLPostHistory )
	+ (select count(*) from  tblGLModuleList )
	+ (select count(*) from  tblGLFiscalYear )
	+ (select count(*) from  tblGLCOATemplate )
	+ (select count(*) from  tblGLCurrentFiscalYear )
	+ (select count(*) from  tblGLCOAAdjustment )
	+ (select count(*) from  tblGLBudgetDetail )
	+ (select count(*) from  tblGLBudgetCode )
	+ (select count(*) from  tblGLAccountUnit )
	+ (select count(*) from  tblGLCOAImportLog )
	+ (select count(*) from  tblGLAccountTemplate )
	+ (select count(*) from  tblGLAccountStructure )
	+ (select count(*) from  tblGLAccountReallocation )
	+ (select count(*) from  tblGLAccountGroup )
	+ (select count(*) from  tblGLAccount )
	+ (select count(*) from  tblGLAccountDefault )
	+ (select count(*) from  tblGLAccountSegment )
	+ (select count(*) from  tblGLCOATemplateDetail )
	+ (select count(*) from  tblGLCOAImportLogDetail )

select [GL Record Count] = @GLRec

if (@GLRec = 0)
BEGIN
	--get all GL constraints and drop it all
	select * into #tmpConstraints from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
	and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblGL%')

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
		RAISERROR('GL has some records.', 16, 1)
	END
