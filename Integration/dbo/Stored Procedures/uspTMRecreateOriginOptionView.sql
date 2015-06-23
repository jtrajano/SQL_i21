GO
	PRINT 'START OF CREATING [uspTMRecreateOriginOptionView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateOriginOptionView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateOriginOptionView
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcoctlmst')
	DROP VIEW vwcoctlmst
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMcoctlmst')
	DROP VIEW vyuTMcoctlmst
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginOption')
	DROP VIEW vyuTMOriginOption
GO

CREATE PROCEDURE uspTMRecreateOriginOptionView 
AS
BEGIN
	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOriginOption]
			AS
			SELECT TOP 1
				ysnLoanEquipment = CAST((CASE WHEN coctl_le_yn= ''Y'' THEN 1 ELSE 0 END) AS BIT)
				,ysnPetro = CAST((CASE WHEN coctl_pt= ''Y'' THEN 1 ELSE 0 END) AS BIT)
				,intOriginOptionId = CAST(A4GLIdentity AS INT)
			FROM
			coctlmst
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOriginOption]
			AS
			SELECT TOP 1
				ysnLoanEquipment = 0
				,ysnPetro = 0
				,intOriginOptionId = 0
			FROM
			coctlmst
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateOriginOptionView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateOriginOptionView] SP'
GO
	EXEC ('uspTMRecreateOriginOptionView')
GO
	PRINT 'END OF Execute [uspTMRecreateOriginOptionView] SP'
GO