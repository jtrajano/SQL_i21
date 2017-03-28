CREATE PROCEDURE [dbo].[uspARGetStatementsCustomer]
AS
	SELECT 
		* 
	FROM 
		tblARSearchStatementCustomer WITH (NOLOCK)  
	ORDER BY 
		tblARSearchStatementCustomer.strCustomerNumber
GO


