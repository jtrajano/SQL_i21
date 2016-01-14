CREATE PROCEDURE [dbo].[uspTRLoadPostingValidation]
	 @intLoadHeaderId AS INT
	 ,@ysnPostOrUnPost AS BIT
	 ,@intUserId AS int 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY
DECLARE @dtmLoadDateTime DATETIME,
        @intShipVia int,
		@intSeller int,
		@intInvoiceId int,
		@InvoiceDeleteCount int,		
		@incInvoiceDeleteval int,
		@ReceiptDeleteCount int,
		@incReceiptDeleteval int,
		@intInventoryTransferId int,
		@TransferDeleteCount int,		
		@incTransferDeleteval int,	
		@intLoadReceiptId int,
		@intInventoryReceiptId int,
		@intEntityUserSecurityId int,
		@intDriver int,
		@ReceiptCount int,
		@incReceiptval int,
		@strOrigin nvarchar(50),
		@strBOL nvarchar(50),
		@intTerminal int,
		@intSupplyPoint int,
		@intCompanyLocation int,
		@intItem int,
		@dblNet DECIMAL(18, 6) = 0,
		@dblGross DECIMAL(18, 6) = 0,
		@dblUnitCost DECIMAL(18, 6) = 0,
		@dblTotalGross DECIMAL(18, 6) = 0,
		@dblTotalNet DECIMAL(18, 6) = 0,
		@GrossorNet nvarchar(50),
		@intLoadReceipt int,
		@DistCount int = 0,
		@incDistDetailval int = 0,
        @intLoadDistributionHeaderId int,
        @intLoadDistributionDetailId int,
        @intDistributionItemId int,
        @dblUnits DECIMAL(18, 6) = 0,
        @dblPrice DECIMAL(18, 6) = 0,
		@strDestination nvarchar(50),
		@intEntityCustomerId int,
		@intEntitySalespersonId int,
		@intShipToLocationId int,
		@intCompanyLocationId int,
		@dtmInvoiceDateTime DATETIME,	
		@strresult NVARCHAR(MAX),	
		@strDescription NVARCHAR(100),
        @dblReveivedQuantity DECIMAL(18, 6) = 0,
        @dblDistributedQuantity DECIMAL(18, 6) = 0;

DECLARE @ReceiptTable TABLE
    (
	intReceiptId INT IDENTITY PRIMARY KEY CLUSTERED,
	intLoadHeaderId INT NULL,
	intLoadReceiptId int NULL,
    strOrigin nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	strBOL nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	intTerminalId int NULL,
	intSupplyPointId int NULL,
	intCompanyLocationId int NULL,
	intItemId int NULL,
	dblNet DECIMAL(18, 6) NULL DEFAULT 0,
	dblGross DECIMAL(18, 6) NULL DEFAULT 0,
	dblUnitCost DECIMAL(18, 6) NULL DEFAULT 0
    )

DECLARE @DistributionHeaderTable TABLE
(
    intDistHeadId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadHeaderId] INT NULL,
	[intLoadDistributionHeaderId] INT NULL,
	[strDestination] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityCustomerId] INT NULL,	
	[intShipToLocationId] INT NULL,
    [intCompanyLocationId] INT NULL,	
	[intEntitySalespersonId] INT NULL,	
	[dtmInvoiceDateTime]  DATETIME   NULL
)

DECLARE @DistributionDetailTable TABLE
(
    intDistDetailId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadHeaderId] INT NULL,
	[intLoadDistributionDetailId] INT NULL,
	[intLoadDistributionHeaderId] INT NULL,
	[intItemId] INT NULL,		
	[dblUnits] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblPrice] DECIMAL(18, 6) NULL DEFAULT 0	
)

DECLARE @ReceiptDeleteTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadReceiptId] INT NULL,
	[intInventoryReceiptId] INT NULL	
)
DECLARE @TransferDeleteTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadReceiptId] INT NULL,
	[intInventoryTransferId] INT NULL	
)
DECLARE @InvoiceDeleteTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadDistributionHeaderId] INT NULL,
	[intInvoiceId] INT NULL	
)

select  @dtmLoadDateTime = TL.dtmLoadDateTime,
        @intShipVia = TL.intShipViaId,
		@intSeller = TL.intSellerId,
		@intDriver = TL.intDriverId
 from dbo.tblTRLoadHeader TL
      where TL.intLoadHeaderId = @intLoadHeaderId

if (isdate(@dtmLoadDateTime) = 0 )
BEGIN
    RAISERROR('Invalid Load Date/Time', 16, 1);
END

if (@intShipVia is null  )
BEGIN
    RAISERROR('Invalid Ship Via', 16, 1);
END

if (@intSeller is null  )
BEGIN
    RAISERROR('Invalid Seller', 16, 1);
END

if (@intDriver is null  )
BEGIN
    RAISERROR('Invalid Driver', 16, 1);
END

INSERT into @ReceiptTable
(
  intLoadHeaderId,
  intLoadReceiptId,
  strOrigin,
  strBOL,
  intTerminalId,
  intSupplyPointId,
  intCompanyLocationId,
  intItemId,
  dblNet,
  dblGross,
  dblUnitCost
)
select TL.intLoadHeaderId,
       TR.intLoadReceiptId,
       TR.strOrigin,
	   TR.strBillOfLading,
	   TR.intTerminalId,
	   TR.intSupplyPointId,
	   TR.intCompanyLocationId,
	   TR.intItemId,
	   TR.dblNet,
	   TR.dblGross,
	   TR.dblUnitCost
 from dbo.tblTRLoadHeader TL
      join dbo.tblTRLoadReceipt TR on TL.intLoadHeaderId = TR.intLoadHeaderId
      where TL.intLoadHeaderId = @intLoadHeaderId
	  
INSERT into @DistributionHeaderTable
(
   intLoadHeaderId,
   intLoadDistributionHeaderId,
--   intLoadReceiptId,
   strDestination,
   intEntityCustomerId,	
   intShipToLocationId,
   intCompanyLocationId,	
   intEntitySalespersonId,	
   dtmInvoiceDateTime  
)
select 
    TL.intLoadHeaderId,
    DH.intLoadDistributionHeaderId,
	DH.strDestination,
	DH.intEntityCustomerId,	
	DH.intShipToLocationId,
    DH.intCompanyLocationId,	
	DH.intEntitySalespersonId,	
	DH.dtmInvoiceDateTime  
 from dbo.tblTRLoadHeader TL
	  join dbo.tblTRLoadDistributionHeader DH on DH.intLoadHeaderId = TL.intLoadHeaderId
      where TL.intLoadHeaderId = @intLoadHeaderId


INSERT into @DistributionDetailTable
(
  intLoadHeaderId,
  intLoadDistributionDetailId,
  intLoadDistributionHeaderId,
  intItemId,		
  dblUnits, 
  dblPrice	
)
select 
  TL.intLoadHeaderId,
  DD.intLoadDistributionDetailId,
  DD.intLoadDistributionHeaderId,
  DD.intItemId,		
  DD.dblUnits, 
  DD.dblPrice	
 from dbo.tblTRLoadHeader TL    
	  join dbo.tblTRLoadDistributionHeader DH on DH.intLoadHeaderId = TL.intLoadHeaderId
	  join dbo.tblTRLoadDistributionDetail DD on DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
      where TL.intLoadHeaderId = @intLoadHeaderId

select @ReceiptCount = count(intReceiptId) from @ReceiptTable

if (@ReceiptCount = 0)
BEGIN
    RAISERROR('Receipt Entries Not Present', 16, 1);
END

set @incReceiptval = 1 
WHILE @incReceiptval <=@ReceiptCount 
BEGIN

  select @intLoadReceipt = RT.intLoadReceiptId,
         @strOrigin = RT.strOrigin,
		 @strBOL = RT.strBOL,
         @intTerminal = RT.intTerminalId,
		 @intSupplyPoint = RT.intSupplyPointId,
		 @intCompanyLocation = RT.intCompanyLocationId,
		 @intItem = RT.intItemId,
		 @dblNet = RT.dblNet,
		 @dblGross = RT.dblGross,
		 @dblUnitCost = RT.dblUnitCost 
  from @ReceiptTable RT where @incReceiptval = intReceiptId
  
  if(@strOrigin = 'Terminal')
      BEGIN
	     if @ysnPostOrUnPost = 1 and (@strBOL is NULL or LTRIM(RTRIM(@strBOL)) = '')
		    BEGIN
			   RAISERROR('Bill Of Lading is Required', 16, 1);
			END
         if (@intTerminal is null  )
         BEGIN
             RAISERROR('Invalid Terminal', 16, 1);
         END
	     if (@intSupplyPoint is null )
         BEGIN
             RAISERROR('Invalid Supply Point', 16, 1);
         END
	     if (@intCompanyLocation is null)
         BEGIN
             RAISERROR('Invalid Bulk Location', 16, 1);
         END
	     if (@intItem is null)
         BEGIN
             RAISERROR('Invalid Purchase Item', 16, 1);
         END
	     select @GrossorNet = strGrossOrNet from dbo.tblTRSupplyPoint where intSupplyPointId = @intSupplyPoint
	     if (@GrossorNet is null)
         BEGIN
             RAISERROR('Gross or Net is not Setup for Supply Point', 16, 1);
         END
	     if(@GrossorNet = 'Gross')
	        BEGIN
	            if(@dblGross is null or @dblGross = 0)
	      	    BEGIN   
	      	       RAISERROR('Gross Quantity cannot be 0', 16, 1);
	      	    END
	        END
	     else
	         BEGIN
	    	     if(@dblNet is null or @dblNet = 0)
	      	        BEGIN   
	      	           RAISERROR('Net Quantity cannot be 0', 16, 1);
	      	        END
	         END
      END
  ELSE
      BEGIN
	       if (@intCompanyLocation is null)
           BEGIN
               RAISERROR('Invalid Bulk Location', 16, 1);
           END
	       if (@intItem is null)
           BEGIN
               RAISERROR('Invalid Purchase Item', 16, 1);
           END	        
	       if((@dblGross is null or @dblGross = 0) and (@dblNet is null or @dblNet = 0))
	       BEGIN	               
	           RAISERROR('Gross and Net Quantity cannot be 0', 16, 1);	         	    
	       END

	  END


    select @dblTotalGross = sum(TR.dblGross) ,@dblTotalNet = sum(TR.dblNet)  from dbo.tblTRLoadReceipt TR
    where TR.intLoadHeaderId = @intLoadHeaderId
	      and TR.intItemId = @intItem
	group by TR.intItemId


	select @dblDistributedQuantity = sum(DD.dblUnits) from dbo.tblTRLoadDistributionHeader DH
                                  join dbo.tblTRLoadDistributionDetail DD on DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
    where intLoadHeaderId = @intLoadHeaderId
	      and DD.intItemId = @intItem
	group by DD.intItemId

  if(@GrossorNet = 'Gross')
      BEGIN
	   set @dblReveivedQuantity = @dblTotalGross
      END
  else
      BEGIN
	   if(@GrossorNet = 'Net')
	     BEGIN
		    set @dblReveivedQuantity = @dblTotalNet
	     END
       else
	     BEGIN
		    set @dblReveivedQuantity = @dblTotalGross
	     END
	  END

      if (@dblReveivedQuantity != @dblDistributedQuantity)
		BEGIN
		    select top 1 @strDescription = strDescription from vyuICGetItemStock IC where IC.intItemId = @intItem 
		    SET @strresult = @strDescription + ' Received Quantity ' + ltrim(@dblReveivedQuantity)  + ' Doesnot match Distributed Quantity ' + ltrim(@dblDistributedQuantity)
		    RAISERROR(@strresult, 16, 1);
		 END

   SET @incReceiptval = @incReceiptval + 1;
END;

select @DistCount = count(intDistDetailId) from @DistributionDetailTable

set @incDistDetailval = 1 
WHILE @incDistDetailval <=@DistCount 
BEGIN
    select @intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId,
           @intLoadDistributionDetailId = DD.intLoadDistributionDetailId,
           @intDistributionItemId = DD.intItemId,
		   @dblUnits = DD.dblUnits,
		   @dblPrice = DD.dblPrice		
    from @DistributionDetailTable DD where @incDistDetailval = intDistDetailId and intLoadHeaderId = @intLoadHeaderId

	select @strDestination = DH.strDestination,
           @intEntityCustomerId = DH.intEntityCustomerId,
           @intEntitySalespersonId = DH.intEntitySalespersonId,
		   @intShipToLocationId = DH.intShipToLocationId,
		   @intCompanyLocationId = DH.intCompanyLocationId,
		   @dtmInvoiceDateTime = DH.dtmInvoiceDateTime		
    from @DistributionHeaderTable DH where DH.intLoadDistributionHeaderId = @intLoadDistributionHeaderId and intLoadHeaderId = @intLoadHeaderId

	if (@strDestination is NULL)
	BEGIN
       RAISERROR('Destination is Invalid', 16, 1);
    END
	if (@strDestination = 'Customer')
	BEGIN
	   if(@intEntityCustomerId is NULL)
	   BEGIN
          RAISERROR('Customer is Invalid', 16, 1); 
       END
	   if(@intEntitySalespersonId is NULL)
	   BEGIN
          RAISERROR('Salesperson is Invalid', 16, 1); 
       END
	   if(@intShipToLocationId is NULL)
	   BEGIN
          RAISERROR('Ship To is Invalid', 16, 1); 
       END
	   
    END
	if(@intCompanyLocationId is NULL)
	BEGIN
       RAISERROR('Location is Invalid', 16, 1); 
    END
	if(isdate(@dtmInvoiceDateTime) = 0)
	BEGIN
       RAISERROR('Invoice Date is Invalid', 16, 1); 
    END
	if(@intDistributionItemId is NULL)
	BEGIN
       RAISERROR('Distribution Item is Invalid', 16, 1); 
    END
	if(@dblUnits = 0)
	BEGIN
       RAISERROR('Distribution Units cannot be 0', 16, 1); 
    END
	
	
   SET @incDistDetailval = @incDistDetailval + 1;
END

INSERT into @ReceiptDeleteTable
(
  intLoadReceiptId,
  intInventoryReceiptId
)
select intLoadReceiptId,intInventoryReceiptId from dbo.tblTRLoadReceipt TR
            join vyuICGetItemStock IC on TR.intItemId = IC.intItemId and TR.intCompanyLocationId = IC.intLocationId
			where (IC.strType = 'Non-Inventory' or (TR.strOrigin ='Terminal' AND (TR.dblUnitCost = 0 or TR.dblFreightRate = 0 or TR.dblPurSurcharge = 0))) and isNull(intInventoryReceiptId,0) != 0 and intLoadHeaderId = @intLoadHeaderId
Union ALL
select intLoadReceiptId,intInventoryReceiptId from dbo.tblTRLoadReceipt  TR          
			where TR.strOrigin = 'Location' and isNull(intInventoryReceiptId,0) != 0 and intLoadHeaderId = @intLoadHeaderId

INSERT into @TransferDeleteTable
(
  intLoadReceiptId,
  intInventoryTransferId
)
select intLoadReceiptId,intInventoryTransferId from dbo.tblTRLoadReceipt TR
            join vyuICGetItemStock IC on TR.intItemId = IC.intItemId and TR.intCompanyLocationId = IC.intLocationId
			where IC.strType = 'Non-Inventory' and isNull(intInventoryTransferId,0) != 0 and intLoadHeaderId = @intLoadHeaderId
UNION ALL
select intLoadReceiptId,TR.intInventoryTransferId FROM		        
			 dbo.tblTRLoadDistributionHeader DH 					
			JOIN dbo.tblTRLoadDistributionDetail DD 
				ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
			JOIN dbo.tblTRLoadReceipt TR 
				ON TR.intLoadHeaderId = DH.intLoadHeaderId	and TR.strReceiptLine in (select Item from dbo.fnTRSplit(DD.strReceiptLink,',')) 			
    WHERE ((TR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' and TR.intCompanyLocationId = DH.intCompanyLocationId)
      or (TR.strOrigin = 'Location' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId = DH.intCompanyLocationId)
	  or (TR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' and TR.intCompanyLocationId = DH.intCompanyLocationId))
	  and isNull(TR.intInventoryTransferId,0) != 0 and DH.intLoadHeaderId = @intLoadHeaderId

INSERT into @InvoiceDeleteTable
(
  intLoadDistributionHeaderId,
  intInvoiceId
)
select intLoadDistributionHeaderId,intInvoiceId from dbo.tblTRLoadDistributionHeader DH 
            where strDestination = 'Location' and isNull(intInvoiceId,0) != 0 and DH.intLoadHeaderId = @intLoadHeaderId


SELECT	TOP 1 @intEntityUserSecurityId = [intEntityUserSecurityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityUserSecurityId] = @intUserId

select @ReceiptDeleteCount = count(intId) from @ReceiptDeleteTable
set @incReceiptDeleteval = 1 
WHILE @incReceiptDeleteval <= @ReceiptDeleteCount 
BEGIN
   select @intLoadReceiptId = intLoadReceiptId,@intInventoryReceiptId = intInventoryReceiptId from @ReceiptDeleteTable where intId = @incReceiptDeleteval

   update dbo.tblTRLoadReceipt 
   set intInventoryReceiptId = null
   where intLoadReceiptId = @intLoadReceiptId
   EXEC dbo.uspICDeleteInventoryReceipt @intInventoryReceiptId,@intEntityUserSecurityId

   SET @incReceiptDeleteval = @incReceiptDeleteval + 1;
END

select @TransferDeleteCount = count(intId) from @TransferDeleteTable
set @incTransferDeleteval = 1 
WHILE @incTransferDeleteval <= @TransferDeleteCount 
BEGIN
   select @intLoadReceiptId = intLoadReceiptId,@intInventoryTransferId = intInventoryTransferId from @TransferDeleteTable where intId = @incTransferDeleteval

   update dbo.tblTRLoadReceipt 
   set intInventoryTransferId = null
   where intLoadReceiptId = @intLoadReceiptId
   EXEC dbo.uspICDeleteInventoryTransfer @intInventoryTransferId,@intEntityUserSecurityId

   SET @incTransferDeleteval = @incTransferDeleteval + 1;
END

select @InvoiceDeleteCount = count(intId) from @InvoiceDeleteTable
set @incInvoiceDeleteval = 1 
WHILE @incInvoiceDeleteval <= @InvoiceDeleteCount 
BEGIN
   select @intLoadDistributionHeaderId = intLoadDistributionHeaderId,@intInvoiceId = intInvoiceId from @InvoiceDeleteTable where intId = @incInvoiceDeleteval

   update dbo.tblTRLoadDistributionHeader 
   set intInvoiceId = null
   where intLoadDistributionHeaderId = @intLoadDistributionHeaderId

   EXEC dbo.uspARDeleteInvoice @intInvoiceId,@intUserId

   SET @incInvoiceDeleteval = @incInvoiceDeleteval + 1;
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