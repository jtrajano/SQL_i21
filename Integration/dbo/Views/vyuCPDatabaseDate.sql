﻿GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPDatabaseDate')
	DROP VIEW vwCPDatabaseDate
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPDatabaseDate')
	DROP VIEW vyuCPDatabaseDate
GO

IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'EC') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPDatabaseDate]
		AS
		select
			id = 1
			,dbdate = GETDATE()
		')
GO