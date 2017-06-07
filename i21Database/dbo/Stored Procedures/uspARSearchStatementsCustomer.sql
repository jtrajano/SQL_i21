CREATE PROCEDURE [dbo].[uspARSearchStatementsCustomer]
(
	@strStatementFormat NVARCHAR(50)
)
AS

DECLARE @tmpstrStatementFormat NVARCHAR(50)
SET @tmpstrStatementFormat = @strStatementFormat

SELECT 
	ARC.[intEntityId],
	ARC.strCustomerNumber,
	strCustomerName		=	EM.strName 
FROM
	(SELECT 
		[intEntityId], 
		strCustomerNumber 
	 FROM 
		tblARCustomer
	 WHERE ysnActive = 1
		AND strStatementFormat =  @strStatementFormat) ARC
INNER JOIN 
	(SELECT 
		intEntityId, 
		strName 
	 FROM 
		tblEMEntity) EM ON ARC.[intEntityId] = EM.intEntityId