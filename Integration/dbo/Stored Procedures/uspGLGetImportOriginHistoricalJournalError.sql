GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glhstmst]') AND type IN (N'U'))
BEGIN 
EXEC('
IF EXISTS(select top 1 1 from sys.procedures where name = ''uspGLGetImportOriginHistoricalJournalError'')
	DROP PROCEDURE uspGLGetImportOriginHistoricalJournalError')


EXEC ('CREATE PROCEDURE [dbo].[uspGLGetImportOriginHistoricalJournalError](@uid UNIQUEIDENTIFIER,@category VARCHAR(50) OUT, @result INT = 0 OUT)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @result = COUNT(1) FROM tblGLFiscalYear
	
	IF (@result = 0)
	BEGIN
		SELECT @category=''FiscalYear'',@result = 1
		RETURN
	END
	
	SELECT @result = 0, @category = ''OriginHistoricalJournalData''
	
	
	DECLARE @temp table(fld int,fld1 int, fld2 varchar(30))
	DECLARE @temp1 table (fld varchar(30))
	DECLARE @temp2 table(strTitle nvarchar(100), strDescription nvarchar(100))
	
	
	
	--format id to ''00000000 00000000'' without the space in origin table
	INSERT into @temp
	SELECT glhst_acct1_8 , glhst_acct9_16, right(''00000000'' + cast(glhst_acct1_8 as varchar(8)),8) + right(''00000000'' + cast(glhst_acct9_16 as varchar(8)),8) 
	FROM glhstmst
	GROUP by glhst_acct1_8,glhst_acct9_16
	
	--format id to ''00000000 00000000'' without the space in tblGLCOACrossReference
	INSERT into @temp1
	SELECT SUBSTRING(strCurrentExternalId,1,8) + SUBSTRING(strCurrentExternalId,10,8) from tblGLCOACrossReference
	
	--inserts to tblGLImportError
	INSERT INTO @temp2(strTitle,strDescription)
	SELECT convert(varchar(20),fld) + '' '' + CONVERT(VARCHAR(20),fld1),
	''Account ID does not exists at iRely Cross Reference. Kindly verify at Origin.''
	FROM @temp	WHERE fld2 not in (SELECT fld FROM @temp1 )
	
		
	
	INSERT INTO @temp2(strTitle,strDescription)
	SELECT convert(varchar(20),glhst_acct1_8) + '' '' + convert(varchar(20),glhst_acct9_16),
	''Invalid Historical Transaction Details Date in the Origin - '' + CONVERT(VARCHAR(20), glhst_trans_dt)
	 FROM glhstmst where LEN(glhst_trans_dt) <> 8
	
	INSERT INTO @temp2(strTitle,strDescription) 
	SELECT convert(varchar(20),glhst_acct1_8) + '' '' + convert(varchar(20),glhst_acct9_16),
	''Invalid Historical Period in the Origin - '' + CONVERT(VARCHAR(20),glhst_period)
	FROM glhstmst
	WHERE  ISDATE(SUBSTRING(CONVERT(VARCHAR(20),glhst_period) ,5,2) + ''/01/'' + SUBSTRING(CONVERT(VARCHAR(20),glhst_period),1,4)) = 0

	--RETURNS ERROR COUNT WITH UID
	INSERT INTO tblGLImportError (guidSessionId,strTitle,strDescription, dteAdded)
	SELECT @uid,strTitle, strDescription,GETDATE() from @temp2 ORDER BY strTitle
	
	SELECT  @result= COUNT(1) FROM tblGLImportError WHERE guidSessionId = @uid
	
END
')
END
