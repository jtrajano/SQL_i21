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

DECLARE  @strSalesCompanyLocation	NVARCHAR(250)	= NULL
		,@ysnActive					BIT = 0
		,@intCompanySegment			INT

SELECT 
	 @strSalesCompanyLocation	= strLocationName
	,@intProfitCenterId			= intProfitCenter
	,@intCompanySegment			= intCompanySegment
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intCompanyLocationId

SET @intAccountId = [dbo].[fnARGetInvoiceTypeAccount](@strTransactionType, @intCompanyLocationId)
SET @strAccountId	= [dbo].[fnGLGetOverrideAccountBySegment](
						 @intAccountId
						,@intProfitCenterId
						,NULL
						,@intCompanySegment
					  )

SELECT @ysnActive = ysnActive
FROM tblGLAccount WITH(NOLOCK)
WHERE strAccountId = @strAccountId

IF @ysnActive = 0
BEGIN
	SET @strErrorMsg = 'Default AR Account ' + @strAccountId + ' for company location ' + @strSalesCompanyLocation + ' is either not existing or inactive.'
	SET @intAccountId = NULL
	SET @strAccountId = NULL
END

IF EXISTS(SELECT TOP 1 ysnAllowSingleLocationEntries FROM tblARCompanyPreference WHERE ISNULL(ysnAllowSingleLocationEntries, 0) = 1)
BEGIN
	SELECT TOP 1 
		 @intLocationAccountSegmentId = intLocationAccountSegmentId
		,@intCompanyAccountSegmentId  = intCompanyAccountSegmentId 
	FROM vyuARAccountDetail 
	WHERE intAccountId = @intAccountId
END