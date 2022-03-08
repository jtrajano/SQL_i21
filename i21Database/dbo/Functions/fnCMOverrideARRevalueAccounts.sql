CREATE FUNCTION fnCMOverrideARRevalueAccounts
 (
     @PostGLEntries RecapTableType READONLY
 )
RETURNS 
 @tbl TABLE(
    intId int IDENTITY(1,1),
    intOverrideLocationAccountId INT,
    intOverrideLOBAccountId INT,
    intOrigAccountId INT,
    intNewGLAccountId INT NULL,
    ysnOverriden BIT
)
AS
BEGIN

DECLARE @ysnHasLOB BIT
SELECT @ysnHasLOB = 1 FROM tblGLAccountStructure A join tblGLSegmentType B on A.intStructureType = B.intSegmentTypeId 
    WHERE B.strSegmentType = 'Line Of Business'

IF NOT EXISTS (SELECT 1 FROM @PostGLEntries WHERE intOverrideLocationAccountId IS NOT NULL AND (intOverrideLOBAccountId IS NOT NULL AND @ysnHasLOB = 1))
    RETURN

INSERT INTO @tbl (intOverrideLocationAccountId,intOverrideLOBAccountId,intOrigAccountId, ysnOverriden )
SELECT intOverrideLocationAccountId,intOverrideLOBAccountId,intAccountId , 0
FROM @PostGLEntries WHERE intOverrideLocationAccountId IS NOT NULL AND (intOverrideLOBAccountId IS NOT NULL AND @ysnHasLOB = 1)
GROUP BY intOverrideLocationAccountId, intOverrideLOBAccountId,intAccountId

DECLARE @strMessage NVARCHAR(MAX)
DECLARE @intId INT,@strOverrideLocationAccountId NVARCHAR(30),@strGLAccountOverrideId NVARCHAR(30), @strOrigAccountId NVARCHAR(30), @newStrAccountId NVARCHAR(30)
WHILE EXISTS (SELECT 1 FROM @tbl WHERE intNewGLAccountId IS NULL)
BEGIN
    SELECT TOP 1 
    @intId=intId,
    @strOverrideLocationAccountId = X.strAccountId,
    @strGLAccountOverrideId=Y.strAccountId,
    @strOrigAccountId = Z.strAccountId 
    FROM @tbl A
    OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intOverrideLocationAccountId
    ) X
        OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intOverrideLOBAccountId
    ) Y
        OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intOrigAccountId
    ) Z

    SELECT @newStrAccountId= dbo.fnGLGetOverrideAccount(3,@strOverrideLocationAccountId,@strOrigAccountId)

    IF @newStrAccountId IS NULL 
        SELECT @strMessage = '<li> Error overriding ' + @strOrigAccountId + ' using ' + @strOverrideLocationAccountId + '</li>'
    ELSE
    BEGIN
        IF @ysnHasLOB = 1 AND @newStrAccountId IS NOT NULL
            SELECT @newStrAccountId= dbo.fnGLGetOverrideAccount(5,@strGLAccountOverrideId,@newStrAccountId)
        
        IF @newStrAccountId IS NULL
            SELECT @strMessage = '<li> Error overriding ' + @strOrigAccountId + ' using ' + @strOverrideLocationAccountId + '</li>'
    END

    IF NOT EXISTS(SELECT 1 FROM tblGLAccount WHERE strAccountId = @newStrAccountId)
    BEGIN
        SELECT @strMessage = '<li>' + @newStrAccountId + 'is not an existing Account Id for override </li>'
    END
    ELSE
        UPDATE @tbl SET intNewGLAccountId =  (SELECT intAccountId from tblGLAccount WHERE strAccountId = @newStrAccountId)
        WHERE intId = @intId
END


IF @strMessage <> ''
BEGIN
    SET @strMessage = '<ul style="text-indent:-40px">' + @strMessage + '</ul>'
	DECLARE @i int 
	SELECT @i = CAST (@strMessage  AS INT)
	
END
RETURN

END
