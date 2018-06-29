CREATE PROCEDURE [dbo].[uspTRLoadProcessLoadContracts]
	 @strTransaction AS nvarchar(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE  @intLoadHeaderId AS INT;
DECLARE  @total as int,
        @incval as int,
		@intLoadDetailId as int,
		@intLoadReceiptId as int,
        @InboundQuantity as decimal(18,6);
       
DECLARE @LoadTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadDetailId] INT NULL,
	[intLoadReceiptId] int null	
)
BEGIN TRY
  select @intLoadHeaderId = intLoadHeaderId from tblTRLoadHeader where strTransaction = @strTransaction

--Update the Logistics Load for actual Qantity from transports
	insert into @LoadTable select distinct intLoadDetailId,intLoadReceiptId from tblTRLoadReceipt where intLoadHeaderId = @intLoadHeaderId 
	
	        
    select @total = count(*) from @LoadTable;
    set @incval = 1 
    WHILE @incval <=@total 
    BEGIN
         select @intLoadDetailId =intLoadDetailId,@intLoadReceiptId = intLoadReceiptId from @LoadTable where @incval = intId
	
         IF (isNull(@intLoadDetailId,0) != 0)
	     BEGIN
	       
             IF (isNull(@intLoadReceiptId,0) != 0)
	         BEGIN
	     	     select top 1 @InboundQuantity =CASE 
	     	                               WHEN SP.strGrossOrNet = 'Gross'
	     	     						       THEN TR.dblGross
	     	     						  WHEN SP.strGrossOrNet = 'Net'
	     	     						       THEN TR.dblNet
	     	     						  END	
	     	     		 from 
	     	                   tblTRLoadReceipt TR 
	     	     			  join tblTRSupplyPoint SP on SP.intSupplyPointId = TR.intSupplyPointId
	     	                   where intLoadReceiptId = @intLoadReceiptId
	     	                 
	     	      
	              UPDATE tblLGLoadDetail SET 
	     		  dblQuantity = @InboundQuantity,			
	     		  intConcurrencyId	=	intConcurrencyId + 1
	     	      WHERE intLoadDetailId=@intLoadDetailId
	     
	         END
         END
	   SET @incval = @incval + 1;
    END
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