GO
IF EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType = 5 )
BEGIN
    DECLARE @strStructureName NVARCHAR(20)
    SELECT TOP 1 @strStructureName = strStructureName FROM tblGLAccountStructure WHERE intStructureType = 5 


	IF OBJECT_ID('vyuGLLineOfBusinessAccountId', 'V') IS NOT NULL
	BEGIN
		DROP VIEW vyuGLLineOfBusinessAccountId;
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
		JOIN tblGLAccountSegment A ON S.['+ @strStructureName +'] COLLATE Latin1_General_CI_AS = A.strCode
		JOIN tblGLAccountStructure B ON B.intAccountStructureId = A.intAccountStructureId
		WHERE B.intStructureType = 5')


	/* Column does not exist or caller does not have permission to view the object */
	END
END
ELSE
BEGIN
    IF OBJECT_ID('vyuGLLineOfBusinessAccountId', 'V') IS NOT NULL
    DROP VIEW vyuGLLineOfBusinessAccountId;
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
