CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountSegment] ON [dbo].[tblGLAccountSegment] 
FOR UPDATE
AS
	DECLARE @intAccountCategory INT
	DECLARE @strCode NVARCHAR(16)
	DECLARE @intSortPrimary INT

	DECLARE @strMask NVARCHAR(1)
	DECLARE @intSortDivider INT
	DECLARE @strLike NVARCHAR(50)
	DECLARE @strLikeFinal NVARCHAR(50)
	DECLARE @intCount INT
	SELECT @intCount = COUNT(1) FROM tblGLAccountStructure
	SELECT  @strLike = REPLICATE('%',@intCount)
	DECLARE cursortrigger CURSOR FOR SELECT  ISNULL(i.intAccountCategoryId,0),
	ISNULL(i.strCode,''),
	 ISNULL(t.intSort,0) FROM inserted i
	JOIN tblGLAccountStructure t ON i.intAccountStructureId = t.intAccountStructureId
	WHERE t.strType = 'Primary'  
	
	OPEN cursortrigger
	FETCH NEXT FROM cursortrigger INTO @intAccountCategory,@strCode,@intSortPrimary
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @strCode != ''
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
			UPDATE tblGLAccount SET intAccountCategoryId = @intAccountCategory WHERE strAccountId LIKE @strLikeFinal
			
		END
		FETCH NEXT FROM cursortrigger INTO @intAccountCategory,@strCode,@intSortPrimary
	END
	CLOSE cursortrigger
	DEALLOCATE cursortrigger

	
	
