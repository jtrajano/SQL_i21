CREATE PROCEDURE [dbo].[uspCFInvoiceReportBalanceValidation](
	 @UserId NVARCHAR(MAX)
	 ,@StatementType NVARCHAR(MAX)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @tblExcludeCustomers TABLE 
	(
		intEntityCustomerId INT
	)

	INSERT INTO @tblExcludeCustomers
	(
		intEntityCustomerId
	)
	SELECT 
	DISTINCT tblCFInvoiceStagingTable.intCustomerId
	FROM tblCFInvoiceStagingTable 
	INNER JOIN tblCFTransaction ON tblCFTransaction.intTransactionId = tblCFInvoiceStagingTable.intTransactionId
	INNER JOIN tblCFNetwork ON tblCFNetwork.intNetworkId = tblCFTransaction.intNetworkId
	WHERE LOWER(tblCFTransaction.strTransactionType) = 'foreign sale'
	AND ISNULL(tblCFNetwork.ysnPostForeignSales,0) = 0
	AND LOWER(tblCFInvoiceStagingTable.strUserId) = LOWER(@UserId)

	DECLARE @intUserId INT
	SELECT TOP 1 @intUserId = intEntityId FROM tblSMUserSecurity WHERE strUserName = @UserId

	
	
	DECLARE @tblMainQuery TABLE 
	(
		 intRowId INT NULL
		,intEntityCustomerId INT NULL
		,strCustomerNumber	 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
		,strCustomerName	 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
		,dtmDate DATETIME NULL
		,dblCalcRunningBalance NUMERIC(18,6) NULL
		,dblTotalAR NUMERIC(18,6) NULL
		,strInvoiceReportNumber  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	)

	--dynamic sql due to ( ROWS are not supported in SSDT project )
	DECLARE @sqlString NVARCHAR(MAX)

	SET @sqlString = '
	SELECT  
	 ROW_NUMBER() OVER(PARTITION BY intEntityCustomerId ORDER BY intEntityCustomerId DESC) 
	,intEntityCustomerId 
	,strCustomerNumber	
	,strCustomerName	
	,dtmDate
	,dblCalcRunningBalance = SUM (CASE WHEN strTransactionType = ''Balance Forward'' 
											  THEN dblBalance - dblPayment 
											  ELSE ISNULL (dblInvoiceTotal, 0) - dblPayment END)
											  OVER (PARTITION BY intEntityCustomerId ORDER BY dtmDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
	,dblTotalAR
	,strCFTempInvoiceReportNumber
	FROM (SELECT *
	FROM tblARCustomerStatementStagingTable 
	WHERE strStatementFormat = ''Balance Forward'' AND intEntityUserId = ' + CAST(@intUserId as nvarchar(MAX)) + ') 
	as innerquery '


	INSERT INTO @tblMainQuery
	(
		 intRowId
		,intEntityCustomerId 
		,strCustomerNumber	
		,strCustomerName	
		,dtmDate
		,dblCalcRunningBalance
		,dblTotalAR
		,strInvoiceReportNumber
	)
	EXEC (@sqlString)


	DELETE FROM @tblMainQuery WHERE intEntityCustomerId IN (SELECT intEntityCustomerId FROM @tblExcludeCustomers)

	
	INSERT INTO tblCFInvoiceReportTotalValidation
	(
		 intEntityCustomerId
		,strCustomerNumber	
		,strCustomerName	
		,dblCFTotal
		,dblARTotal
		,dblDiff
		,dtmTransactionDate
		,strUserId
		,strStatementType
		,strErrorType
		,strTransactionId
	)
	SELECT  
		 mainQuery.intEntityCustomerId
		 ,strCustomerNumber	
		 ,strCustomerName	
		,dblCalcRunningBalance	
		,dblTotalAR	
		,ABS(ISNULL(dblCalcRunningBalance,0) - ISNULL(dblTotalAR,0))
		,mainQuery.dtmDate
		,@UserId
		,@StatementType	
		,'Running Balance <> AR'
		,strInvoiceReportNumber
	FROM (
			
			SELECT intEntityCustomerId, MAX(intRowId) as intLastRow
			FROM @tblMainQuery
			GROUP BY intEntityCustomerId
		) as innerQuery
	INNER JOIN @tblMainQuery as mainQuery
	ON mainQuery.intEntityCustomerId = innerQuery.intEntityCustomerId
	AND mainQuery.intRowId = innerQuery.intLastRow
	AND dblCalcRunningBalance != dblTotalAR


END
GO
