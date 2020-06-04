CREATE PROCEDURE [dbo].[uspARGetDefaultAccount]
	  @strTransactionType		NVARCHAR(25)
	, @intCompanyLocationId		INT
	, @intAccountId				INT				= NULL OUTPUT
	, @strAccountId				NVARCHAR(250)	= NULL OUTPUT
	, @strErrorMsg				NVARCHAR(250)	= NULL OUTPUT
AS	

DECLARE @intARAccountId 			INT = NULL
	  , @intProfitCenterId			INT = NULL
      , @strSalesCompanyLocation	NVARCHAR(250)	= NULL

SET @intARAccountId = [dbo].[fnARGetInvoiceTypeAccount](@strTransactionType, @intCompanyLocationId)

SELECT @strSalesCompanyLocation = strLocationName
	 , @intProfitCenterId		= intProfitCenter
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intCompanyLocationId

SELECT @strErrorMsg = 'Default AR Account ' + strAccountId + ' for company location ' + @strSalesCompanyLocation + ' is inactive.'
FROM tblGLAccount WITH(NOLOCK)
WHERE intAccountId = [dbo].[fnGetGLAccountIdFromProfitCenter](@intARAccountId, @intProfitCenterId)
  AND ysnActive = 0

IF ISNULL(@strErrorMsg,'') <> ''
	BEGIN
		SELECT TOP 1 @intARAccountId = CASE WHEN @strTransactionType = 'Cash Refund' THEN intAPAccount
											WHEN @strTransactionType = 'Cash' THEN intUndepositedFundsId
											WHEN @strTransactionType = 'Customer Prepayment' THEN intSalesAdvAcct
											ELSE intARAccount
									   END
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @intCompanyLocationId
		
		IF @intARAccountId IS NULL AND @strTransactionType NOT IN ('Customer Prepayment', 'Cash', 'Cash Refund')
			SET @intARAccountId = (SELECT TOP 1 [intARAccountId] FROM tblARCompanyPreference WHERE [intARAccountId] IS NOT NULL AND intARAccountId <> 0)		
	END

SELECT @intAccountId	= intAccountId
	 , @strAccountId	= strAccountId
FROM tblGLAccount WITH(NOLOCK) 
WHERE intAccountId  = @intARAccountId