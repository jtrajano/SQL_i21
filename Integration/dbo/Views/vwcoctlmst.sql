CREATE VIEW [dbo].[vwcoctlmst]
AS
SELECT
vwcoctl_le_yn = coctl_le_yn
,vwctl_sp_yn = coctl_sp_yn
,A4GLIdentity = CAST(A4GLIdentity   AS INT)
FROM
coctlmst