IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwticmst')
	DROP VIEW vwticmst
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= CAST(0 AS DECIMAL(18,6))
		,vwtic_cus_no	= CAST('' AS CHAR(10))
		,vwtic_type	= CAST('' AS CHAR(1))
	')
GO

-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= pttic_ship_total
		,vwtic_cus_no	= pttic_cus_no
		,vwtic_type	= pttic_type
		,vwtic_line = pttic_line_no
		FROM
		ptticmst
			')
GO
