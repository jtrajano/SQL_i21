CREATE PROCEDURE [dbo].[uspTRDeleteLoadHeader]
	 @intLoadHeaderId AS INT,
	 @intDelLoadReceiptId AS INT,	
	 @intDelDistributionId AS INT, 	 
	 @intUserId AS INT	
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
        @intLoadReceiptId int,
        @intInventoryReceiptId int,
    	@intInventoryTransferId int,
		@intEntityUserSecurityId int,
		@intLoadDistributionHeaderId int,
        @intInvoiceId int,	
        @total int;
DECLARE @IRITTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intLoadReceiptId int,
    intInventoryReceiptId int,
	intInventoryTransferId int
    )		
DECLARE @IVTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intLoadDistributionHeaderId int,
    intInvoiceId int	
    )

BEGIN TRY

SELECT	TOP 1 @intEntityUserSecurityId = [intEntityUserSecurityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityUserSecurityId] = @intUserId
if @intLoadHeaderId != 0
BEGIN
     Insert into @IRITTable
     select intLoadReceiptId,intInventoryReceiptId,intInventoryTransferId from tblTRLoadReceipt where intLoadHeaderId = @intLoadHeaderId
     
     Insert into @IVTable
     select intLoadDistributionHeaderId,intInvoiceId  from tblTRLoadDistributionHeader DH 
     where intLoadHeaderId = @intLoadHeaderId
END
if @intDelLoadReceiptId != 0
BEGIN
     Insert into @IRITTable
     select intLoadReceiptId,intInventoryReceiptId,intInventoryTransferId from tblTRLoadReceipt where intLoadReceiptId = @intDelLoadReceiptId    
END
if @intDelDistributionId != 0
BEGIN
     Insert into @IVTable
     select intLoadDistributionHeaderId,intInvoiceId  from tblTRLoadDistributionHeader DH 
     where intLoadDistributionHeaderId = @intDelDistributionId
END
select @total = count(*) from @IRITTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   select @intLoadReceiptId = intLoadReceiptId,@intInventoryReceiptId = intInventoryReceiptId ,@intInventoryTransferId = intInventoryTransferId from @IRITTable where intId = @incval
   
   update tblTRLoadReceipt 
   set intInventoryReceiptId = null,intInventoryTransferId = null where intLoadReceiptId = @intLoadReceiptId

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
   select @intInvoiceId = intInvoiceId,@intLoadDistributionHeaderId = intLoadDistributionHeaderId from @IVTable where intId = @incval

   update tblTRLoadDistributionHeader 
   set intInvoiceId = null where intLoadDistributionHeaderId = @intLoadDistributionHeaderId

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