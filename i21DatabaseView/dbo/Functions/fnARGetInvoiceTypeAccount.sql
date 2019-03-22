CREATE FUNCTION [dbo].[fnARGetInvoiceTypeAccount]
(
	 @TransactionType	NVARCHAR(25)
	,@CompanyLocationId	INT
)
RETURNS INT
AS
BEGIN
	DECLARE @ARAccountId INT
		, @ProfitCenterId INT

	SET @ARAccountId = NULL
	SET @ProfitCenterId = (SELECT TOP 1 intProfitCenter FROM tblSMCompanyLocation where intCompanyLocationId = @CompanyLocationId)

	IF @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
		SET @ARAccountId = (SELECT TOP 1 [intARAccountId] FROM tblARCompanyPreference WHERE [intARAccountId] IS NOT NULL AND intARAccountId <> 0)

	IF @TransactionType = 'Cash Refund'
		SET @ARAccountId = (SELECT TOP 1 [intAPAccount] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)

	IF @TransactionType = 'Cash'
		SET @ARAccountId = (SELECT TOP 1 [intUndepositedFundsId] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)
		
	IF @TransactionType = 'Customer Prepayment'
		SET @ARAccountId = (SELECT TOP 1 [intSalesAdvAcct] FROM tblSMCompanyLocation WHERE [intCompanyLocationId] = @CompanyLocationId)
		
	SET @ARAccountId = ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](@ARAccountId, @ProfitCenterId), @ARAccountId)

	RETURN @ARAccountId
END