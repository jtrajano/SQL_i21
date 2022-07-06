﻿GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwpyemst')
	DROP VIEW vwpyemst
GO
-- AG VIEW
IF  ((SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AG'	) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'agpyemst') = 1)
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vwpyemst]
		AS
		SELECT 
		vwpye_amt	= agpye_amt
		,vwpye_cus_no	=agpye_cus_no COLLATE Latin1_General_CI_AS    
		from
		agpyemst
		')
END
GO
-- PT VIEW
IF  ((SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PT'	) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ptpyemst') = 1)
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vwpyemst]
		AS
		SELECT 
			vwpye_amt	= ptpye_amt
			,vwpye_cus_no	=ptpye_cus_no COLLATE Latin1_General_CI_AS    
			from
			ptpyemst
		')
END
GO
