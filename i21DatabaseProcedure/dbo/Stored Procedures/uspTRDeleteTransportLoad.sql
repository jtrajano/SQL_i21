CREATE PROCEDURE [dbo].[uspTRDeleteTransportLoad]
	 @intTransportLoadId AS INT	 
	 ,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

Declare @incval int,
        @intTransportReceiptId int,
        @intInventoryReceiptId int,
    	@intInventoryTransferId int,
		@intEntityUserSecurityId int,
		@intDistributionHeaderId int,
        @intInvoiceId int,	
        @total int;
DECLARE @IRITTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intTransportReceiptId int,
    intInventoryReceiptId int,
	intInventoryTransferId int
    )		
DECLARE @IVTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intDistributionHeaderId int,
    intInvoiceId int	
    )

BEGIN TRY

SELECT	TOP 1 @intEntityUserSecurityId = [intEntityUserSecurityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityUserSecurityId] = @intUserId

Insert into @IRITTable
select intTransportReceiptId,intInventoryReceiptId,intInventoryTransferId from tblTRTransportReceipt where intTransportLoadId = @intTransportLoadId

Insert into @IVTable
select intDistributionHeaderId,intInvoiceId  from tblTRTransportReceipt TR
join tblTRDistributionHeader DH on TR.intTransportReceiptId = DH.intTransportReceiptId
where intTransportLoadId = @intTransportLoadId

select @total = count(*) from @IRITTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   select @intTransportReceiptId = intTransportReceiptId,@intInventoryReceiptId = intInventoryReceiptId ,@intInventoryTransferId = intInventoryTransferId from @IRITTable where intId = @incval
   
   update tblTRTransportReceipt 
   set intInventoryReceiptId = null,intInventoryTransferId = null where intTransportReceiptId = @intTransportReceiptId

   if ISNULL(@intInventoryReceiptId,0) != 0
   BEGIN
       EXEC [dbo].[uspICDeleteInventoryReceipt]  @intInventoryReceiptId,@intEntityUserSecurityId 
   END
   if ISNULL(@intInventoryTransferId,0) != 0
   BEGIN
       EXEC [dbo].[uspICDeleteInventoryTransfer] @intInventoryTransferId ,@intEntityUserSecurityId 
   END
   SET @incval = @incval + 1;

END;

select @total = count(*) from @IVTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   select @intInvoiceId = intInvoiceId,@intDistributionHeaderId = intDistributionHeaderId from @IVTable where intId = @incval

   update tblTRDistributionHeader 
   set intInvoiceId = null where intDistributionHeaderId = @intDistributionHeaderId

   if ISNULL(@intInvoiceId,0) != 0
   BEGIN
       EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId ,@intUserId 
   END 
   SET @incval = @incval + 1;

END;

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH