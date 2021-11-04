CREATE PROCEDURE [dbo].uspSCRemoveDirectPayables
	@intTicketId  INT 
	,@intUserId INT
	
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @voucherPayable VoucherPayable
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @defaultCurrency INT;
DECLARE @currentDateFilter DATETIME = (SELECT CONVERT(char(10), GETDATE(),126));


BEGIN
	
	
	INSERT INTO @voucherPayable(
			[intEntityVendorId]			
			,[intScaleTicketId]	
			,intTransactionType 
			,intContractDetailId
			,intItemId
			,intLoadShipmentDetailId				
	)
	SELECT 
		[intEntityVendorId]	= intEntityVendorId		
		,[intScaleTicketId] = intTicketId
		,intTransactionType = 1
		,intContractDetailId = intContractDetailId
		,intItemId	= intItemId
		,intLoadShipmentDetailId = intLoadDetailId
	FROM tblSCTicketDirectAddPayable 
	WHERE intTicketId = @intTicketId 


	
	IF EXISTS(SELECT TOP 1 1 FROM @voucherPayable)
	BEGIN
		EXEC [dbo].[uspAPRemoveVoucherPayable]
			@voucherPayable = @voucherPayable
			,@throwError = 1
			,@error = @ErrorMessage
	END


	
END
GO