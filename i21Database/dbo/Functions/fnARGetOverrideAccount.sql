CREATE FUNCTION dbo.[fnARGetOverrideAccount]
(
	 @intSegmentTypeId			INT
	,@intAccountIdUseToOverride	INT
	,@intAccountIdToBeOverriden	INT
)
RETURNS @returntable TABLE
(
	 [strOverrideAccount]	NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	,[intOverrideAccount]   INT
	,[bitSameLocation]		BIT
)
AS
BEGIN
	DECLARE  @strOverrideAccount				NVARCHAR(40)
			,@intOverrideAccount				INT			= 0
			,@strAccountIdToBeOverriden			NVARCHAR(40)
			,@bitSameLocation					BIT			= 0
			,@intAccountSegmentIdToBeOverriden	INT

	SELECT 
		 @strAccountIdToBeOverriden			= strAccountId
		,@intAccountSegmentIdToBeOverriden	= intAccountSegmentId
	FROM vyuGLSegmentMapping
	WHERE intAccountId = @intAccountIdToBeOverriden
	AND intSegmentTypeId = @intSegmentTypeId


	SELECT 
		 @strOverrideAccount= dbo.[fnGLGetOverrideAccount](@intSegmentTypeId, strAccountId, @strAccountIdToBeOverriden)
		,@bitSameLocation	= CASE WHEN @intAccountSegmentIdToBeOverriden = intAccountSegmentId THEN 1 ELSE 0 END
	FROM vyuGLSegmentMapping
	WHERE intAccountId = @intAccountIdUseToOverride
	AND intSegmentTypeId = @intSegmentTypeId

	SELECT TOP 1 @intOverrideAccount = intAccountId
	FROM tblGLAccount
	WHERE strAccountId = @strOverrideAccount

	INSERT INTO @returntable
	SELECT @strOverrideAccount, @intOverrideAccount, @bitSameLocation

	RETURN
END