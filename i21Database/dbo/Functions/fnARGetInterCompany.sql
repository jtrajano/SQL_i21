CREATE FUNCTION [dbo].[fnARGetInterCompany]
(
	@intInvoiceId INT = NULL
)
RETURNS @returntable TABLE
(
	strDatabaseName NVARCHAR(50) NOT NULL,
	strCompanyName	NVARCHAR(50) NOT NULL
)
AS
BEGIN
	DECLARE @strDatabaseName NVARCHAR(50)

	INSERT INTO @returntable(strDatabaseName, strCompanyName)
	SELECT strDatabaseName, strCompanyName
	FROM tblARInvoice I
	INNER JOIN tblARCustomer C
	ON I.intEntityCustomerId = C.intEntityId
	INNER JOIN tblSMInterCompany IC
	ON C.intInterCompanyId = IC.intInterCompanyId
	WHERE I.intInvoiceId = @intInvoiceId
	
	RETURN
END
