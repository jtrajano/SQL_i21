CREATE PROCEDURE [dbo].[uspNRReportAgedNotes]
@AgingDate Datetime= NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @AgingDate IS NULL
	SET @AgingDate=GETDATE()

	DECLARE @tbl AS TABLE (intCustomerId Int, strCustomerNumber NVARCHAR(20), strName nvarchar(100) , strAddress nvarchar(100)
							, strPhone nvarchar(50), strCity  NVARCHAR(100), strState NVARCHAR(100),strZipCode  NVARCHAR(100)
							, strCountry nvarchar(100))
							
	INSERT INTO @tbl 
	SELECT  Cus.[intEntityCustomerId]
	,Cus.strCustomerNumber
	,Entity.strName
	,Loc.strAddress
	,Con.strPhone
	,Loc.strCity
	,Loc.strState
	,Loc.strZipCode 
	,Loc.strCountry
	FROM tblEntity as Entity
	INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]
	INNER JOIN tblARCustomerToContact as CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
	LEFT JOIN tblEntityContact as Con ON CusToCon.[intEntityContactId] = Con.[intEntityContactId]
	LEFT JOIN tblEntityLocation as Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
	
	
	SELECT cus.strCustomerNumber AS [Customer Number]
	, Rtrim(strName) AS [Customer Name]
	, N.strNoteNumber AS [Note Number]	, N.dblCreditLimit [Credit Limit]
	, (Select ISNULL(SUM(dblExpectedPayAmt),0) from dbo.tblNRScheduleTransaction Where intNoteId = N.intNoteId AND (dtmExpectedPayDate Between DATEADD(d,-30,@AgingDate) AND @AgingDate) AND dblPayAmt=0) AS [Current]
	, (Select ISNULL(SUM(dblExpectedPayAmt),0) from dbo.tblNRScheduleTransaction Where intNoteId = N.intNoteId AND dtmExpectedPayDate Between DATEADD(d,-60,@AgingDate) AND DATEADD(d,-31,@AgingDate) AND dblPayAmt=0) AS [31-60 Days]
	, (Select ISNULL(SUM(dblExpectedPayAmt),0) from dbo.tblNRScheduleTransaction Where intNoteId = N.intNoteId AND dtmExpectedPayDate Between DATEADD(d,-90,@AgingDate) AND DATEADD(d,-61,@AgingDate) AND dblPayAmt=0) AS [61-90 Days]
	, (Select ISNULL(SUM(dblExpectedPayAmt),0) from dbo.tblNRScheduleTransaction Where intNoteId = N.intNoteId AND dtmExpectedPayDate Between DATEADD(d,-120,@AgingDate) AND DATEADD(d,-91,@AgingDate) AND dblPayAmt=0) AS [91-120 Days]
	, (Select ISNULL(SUM(dblExpectedPayAmt),0) from dbo.tblNRScheduleTransaction Where intNoteId = N.intNoteId AND dtmExpectedPayDate < DATEADD(d,-121,@AgingDate) AND dblPayAmt=0) AS [Over 120]
	FROM @tbl cus
	JOIN dbo.tblNRNote N ON N.intCustomerId = cus.intCustomerId
	--WHERE N.strNoteType = 'Scheduled Invoice'
	
END
