-- =============================================
-- Author:		Jeffrey Trajano
-- Create date: 13-05-2020
-- Description:	For Undeposited Fund Report
-- =============================================
CREATE PROCEDURE uspCMUndepositedFundReport
    (@xmlParam NVARCHAR(MAX)= '')
AS

DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)
DECLARE @xmlDocumentId AS INT;

EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)
DECLARE @dtmDateCurrent DATETIME
SELECT @dtmDateCurrent = CAST(CONVERT(nvarchar(20), GETDATE(), 101) AS DATETIME)

DECLARE @dtmDateFrom DATETIME,@dtmDateTo DATETIME,@dtmCMDate DATETIME, @dtmTemp DATETIME,@condition NVARCHAR(40)

SELECT 
	@dtmDateFrom = [from],
	@dtmTemp = [from],
	@dtmDateTo =  [to],
	@condition  = condition 
FROM @temp_xml_table WHERE [fieldname] = 'dtmDate' 

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	
	IF @dtmDateFrom IS NULL 
	BEGIN
		SET @condition = 'As Of'
	END 

	IF @condition <> 'Equal To'
	BEGIN

		SELECT
			@dtmDateFrom = isnull(@dtmDateFrom,'01/01/1900')
			,@dtmDateTo =
			CASE WHEN @dtmTemp IS NULL
				THEN @dtmDateCurrent
				ELSE ISNULL(@dtmDateTo,@dtmDateFrom)
			END

		SELECT @dtmCMDate = DATEADD( DAY, 1, @dtmDateTo) 
		SELECT @dtmDateTo = DATEADD( SECOND,-1, DATEADD(DAY, 1 ,@dtmDateTo))
	END
	ELSE

	BEGIN
		SELECT @dtmDateTo = DATEADD( SECOND,-1, DATEADD(DAY, 1 ,@dtmDateFrom))
		SELECT @dtmCMDate = DATEADD( SECOND, 1, @dtmDateTo) 
	END

	--SELECT @dtmDateFrom, @dtmDateTo,@dtmCMDate

	--RETURN

	DECLARE @intUserId INT, @intBankAccountId INT
	select TOP 1 @intUserId = intEntityId from tblSMConnectedUser order by dtmConnectDate desc
	SELECT TOP 1 @intBankAccountId = intBankAccountId FROM tblCMBankAccount
	IF @intBankAccountId IS NULL
	BEGIN
		RAISERROR('There are no bank accounts', 16, 1);
		RETURN;
	END
		
	EXEC [dbo].[uspCMRefreshUndepositedFundsFromOrigin]	@intBankAccountId = @intBankAccountId,@intUserId = @intUserId


	DECLARE @strLocation nvarchar(50)
	SELECT @strLocation = [from] FROM @temp_xml_table WHERE [fieldname] = 'strLocationName' --and condition in ('Equal To' , 'Between')


	
	DECLARE @intCompanySegmentFrom INT
	DECLARE @intCompanySegmentTo INT
	DECLARE @strCompanyCondition NVARCHAR(30)
	SELECT @intCompanySegmentFrom = CAST([from]AS INT),  @intCompanySegmentTo = CAST([to]AS INT), @strCompanyCondition =  [condition]  
	FROM @temp_xml_table WHERE [fieldname] = 'strCompanySegment' 




DECLARE @strSQL NVARCHAR(MAX) ='
	select
	0 as rowId,
	@dtmDateFrom as dtmDateFrom,
	@dtmDateTo as dtmDateTo,
	@dtmCMDate as dtmCMDateParam,
	@strLocation as strLocationParam,
	null as dtmDate,
	'''' AS strName,
	'''' AS strSourceTransactionId,
	'''' AS strPaymentMethod,
	'''' AS strSourceSystem,
	'''' AS strEODNumber,
	'''' AS strEODDrawer,
	cast(0 as bit) AS ysnEODComplete,
	'''' AS strCardType,
	'''' AS strLocationName,
	'''' AS strUserName,
	'''' AS strTransactionId,
	cast(0 as bit)  AS ysnPosted,
	null AS dtmCMDate,
	0 AS dblAmount,
	'''' AS strBatchId,
	'''' strCompanySegment,
	'''' strAccountId
	UNION
	SELECT 
	a.rowId,
	@dtmDateFrom as dtmDateFrom,
	@dtmDateTo as dtmDateTo,
	@dtmCMDate as dtmCMDateParam,
	@strLocation as strLocationParam,
	a.dtmDate,
	a.strName,
	a.strSourceTransactionId,
	a.strPaymentMethod,
	a.strSourceSystem,
	a.strEODNumber,
	a.strEODDrawer ,
	a.ysnEODComplete ,
	a.strCardType,
	a.strLocationName strLocationName,
	a.strUserName,
	a.strTransactionId,
	a.ysnPosted,
	a.dtmCMDate,
	a.dblAmount,
	GL.strBatchId,
	a.strCompanySegment,
	a.strAccountId
	FROM dbo.fnCMUndepositedFundReport(@dtmDateFrom,@dtmDateTo,@dtmCMDate) a
	OUTER APPLY(
		SELECT TOP 1 strBatchId FROM tblGLDetail 
		WHERE strTransactionId = a.strSourceTransactionId 
		AND strTransactionType = ''Receive Payments''
		AND ysnIsUnposted = 0
	)GL
	WHERE ISNULL(@strLocation, a.strLocationName) = a.strLocationName '
		 

IF (@strCompanyCondition = 'Between')
	IF ( @intCompanySegmentFrom IS NOT NULL AND @intCompanySegmentTo IS NOT NULL )
	SET @strSQL = @strSQL + ' AND CAST(a.strCompanySegment AS INT)  BETWEEN ' +  CAST(@intCompanySegmentFrom AS NVARCHAR(10))  + ' AND ' +  CAST(@intCompanySegmentTo AS NVARCHAR(10))
ELSE IF ( @intCompanySegmentFrom IS NOT NULL AND @intCompanySegmentTo IS NULL ) GOTO _Equal



IF (@strCompanyCondition = 'Equal To'  AND @intCompanySegmentFrom IS NOT NULL )BEGIN
	_Equal:
	SET @strSQL = @strSQL + ' AND CAST(a.strCompanySegment AS INT) = ' +  CAST(@intCompanySegmentFrom AS NVARCHAR(10))  
END

--SELECT @strSQL
EXEC sp_executesql @strSQL
,N' @dtmDateFrom DATETIME, @dtmDateTo DATETIME, @dtmCMDate DATETIME,@strLocation NVARCHAR(50)'
, @dtmDateFrom = @dtmDateFrom, @dtmDateTo=@dtmDateTo,@dtmCMDate=@dtmCMDate,@strLocation = @strLocation

END