CREATE PROCEDURE [dbo].[uspCFInvoiceReportBalanceValidation](
	 @UserId NVARCHAR(MAX)
)
AS
BEGIN

	DECLARE @intUserId INT
	SELECT TOP 1 @intUserId = intEntityId FROM tblSMUserSecurity WHERE strUserName = @UserId

	
	SET NOCOUNT ON;
	
	DECLARE @tblMainQuery TABLE 
	(
		 intEntityCustomerId INT NULL
		,strCustomerNumber	 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
		,strCustomerName	 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
		,dtmDate DATETIME NULL
		,dblCalcRunningBalance NUMERIC(18,6) NULL
		,dblTotalAR NUMERIC(18,6) NULL
	)


	INSERT INTO @tblMainQuery
	(
		 intEntityCustomerId 
		,strCustomerNumber	
		,strCustomerName	
		,dtmDate
		,dblCalcRunningBalance
		,dblTotalAR
	)
	SELECT  
	 intEntityCustomerId 
	,strCustomerNumber	
	,strCustomerName	
	,dtmDate
	,dblCalcRunningBalance = SUM (CASE WHEN strTransactionType = 'Balance Forward' 
											  THEN dblBalance - dblPayment 
											  ELSE ISNULL (dblInvoiceTotal, 0) - dblPayment END)
											  OVER (PARTITION BY intEntityCustomerId ORDER BY dtmDate ROWS
											 BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
	,dblTotalAR
	FROM (SELECT *
	FROM tblARCustomerStatementStagingTable 
	WHERE strStatementFormat = 'Balance Forward' AND intEntityUserId = @intUserId) 
	as innerquery 


	
	INSERT INTO tblCFInvoiceReportBalanceValidation
	(
		 intEntityCustomerId
		,strCustomerNumber	
		,strCustomerName	
		,dblRunningBalance
		,dblAREndingBalance
		,dblDiff
		,dtmDate
		,strUserId
		,strStatementType
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
		,'invoice'	
	FROM (
			SELECT intEntityCustomerId , MAX(dtmDate) as dtmDate 
			FROM @tblMainQuery
			GROUP BY intEntityCustomerId
		) as innerQuery
	INNER JOIN @tblMainQuery as mainQuery
	ON mainQuery.intEntityCustomerId = innerQuery.intEntityCustomerId
	AND mainQuery.dtmDate = innerQuery.dtmDate
	AND dblCalcRunningBalance != dblTotalAR


	





END


