CREATE PROCEDURE [dbo].[uspARGetDefaultAccount]
	 @strTransactionType			NVARCHAR(25)
	,@intCompanyLocationId			INT
	,@intAccountId					INT				= NULL OUTPUT
	,@strAccountId					NVARCHAR(250)	= NULL OUTPUT
	,@strErrorMsg					NVARCHAR(250)	= NULL OUTPUT
	,@intLocationAccountSegmentId	INT				= NULL OUTPUT
	,@intCompanyAccountSegmentId	INT				= NULL OUTPUT
	,@intProfitCenterId				INT				= NULL OUTPUT
AS	

DECLARE  @intCompanySegment			INT
		,@intARAccountId 			INT = NULL
		,@strARAccountId			NVARCHAR (40)
		,@strSalesCompanyLocation	NVARCHAR(250)	= NULL
		,@ysnActive					BIT = 0

SELECT 
	 @strSalesCompanyLocation	= strLocationName
	,@intProfitCenterId			= intProfitCenter
	,@intCompanySegment			= intCompanySegment
	,@intARAccountId			= intARAccount
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intCompanyLocationId

SET @strARAccountId = [dbo].[fnGLGetOverrideAccountBySegment](
						 [dbo].[fnARGetInvoiceTypeAccount](@strTransactionType, @intCompanyLocationId)
						,@intProfitCenterId
						,NULL
						,@intCompanySegment
					  )

SELECT
	 @intARAccountId= intAccountId
	,@strARAccountId=strAccountId
	,@ysnActive		= ysnActive
FROM tblGLAccount WITH(NOLOCK)
WHERE strAccountId = @strARAccountId
OR (@strARAccountId IS NULL AND intAccountId = @intARAccountId)

IF @ysnActive = 0
	SET @strErrorMsg = 'Default AR Account ' + @strARAccountId + ' for company location ' + @strSalesCompanyLocation + ' is inactive.'

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
		
	SET @intARAccountId = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE intAccountId = @intARAccountId AND ysnActive = 1)
END

SELECT @intAccountId	= intAccountId
	 , @strAccountId	= strAccountId
FROM tblGLAccount WITH(NOLOCK) 
WHERE intAccountId  = @intARAccountId

IF EXISTS(SELECT TOP 1 ysnAllowSingleLocationEntries FROM tblARCompanyPreference WHERE ISNULL(ysnAllowSingleLocationEntries, 0) = 1)
BEGIN
	SELECT TOP 1 
		 @intLocationAccountSegmentId = intLocationAccountSegmentId
		,@intCompanyAccountSegmentId  = intCompanyAccountSegmentId 
	FROM vyuARAccountDetail 
	WHERE intAccountId = @intARAccountId
END