CREATE PROCEDURE [dbo].[uspSTUpdatePromoSalesTotal]
AS
BEGIN TRY

	 BEGIN TRANSACTION

	 DECLARE @intPromoSalesListId AS INT

	 DECLARE db_cursor CURSOR FOR 
	 SELECT intPromoSalesListId 
	 FROM tblSTPromotionSalesList
	 
	 OPEN db_cursor  
	 FETCH NEXT FROM db_cursor INTO @intPromoSalesListId  
	 
	 WHILE @@FETCH_STATUS = 0  
	 BEGIN  
		DECLARE @toUpdate AS BIT

		IF EXISTS (SELECT intPromoSalesListId 
					FROM tblSTPromotionSalesList
					WHERE dblPromoPrice != (SELECT SUM(dblPrice) FROM (SELECT intPromoSalesListId, (intQuantity * dblPrice) AS dblPrice  FROM tblSTPromotionSalesListDetail) det WHERE intPromoSalesListId = @intPromoSalesListId)
						AND intPromoSalesListId = @intPromoSalesListId)
						BEGIN
							UPDATE tblSTPromotionSalesList 
							SET dblPromoPrice = (SELECT SUM(dblPrice) FROM (SELECT intPromoSalesListId, (intQuantity * dblPrice) AS dblPrice  FROM tblSTPromotionSalesListDetail) det WHERE intPromoSalesListId = @intPromoSalesListId),
								intPromoUnits = (SELECT SUM(intQuantity) FROM tblSTPromotionSalesListDetail WHERE intPromoSalesListId = @intPromoSalesListId)
							WHERE intPromoSalesListId = @intPromoSalesListId
						END
	 
	 	FETCH NEXT FROM db_cursor INTO @intPromoSalesListId 
	 END 
	 
	 CLOSE db_cursor  
	 DEALLOCATE db_cursor 

END TRY

BEGIN CATCH

	-- ROLLBACK
	GOTO ExitWithRollback
END CATCH


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			-- PRINT 'Will Rollback'
			ROLLBACK TRANSACTION 
		END
	
		
ExitPost: