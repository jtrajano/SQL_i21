
GO
	PRINT N'BEGIN CHECK coctlmst'
GO
	SET NOCOUNT ON
GO
	declare @strDBName nvarchar(max), @intCount int
	select @strDBName = db_name()
	select @intCount = count(*) from coctlmst

	select @intCount, @strDBName

	IF (@intCount > 1)
	BEGIN
		declare @strMessage nvarchar(max)
		set @strMessage = @strDBName + ' has multiple records on coctlmst. Cannot continue upgrade.'
		RAISERROR(@strMessage, 16, 1)
	END

GO
	SET NOCOUNT OFF

GO
	PRINT N'END CHECK coctlmst'
GO