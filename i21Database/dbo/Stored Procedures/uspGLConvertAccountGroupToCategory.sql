CREATE PROCEDURE [dbo].[uspGLConvertAccountGroupToCategory]
AS
DECLARE @intParentGroupId int
DECLARE @intAccountGroupId int
DECLARE @intAccountCategoryId int
DECLARE @intIndex INT
DECLARE @strAccountGroup varchar(100)--= 'Cash Accounts'-- 'Receivables' --'Payables'
DECLARE @strAccountCategory varchar(100)

CREATE TABLE #catGroup(
	strAccountGroup varchar(50),
	strAccountCategory varchar(50),
	intIndex INT
)
CREATE TABLE #tmpTbl(
	intAccountGroupId int,
	intParentGroupId int
)
CREATE TABLE #tmpTbl1(
	intAccountGroupId int
	
)
INSERT INTO #catGroup values('Cash Accounts', 'Cash Account',0)
INSERT INTO #catGroup values('Payables', 'AP Account',1)
INSERT INTO #catGroup values('Receivables', 'AR Account',2)

WHILE EXISTS (SELECT * FROM #catGroup)
BEGIN
SELECT TOP 1 @strAccountGroup = strAccountGroup,@strAccountCategory = strAccountCategory, @intIndex = intIndex FROM #catGroup ORDER BY intIndex
DELETE FROM #catGroup WHERE intIndex = @intIndex

SELECT @intParentGroupId = intParentGroupId,@intAccountGroupId = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = @strAccountGroup
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
INSERT into #tmpTbl
SELECT * FROM menu_tree 
--WHERE menu_tree.intParentGroupId > @intAccountGroupId

;WITH accounttbl(intAccountGroupId)
as( 
	SELECT intParentGroupId FROM #tmpTbl
	UNION all
	SELECT intAccountGroupId FROM #tmpTbl
)
INSERT INTO #tmpTbl1
SELECT intAccountGroupId FROM accounttbl GROUP BY intAccountGroupId


DECLARE @i int
DECLARE @p int
DECLARE @x int
DECLARE cursortbl CURSOR FOR SELECT intAccountGroupId FROM #tmpTbl1 ORDER BY intAccountGroupId
OPEN cursortbl
FETCH NEXT FROM cursortbl INTO @i
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @p = intParentGroupId FROM tblGLAccountGroup WHERE intAccountGroupId = @i
	IF NOT EXISTS (SELECT * FROM #tmpTbl1 WHERE intAccountGroupId = @p)
		SET @x = @i
	FETCH NEXT FROM cursortbl INTO @i
END
CLOSE cursortbl
DEALLOCATE cursortbl

DELETE FROM #tmpTbl1 WHERE intAccountGroupId = @x

UPDATE tblGLAccountSegment SET intAccountCategoryId = @intAccountCategoryId
FROM tblGLAccountSegment s join #tmpTbl1 b
on s.intAccountGroupId = b.intAccountGroupId


SELECT @i = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'General' 
UPDATE tblGLAccountSegment SET intAccountCategoryId = @i WHERE intAccountCategoryId  IS NULL
		

DELETE FROM #tmpTbl
DELETE FROM #tmpTbl1
END

DROP TABLE #tmpTbl
DROP TABLE #tmpTbl1
DROP TABLE #catGroup
RETURN 0
