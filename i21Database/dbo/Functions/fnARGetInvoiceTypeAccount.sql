CREATE FUNCTION [dbo].[fnARGetInvoiceTypeAccount]
(
	 @TransactionType	NVARCHAR(25)
	,@CompanyLocationId	INT
)
RETURNS INT
AS
BEGIN
	DECLARE 
		 @intARAccountId 	INT = NULL
		,@strARAccountId	NVARCHAR (40)

	SELECT TOP 1 
		 @intARAccountId	= CASE @TransactionType WHEN 'Cash Refund' THEN intAPAccount
								WHEN 'Cash' THEN intUndepositedFundsId
								WHEN 'Customer Prepayment' THEN intSalesAdvAcct
								ELSE intARAccount
							  END
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @CompanyLocationId

	IF @intARAccountId IS NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
		SELECT TOP 1 @intARAccountId = [intARAccountId] FROM tblARCompanyPreference WHERE [intARAccountId] IS NOT NULL AND intARAccountId <> 0

	RETURN @intARAccountId
END