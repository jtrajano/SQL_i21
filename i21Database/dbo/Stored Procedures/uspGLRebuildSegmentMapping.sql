CREATE PROCEDURE uspGLRebuildSegmentMapping
AS
SET XACT_ABORT ON

truncate table tblGLAccountSegmentMapping

DECLARE @tbl TABLE(
	intAccountStructureId int,
	intLength INT,
	intSort int
)
declare @strMask nvarchar(1)
SELECT  @strMask = strMask from tblGLAccountStructure where strType = 'Divider'
INSERT INTO @tbl (intAccountStructureId, intLength,intSort) 
select intAccountStructureId, intLength,intSort from tblGLAccountStructure where strType <> 'Divider' order by  intSort

DECLARE @i int
DECLARE @x INT = 1, @intLength int
WHILE EXISTS (SELECT TOP 1 1 FROM @tbl )
BEGIN
	SELECT TOP 1 @i = intAccountStructureId ,@intLength = intLength from @tbl order by intSort

	INSERT INTO tblGLAccountSegmentMapping(intAccountId, intAccountSegmentId, intConcurrencyId)
	SELECT 
	intAccountId,
	S.intAccountSegmentId,
	1
	FROM dbo.tblGLAccount A
	OUTER APPLY(
		SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountStructureId = @i AND strCode = 
		substring(REPLACE(A.strAccountId, @strMask,''), @x, @intLength)
	)S
	SET @x += @intLength
	
	DELETE FROM @tbl where intAccountStructureId = @i
END


--sele
