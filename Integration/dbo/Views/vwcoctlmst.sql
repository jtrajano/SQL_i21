IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcoctlmst')
	DROP VIEW vwcoctlmst
GO

CREATE VIEW [dbo].[vwcoctlmst]
AS
SELECT
vwcoctl_le_yn = coctl_le_yn
,vwctl_sp_yn = coctl_sp_yn
,A4GLIdentity = CAST(A4GLIdentity   AS INT)
FROM
coctlmst