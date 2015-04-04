CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountSegment] ON [dbo].[tblGLAccountSegment] 
FOR UPDATE
AS
	DECLARE @intAccountCategoryId INT
	DECLARE @strCode NVARCHAR(16)
	DECLARE @intSortPrimary INT
	DECLARE @intEntityIDLastModified INT
	DECLARE @strMask NVARCHAR(1)
	DECLARE @intSortDivider INT
	DECLARE @strLike NVARCHAR(50)
	DECLARE @strLikeFinal NVARCHAR(50)
	DECLARE @intCount INT
		
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable)
	SELECT 
		d.intAccountSegmentId
		,'Account Category'
		,'Move'
		,getdate()
		,CAST(d.intAccountCategoryId as nvarchar(10)) 
		,CAST(i.intAccountCategoryId AS nvarchar(10))
		,i.intEntityIdLastModified,'Account Segment'
	FROM deleted d 
	JOIN inserted i ON i.intAccountSegmentId = d.intAccountSegmentId
	WHERE  i.intAccountCategoryId != d.intAccountCategoryId


	SELECT @intCount = COUNT(1) FROM tblGLAccountStructure
	SELECT  @strLike = REPLICATE('%',@intCount)
	DECLARE cursortrigger CURSOR FOR SELECT  i.intAccountCategoryId,
	i.strCode,
	t.intSort,
	i.intEntityIdLastModified
	FROM inserted i
	JOIN tblGLAccountStructure t ON i.intAccountStructureId = t.intAccountStructureId
	JOIN deleted d ON i.intAccountSegmentId = d.intAccountSegmentId
	WHERE 
		t.strType = 'Primary'  AND
		d.intAccountCategoryId!= i.intAccountCategoryId OR i.intEntityIdLastModified = 0 -- force update on post deployment
	OPEN cursortrigger
	FETCH NEXT FROM cursortrigger INTO @intAccountCategoryId, @strCode,@intSortPrimary,@intEntityIDLastModified
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		DECLARE cursortbl CURSOR FOR SELECT strMask, intSort FROM tblGLAccountStructure WHERE strType = 'Divider' ORDER BY intSort
		OPEN cursortbl
		FETCH NEXT FROM cursortbl INTO @strMask,@intSortDivider
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @strLikeFinal =STUFF(@strLike,@intSortDivider + 1,1,@strMask)
				FETCH NEXT FROM cursortbl INTO @strMask,@intSortDivider
			END
		CLOSE cursortbl
		DEALLOCATE cursortbl
			
		SELECT @strLikeFinal =STUFF(@strLikeFinal,@intSortPrimary + 1,1,@strCode)
		PRINT @strLikeFinal
		IF @strLikeFinal != @strLike
		UPDATE tblGLAccount SET intAccountCategoryId = @intAccountCategoryId,intEntityIdLastModified = @intEntityIDLastModified  WHERE strAccountId LIKE @strLikeFinal
		FETCH NEXT FROM cursortrigger INTO @intAccountCategoryId, @strCode,@intSortPrimary,@intEntityIDLastModified
	END
	CLOSE cursortrigger
	DEALLOCATE cursortrigger