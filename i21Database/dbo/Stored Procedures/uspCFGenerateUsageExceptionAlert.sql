CREATE PROCEDURE [dbo].[uspCFGenerateUsageExceptionAlert](
	@intEntityId INT,
	@strNetworks NVARCHAR(MAX) = '',
	@dtmTransactionFrom DATETIME = NULL,
	@dtmTransactionTo DATETIME = NULL,
	@intCustomerEntityId INT = NULL
)
AS
BEGIN
	
	--DECLARE @intEntityId INT = 1
	--DECLARE @strNetworks NVARCHAR(MAX) = 'pacpride,NBS'
	--DECLARE @dtmTransactionFrom DATETIME = NULL
	--DECLARE @dtmTransactionTo DATETIME = NULL
	
	DECLARE @networkWhereClause NVARCHAR(MAX) = ''
	DECLARE @strTransactionFrom NVARCHAR(25)
	DECLARE @strTransactionTo NVARCHAR(25)
	DECLARE @customerWhereClause NVARCHAR(MAX) = ''


	-------Convert date to string 
	SELECT @strTransactionFrom = CONVERT(NVARCHAR(25), ISNULL(@dtmTransactionFrom,'1/1/1900'),121) 
		   ,@strTransactionTo = CONVERT(NVARCHAR(25), ISNULL(@dtmTransactionTo,'1/1/9999'),121) 

	-------Check for network parameter
	IF(ISNULL(@strNetworks,'') <> '')
	BEGIN
		SET @networkWhereClause =  ' AND strNetwork IN (''' + REPLACE(@strNetworks,',',''',''') + ''')'
	END

	IF(ISNULL(@intCustomerEntityId,0) <> 0)
	BEGIN
		SET @customerWhereClause = ' AND intEntityId = ' + CAST(@intCustomerEntityId AS NVARCHAR(10))
	END

	DELETE FROM tblCFUsageExceptionAlertStaging WHERE intUserId = @intEntityId

	IF OBJECT_ID('tempdb..#tblCFTransactionList') IS NOT NULL DROP TABLE #tblCFTransactionList	
	CREATE TABLE #tblCFTransactionList (intTransactionId INT)

	EXEC('
		INSERT INTO #tblCFTransactionList (intTransactionId)
		SELECT 
			intTransactionId 
		FROM vyuCFUsageExceptionAlertTransaction
		WHERE ISNULL(strCustomerNumber,'''') <> '''' 
			AND DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0) >= ''' + @strTransactionFrom + ''' 
			AND DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0) <= ''' + @strTransactionTo + '''' 
			+ @networkWhereClause 
			+ @customerWhereClause
		)
	
	IF OBJECT_ID('tempdb..#CustomerTransactionCount') IS NOT NULL DROP TABLE #CustomerTransactionCount
	SELECT 
		strCustomerNumber
		,intTransactionCount = COUNT(strCustomerNumber)
		,dtmTransactionDate = DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0)
	INTO #CustomerTransactionCount
	FROM  vyuCFUsageExceptionAlertTransaction
	WHERE intTransactionId IN (SELECT intTransactionId FROM #tblCFTransactionList)
	GROUP BY strCustomerNumber,DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0)

	INSERT INTO tblCFUsageExceptionAlertStaging(
		strCustomerNumber
		,strCustomerName
		,intTransactionLimit
		,strNetwork
		,strEmailDistributionOption
		,strEmailAddress
		,strCardNumber
		,strCardDescription
		,strProduct
		,strProductDescription
		,strSiteNumber
		,strSiteName
		,dtmTransactionDate
		,dblQuantity
		,dblTotalAmount
		,strDriverPin
		,ysnSendEmail
		,intTransactionCount
		,intUserId
		,dtmPeriodFrom
		,dtmPeriodTo
		,blbMessageBody
		,strFullAddress
		,intEntityId
	)
	SELECT 
		strCustomerNumber = B.strCustomerNumber
		,strCustomerName = B.strName
		,intTransactionLimit = B.intTransactionLimit
		,strNetwork = B.strNetwork
		,strEmailDistributionOption = B.strEmailDistributionOption
		,strEmailAddress = B.strEmail
		,strCardNumber = B.strCardNumber
		,strCardDescription = B.strCardDescription
		,strProduct = B.strProduct
		,strProductDescription = B.strProductDescription
		,strSiteNumber = B.strSiteNumber
		,strSiteName = B.strSiteName
		,dtmTransactionDate = B.dtmTransactionDate
		,dblQuantity = B.dblQuantity
		,dblTotalAmount = B.dblTotal
		,strDriverPin = B.strDriverPin
		,ysnSendEmail = CAST((CASE WHEN ISNULL(B.strEmail,'') = '' THEN 0 ELSE 1 END) AS BIT)
		,intTransactionCount = C.intTransactionCount
		,intUserId = @intEntityId
		,dtmPeriodFrom = ISNULL(@dtmTransactionFrom,'1/1/1900')
		,dtmPeriodTo = ISNULL(@dtmTransactionTo,'1/1/1900')
		,blbMessageBody = (SELECT TOP 1 blbMessage 
						  FROM [dbo].[fnCFGetDefaultCommentTable](NULL, B.intEntityId, 'CF Alerts', NULL, 'Header', NULL, 1))
		,strFullAddress = B.strAddress
		,intEntityId = B.intEntityId
	FROM vyuCFUsageExceptionAlertTransaction B
	INNER JOIN #CustomerTransactionCount C
		ON B.strCustomerNumber = C.strCustomerNumber
			AND DATEADD(dd, DATEDIFF(dd, 0, B.dtmTransactionDate), 0) = DATEADD(dd, DATEDIFF(dd, 0, C.dtmTransactionDate), 0)
	WHERE C.intTransactionCount > B.intTransactionLimit
		AND B.intTransactionId IN (SELECT intTransactionId FROM #tblCFTransactionList)
		AND C.strCustomerNumber IS NOT NULL
	--GROUP BY strCustomerNumber
	--	,strName
	--	,intTransactionLimit
	--	,strNetwork
	--	,strEmailDistributionOption
	--	,strEmail
	--	,strCardNumber
	--	,strCardDescription
	--	,strProduct
	--	,strProductDescription
	--	,strSiteNumber
	--	,strSiteName
	--	,dtmTransactionDate
	--	,strDriverPin
	--HAVING B.intTransactionLimit < COUNT(B.strCustomerNumber)	

END


