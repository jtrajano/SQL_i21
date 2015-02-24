
GO
	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[coctlmst]') AND type IN (N'U')) GOTO Check_Exit;

	PRINT N'BEGIN CHECK coctlmst'

	SET NOCOUNT ON

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


	SET NOCOUNT OFF


	PRINT N'END CHECK coctlmst'

Check_Exit:

GO
