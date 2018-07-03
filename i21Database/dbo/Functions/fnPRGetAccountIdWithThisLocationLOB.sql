CREATE FUNCTION [dbo].[fnPRGetAccountIdWithThisLocationLOB]
(
	@intAccountId INT,
	@intProfitCenter INT = NULL,
	@intLineOfBusiness INT = NULL
)
RETURNS INT
AS
BEGIN
	DECLARE 
		@intOrigPrimaryAccount INT
		,@intOrigProfitCenter INT
		,@intOrigLOB INT
		,@intFinalAccountId INT

	--Step 1: Get the original Segments of the Account
	SELECT TOP 1 @intOrigPrimaryAccount = [Primary Account], @intOrigProfitCenter = [Location], @intOrigLOB = [LOB]
	FROM (
		SELECT 
			A.intAccountId
			,D.strAccountId
			,B.intAccountSegmentId
			,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END
		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
	) AS S
	PIVOT
	(
		MAX(intAccountSegmentId)
		FOR [strStructureName] IN ([Primary Account], [Location], [LOB])
	) AS PVT
	WHERE [intAccountId] = @intAccountId

	--Step 2: Get the Account that uses the acquired Primary Account, Profit Center, and LOB
	SELECT TOP 1 @intFinalAccountId = intAccountId
	FROM (
		SELECT 
			A.intAccountId
			,D.strAccountId
			,B.intAccountSegmentId
			,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END
		FROM tblGLAccountSegmentMapping A
		INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
		INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
		INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
	) AS S
	PIVOT
	(
		MAX(intAccountSegmentId)
		FOR [strStructureName] IN ([Primary Account], [Location], [LOB])
	) AS PVT
	WHERE [Primary Account] = @intOrigPrimaryAccount
		AND ISNULL([Location], 0) = ISNULL(@intProfitCenter, ISNULL(@intOrigProfitCenter, 0))
		AND ISNULL([LOB], 0) = ISNULL(@intLineOfBusiness, ISNULL(@intOrigLOB, 0))

	RETURN @intFinalAccountId
END

GO