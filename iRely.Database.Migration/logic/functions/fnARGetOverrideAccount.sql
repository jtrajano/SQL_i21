--liquibase formatted sql

-- changeset Von:fnARGetOverrideAccount.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION dbo.[fnARGetOverrideAccount]
(
	 @intAccountIdUseToOverride	INT
	,@intAccountIdToBeOverriden	INT
	,@bitOverrideCompany		BIT
	,@bitOverrideLocation		BIT
	,@bitOverrideLineOfBusiness	BIT
)
RETURNS @returntable TABLE
(
	 [strOverrideAccount]			NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	,[intOverrideAccount]			INT
	,[bitSameCompanySegment]		BIT
	,[bitSameLocationSegment]		BIT
	,[bitSameLineOfBusinessSegment]	BIT
	,[bitOverriden]					BIT
)
AS
BEGIN
	DECLARE  @strOverrideAccount				NVARCHAR(40)= NULL
			,@intOverrideAccount				INT			= @intAccountIdToBeOverriden
			,@strAccountIdToBeOverriden			NVARCHAR(40)
			,@strAccountIdUseToOverride			NVARCHAR(40)
			,@intAccountSegmentIdCompany		INT
			,@intAccountSegmentIdLocation		INT
			,@intAccountSegmentIdLineOfBusiness	INT
			,@bitSameCompanySegment				BIT			= 1
			,@bitSameLocationSegment			BIT			= 1
			,@bitSameLineOfBusinessSegment		BIT			= 1

	SELECT @strAccountIdToBeOverriden = strAccountId
	FROM tblGLAccount
	WHERE intAccountId = @intAccountIdToBeOverriden

	SELECT @strAccountIdUseToOverride = strAccountId
	FROM tblGLAccount
	WHERE intAccountId = @intAccountIdUseToOverride

	IF(@bitOverrideCompany = 1)
	BEGIN
		SELECT @intAccountSegmentIdCompany = intAccountSegmentId
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdToBeOverriden
		AND intSegmentTypeId = 6

		SELECT 
			 @strOverrideAccount	= dbo.[fnGLGetOverrideAccount](6, @strAccountIdUseToOverride, ISNULL(@strOverrideAccount, @strAccountIdToBeOverriden))
			,@bitSameCompanySegment	= CASE WHEN @intAccountSegmentIdCompany = intAccountSegmentId THEN 1 ELSE 0 END
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdUseToOverride
		AND intSegmentTypeId = 6
	END

	IF(@bitOverrideLocation = 1)
	BEGIN
		SELECT 
			@intAccountSegmentIdLocation	= intAccountSegmentId
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdToBeOverriden
		AND intSegmentTypeId = 3

		SELECT 
			 @strOverrideAccount	= dbo.[fnGLGetOverrideAccount](3, @strAccountIdUseToOverride, ISNULL(@strOverrideAccount, @strAccountIdToBeOverriden))
			,@bitSameLocationSegment= CASE WHEN @intAccountSegmentIdLocation = intAccountSegmentId THEN 1 ELSE 0 END
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdUseToOverride
		AND intSegmentTypeId = 3
	END

	IF(@bitOverrideLineOfBusiness = 1)
	BEGIN
		SELECT @intAccountSegmentIdLineOfBusiness = intAccountSegmentId
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdToBeOverriden
		AND intSegmentTypeId = 5

		SELECT 
			 @strOverrideAccount			= dbo.[fnGLGetOverrideAccount](5, @strAccountIdUseToOverride, ISNULL(@strOverrideAccount, @strAccountIdToBeOverriden))
			,@bitSameLineOfBusinessSegment	= CASE WHEN @intAccountSegmentIdLineOfBusiness = intAccountSegmentId THEN 1 ELSE 0 END
		FROM vyuGLSegmentMapping
		WHERE intAccountId = @intAccountIdUseToOverride
		AND intSegmentTypeId = 5
	END

	SELECT TOP 1 @intOverrideAccount = intAccountId
	FROM tblGLAccount
	WHERE strAccountId = ISNULL(@strOverrideAccount, '')

	INSERT INTO @returntable
	SELECT @strOverrideAccount, @intOverrideAccount, @bitSameCompanySegment, @bitSameLocationSegment, @bitSameLineOfBusinessSegment, CASE WHEN @intAccountIdToBeOverriden = @intOverrideAccount THEN 0 ELSE 1 END

	RETURN
END



