GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwslsmst')
	DROP VIEW vwslsmst
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwslsmst]  
		AS  
		SELECT   	  
		vwsls_slsmn_id   = agsls_slsmn_id  
		,vwsls_name    =  ISNULL(agsls_name, '''')
		,vwsls_addr1   = agsls_addr1  
		,vwsls_addr2   = agsls_addr2  
		,vwsls_city    = agsls_city  
		,vwsls_state   = agsls_state  
		,vwsls_zip    = agsls_zip  
		,vwsls_country   = CAST(agsls_country AS CHAR(4))  
		,vwsls_phone   = agsls_phone  
		,vwsls_sales_ty_1  = agsls_sales_ty_1  
		,vwsls_sales_ty_2  = agsls_sales_ty_2  
		,vwsls_sales_ty_3  = agsls_sales_ty_3  
		,vwsls_sales_ty_4  = agsls_sales_ty_4  
		,vwsls_sales_ty_5  = agsls_sales_ty_5  
		,vwsls_sales_ty_6  = agsls_sales_ty_6  
		,vwsls_sales_ty_7  = agsls_sales_ty_7  
		,vwsls_sales_ty_8  = agsls_sales_ty_8  
		,vwsls_sales_ty_9  = agsls_sales_ty_9  
		,vwsls_sales_ty_10  = agsls_sales_ty_10  
		,vwsls_sales_ty_11  = agsls_sales_ty_11  
		,vwsls_sales_ty_12  = agsls_sales_ty_12  
		,vwsls_sales_ly_1  = agsls_sales_ly_1  
		,vwsls_sales_ly_2  = agsls_sales_ly_2  
		,vwsls_sales_ly_3  = agsls_sales_ly_3  
		,vwsls_sales_ly_4  = agsls_sales_ly_4  
		,vwsls_sales_ly_5  = agsls_sales_ly_5  
		,vwsls_sales_ly_6  = agsls_sales_ly_6  
		,vwsls_sales_ly_7  = agsls_sales_ly_7  
		,vwsls_sales_ly_8  = agsls_sales_ly_8  
		,vwsls_sales_ly_9  = agsls_sales_ly_9  
		,vwsls_sales_ly_10  = agsls_sales_ly_10  
		,vwsls_sales_ly_11  = agsls_sales_ly_11  
		,vwsls_sales_ly_12  = agsls_sales_ly_12  
		,vwsls_profit_ty_1  = agsls_profit_ty_1  
		,vwsls_profit_ty_2  = agsls_profit_ty_2  
		,vwsls_profit_ty_3  = agsls_profit_ty_3  
		,vwsls_profit_ty_4  = agsls_profit_ty_4  
		,vwsls_profit_ty_5  = agsls_profit_ty_5  
		,vwsls_profit_ty_6  = agsls_profit_ty_6  
		,vwsls_profit_ty_7  = agsls_profit_ty_7  
		,vwsls_profit_ty_8  = agsls_profit_ty_8  
		,vwsls_profit_ty_9  = agsls_profit_ty_9  
		,vwsls_profit_ty_10  = agsls_profit_ty_10  
		,vwsls_profit_ty_11  = agsls_profit_ty_11  
		,vwsls_profit_ty_12  = agsls_profit_ty_12  
		,vwsls_profit_ly_1  = agsls_profit_ly_1  
		,vwsls_profit_ly_2  = agsls_profit_ly_2  
		,vwsls_profit_ly_3  = agsls_profit_ly_3  
		,vwsls_profit_ly_4  = agsls_profit_ly_4  
		,vwsls_profit_ly_5  = agsls_profit_ly_5  
		,vwsls_profit_ly_6  = agsls_profit_ly_6  
		,vwsls_profit_ly_7  = agsls_profit_ly_7  
		,vwsls_profit_ly_8  = agsls_profit_ly_8  
		,vwsls_profit_ly_9  = agsls_profit_ly_9  
		,vwsls_profit_ly_10  = agsls_profit_ly_10  
		,vwsls_profit_ly_11  = agsls_profit_ly_11  
		,vwsls_profit_ly_12  = agsls_profit_ly_12  
		,vwsls_email   = agsls_email  
		,vwsls_textmsg_email = agsls_textmsg_email  
		,vwsls_dispatch_email = CAST(agsls_dispatch_email AS CHAR(4))  
		,vwsls_user_id   = agsls_user_id  
		,vwsls_user_rev_dt  = agsls_user_rev_dt  
		,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
		FROM agslsmst
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwslsmst]  
		AS  
		SELECT  
	  
		vwsls_slsmn_id   = ptsls_slsmn_id  
		,vwsls_name    =  ISNULL(ptsls_name, '''')
		,vwsls_addr1   = ptsls_addr1  
		,vwsls_addr2   = ptsls_addr2  
		,vwsls_city    = ptsls_city  
		,vwsls_state   = ptsls_state  
		,vwsls_zip    = ptsls_zip  
		,vwsls_country   = CAST(NULL AS CHAR(4))
		,vwsls_phone   = CAST(ptsls_phone AS CHAR(15))  
		,vwsls_sales_ty_1  = ptsls_sales_ty_1  
		,vwsls_sales_ty_2  = ptsls_sales_ty_2  
		,vwsls_sales_ty_3  = ptsls_sales_ty_3  
		,vwsls_sales_ty_4  = ptsls_sales_ty_4  
		,vwsls_sales_ty_5  = ptsls_sales_ty_5  
		,vwsls_sales_ty_6  = ptsls_sales_ty_6  
		,vwsls_sales_ty_7  = ptsls_sales_ty_7  
		,vwsls_sales_ty_8  = ptsls_sales_ty_8  
		,vwsls_sales_ty_9  = ptsls_sales_ty_9  
		,vwsls_sales_ty_10  = ptsls_sales_ty_10  
		,vwsls_sales_ty_11  = ptsls_sales_ty_11  
		,vwsls_sales_ty_12  = ptsls_sales_ty_12  
		,vwsls_sales_ly_1  = ptsls_sales_ly_1  
		,vwsls_sales_ly_2  = ptsls_sales_ly_2  
		,vwsls_sales_ly_3  = ptsls_sales_ly_3  
		,vwsls_sales_ly_4  = ptsls_sales_ly_4  
		,vwsls_sales_ly_5  = ptsls_sales_ly_5  
		,vwsls_sales_ly_6  = ptsls_sales_ly_6  
		,vwsls_sales_ly_7  = ptsls_sales_ly_7  
		,vwsls_sales_ly_8  = ptsls_sales_ly_8  
		,vwsls_sales_ly_9  = ptsls_sales_ly_9  
		,vwsls_sales_ly_10  = ptsls_sales_ly_10  
		,vwsls_sales_ly_11  = ptsls_sales_ly_11  
		,vwsls_sales_ly_12  = ptsls_sales_ly_12  
		,vwsls_profit_ty_1  = ptsls_profit_ty_1  
		,vwsls_profit_ty_2  = ptsls_profit_ty_2  
		,vwsls_profit_ty_3  = ptsls_profit_ty_3  
		,vwsls_profit_ty_4  = ptsls_profit_ty_4  
		,vwsls_profit_ty_5  = ptsls_profit_ty_5  
		,vwsls_profit_ty_6  = ptsls_profit_ty_6  
		,vwsls_profit_ty_7  = ptsls_profit_ty_7  
		,vwsls_profit_ty_8  = ptsls_profit_ty_8  
		,vwsls_profit_ty_9  = ptsls_profit_ty_9  
		,vwsls_profit_ty_10  = ptsls_profit_ty_10  
		,vwsls_profit_ty_11  = ptsls_profit_ty_11  
		,vwsls_profit_ty_12  = ptsls_profit_ty_12  
		,vwsls_profit_ly_1  = ptsls_profit_ly_1  
		,vwsls_profit_ly_2  = ptsls_profit_ly_2  
		,vwsls_profit_ly_3  = ptsls_profit_ly_3  
		,vwsls_profit_ly_4  = ptsls_profit_ly_4  
		,vwsls_profit_ly_5  = ptsls_profit_ly_5  
		,vwsls_profit_ly_6  = ptsls_profit_ly_6  
		,vwsls_profit_ly_7  = ptsls_profit_ly_7  
		,vwsls_profit_ly_8  = ptsls_profit_ly_8  
		,vwsls_profit_ly_9  = ptsls_profit_ly_9  
		,vwsls_profit_ly_10  = ptsls_profit_ly_10  
		,vwsls_profit_ly_11  = ptsls_profit_ly_11  
		,vwsls_profit_ly_12  = ptsls_profit_ly_12  
		,vwsls_email   = CAST(ptsls_email AS CHAR(50))  
		,vwsls_textmsg_email = CAST(ptsls_textmsg_email AS CHAR(50))  
		,vwsls_dispatch_email = CAST(ptsls_dispatch_email AS CHAR(4))  
		,vwsls_user_id   = CAST(NULL AS CHAR(16))  
		,vwsls_user_rev_dt  = 0   
		,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
		FROM ptslsmst
		')
GO
