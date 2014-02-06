CREATE VIEW [dbo].[vwlocmst]
AS

SELECT
	agloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
	agloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
	agloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
	CAST(A4GLIdentity AS INT) as A4GLIdentity	
FROM aglocmst