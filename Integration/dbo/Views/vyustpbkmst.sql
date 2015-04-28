GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyustpbkmst')
   BEGIN
	DROP VIEW vyustpbkmst
	END

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stpbkmst')
BEGIN
	EXEC ('
		CREATE VIEW [dbo].vyustpbkmst
		AS 
       select stpbk_store_name,
       stpbk_upcno,
       stpbk_upc_modno,
       stpbk_item_desc,
       stpbk_pos_desc,
       stpbk_price,
       stpbk_vnd_id,
       stpbk_vnd_itm_id,
       stpbk_casesize, 
       stpbk_deptno,
       stpbk_family,
       stpbk_class,
       A4GLIdentity
       from stpbkmst
	')
END

GO

