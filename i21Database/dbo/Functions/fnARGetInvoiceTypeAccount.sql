CREATE FUNCTION [dbo].[fnARGetInvoiceTypeAccount]
(
	 @TransactionType	NVARCHAR(25)
	,@CompanyLocationId	INT
)
RETURNS INT
AS
BEGIN

	DECLARE @ARAccountId INT
	SET @ARAccountId = NULL

	IF @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
		SET @ARAccountId = (SELECT TOP 1 [intARAccountId] FROM tblARCompanyPreference WHERE [intARAccountId] IS NOT NULL AND intARAccountId <> 0)

	IF @TransactionType IN ('Cash', 'Cash Refund')
		SET @ARAccountId = (SELECT TOP 1 [intUndepositedFundsId] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)
		
	IF @TransactionType = 'Customer Prepayment'
		SET @ARAccountId = (SELECT TOP 1 [intSalesAdvAcct] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)

	RETURN @ARAccountId
END
