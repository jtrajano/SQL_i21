CREATE FUNCTION [dbo].[fnGLPrimaryAccountHasBalance]
(
	@intAccountId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE 
		@strCode NVARCHAR(20),
		@ysnHasBalance BIT

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
	INSERT INTO @tbl
	SELECT
		Mapping.intAccountId, ISNULL(BeginningBalance.beginBalance, 0)
	FROM [dbo].[tblGLAccountSegment] AccountSegment
	JOIN [dbo].[tblGLAccountSegmentMapping] Mapping
		ON Mapping.intAccountSegmentId = AccountSegment.intAccountSegmentId
	JOIN [dbo].[tblGLAccount] A
		ON A.intAccountId = Mapping.intAccountId
	OUTER APPLY (
		SELECT beginBalance FROM [dbo].[fnGLGetBeginningBalanceAndUnitTB](A.strAccountId, GETDATE(), -1)
	) BeginningBalance
	WHERE AccountSegment.strCode = @strCode
		AND BeginningBalance.beginBalance <> 0

	IF EXISTS (SELECT TOP 1 1 FROM @tbl)
		SET @ysnHasBalance = 1
	ELSE
		SET @ysnHasBalance = 0

	RETURN @ysnHasBalance
END
