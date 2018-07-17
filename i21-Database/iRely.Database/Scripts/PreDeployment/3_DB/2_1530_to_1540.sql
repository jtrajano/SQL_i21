--tblDBPanelFormat
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelFormat]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'strBackColor' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intBackColor' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intBackColor', 'strBackColor', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'strFontColor' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intFontColor' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intFontColor', 'strFontColor', 'COLUMN'
	END
  	     
END
GO
