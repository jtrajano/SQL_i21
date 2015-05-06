CREATE PROCEDURE [dbo].[uspGLConvertAccountGroupToCategory]
AS
DECLARE @intAccountGroupId int
DECLARE @intAccountCategoryId int
DECLARE @intIndex INT
DECLARE @strAccountGroup varchar(100)--= 'Cash Accounts'-- 'Receivables' --'Payables'
DECLARE @strAccountCategory varchar(100)
SET NOCOUNT ON
DECLARE @catGroup TABLE (
	strAccountGroup varchar(50),
	strAccountCategory varchar(50),
	intIndex INT
)
DECLARE @tmpTbl TABLE (
	intAccountGroupId int,
	intParentGroupId int
)
DECLARE @tmpTbl1 TABLE (
	intAccountGroupId int
	
)
INSERT INTO @catGroup 
	SELECT 'Cash Accounts', 'Cash Account',0 
	UNION SELECT 'Payables', 'AP Account',1
	UNION SELECT 'Receivables', 'AR Account',2 
	UNION SELECT 'Undeposited Funds','Undeposited Funds',3

WHILE EXISTS (SELECT * FROM @catGroup)
BEGIN
	SELECT TOP 1 @strAccountGroup = strAccountGroup,@strAccountCategory = strAccountCategory, @intIndex = intIndex FROM @catGroup ORDER BY intIndex
	DELETE FROM @catGroup WHERE intIndex = @intIndex

	SELECT @intAccountGroupId = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = @strAccountGroup
	SELECT @intAccountCategoryId = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory =  @strAccountCategory


	;WITH menu_tree (intParentGroupId,intAccountGroupId) 
	AS ( 
		SELECT intParentGroupId,intAccountGroupId
		FROM tblGLAccountGroup 
		WHERE intAccountGroupId = @intAccountGroupId

		UNION ALL SELECT tbl.intParentGroupId,tbl.intAccountGroupId
		FROM tblGLAccountGroup tbl, menu_tree mt 
		WHERE tbl.intParentGroupId = mt.intAccountGroupId
	) 
	INSERT into @tmpTbl
	SELECT * FROM menu_tree 
	--WHERE menu_tree.intParentGroupId > @intAccountGroupId

	;WITH accounttbl(intAccountGroupId)
	as( 
		SELECT intParentGroupId FROM @tmpTbl
		UNION all
		SELECT intAccountGroupId FROM @tmpTbl
	)
	INSERT INTO @tmpTbl1
	SELECT intAccountGroupId FROM accounttbl GROUP BY intAccountGroupId


	DECLARE @i int
	DECLARE @p int
	DECLARE @x int
	DECLARE cursortbl CURSOR FOR SELECT intAccountGroupId FROM @tmpTbl1 ORDER BY intAccountGroupId
	OPEN cursortbl
	FETCH NEXT FROM cursortbl INTO @i
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @p = intParentGroupId FROM tblGLAccountGroup WHERE intAccountGroupId = @i
		IF NOT EXISTS (SELECT * FROM @tmpTbl1 WHERE intAccountGroupId = @p)
			SET @x = @i
		FETCH NEXT FROM cursortbl INTO @i
	END
	CLOSE cursortbl
	DEALLOCATE cursortbl

	DELETE FROM @tmpTbl1 WHERE intAccountGroupId = @x

	--update tblGLAccount account category
	UPDATE s SET intAccountCategoryId = @intAccountCategoryId
	FROM tblGLAccount s join @tmpTbl1 b
	on s.intAccountGroupId = b.intAccountGroupId
	AND s.intAccountCategoryId IS NULL

	;WITH GLAccount(intAccountId)AS
	(
		SELECT intAccountId from tblGLAccount a
		join @tmpTbl1 t on a.intAccountGroupId = t.intAccountGroupId
	),
	GLSegment(intAccountSegmentId) AS
	(
		SELECT s.intAccountSegmentId FROM tblGLAccountSegmentMapping m
		join GLAccount g ON m.intAccountId = g.intAccountId
		join tblGLAccountSegment s on s.intAccountSegmentId = m.intAccountSegmentId
		join tblGLAccountStructure t on s.intAccountStructureId = s.intAccountStructureId
		WHERE t.strType = 'Primary'
		GROUP BY s.intAccountSegmentId
	)
	UPDATE t SET intAccountCategoryId = @intAccountCategoryId  FROM tblGLAccountSegment t
	JOIN GLSegment g
	ON t.intAccountSegmentId = g.intAccountSegmentId
	AND t.intAccountCategoryId IS NULL
 
	DELETE FROM @tmpTbl
	DELETE FROM @tmpTbl1
END
--updating accounts/primary segments to general category if null
DECLARE @generalCategoryId INT
SELECT @generalCategoryId = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'General' 
	
UPDATE s SET intAccountCategoryId = @generalCategoryId  FROM tblGLAccountSegment s 
	JOIN tblGLAccountStructure  t ON t.intAccountStructureId = s.intAccountStructureId
	WHERE intAccountCategoryId  IS NULL AND t.strType = 'Primary'
UPDATE tblGLAccount SET intAccountCategoryId = @generalCategoryId WHERE intAccountCategoryId  IS NULL
	

