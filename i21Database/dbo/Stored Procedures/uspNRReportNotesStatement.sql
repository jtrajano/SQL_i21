CREATE PROCEDURE [dbo].[uspNRReportNotesStatement]
 @intStartCusNo Int
,@intEndCusNo Int
,@dtmStartDate DateTime
,@dtmEndDate DateTime
AS
BEGIN
--SET @intStartCusNo = 1
--SET @intEndCusNo = 5
--SET @dtmStartDate = '2014-09-19 21:49:15.607'
--SET @dtmEndDate = '2015-01-19 21:49:15.607'
----select GETDATE()

	DECLARE @tbl AS TABLE (intCustomerId Int, strCustomerNumber NVARCHAR(20), strName nvarchar(100) , strAddress nvarchar(100)
							, strPhone nvarchar(50), strCity  NVARCHAR(100), strState NVARCHAR(100),strZipCode  NVARCHAR(100))
							
	INSERT INTO @tbl 
	SELECT  Cus.intCustomerId
	,Cus.strCustomerNumber
	,Entity.strName
	,Loc.strAddress
	,Con.strPhone
	,Loc.strCity
	,Loc.strState
	,Loc.strZipCode 
	FROM tblEntity as Entity
	INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.intEntityId
	INNER JOIN tblARCustomerToContact as CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
	LEFT JOIN tblEntityContact as Con ON CusToCon.intContactId = Con.intContactId
	LEFT JOIN tblEntityLocation as Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
	WHERE Cus.intCustomerId Between @intStartCusNo AND @intEndCusNo

	--select * from @tbl

	SELECT  a.intCustomerId, CUS.strCustomerNumber as 'Customer Number', ISNULL (CUS.strName,'') as 'Customer Name'
	,ISNULL (CUS.strAddress,'') as 'Address', ISNULL (CUS.strCity,'')  +','+ '  '+ ISNULL (CUS.strState,'')  +'  '+ ISNULL (CUS.strZipCode,'') as 'Address2'
	, a.strNoteNumber as 'Note Number', a.dblCreditLimit as 'Credit Limit', a.dblInterestRate as 'Interest Rate'
	, a.dtmMaturityDate as 'Maturity Date',@dtmStartDate As 'Start Date', @dtmEndDate As 'End Date'
	,a.[As Of] as 'As Of', a.[History Date] as 'History Date',a.[History Type] as 'History Type'
	,a.[Amount]As 'Amount', a.intTransDays as 'Days', a.[Interest] As 'Interest', a.dblPrincipal as 'Principal'
	, a.PayOffBalance,a.[HISTORY ID],a.[Interest Since Last Transaction] 
	,a.[Int Adj], a.[Tot Int], a.[Amt App Int]
	 FROM 
	 (
	SELECT N.intCustomerId, N.strNoteNumber, N.dblCreditLimit, N.dblInterestRate, N.dtmMaturityDate
	,@dtmStartDate As 'Start Date', @dtmEndDate As 'End Date'
	,CAST(CONVERT(NVARCHAR(10),NT.dtmAsOfDate,101)AS DateTime)as 'As Of'
	,CAST(CONVERT(NVARCHAR(10),NT.dtmNoteTranDate,101)AS DateTime)AS 'History Date' 
	,CASE WHEN NT.intNoteTransTypeId=7 
			THEN ISNULL((SELECT top 1 AT.strAdjShowAs  FROM dbo.tblNRNoteTransaction trans JOIN dbo.tblNRAdjustmentType AT ON trans.intAdjTypeId = AT.intAdjTypeId  
				WHERE intNoteId =NT.intNoteId AND NT.intNoteTransTypeId=7  AND intNoteTransId =NT.intNoteTransId AND dtmAsOfDate = NT.dtmAsOfDate),NTT.strNoteTransTypeName)    
		ELSE NTT.strNoteTransTypeName END as 'History Type' 
	,CASE WHEN NT.intNoteTransTypeId = 4 
			THEN NT.dblTransAmount * (-1) 
		WHEN NT.intNoteTransTypeId = 1 
			THEN (SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND dtmAsOfDate = NT.dtmAsOfDate) 
		ELSE NT.dblTransAmount END As 'Amount'
	, NT.intTransDays
	, NT.dblInterestToDate As 'Interest', NT.dblPrincipal,
	CASE
		When NT.intNoteTransTypeId =7 AND strAdjOnPrincOrInt = 'Principal' then ISNULL(NT.dblPayOffBalance,0)
		WHEN NT.intNoteTransTypeId =7 AND strAdjOnPrincOrInt = 'Interest' AND NT.dblTransAmount <0 AND NT.dblPrincipal =0 
			THEN ISNULL(NT.dblPayOffBalance,0)
		WHEN NT.intNoteTransTypeId <> 3 
			THEN ISNULL(NT.dblPayOffBalance,0)  
		WHEN NT.intNoteTransTypeId =3  AND NT.dblPayOffBalance <>0  AND NT.dblPrincipal <> 0 
			THEN ISNULL (NT.dblPrincipal,0)  
			+ ISNULL ((SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest'
				AND CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime) <= (CAST(CONVERT(NVARCHAR(10),NT.dtmAsOfDate,101)AS DateTime))),0)
			+ ISNULL ((SELECT SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId 
				AND CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime) <= (CAST(CONVERT(NVARCHAR(10),NT.dtmAsOfDate,101)AS DateTime))),0) 
		WHEN NT.intNoteTransTypeId =3  AND NT.dblPayOffBalance <>0  AND NT.dblPrincipal = 0 
			THEN  ISNULL ((SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId = 7 
				AND strAdjOnPrincOrInt = 'Interest'AND CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime) <= (CAST(CONVERT(NVARCHAR(10),NT.dtmAsOfDate,101)AS DateTime))),0)
			+ ISNULL ((SELECT SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId 
				AND CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime) <= (CAST(CONVERT(NVARCHAR(10),NT.dtmAsOfDate,101)AS DateTime))),0)
			- ISNULL((SELECT SUM(round(dblAmtAppToInterest,2)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId  AND intNoteTransTypeId = 4),0)
		When  NT.dblPayOffBalance =0  
			THEN ISNULL (NT.dblPayOffBalance,0)
		When NT.dblPrincipal =0   
			THEN (ISNULL((SELECT SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId  AND NT.intNoteTransTypeId=3),0)
			+ ISNULL((SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest' ),0)  
			- ISNULL((SELECT SUM(round(dblAmtAppToInterest,2)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId  AND intNoteTransTypeId = 4),0))
		ELSE ISNULL (NT.dblPrincipal,0)  
			+ ISNULL((SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest'),0) 
			+ ISNULL ((SELECT SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId),0)
			- ISNULL((SELECT SUM(round(dblAmtAppToInterest,2)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId  AND intNoteTransTypeId = 4),0)
		END as 'PayOffBalance'
	, NT.intNoteTransId AS 'HISTORY ID'
	,(SELECT TOP 1 dblInterestToDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND  dtmAsOfDate = NT.dtmAsOfDate AND intNoteTransId=NT.intNoteTransId 
		ORDER BY intNoteTransId DESC) AS 'Interest Since Last Transaction'
	, ISNULL ((SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest'),0) 
		AS 'Int Adj' 
	, ISNULL ((SELECT SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId ),0) AS 'Tot Int'
	, ISNULL((SELECT SUM(round(dblAmtAppToInterest,2)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId  AND intNoteTransTypeId = 4),0) AS 'Amt App Int'
	FROM dbo.tblNRNote N
	JOIN dbo.tblNRNoteTransaction NT ON NT.intNoteId = N.intNoteId AND  (NT.intNoteTransTypeId<>1)
	JOIN dbo.tblNRNoteTransType NTT ON NTT.intNoteTransTypeId = NT.intNoteTransTypeId
	WHERE N.ysnWriteOff = 0 --AND N.NRNOT_PRINCIPAL > 0 
	AND  N.intCustomerId >= @intStartCusNo AND N.intCustomerId <= @intEndCusNo
	AND NT.dtmAsOfDate BETWEEN @dtmStartDate AND @dtmEndDate

	UNION

	SELECT distinct N.intCustomerId, N.strNoteNumber, N.dblCreditLimit, N.dblInterestRate, N.dtmMaturityDate
	,@dtmStartDate As 'Start Date', @dtmEndDate As 'End Date'
	,CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
			AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
		THEN (SELECT TOP 1 CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime)AS 'As Of'  FROM dbo.tblNRNoteTransaction  WHERE intNoteTransTypeId =1 AND intNoteId =NT.intNoteId 
			AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101)  
			ORDER BY intNoteTransId DESC)
		ELSE (SELECT TOP 1 CAST(CONVERT(NVARCHAR(10),dtmAsOfDate,101)AS DateTime)as 'As Of'  FROM dbo.tblNRNoteTransaction  WHERE intNoteTransTypeId =1 AND intNoteId =NT.intNoteId 
			AND  dtmAsOfDate = NT.dtmAsOfDate ORDER BY intNoteTransId DESC)
	 END  AS 'AsOf'
	,CASE WHEN dtmNoteTranDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmNoteTranDate)-1),NT.dtmNoteTranDate),101) 
			AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmNoteTranDate))),DATEADD(mm,1,NT.dtmNoteTranDate)),101) 
		THEN(select top 1 CAST(CONVERT(NVARCHAR(10),dtmNoteTranDate,101)AS DateTime)as 'HistoryDate'  FROM dbo.tblNRNoteTransaction  WHERE intNoteTransTypeId =1 
				AND intNoteId =NT.intNoteId AND dtmNoteTranDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmNoteTranDate)-1),NT.dtmNoteTranDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmNoteTranDate))),DATEADD(mm,1,NT.dtmNoteTranDate)),101)  
				ORDER BY intNoteTransId DESC)
		ELSE (select top 1 CAST(CONVERT(NVARCHAR(10),NT.dtmNoteTranDate,101)AS DateTime)as 'HistoryDate' FROM dbo.tblNRNoteTransaction  WHERE intNoteTransTypeId =1 
				AND intNoteId =NT.intNoteId  AND  dtmNoteTranDate = NT.dtmNoteTranDate ORDER BY intNoteTransId DESC)
	 END AS 'HistoryDate'
	,NTT.strNoteTransTypeName  
	,CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
			THEN (SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction	WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId=NT.intNoteTransTypeId 
				AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) ) 
		ELSE (SELECT SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = NT.intNoteId AND intNoteTransTypeId=NT.intNoteTransTypeId 
				AND  dtmAsOfDate = NT.dtmAsOfDate)
	  END As 'Amount'
	, DATEDIFF( d, CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101)
		, CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) ) As 'Days'
	, (SELECT TOP 1 dblInterestToDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = N.intNoteId AND intNoteTransTypeId = 1 
		ORDER BY intNoteTransId DESC) AS 'InterestToDate'
	, CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
			THEN (SELECT TOP 1 dblPrincipal FROM dbo.tblNRNoteTransaction WHERE intNoteId = N.intNoteId AND intNoteTransTypeId = 1  
				AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101)  
				ORDER BY intNoteTransId DESC)
		ELSE(SELECT TOP 1 dblPrincipal FROM dbo.tblNRNoteTransaction WHERE intNoteId = N.intNoteId AND intNoteTransTypeId = 1 
				AND  dtmAsOfDate = NT.dtmAsOfDate ORDER BY intNoteTransId DESC)
	  END AS 'Principal'
	, CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
			THEN (SELECT top 1 dblPayOffBalance FROM dbo.tblNRNoteTransaction WHERE intNoteId = N.intNoteId AND intNoteTransTypeId = 1 
				AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
				ORDER BY intNoteTransId DESC) 
		ELSE (SELECT top 1 dblPayOffBalance FROM dbo.tblNRNoteTransaction WHERE intNoteId = N.intNoteId AND intNoteTransTypeId = 1 
				AND  dtmAsOfDate = NT.dtmAsOfDate  ORDER BY intNoteTransId DESC)
	  END as 'PayOffBalance'
	, CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
			THEN (SELECT TOP 1 intNoteTransId FROM dbo.tblNRNoteTransaction WHERE intNoteId =N.intNoteId AND intNoteTransTypeId =1 
				AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101))
		ELSE (SELECT TOP 1 intNoteTransId FROM dbo.tblNRNoteTransaction WHERE intNoteId =N.intNoteId AND intNoteTransTypeId =1 
				AND  dtmAsOfDate = NT.dtmAsOfDate )
	  END AS 'HISTORY ID'
	, CASE WHEN dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101) 
		THEN (Select top 1 dblInterestToDate FROM dbo.tblNRNoteTransaction WHERE intNoteId =NT.intNoteId AND intNoteTransTypeId =1 
				AND dtmAsOfDate BETWEEN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(NT.dtmAsOfDate)-1),NT.dtmAsOfDate),101) 
				AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,NT.dtmAsOfDate))),DATEADD(mm,1,NT.dtmAsOfDate)),101)ORDER BY intNoteTransId DESC)
		ELSE (Select top 1 dblInterestToDate FROM dbo.tblNRNoteTransaction WHERE intNoteId =NT.intNoteId AND intNoteTransTypeId =1 
				AND  dtmAsOfDate = NT.dtmAsOfDate ORDER BY intNoteTransId DESC)
	  END AS 'Interest Since Last Transaction'
	,0 as 'Int Adj'
	,0 as 'Tot Int'
	,0 as 'Amt App Int'
	FROM dbo.tblNRNote N
	JOIN dbo.tblNRNoteTransaction NT ON NT.intNoteId = N.intNoteId AND (NT.intNoteTransTypeId=1 )
	JOIN dbo.tblNRNoteTransType NTT ON NTT.intNoteTransTypeId = NT.intNoteTransTypeId
	WHERE N.ysnWriteOff = 0 --AND N.NRNOT_PRINCIPAL > 0 
	AND  N.intCustomerId >= @intStartCusNo AND N.intCustomerId <= @intEndCusNo
	AND NT.dtmAsOfDate BETWEEN @dtmStartDate AND @dtmEndDate

	) a JOIN @tbl CUS ON CUS.intCustomerId = a.intCustomerId -- COLLATE DATABASE_DEFAULT  = a.intCustomerId COLLATE DATABASE_DEFAULT 
	ORDER BY a.[HISTORY ID] ASC

END
