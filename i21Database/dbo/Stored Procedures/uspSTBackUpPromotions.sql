CREATE PROCEDURE [dbo].[uspSTBackUpPromotions]
AS
BEGIN
	
	DECLARE @SQL1 NVARCHAR(MAX)
	DECLARE @MiXMatchCount INT 
	DECLARE @ComboCount INT
	DECLARE @ItemListCount INT
	select @MiXMatchCount = 0,  @ComboCount = 0, @ItemListCount = 0

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stitlsav')
    BEGIN
	     DROP table stitlsav
	END

	SET @SQL1 =  'select stitl_store_name,
                   stitl_ruby_mix_no,
                   stitl_seq_no,
                   stitl_xml_list_id,
                   stitl_description,
                   stitl_upcno,
                   stitl_upc_modno,
                   stitl_last_chg_dt,
                   stitl_deleted_yn,
                   stitl_sent_to_ruby_yn,
                   stitl_user_id,
                   stitl_user_rev_dt,
                   stitl_user_time,
				   A4GLIdentity into stitlsav from stitlmst' 

     EXEC (@SQL1)

     IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stitlsav')
     BEGIN
	     SET  @ItemListCount = 1
	 END   

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stmixsav')
     BEGIN
	     DROP table stmixsav
	 END

	 SET @SQL1 =  'select stmix_store_name,
                stmix_id,
                stmix_dept_9,
                stmix_description,
                stmix_beg_date,
                stmix_beg_time,
                stmix_end_date,
                stmix_end_time,
                stmix_salesrestrict,
                stmix_strict_high,
                stmix_strict_low,
                stmix_max_units,
                stmix_mm_units,
                stmix_price,
                stmix_deleted_yn,
                stmix_sent_to_ruby_yn,
                stmix_promo_reason,
                stmix_itemlist_id_1,
                stmix_itemlist_id_2,
                stmix_itemlist_id_3,
                stmix_itemlist_id_4,
                stmix_itemlist_id_5,
                stmix_itemlist_qty_1,
                stmix_itemlist_qty_2,
                stmix_itemlist_qty_3,
                stmix_itemlist_qty_4,
                stmix_itemlist_qty_5,
                stmix_itemlist_unitprice_1,
                stmix_itemlist_unitprice_2,
                stmix_itemlist_unitprice_3,
                stmix_itemlist_unitprice_4,
                stmix_itemlist_unitprice_5,
                stmix_user_id,
                stmix_user_rev_dt,
                stmix_user_time,
				A4GLIdentity into stmixsav from stmixmst' 

     EXEC (@SQL1)

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stmixsav')
     BEGIN
	     SET  @MiXMatchCount = 1
	 END   

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stcbosav')
     BEGIN
	     DROP table stcbosav
	 END

	 SET @SQL1 =  'select stcbo_store_name,
                  stcbo_id, 
	              stcbo_combo_description,
                  stcbo_promo_code,
                  stcbo_promo_reason,
                  stcbo_combo_price,
                  stcbo_fee_type,
                  stcbo_dept_9,
                  stcbo_prod_code_n,
                  stcbo_beg_date,
                  stcbo_beg_time,
                  stcbo_end_date,
                  stcbo_end_time,
                  stcbo_tran_limit,
                  stcbo_itemlist_id_1,
                  stcbo_itemlist_id_2,
                  stcbo_itemlist_id_3,
                  stcbo_itemlist_id_4,
                  stcbo_itemlist_id_5,
                  stcbo_item_qty_1,
                  stcbo_item_qty_2,
                  stcbo_item_qty_3,
                  stcbo_item_qty_4,
                  stcbo_item_qty_5,
                  stcbo_item_unitprice_1,
                  stcbo_item_unitprice_2,
                  stcbo_item_unitprice_3,
                  stcbo_item_unitprice_4,
                  stcbo_item_unitprice_5,
                  stcbo_receipt_itemize,
                  stcbo_returnable,
                  stcbo_food_stamp,
                  stcbo_id1_req,
                  stcbo_id2_req,
                  stcbo_disc_allowed,
                  stcbo_bluelaw_1_applies,
                  stcbo_bluelaw_2_applies,
                  stcbo_taxflag1,
                  stcbo_taxflag2,
                  stcbo_taxflag3,
                  stcbo_taxflag4,
                  stcbo_deleted_yn,
                  stcbo_sent_to_ruby_yn,
                  stcbo_user_id,
                  stcbo_user_rev_dt,
                  stcbo_user_time, 
				  A4GLIdentity
	              into stcbosav from stcbomst'

     EXEC (@SQL1)

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'stcbosav')
     BEGIN
	     SET  @ComboCount = 1
	 END   

	 select @MiXMatchCount as MixMatchCount, @ComboCount as ComboCount, @ItemListCount as ItemListCount	

     EXEC (@SQL1) 

END
GO
