CREATE FUNCTION [dbo].[fnARGetInvoiceTypeAccount]
(
	 @TransactionType	NVARCHAR(25)
	,@CompanyLocationId	INT
)
RETURNS INT
AS
BEGIN
	DECLARE 
		 @intCompanySegment	INT = NULL
		,@intARAccountId 	INT = NULL
		,@intProfitCenterId	INT = NULL
		,@strARAccountId	NVARCHAR (40)

	SELECT TOP 1 
		 @intARAccountId	= CASE @TransactionType WHEN 'Cash Refund' THEN intAPAccount
								WHEN 'Cash' THEN intUndepositedFundsId
								WHEN 'Customer Prepayment' THEN intSalesAdvAcct
								ELSE intARAccount
							  END
		,@intProfitCenterId	= intProfitCenter
		,@intCompanySegment	= intCompanySegment
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @CompanyLocationId

	IF @intARAccountId IS NULL AND @TransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
		SELECT TOP 1 @intARAccountId = [intARAccountId] FROM tblARCompanyPreference WHERE [intARAccountId] IS NOT NULL AND intARAccountId <> 0
	
	SET @strARAccountId = [dbo].[fnGLGetOverrideAccountBySegment](
						 @intARAccountId
						,@intProfitCenterId
						,NULL
						,@intCompanySegment
					  )

	SELECT @intARAccountId = intAccountId
	FROM tblGLAccount WITH(NOLOCK)
	WHERE strAccountId = @strARAccountId
	OR (ISNULL(@strARAccountId, '') = '' AND intAccountId = @intARAccountId)

	RETURN @intARAccountId
END