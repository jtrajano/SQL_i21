CREATE  PROCEDURE [dbo].[uspGLGetAccountDetailReport]
       (@xmlParam NVARCHAR(MAX)= '')
AS
BEGIN
   SET NOCOUNT ON;
   IF (ISNULL(@xmlParam,'')  = '')
   BEGIN
		SELECT DISTINCT
		'' AS strCompanyName,
		'' AS AccountHeader,
		'' AS strAccountDescription,
		'' AS strAccountType,
		'' AS strAccountGroup,
		getdate() AS dtmDate,
		'' AS strBatchId,
		0.0  AS dblDebit,
		0.0 AS dblCredit,
		0.0 AS dblDebitUnit,
		0.0 AS dblCreditUnit,
		'' AS strDetailDescription,
		'' AS strTransactionId,
		0 AS intTransactionId,
		'' AS strTransactionType,
		'' AS strTransactionForm ,
		'' AS strModuleName,
		'' AS strReference,
		'' AS strReferenceDetail,
		'' AS strDocument,
		0.0 AS dblTotal,
		0 AS intAccountUnitId,
		'' AS strCode,
		0 AS intGLDetailId,
		0 AS ysnIsUnposted,
		'' AS strAccountId,
		'' AS [Primary Account],
		'' AS Location,
		'' AS strUOMCode,
		0.0 AS dblBeginBalance,
		0.0 AS dblBeginBalanceUnit
		RETURN;
   END
   --SET FMTONLY off;
   DECLARE @idoc INT
   DECLARE @filterTable FilterTableType
   DECLARE @strAccountIdFrom NVARCHAR(50)=''
   DECLARE @strAccountIdTo NVARCHAR(50)=''
   DECLARE @strPrimaryCodeFrom NVARCHAR(50)=''
   DECLARE @strPrimaryCodeTo NVARCHAR(50)=''
   DECLARE @strPrimaryCodeCondition NVARCHAR(50) = ''
   DECLARE @dtmDateFrom NVARCHAR(50)=''
   DECLARE @dtmDateTo NVARCHAR(50)=''
   DECLARE @strAccountIdCondition NVARCHAR(20)=''

   IF @xmlParam <> ''
   BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		INSERT INTO @filterTable
		SELECT  *
		FROM    OPENXML(@idoc, '/xmlparam/filters/filter', 2)
		WITH ([fieldname] nvarchar(50)
						, [condition] nvarchar(20)
						, [from] nvarchar(50)
						, [to] nvarchar(50)
						, [join] nvarchar(10)
						, [begingroup] nvarchar(50)
						, [endgroup] nvarchar(50)
						, [datatype] nvarchar(50))

		DELETE FROM @filterTable WHERE [from] IS NULL OR RTRIM([from]) = ''
		UPDATE @filterTable SET [fieldname] = 'strCode',[from] = '' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'Yes'
		UPDATE @filterTable SET [fieldname] = 'strCode',[from] = 'AA' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'No'
		UPDATE @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'PrimaryAccount'
		UPDATE @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'Primary Account'
		DELETE FROM @filterTable WHERE [condition]= 'All Date'
		SELECT TOP 1 @strAccountIdFrom= ISNULL([from],'') , @strAccountIdTo = ISNULL([to],'') ,@strAccountIdCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = 'strAccountId'
		SELECT TOP 1 @strPrimaryCodeFrom= ISNULL([from],'') , @strPrimaryCodeTo = ISNULL([to],'') ,@strPrimaryCodeCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = '[Primary Account]'
		SELECT TOP 1 @dtmDateFrom= ISNULL([from],'') , @dtmDateTo = ISNULL([to],'') from  @filterTable WHERE [fieldname] = 'dtmDate'

		IF EXISTS(
				SELECT TOP 1 1 FROM @filterTable WHERE
				(
					condition LIKE  '%Date'  or
					condition like '%Month' or
					condition like '%Period' or
					condition like '%Year' or
					condition like '%Quarter' or
					condition = 'As Of') AND ([from] ='' OR [to] =''))
		BEGIN
			RAISERROR (N'Between condition needs from and to parameter to be present.',10, 1);
			RETURN
		END

		DECLARE @sqlCte NVARCHAR(MAX) = 
		dbo.[fnGLGetAccountDetailSQL]
		(
			@strAccountIdFrom,
			@dtmDateFrom,
			@dtmDateTo,
			@filterTable
		)
		SELECT @sqlCte += 'select * from result'
		EXEC (@sqlCte)
   END
END
GO

