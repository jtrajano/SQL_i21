
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

DECLARE @dtmDateFrom DATETIME,@dtmDateTo DATETIME,@dtmCMDate DATETIME, @dtmTemp DATETIME

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@dtmDateFrom = [from],
		@dtmTemp = [from],
		@dtmDateTo =  [to]
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDate' --and condition in ('Equal To' , 'Between')



	SELECT @dtmDateFrom = isnull(@dtmDateFrom,'01/01/1900'),
		@dtmDateTo = case when @dtmTemp is null THEN '01-01-2099' ELSE isnull(@dtmDateTo,@dtmDateFrom) END
		
		

	SELECT @dtmCMDate = CASE WHEN 	@dtmDateTo = '01/01/2099' THEN '01/01/1900' ELSE DATEADD( DAY, 1, @dtmDateTo) END

	SELECT @dtmDateTo = DATEADD( SECOND,-1, DATEADD(DAY, 1 ,@dtmDateTo))



	DECLARE @strLocation NVARCHAR(50)
	SELECT 
		@strLocation = [from]
		
	FROM @temp_xml_table WHERE [fieldname] = 'strLocationName' --and condition in ('Equal To' , 'Between')


	


	select
	0 as rowId,
	@dtmDateFrom as dtmDateFrom,
	@dtmDateTo as dtmDateTo,
	@dtmCMDate as dtmCMDateParam,
	null as dtmDate,
	'' AS strName,
	'' AS strSourceTransactionId,
	'' AS strPaymentMethod,
	'' AS strSourceSystem,
	'' AS strEODNumber,
	'' AS strEODDrawer,
	cast(0 as bit) AS ysnEODComplete,
	'' AS strCardType,
	'' AS strLocationName,
	'' AS strUserName,
	'' AS strTransactionId,
	cast(0 as bit)  AS ysnPosted,
	null AS dtmCMDate,
	0 AS dblAmount
	UNION

	SELECT 
	a.rowId,
	@dtmDateFrom as dtmDateFrom,
	@dtmDateTo as dtmDateTo,
	@dtmCMDate as dtmCMDateParam,
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
	a.dtmDate dtmCMDate,
	a.dblAmount 
	FROM dbo.fnCMUndepositedFundReport(@dtmDateFrom,@dtmDateTo,@dtmCMDate) a
	WHERE ISNULL(@strLocation, a.strLocationName) = a.strLocationName

END
ELSE
BEGIN
	select
	0 as rowId,
	@dtmDateFrom as [dtmDateFrom],
	@dtmDateTo as [dtmDateTo],
	@dtmCMDate as dtmCMDateParam,
	null as dtmDate,
	'' AS strName,
	'' AS strSourceTransactionId,
	'' AS strPaymentMethod,
	'' AS strSourceSystem,
	'' AS strEODNumber,
	'' AS strEODDrawer,
	cast(0 as bit) AS ysnEODComplete,
	'' AS strCardType,
	'' AS strLocationName,
	'' AS strUserName,
	'' AS strTransactionId,
	cast(0 as bit)  AS ysnPosted,
	null AS dtmCMDate,
	0 AS dblAmount
END







