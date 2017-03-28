CREATE PROCEDURE [dbo].[uspGRDeleteStorageHistory]
	 @strSourceType NVARCHAR(30)
	,@IntSourceKey INT		
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)		
	
	    IF  @strSourceType = 'InventoryShipment'
		BEGIN
			DELETE FROM tblGRStorageHistory Where intInventoryShipmentId=@IntSourceKey 
		END
		IF  @strSourceType = 'Voucher'
		BEGIN
			DELETE FROM tblGRStorageHistory Where intBillId=@IntSourceKey 
		END
		IF  @strSourceType = 'Invoice'
		BEGIN
			DELETE FROM tblGRStorageHistory Where intInvoiceId=@IntSourceKey 
		END 

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH