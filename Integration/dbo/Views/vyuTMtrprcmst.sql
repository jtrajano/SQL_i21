GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMtrprcmst')
	DROP VIEW vyuTMtrprcmst

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuTMtrprcmst]
		AS
		SELECT
		strVendorNumber = ''
			,strRackItemNumber = ''
			,dblVendorRackPrice = 0
			,dblJobberRackPrice = 0
			,dtmDate = GETDATE()
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1 AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'trprcmst')
	EXEC ('
		CREATE VIEW [dbo].[vyuTMtrprcmst]
		AS
		SELECT 
			strVendorNumber = trprc_vnd_no
			,strRackItemNumber = trprc_pt_itm_no
			,dblVendorRackPrice = trprc_rack_prc
			,dblJobberRackPrice = trprc_cost
			,dtmDate = (CASE WHEN trprc_rev_dt = 0 THEN NULL 
										ELSE
											CONVERT(DATETIME, SUBSTRING(CAST(trprc_rev_dt  AS NVARCHAR(8)),1,4) + ''/'' 
													+ SUBSTRING(CAST(trprc_rev_dt  AS NVARCHAR(8)),5,2) + ''/''
													+  SUBSTRING(CAST(trprc_rev_dt  AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
										END)
		FROM trprcmst
		')

GO
