CREATE PROCEDURE [dbo].[uspAPRemoveVoucherPayableTransaction]
	@intTransactionId INT = NULL,
	@intUserId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF  

BEGIN TRY
	IF @intTransactionId IS NOT NULL
	BEGIN
		--GET intId and strId OF WILL BE DELETED VOUCHER PAYABLES
		DECLARE @intPayableIds AS TABLE (
			intVoucherPayableId INT NOT NULL,
			strReceiptNumber VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL 
		)

		INSERT INTO @intPayableIds (intVoucherPayableId, strReceiptNumber)
		SELECT P.intVoucherPayableId, IR.strReceiptNumber
		FROM tblAPVoucherPayable P 
		INNER JOIN tblICInventoryReceipt IR ON P.strSourceNumber = IR.strReceiptNumber
		WHERE IR.intInventoryReceiptId = @intTransactionId

		DECLARE @intCompletedPayableIds AS TABLE (
			intVoucherPayableId INT NOT NULL,
			strReceiptNumber VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
		)

		INSERT INTO @intCompletedPayableIds (intVoucherPayableId, strReceiptNumber)
		SELECT PC.intVoucherPayableId, IR.strReceiptNumber
		FROM tblAPVoucherPayableCompleted PC 
		INNER JOIN tblICInventoryReceipt IR ON PC.strSourceNumber = IR.strReceiptNumber
		WHERE IR.intInventoryReceiptId = @intTransactionId

		--DELETE VOUCHER PAYABLE AND TAX STAGING
		DELETE P
		FROM tblAPVoucherPayable P
		WHERE P.strSourceNumber IN (SELECT strReceiptNumber FROM @intPayableIds)

		DELETE T
		FROM tblAPVoucherPayableTaxStaging T
		WHERE T.intVoucherPayableId IN (SELECT intVoucherPayableId FROM @intPayableIds)

		--DELETE COMPLETED VOUCHER PAYABLE AND TAX STAGING
		DELETE PC
		FROM tblAPVoucherPayableCompleted PC
		WHERE PC.strSourceNumber IN (SELECT strReceiptNumber FROM @intCompletedPayableIds)

		DELETE TC
		FROM tblAPVoucherPayableTaxCompleted TC
		WHERE TC.intVoucherPayableId IN (SELECT intVoucherPayableId FROM @intCompletedPayableIds)
	END
END TRY

BEGIN CATCH	

	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	

END CATCH		

RETURN 1		                     
		                     
END