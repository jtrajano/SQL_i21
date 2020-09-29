CREATE PROCEDURE uspGLImportChartOfAccountsFromStaging
( 
    @strBatchId NVARCHAR(40)
)
AS


UPDATE T set ysnExist = 1 FROM  tblGLAccountImportStaging T JOIN tblGLAccount A ON A.strAccountId = T.strAccountId
WHERE @strBatchId = strBatchId

DECLARE @tmp  AS TABLE (
	strAccountId nvarchar(40) COLLATE Latin1_General_CI_AS ,
	strSegmentId nvarchar(20)  COLLATE Latin1_General_CI_AS ,
	intRowId INT,
	intLineNo INT,
	intAccountStructureId INT,
	strComment NVARCHAR(200)  COLLATE Latin1_General_CI_AS,
	intAccountSegmentId int NULL,
	ysnSuccess BIT NULL
	
)

INSERT intO @tmp (strAccountId, intRowId, strSegmentId, intLineNo)
SELECT A.strAccountId, Split.rowId, Split.Item, A.intLineNo FROM  tblGLAccountImportStaging A
OUTER APPLY   (
	SELECT ROW_NUMBER() over(order by (SELECT null)) rowId,  * FROM   [dbo].fnTRSplit(A.strAccountId, '-') 
)Split
WHERE isnull(A.ysnExist, 0) = 0 and @strBatchId = strBatchId


;WITH Struct as(
SELECT ROW_NUMBER() over(order by intSort ) intRowId, intAccountStructureId FROM  tblGLAccountStructure WHERE strType != 'Divider' 
)
UPDATE T  set intAccountStructureId =S.intAccountStructureId FROM  @tmp T JOIN Struct S ON S.intRowId = T.intRowId
UPDATE T set intAccountSegmentId = S.intAccountSegmentId FROM  @tmp T 
OUTER APPLY  (
 SELECT  TOP 1 intAccountSegmentId FROM  tblGLAccountSegment WHERE strCode = T.strSegmentId and intAccountStructureId = T.intAccountStructureId
) S
;WITH MissingSegment as(
	SELECT strAccountId FROM  @tmp WHERE intAccountSegmentId IS NULL GROUP BY strAccountId
)
UPDATE T SET ysnMissingSegment = 1
FROM   tblGLAccountImportStaging T JOIN MissingSegment M ON M.strAccountId = T.strAccountId

INSERT intO tblGLAccount ([strAccountId],[strDescription], [intAccountGroupId],[ysnSystem],[ysnActive],intCurrencyID, intConcurrencyId)
SELECT a.strAccountId,
		'',
		intAccountGroupId,
		0,
		0,
		3,
		1
FROM  tblGLAccountImportStaging a 
JOIN @tmp T ON T.strAccountId = a.strAccountId
JOIN tblGLAccountSegment  S ON S.strCode = T.strSegmentId
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId
WHERE  T.intRowId = 1 
AND ST.strType = 'Primary'
AND isnull(ysnMissingSegment,0) = 0
AND  isnull(ysnExist,0) = 0
AND isnull(ysnAccountBuilt , 0) = 0
and strBatchId = @strBatchId


UPDATE T set ysnAccountBuilt = 1, intAccountId = A.intAccountId FROM  tblGLAccountImportStaging T  
JOIN tblGLAccount A ON A.strAccountId = T.strAccountId 
and strBatchId = @strBatchId

INSERT intO tblGLAccountSegmentMapping(intAccountSegmentId, intAccountId, intConcurrencyId)
SELECT T.intAccountSegmentId, A.intAccountId ,1
FROM  tblGLAccountImportStaging A 
JOIN @tmp T ON A.strAccountId = T.strAccountId
WHERE isnull(ysnAccountBuilt , 0) = 1
and strBatchId = @strBatchId


;WITH CTE(intAccountId,strDescription) 
AS(
SELECT A1.intAccountId,
STUFF(( 
SELECT  ' ' + '-' + ' ' +  RTRIM(S.strChartDesc)
FROM          dbo.tblGLAccountSegment S INNER JOIN
					dbo.tblGLAccountSegmentMapping M ON S.intAccountSegmentId = M.intAccountSegmentId 
					JOIN tblGLAccountStructure St ON S.intAccountStructureId = St.intAccountStructureId
					JOIN @tmp T ON T.intAccountSegmentId = S.intAccountSegmentId
					RIGHT OUTER JOIN dbo.tblGLAccount A2 ON M.intAccountId = A2.intAccountId 
					WHERE A2.intAccountId = A1.intAccountId
					ORDER BY St.intSort
	FOR XML PATH('') )  
, 1, 2, '' ) AS strDescription
FROM  tblGLAccount A1  
JOIN tblGLAccountImportStaging S ON S.intAccountId = A1.intAccountId
WHERE strBatchId = @strBatchId AND ysnAccountBuilt = 1
GROUP BY A1.intAccountId)
UPDATE A SET A.strDescription = ISNULL(CTE.strDescription ,'')
FROM  tblGLAccount A INNER JOIN CTE ON A.intAccountId = CTE.intAccountId
INNER JOIN tblGLAccountSegmentMapping M ON A.intAccountId = M.intAccountId
INNER JOIN tblGLAccountSegment S ON M.intAccountSegmentId = S.intAccountSegmentId
