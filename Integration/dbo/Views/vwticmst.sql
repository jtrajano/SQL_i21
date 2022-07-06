﻿GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwticmst')
	DROP VIEW vwticmst
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AG'	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= CAST(0 AS DECIMAL(18,6))
		,vwtic_cus_no	= CAST('' AS CHAR(10))  COLLATE Latin1_General_CI_AS      
		,vwtic_type	= CAST('' AS CHAR(1))  COLLATE Latin1_General_CI_AS      
	')
GO

-- PT VIEW
IF  ((SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PT'	) = 1
	AND (select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptticmst') = 1)
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= pttic_ship_total
		,vwtic_cus_no	= pttic_cus_no  COLLATE Latin1_General_CI_AS      
		,vwtic_type	= pttic_type  COLLATE Latin1_General_CI_AS      
		,vwtic_line = pttic_line_no
		FROM
		ptticmst
			')
END
GO
