CREATE PROCEDURE uspGLRebuildSegmentMapping
AS
SET XACT_ABORT ON

DELETE FROM tblGLAccountSegmentMapping

DECLARE @tbl TABLE(
	intAccountStructureId int
)
INSERT INTO @tbl select intAccountStructureId from tblGLAccountStructure where strType <> 'Divider' order by  intSort

DECLARE @i int
DECLARE @x INT = 1
WHILE EXISTS (SELECT TOP 1 1 FROM @tbl)
BEGIN
	SELECT TOP 1 @i = intAccountStructureId from @tbl
	INSERT INTO tblGLAccountSegmentMapping(intAccountId, intAccountSegmentId, intConcurrencyId)
	SELECT 
	intAccountId,
	S.intAccountSegmentId,
	1
	FROM dbo.tblGLAccount A
	OUTER APPLY(
		SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountStructureId = @i AND strCode = 
		REVERSE(PARSENAME(REPLACE(REVERSE(A.strAccountId), '-', '.'), @x)) 
	)S
	SET @x +=1
	DELETE FROM @tbl where intAccountStructureId = @i
END

	



