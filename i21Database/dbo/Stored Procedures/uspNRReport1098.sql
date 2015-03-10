CREATE PROCEDURE [dbo].[uspNRReport1098]
AS
BEGIN
	DECLARE  @1098Year Char(4) = '2015'

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
	
	DECLARE @StartDate AS DateTime, @EndDate AS DateTime
	SET @StartDate = CAST('01/01/' + @1098Year as Datetime)
	SET @EndDate = CAST('12/31/' + @1098Year as Datetime)
	
	print @StartDate
	Print @EndDate
	
	SELECT 
	@1098Year AS 'Year' 
	, ( SELECT [strCompanyName] FROM [tblSMCompanySetup]) AS [Recipient]
	, ( SELECT ISNULL(strAddress,'') + CHAR(13) + ISNULL(strCity,'') 
		+ CHAR(13) + ISNULL(strState,'') + CHAR(13) + ISNULL(strCountry,'') 
		+ CHAR(13) + ISNULL(strZip, '') FROM dbo.tblSMCompanySetup) AS [Recipient Address]
	--, '409 NORTH MAIN STREET' + CHAR(13) + 'BLUFFTON' + CHAR(13) + '46714' + CHAR(13) + 'IN' AS [Recipient Address]
	, rtrim(cus.strName) AS [Borrower's Name]
	, ISNULL(strAddress,'') AS [Street Address]
	, cus.strCity AS [City]
	, cus.strState AS [State]
	, cus.strCountry AS [Country]
	, cus.strZipCode AS [Zip]
	, N.strNoteNumber AS [Note Number]
	, (SELECT SUM(dblInterest) FROM dbo.tblNRScheduleTransaction 
	WHERE dtmPaidOn BETWEEN @StartDate AND @EndDate AND intNoteId = N.intNoteId
	) AS [Interest Received]
	FROM @tbl cus
	JOIN dbo.tblNRNote N ON N.intCustomerId = cus.intCustomerId
	WHERE N.strNoteType = 'Scheduled Invoice'

END