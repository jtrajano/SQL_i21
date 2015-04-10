GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuStpbkmst')
BEGIN
	DROP VIEW vyuStpbkmst
END

GO

GO

IF EXISTS(select top 1 1 from IINFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stpbkmst')
BEGIN
   
   EXEC ('
   create view vyuStpbkmst
   AS
    select A4GLIdentity as  intStpbkmstId,
           stpbk_store_name as strStoreName,
           stpbk_upcno as strUpcCode,
	       stpbk_upc_modno as intModNo,
           stpbk_price as dblRetailPrice,
	       stpbk_sale_price as dblSalePrice,
	      stpbk_item_desc as strItemDescription

    from stpbkmst 
	')

END

GO







	





