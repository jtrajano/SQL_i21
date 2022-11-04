CREATE FUNCTION [dbo].[fnGLPrimaryAccountHasBalance]
(
	@intAccountId INT,
	@dtmDate DATETIME,
	@ysnGoLive BIT = 0
)
RETURNS BIT
AS
BEGIN
	DECLARE 
		@strCode NVARCHAR(20),
		@dtmDateLimit DATETIME,
		@ysnHasBalance BIT

	-- SET Date Limit to Date + 1 year
	IF @ysnGoLive = 1
		SELECT @dtmDateLimit = DATEADD(YEAR, 1, @dtmDate)

	-- Get Primary Segment Account Code
	SELECT @strCode = AccountSegment.strCode
	FROM [dbo].[tblGLAccountSegment] AccountSegment
	JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
		ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
	JOIN dbo.tblGLAccountStructure Structure 
		ON Structure.intAccountStructureId = AccountSegment.intAccountStructureId AND Structure.strType = 'Primary'
	WHERE
		Mapping.intAccountId = @intAccountId

	DECLARE @tbl TABLE(
		intAccountId INT,
		dblBalance NUMERIC(18, 6)
	)

	-- Get all affected accounts

	IF @ysnGoLive = 1
	BEGIN
		INSERT INTO @tbl
		SELECT
			Mapping.intAccountId, ISNULL(EndDate.beginBalance, 0) - ISNULL(StartDate.beginBalance, 0)
		FROM [dbo].[tblGLAccountSegment] AccountSegment
		JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
			ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
		JOIN [dbo].[tblGLAccount] A
			ON A.intAccountId = Mapping.intAccountId
		OUTER APPLY (
			SELECT ISNULL(beginBalance, 0) beginBalance FROM [dbo].[fnGLGetBeginningBalanceAndUnit](A.strAccountId, @dtmDate)
		) StartDate
		OUTER APPLY (
			SELECT ISNULL(beginBalance, 0) beginBalance FROM [dbo].[fnGLGetBeginningBalanceAndUnit](A.strAccountId, @dtmDateLimit)
		) EndDate
		WHERE AccountSegment.strCode = @strCode
	END
	ELSE
	BEGIN
		INSERT INTO @tbl
		SELECT
			Mapping.intAccountId, BeginBalance.beginBalance
		FROM [dbo].[tblGLAccountSegment] AccountSegment
		JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
			ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
		JOIN [dbo].[tblGLAccount] A
			ON A.intAccountId = Mapping.intAccountId
		OUTER APPLY (
			SELECT ISNULL(beginBalance, 0) beginBalance FROM [dbo].[fnGLGetBeginningBalanceAndUnit](A.strAccountId, @dtmDate)
		) BeginBalance
		WHERE AccountSegment.strCode = @strCode
	END

	IF EXISTS (SELECT TOP 1 1 FROM @tbl WHERE dblBalance <> 0)
		SET @ysnHasBalance = 1
	ELSE
		SET @ysnHasBalance = 0

	RETURN @ysnHasBalance
END
