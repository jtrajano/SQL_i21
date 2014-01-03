--tblDBPanel
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanel]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intPanelID', 'intPanelId', 'COLUMN'
	END
	  
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intUserID', 'intUserId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intSourcePanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intSourcePanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intSourcePanelID', 'intSourcePanelId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intConnectionId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intConnectionID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanel'))
	BEGIN
	 EXEC sp_rename 'tblDBPanel.intConnectionID', 'intConnectionId', 'COLUMN'
	END
	     
END
GO



 --tblDBPanelAccess
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelAccess]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intPanelUserID', 'intPanelColumnId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelAccess'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelAccess.intPanelID', 'intPanelId', 'COLUMN'
	END
	     
END
GO



 --tblDBPanelColumn
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelColumn]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelColumnId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelColumnID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intPanelColumnID', 'intPanelColumnId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelColumn'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelColumn.intPanelID', 'intPanelId', 'COLUMN'
	END
	     
END
GO



--tblDBPanelFormat
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelFormat]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelFormatId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelFormatID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intPanelFormatID', 'intPanelFormatId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intUserID', 'intUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelFormat'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelFormat.intPanelID', 'intPanelId', 'COLUMN'
	END	
	  	     
END
GO



--tblDBPanelTab
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelTab]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelTab.intPanelTabID', 'intPanelTabId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelTab'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelTab.intUserID', 'intUserId', 'COLUMN'
	END
	  		     
END
GO



--tblDBPanelUser
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblDBPanelUser]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelUserID', 'intPanelUserId', 'COLUMN'
	END

	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelID', 'intPanelId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intPanelTabID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intPanelTabID', 'intPanelTabId', 'COLUMN'
	END
	
	IF NOT EXISTS(SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser')) AND EXISTS (SELECT top 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblDBPanelUser'))
	BEGIN
	 EXEC sp_rename 'tblDBPanelUser.intUserID', 'intUserId', 'COLUMN'
	END  
	     
END
GO