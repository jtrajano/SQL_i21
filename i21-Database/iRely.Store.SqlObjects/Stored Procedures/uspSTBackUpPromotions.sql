CREATE PROCEDURE [dbo].[uspSTBackUpPromotions]
AS
BEGIN
	
	DECLARE @MiXMatchCount INT 
	DECLARE @ComboCount INT
	DECLARE @ItemListCount INT

	select @MiXMatchCount = 0,  @ComboCount = 0, @ItemListCount = 0

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTPromotionItemList_BKP')
    BEGIN
	     DROP table tblSTPromotionItemList_BKP
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTPromotionItemListDetail_BKP')
    BEGIN
	     DROP table tblSTPromotionItemListDetail_BKP
	END

    SELECT * INTO tblSTPromotionItemList_BKP from tblSTPromotionItemList

	SELECT * INTO tblSTPromotionItemListDetail_BKP from tblSTPromotionItemListDetail

    IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTCombo_BKP')
    BEGIN
	     DROP table tblSTCombo_BKP
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTComboDetail_BKP')
    BEGIN
	     DROP table tblSTComboDetail_BKP
	END

	 
	 SELECT * INTO tblSTCombo_BKP from tblSTPromotionSalesList where strPromoType = 'C'

	 SELECT  adj1.intPromoSalesListDetailId, adj1.intPromoSalesListId ,
	 adj1.intPromoItemListId,adj1.intQuantity,adj1.dblPrice,adj1.intConcurrencyId INTO tblSTComboDetail_BKP 
	 from tblSTPromotionSalesListDetail as adj1 INNER JOIN tblSTPromotionSalesList as adj2
	 ON adj1.intPromoSalesListId = adj2.intPromoSalesListId 
	 where adj2.strPromoType = 'C'
	 

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTMixMatch_BKP')
     BEGIN
	     DROP TABLE tblSTMixMatch_BKP
	 END   

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTMixMatchDetail_BKP')
     BEGIN
	     DROP TABLE tblSTMixMatchDetail_BKP
	 END 

	 SELECT * INTO tblSTMixMatch_BKP from tblSTPromotionSalesList where strPromoType = 'M'

	 SELECT adj1.intPromoSalesListDetailId, adj1.intPromoSalesListId ,
	 adj1.intPromoItemListId,adj1.intQuantity,adj1.dblPrice,adj1.intConcurrencyId INTO tblSTMixMatchDetail_BKP 
	 from tblSTPromotionSalesListDetail as adj1 INNER JOIN tblSTPromotionSalesList as adj2
	 ON adj1.intPromoSalesListId = adj2.intPromoSalesListId 
	 where adj2.strPromoType = 'M'

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTPromotionItemList_BKP')
     BEGIN
	     IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTPromotionItemListDetail_BKP')
         BEGIN 
	          SET  @ItemListCount = 1
         END
	 END  

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTCombo_BKP')
     BEGIN
	     IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTComboDetail_BKP')
         BEGIN 
	          SET  @ComboCount = 1
         END
	 END  

	 IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTMixMatch_BKP')
     BEGIN
	     IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSTMixMatchDetail_BKP')
         BEGIN 
	          SET  @MiXMatchCount = 1
         END
	 END  

	 select @MiXMatchCount as MixMatchCount, @ComboCount as ComboCount, @ItemListCount as ItemListCount	

END