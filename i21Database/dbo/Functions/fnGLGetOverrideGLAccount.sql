
CREATE FUNCTION [dbo].[fnGLGetOverrideGLAccount]
(
	@intAccountId INT, -- Overriding Account
	@intAccountId1 INT, -- Account that will be overriden
	@intStructureType INT = 3
)
RETURNS @returntable TABLE
(
	intAccountId INT NULL,
	strError nvarchar(100) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN


DECLARE @strAccountId NVARCHAR(30) ,@strAccountId1 NVARCHAR(30) 
SELECT @strAccountId = strAccountId from tblGLAccount where intAccountId = @intAccountId
SELECT @strAccountId1 = strAccountId from tblGLAccount where intAccountId = @intAccountId1
IF @strAccountId IS NULL
INSERT INTO @returntable (strError) values('Overriding Account Id is not existing GL Account' )

IF @strAccountId1 IS NULL
INSERT INTO @returntable (strError) values('Account Id To Override is not existing GL Account' )



DECLARE @intStart INT, @intEnd INT, @intLength INT, @intDividerCount INT
SELECT @intDividerCount = count(1)  from tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType

SELECT @intStart = SUM(intLength) + @intDividerCount from tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType -- location
SELECT @intLength = intLength from tblGLAccountStructure WHERE intStructureType = @intStructureType -- lob
SELECT @intEnd = @intStart + @intLength

DECLARE @strSegment NVARCHAR(10) 
SELECT @strSegment = SUBSTRING(@strAccountId,@intStart+1,@intLength)
declare @intL int = len(@strAccountId)
declare @str NVARCHAR(30)=''
DECLARE @i int = 1
WHILE @i <= @intL
BEGIN
	if @i > @intStart and @i < @intEnd
	BEGIN
		SELECT @str+= @strSegment
		SET @i = @i + @intLength
	END
	ELSE
	BEGIN
		SELECT @str+= SUBSTRING(@strAccountId1, @i, 1)
		SET @i=@i+1
	END
END


IF @str = ''
	INSERT INTO @returntable (intAccountId, strError) values( NULL, 'Unknown error has occur.')
ELSE
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = @str)
BEGIN
	INSERT INTO @returntable (intAccountId, strError) values( NULL, @str + ' is not an existing account for override.')
END
ELSE
	INSERT INTO @returntable (intAccountId, strError) 
	SELECT TOP 1 intAccountId,'' FROM tblGLAccount WHERE strAccountId = @str

RETURN;

END