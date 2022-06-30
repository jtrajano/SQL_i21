CREATE PROCEDURE uspGLRefreshOverrideAccountTable
@ysnForceReset BIT = 0
AS
DECLARE @objectId INT
DECLARE @ysnMissingAccounts BIT = 0
SELECT @objectId = OBJECT_ID (N'tblGLOverrideAccount', N'U') 
IF @objectId IS NULL OR @ysnForceReset = 1
BEGIN
    IF @objectId IS NOT NULL 
        EXEC ('DROP TABLE tblGLOverrideAccount')

    SELECT * INTO tblGLOverrideAccount FROM tblGLTempCOASegment
    ALTER TABLE dbo.tblGLOverrideAccount ADD strOverrideAccount AS (
        [Primary Account] +
        CASE WHEN [Location] IS NULL THEN '' ELSE  '-' +[Location]  END + 
        CASE WHEN [Line Of Business] IS NULL THEN  '' ELSE '-' +[Line Of Business] END + 
        CASE WHEN [Company] IS NULL THEN '' ELSE '-'+ [Company] END 
    )

END
ELSE
BEGIN
    SELECT TOP 1 @ysnMissingAccounts = 1  FROM tblGLTempCOASegment WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLOverrideAccount)
    IF @ysnMissingAccounts = 1
    BEGIN
        EXEC(
        'INSERT INTO tblGLOverrideAccount (strAccountId, intAccountId,[Primary Account], [Location], [Line Of Business], [Company])
        SELECT strAccountId, intAccountId,[Primary Account], [Location], [Line Of Business], [Company]  
        FROM tblGLTempCOASegment WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLOverrideAccount)')
    END
END


DECLARE @tblTemp TABLE( intRowId INT,intLength INT, intStructureType INT)
DECLARE @tblItem TABLE (intItem INT)
DECLARE @strOverrideREArray NVARCHAR(10)


SELECT TOP 1 @strOverrideREArray =strOverrideREArray FROM tblGLCompanyPreferenceOption

IF @strOverrideREArray IS NOT NULL
BEGIN
    INSERT INTO @tblItem (intItem)
    SELECT CAST( Item AS INT) FROM dbo.fnSplitString(@strOverrideREArray,',')
END



IF EXISTS (SELECT 1 FROM @tblItem)
BEGIN

    INSERT INTO @tblTemp(intRowId, intLength,intStructureType)
    SELECT ROW_NUMBER() OVER(ORDER BY intSort) intRowId, intLength, intStructureType
    FROM tblGLAccountStructure  where strType NOT IN ('Divider', 'Primary') ORDER BY intSort

    DECLARE @i INT,@intStructureType INT,@intLength INT, @colName NVARCHAR(30),@sqlExec NVARCHAR(500)  

    WHILE EXISTS (SELECT 1 FROM @tblItem )
    BEGIN

        SELECT TOP  1 @i = intItem FROM @tblItem 

        SELECT @intStructureType=intStructureType,@intLength = intLength FROM @tblTemp WHERE intRowId = @i 

        IF @intStructureType = 3 SET @colName = '[Location]'
        IF @intStructureType = 5 SET @colName = '[Line Of Business]'
        IF @intStructureType = 6 SET @colName = '[Company]'

        SET @sqlExec = 'UPDATE tblGLOverrideAccount SET '+ @colName +' = REPLICATE(''X'',' + cast(@intLength as nvarchar(2)) +')'

        IF @ysnMissingAccounts = 1 SET @sqlExec = @sqlExec + ' WHERE CHARINDEX(''X'', ' + @colName + ') = 0' 

        EXEC (@sqlExec)

        DELETE FROM @tblItem WHERE intItem = @i

    END

END
GO

