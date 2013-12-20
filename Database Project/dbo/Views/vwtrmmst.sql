CREATE VIEW [dbo].[vwtrmmst]
AS
SELECT 
vwtrm_key_n = CAST(agtrm_key_n AS INT)
,vwtrm_desc = agtrm_desc
,A4GLIdentity= CAsT(A4GLIdentity AS INT)
FROM
agtrmmst
