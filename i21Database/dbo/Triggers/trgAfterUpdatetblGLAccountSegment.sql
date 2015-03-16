CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountSegment] ON [dbo].[tblGLAccountSegment] 
FOR UPDATE
AS
	DECLARE @intAccountCategory INT
	DECLARE @strCode NVARCHAR(16)
	DECLARE @intSortPrimary INT
	
	SELECT Top 1 
		@intAccountCategory = ISNULL(i.intAccountCategoryId,0), 
		@strCode =ISNULL(i.strCode,''),
		@intSortPrimary = ISNULL(t.intSort,0)
		FROM inserted i
		JOIN tblGLAccountStructure t ON i.intAccountStructureId = t.intAccountStructureId
		WHERE t.strType = 'Primary'  
	
	IF @strCode != ''
	BEGIN
		--UPDATE tblGLAccount WHERE
		DECLARE @strMask NVARCHAR(1)
		DECLARE @intSortDivider INT
		
		DECLARE @strLike NVARCHAR(10)
		DECLARE @intCount INT
		SELECT @intCount = COUNT(1) FROM tblGLAccountStructure
		SELECT @strLike = REPLICATE('%',@intCount)
		
			
		DECLARE cursortbl CURSOR FOR SELECT strMask, intSort FROM tblGLAccountStructure WHERE strType = 'Divider' ORDER BY intSort
		OPEN cursortbl
		FETCH NEXT FROM cursortbl INTO @strMask,@intSortDivider
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @strLike =STUFF(@strLike,@intSortDivider + 1,1,@strMask)
				FETCH NEXT FROM cursortbl INTO @strMask,@intSortDivider
			END
		CLOSE cursortbl
		DEALLOCATE cursortbl
		
		SELECT @strLike =STUFF(@strLike,@intSortPrimary + 1,1,@strCode)
		UPDATE tblGLAccount SET intAccountCategoryId = @intAccountCategory WHERE strAccountId LIKE @strLike

	END
	
