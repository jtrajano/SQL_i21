CREATE PROCEDURE [dbo].[uspGLExportAccountToCSV] 
	(@intJournalId INT,@strJournalDetailId NVARCHAR(MAX)='')
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SQLString nvarchar(max);
	DECLARE @ParmDefinition nvarchar(500);
	--declare @intJournalId int = 1583
	--declare @strJournalDetailId nvarchar(max) = '58985'
 --    --Insert statements for procedure here
    IF EXISTS (SELECT  * from tempdb.dbo.sysobjects o WHERE o.xtype in ('U') AND o.id = object_id(N'tempdb..#tempCSV'))
		DROP TABLE #tempCSV
    CREATE TABLE #tempCSV(
		 _year nvarchar(4) null,
		 period int null,
		 strExternalId nvarchar(20) null,
		 strSourceType nvarchar(10)null,
		 strSourceId nvarchar(5)null,
		 intLineNo int null,
		 dtmDate DATETIME null,
		 strReference nvarchar(100) null,
		 strDocument nvarchar(100) null,
		 strComments nvarchar(255) null,
		 strDebitCredit nvarchar,
		 amount numeric(18,6) null,
		 dblUnitsInLBS  numeric(18,6) null,
		 strCorrecting nvarchar(1) null
    )
    
	SET @SQLString =N'INSERT INTO #tempCSV
	SELECT NULL as _year, null as period , c.strExternalId,a.strSourceType,a.strSourceId,b.intLineNo,b.dtmDate,b.strReference,b.strDocument,
	b.strComments,CASE WHEN b.dblCredit > b.dblDebit THEN ''C'' ELSE ''D'' END,   b.dblDebit + b.dblCredit,b.dblUnitsInLBS,ISNULL(b.strCorrecting,''N'') from tblGLJournal a 
	INNER JOIN tblGLJournalDetail b on a.intJournalId= b.intJournalId 
	left join tblGLCOACrossReference c on b.intAccountId = c.inti21Id 
	WHERE b.intJournalId = @_intJournalId'
	SET @ParmDefinition = N'@_intJournalId INT'
	IF LEN(@strJournalDetailId)>0
		BEGIN
			SET @SQLString += ' AND b.intJournalDetailId IN(select intValue FROM dbo.fnCreateTableFromDelimitedValues(@_strJournalDetailId,'',''))'
			SET @ParmDefinition += ',@_strJournalDetailId NVARCHAR(MAX)'
			EXECUTE sp_executesql @SQLString, @ParmDefinition, @_intJournalId = @intJournalId, @_strJournalDetailId = @strJournalDetailId
		END
	ELSE
		EXECUTE sp_executesql @SQLString, @ParmDefinition, @_intJournalId = @intJournalId
	
	DECLARE @dtmDate datetime,@strFiscalYear NVARCHAR(4), @intPeriod INT ,@dtmDateFrom DATETIME
	DECLARE cursor_tbl CURSOR FOR SELECT dtmDate FROM #tempCSV GROUP BY dtmDate
	OPEN cursor_tbl
	FETCH NEXT FROM cursor_tbl INTO @dtmDate
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @strFiscalYear = b.strFiscalYear,@dtmDateFrom = b.dtmDateFrom FROM tblGLFiscalYearPeriod a join tblGLFiscalYear b
				ON a.intFiscalYearId = b.intFiscalYearId WHERE  dtmStartDate <=@dtmDate and dtmEndDate>=@dtmDate
			IF(@strFiscalYear IS NOT NULL)
			BEGIN
				SELECT  @intPeriod= DATEDIFF(MONTH,@dtmDateFrom,@dtmDate) + 1
				UPDATE #tempCSV SET _year = @strFiscalYear, period = @intPeriod WHERE dtmDate = @dtmDate
			END
			FETCH NEXT FROM cursor_tbl INTO @dtmDate
		END
	CLOSE cursor_tbl
	DEALLOCATE cursor_tbl
	END
	
	SELECT _year,
		 period ,
		 strExternalId,
		 strSourceType,
		 strSourceId,
		 intLineNo,
		 CONVERT(VARCHAR(8),dtmDate,112) [dtmDate],
		 CONVERT(VARCHAR(8), dtmDate ,108) [time],
		 strReference,
		 strDocument,
		 strComments ,
		 strDebitCredit,
		 amount,
		 dblUnitsInLBS ,
		 case WHEN LEN(LTRIM(strCorrecting))= 0 THEN 'N' ELSE strCorrecting END [strCorrecting]
		 FROM #tempCSV
	DROP TABLE #tempCSV
