IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwpyemst')
	DROP VIEW vwpyemst
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwpyemst]
		AS
		SELECT 
		vwpye_amt	= agpye_amt
		,vwpye_cus_no	=agpye_cus_no
		from
		agpyemst
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwpyemst]
		AS
		SELECT 
			vwpye_amt	= ptpye_amt
			,vwpye_cus_no	=ptpye_cus_no
			from
			ptpyemst
		')
GO
