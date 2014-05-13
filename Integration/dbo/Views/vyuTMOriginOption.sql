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

CREATE VIEW [dbo].[vyuTMOriginOption]
AS
SELECT TOP 1
ysnLoanEquipment = CAST((CASE WHEN coctl_le_yn= 'Y' THEN 1 ELSE 0 END) AS BIT)
,ysnPetro = CAST((CASE WHEN coctl_pt= 'Y' THEN 1 ELSE 0 END) AS BIT)
,intOriginOptionId = CAST(A4GLIdentity AS INT)
FROM
coctlmst

GO