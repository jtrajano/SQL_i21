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

DECLARE  @strSalesCompanyLocation			NVARCHAR(250)	= NULL
		,@ysnActive							BIT = 0
		,@intCompanySegment					INT
		,@OverrideARAccountCompanySegment	BIT
		,@OverrideARAccountLocationSegment	BIT
		,@intCompanyARAccountId				INT				= NULL

SELECT 
	 @strSalesCompanyLocation	= strLocationName
	,@intProfitCenterId			= intProfitCenter
	,@intCompanySegment			= intCompanySegment
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intCompanyLocationId

SELECT TOP 1 
	 @intCompanyARAccountId				= [intARAccountId]
	,@OverrideARAccountCompanySegment	= ysnOverrideARAccountCompanySegment
	,@OverrideARAccountLocationSegment	= ysnOverrideARAccountLocationSegment
FROM tblARCompanyPreference 

SET @intAccountId = [dbo].[fnARGetInvoiceTypeAccount](@strTransactionType, @intCompanyLocationId)

IF (@OverrideARAccountLocationSegment = 1 AND ISNULL(@intProfitCenterId, 0) > 0) OR (@OverrideARAccountCompanySegment = 1 AND ISNULL(@intCompanySegment, 0) > 0)
BEGIN
	SET @strAccountId = [dbo].[fnGLGetOverrideAccountBySegment](
						 @intAccountId
						,CASE WHEN @OverrideARAccountLocationSegment = 1 THEN @intProfitCenterId ELSE NULL END
						,NULL
						,CASE WHEN @OverrideARAccountCompanySegment = 1 THEN @intCompanySegment ELSE NULL END
					  )

	SELECT TOP 1
		 @ysnActive		= ysnActive
		,@strAccountId	= strAccountId
		,@intAccountId	= intAccountId
	FROM tblGLAccount WITH(NOLOCK)
	WHERE strAccountId = @strAccountId
END
ELSE
BEGIN
	SELECT TOP 1
		 @ysnActive		= ysnActive
		,@strAccountId	= strAccountId
	FROM tblGLAccount WITH(NOLOCK)
	WHERE intAccountId = @intAccountId
END

IF @ysnActive = 0
BEGIN
	SET @strErrorMsg = 'Default AR Account ' + @strAccountId + ' for company location ' + @strSalesCompanyLocation + ' is either not existing or inactive.'

	SELECT TOP 1
		 @intAccountId = intAccountId
		,@strAccountId = strAccountId
	FROM tblGLAccount WITH(NOLOCK)
	WHERE intAccountId = @intCompanyARAccountId 
	AND ysnActive = 1

	IF (@OverrideARAccountLocationSegment = 1 AND ISNULL(@intProfitCenterId, 0) > 0) OR (@OverrideARAccountCompanySegment = 1 AND ISNULL(@intCompanySegment, 0) > 0)
	BEGIN
		SET @strAccountId = [dbo].[fnGLGetOverrideAccountBySegment](
							 @intAccountId
							,CASE WHEN @OverrideARAccountLocationSegment = 1 THEN @intProfitCenterId ELSE NULL END
							,NULL
							,CASE WHEN @OverrideARAccountCompanySegment = 1 THEN @intCompanySegment ELSE NULL END
						  )

		SELECT TOP 1
			 @strAccountId	= strAccountId
			,@intAccountId	= intAccountId
		FROM tblGLAccount WITH(NOLOCK)
		WHERE strAccountId = @strAccountId
	END
END

IF EXISTS(SELECT TOP 1 ysnAllowSingleLocationEntries FROM tblARCompanyPreference WHERE ISNULL(ysnAllowSingleLocationEntries, 0) = 1)
BEGIN
	SELECT TOP 1 
		 @intLocationAccountSegmentId = intLocationAccountSegmentId
		,@intCompanyAccountSegmentId  = intCompanyAccountSegmentId 
	FROM vyuARAccountDetail 
	WHERE intAccountId = @intAccountId
END