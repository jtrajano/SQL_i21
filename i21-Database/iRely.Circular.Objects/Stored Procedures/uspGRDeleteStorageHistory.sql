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
			IF NOT EXISTS (
							SELECT 1
							FROM tblARInvoiceDetail ARD
							JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = ARD.intInvoiceId
							JOIN tblICItem Item ON Item.intItemId = ARD.intItemId
							WHERE ARD.intInvoiceId = @IntSourceKey
							AND ARD.intCustomerStorageId IS NULL
							AND Item.strCostType <> 'Discount'
							AND Item.strType <> 'Other Charge'
					      )
			BEGIN
					UPDATE QM
					SET QM.dblDiscountPaid = 0
					FROM tblGRCustomerStorage CS
					JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId
					JOIN tblGRDiscountScheduleCode GSC ON GSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					JOIN tblARInvoiceDetail ARD ON ARD.intCustomerStorageId = CS.intCustomerStorageId AND ARD.intItemId = GSC.intItemId
					WHERE ARD.intInvoiceId = @IntSourceKey AND QM.strSourceType = 'Storage'
				
					;WITH SRC
					AS (
						SELECT 
							 CS.intCustomerStorageId
							,SUM(QM.dblDiscountPaid) AS Discountpaid
						FROM tblGRCustomerStorage CS
						JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId
						JOIN tblGRDiscountScheduleCode GSC ON GSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
						JOIN tblARInvoiceDetail ARD ON ARD.intCustomerStorageId = CS.intCustomerStorageId AND ARD.intItemId = GSC.intItemId
						WHERE ARD.intInvoiceId = @IntSourceKey AND QM.strSourceType = 'Storage'
						GROUP BY CS.intCustomerStorageId
						)
													
					UPDATE CS
					SET CS.dblDiscountsPaid = Q.Discountpaid
					FROM tblGRCustomerStorage CS
					JOIN SRC Q ON Q.intCustomerStorageId = CS.intCustomerStorageId
					JOIN tblARInvoiceDetail ARD ON ARD.intCustomerStorageId = CS.intCustomerStorageId 
				    WHERE ARD.intInvoiceId = @IntSourceKey
			END

			IF EXISTS (
							SELECT 1
							FROM tblARInvoiceDetail ARD
							JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = ARD.intInvoiceId
							JOIN tblICItem Item ON Item.intItemId = ARD.intItemId
							JOIN tblGRStorageHistory SH ON SH.intInvoiceId = Invoice.intInvoiceId
							WHERE ARD.intInvoiceId			 = @IntSourceKey AND ARD.intCustomerStorageId IS NOT NULL
								AND Item.strCostType		 = 'Other Charges'
								AND Item.strType			 = 'Other Charge'
								AND SH.strType				 = 'Generated Fee Invoice'
					   )
			BEGIN
			 
						UPDATE CS
						SET CS.dblFeesPaid = 0
						FROM tblGRCustomerStorage CS
						JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
						WHERE SH.intInvoiceId = @IntSourceKey AND SH.strType = 'Generated Fee Invoice'
			END

			DELETE FROM tblGRStorageHistory Where intInvoiceId=@IntSourceKey 

		END 

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH