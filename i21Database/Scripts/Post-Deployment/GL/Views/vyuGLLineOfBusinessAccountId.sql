GO

IF OBJECT_ID('vyuGLLineOfBusinessAccountId', 'V') IS NOT NULL
	DROP VIEW vyuGLLineOfBusinessAccountId;
DECLARE @strStructureName NVARCHAR(20)
SELECT TOP 1 @strStructureName = strStructureName FROM tblGLAccountStructure WHERE intStructureType = 5 


IF ISNULL(@strStructureName,'') <> ''
BEGIN
	EXEC('
	CREATE VIEW dbo.vyuGLLineOfBusinessAccountId
	AS
	SELECT
	A.intAccountSegmentId,
	S.intAccountId,
	A.strCode,
	A.strDescription,
	S.strAccountId COLLATE Latin1_General_CI_AS strAccountId
	FROM tblGLTempCOASegment S 
	JOIN tblGLAccountSegment A ON S.['+ @strStructureName +'] COLLATE Latin1_General_CI_AS = A.strCode')
END
ELSE
BEGIN
    EXEC('
    CREATE VIEW dbo.vyuGLLineOfBusinessAccountId
    AS
    SELECT
    intAccountSegmentId = NULL,
    intAccountId = NULL,
    strCode  = '''',
    strDescription  = '''',
    strAccountId = ''''
    ')
END
GO
