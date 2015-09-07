CREATE PROCEDURE [dbo].[uspTRPostingValidation]
	 @intTransportLoadId AS INT
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
		@intDriver int,
		@ReceiptCount int,
		@incReceiptval int,
		@strOrigin nvarchar(50),
		@intTerminal int,
		@intSupplyPoint int,
		@intCompanyLocation int,
		@intItem int,
		@dblNet DECIMAL(18, 6) = 0,
		@dblGross DECIMAL(18, 6) = 0,
		@dblUnitCost DECIMAL(18, 6) = 0,
		@GrossorNet nvarchar(50),
		@intTransportReceipt int,
		@DistCount int = 0,
		@incDistDetailval int = 0,
        @intDistributionHeaderId int,
        @intDistributionDetailId int,
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
        @dblReveivedQuantity DECIMAL(18, 6) = 0,
        @dblDistributedQuantity DECIMAL(18, 6) = 0;

DECLARE @ReceiptTable TABLE
    (
	intReceiptId INT IDENTITY PRIMARY KEY CLUSTERED,
	intTransportLoadId INT NULL,
	intTransportReceiptId int NULL,
    strOrigin nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
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
	[intTransportLoadId] INT NULL,
	[intDistributionHeaderId] INT NULL,
	[intTransportReceiptId] INT NULL,
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
	[intTransportLoadId] INT NULL,
	[intTransportReceiptId] INT NULL,
	[intDistributionDetailId] INT NULL,
	[intDistributionHeaderId] INT NULL,
	[intItemId] INT NULL,		
	[dblUnits] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblPrice] DECIMAL(18, 6) NULL DEFAULT 0	
)


select  @dtmLoadDateTime = TL.dtmLoadDateTime,
        @intShipVia = TL.intShipViaId,
		@intSeller = TL.intSellerId,
		@intDriver = TL.intDriverId
 from dbo.tblTRTransportLoad TL
      where TL.intTransportLoadId = @intTransportLoadId

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
  intTransportLoadId,
  intTransportReceiptId,
  strOrigin,
  intTerminalId,
  intSupplyPointId,
  intCompanyLocationId,
  intItemId,
  dblNet,
  dblGross,
  dblUnitCost
)
select TL.intTransportLoadId,
       TR.intTransportReceiptId,
       TR.strOrigin,
	   TR.intTerminalId,
	   TR.intSupplyPointId,
	   TR.intCompanyLocationId,
	   TR.intItemId,
	   TR.dblNet,
	   TR.dblGross,
	   TR.dblUnitCost
 from dbo.tblTRTransportLoad TL
      join tblTRTransportReceipt TR on TL.intTransportLoadId = TR.intTransportLoadId
      where TL.intTransportLoadId = @intTransportLoadId
	  
INSERT into @DistributionHeaderTable
(
   intTransportLoadId,
   intDistributionHeaderId,
   intTransportReceiptId,
   strDestination,
   intEntityCustomerId,	
   intShipToLocationId,
   intCompanyLocationId,	
   intEntitySalespersonId,	
   dtmInvoiceDateTime  
)
select 
    TL.intTransportLoadId,
    DH.intDistributionHeaderId,
    DH.intTransportReceiptId,
	DH.strDestination,
	DH.intEntityCustomerId,	
	DH.intShipToLocationId,
    DH.intCompanyLocationId,	
	DH.intEntitySalespersonId,	
	DH.dtmInvoiceDateTime  
 from dbo.tblTRTransportLoad TL
      join tblTRTransportReceipt TR on TL.intTransportLoadId = TR.intTransportLoadId
	  join tblTRDistributionHeader DH on DH.intTransportReceiptId = TR.intTransportReceiptId
      where TL.intTransportLoadId = @intTransportLoadId


INSERT into @DistributionDetailTable
(
  intTransportLoadId,
  intTransportReceiptId,
  intDistributionDetailId,
  intDistributionHeaderId,
  intItemId,		
  dblUnits, 
  dblPrice	
)
select 
  TL.intTransportLoadId,
  TR.intTransportReceiptId,
  DD.intDistributionDetailId,
  DD.intDistributionHeaderId,
  DD.intItemId,		
  DD.dblUnits, 
  DD.dblPrice	
 from dbo.tblTRTransportLoad TL
      join tblTRTransportReceipt TR on TL.intTransportLoadId = TR.intTransportLoadId
	  join tblTRDistributionHeader DH on DH.intTransportReceiptId = TR.intTransportReceiptId
	  join tblTRDistributionDetail DD on DD.intDistributionHeaderId = DH.intDistributionHeaderId
      where TL.intTransportLoadId = @intTransportLoadId

select @ReceiptCount = count(intReceiptId) from @ReceiptTable

if (@ReceiptCount = 0)
BEGIN
    RAISERROR('Receipt Entries Not Present', 16, 1);
END

set @incReceiptval = 1 
WHILE @incReceiptval <=@ReceiptCount 
BEGIN

  select @intTransportReceipt = RT.intTransportReceiptId,
         @strOrigin = RT.strOrigin,
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
	     select @GrossorNet = strGrossOrNet from tblTRSupplyPoint where intSupplyPointId = @intSupplyPoint
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
		   select @DistCount = count(*) from tblTRDistributionHeader DH
		                 join tblTRDistributionDetail DD on DH.intDistributionHeaderId = DD.intDistributionHeaderId
						 where DH.intTransportReceiptId = @intTransportReceipt		   
		   if (@DistCount = 0)
           BEGIN
               RAISERROR('Distribution entries are Not Found', 16, 1);
           END	
	  END
  if (@dblUnitCost is null or @dblUnitCost = 0)
     BEGIN
	   if(@strOrigin != 'Location')
	   BEGIN
         RAISERROR('Unit Cost cannot be 0', 16, 1);
       END
     END
  if(@GrossorNet = 'Gross')
      BEGIN
	   set @dblReveivedQuantity = @dblGross
      END
  else
      BEGIN
	   if(@GrossorNet = 'Net')
	     BEGIN
		    set @dblReveivedQuantity = @dblNet
	     END
       else
	     BEGIN
		    set @dblReveivedQuantity = @dblGross
	     END
	  END
  select @dblDistributedQuantity = sum(DD.dblUnits) from @DistributionHeaderTable DH
	 join @DistributionDetailTable DD on DH.intDistributionHeaderId = DD.intDistributionHeaderId
	 where DH.intTransportReceiptId = @intTransportReceipt and DD.intItemId = @intItem and DH.intTransportLoadId = @intTransportLoadId

  if (@strOrigin = 'Terminal' and @dblReveivedQuantity != @dblDistributedQuantity and @dblDistributedQuantity != 0)
     BEGIN
        SET @strresult = 'Received Quantity ' + ltrim(convert(int,@dblReveivedQuantity)) + ' Doesnot match Distributed Quantity ' + ltrim(convert(int,@dblDistributedQuantity)) 
        RAISERROR(@strresult, 16, 1);
     END
  else
      BEGIN
	     if (@strOrigin = 'Location' and @dblReveivedQuantity != @dblDistributedQuantity)
		 BEGIN
		    SET @strresult = 'Received Quantity ' + ltrim(convert(int,@dblReveivedQuantity))  + ' Doesnot match Distributed Quantity ' + ltrim(convert(int,@dblDistributedQuantity))
		    RAISERROR(@strresult, 16, 1);
		 END
	  END

   SET @incReceiptval = @incReceiptval + 1;
END;

select @DistCount = count(intDistDetailId) from @DistributionDetailTable

set @incDistDetailval = 1 
WHILE @incDistDetailval <=@DistCount 
BEGIN
    select @intDistributionHeaderId = DD.intDistributionHeaderId,
           @intDistributionDetailId = DD.intDistributionDetailId,
           @intDistributionItemId = DD.intItemId,
		   @dblUnits = DD.dblUnits,
		   @dblPrice = DD.dblPrice		
    from @DistributionDetailTable DD where @incDistDetailval = intDistDetailId and intTransportLoadId = @intTransportLoadId

	select @strDestination = DH.strDestination,
           @intEntityCustomerId = DH.intEntityCustomerId,
           @intEntitySalespersonId = DH.intEntitySalespersonId,
		   @intShipToLocationId = DH.intShipToLocationId,
		   @intCompanyLocationId = DH.intCompanyLocationId,
		   @dtmInvoiceDateTime = DH.dtmInvoiceDateTime		
    from @DistributionHeaderTable DH where DH.intDistributionHeaderId = @intDistributionHeaderId and intTransportLoadId = @intTransportLoadId

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
       RAISERROR('Invocie Date is Invalid', 16, 1); 
    END
	if(@intDistributionItemId is NULL)
	BEGIN
       RAISERROR('Distribution Item is Invalid', 16, 1); 
    END
	if(@dblUnits = 0)
	BEGIN
       RAISERROR('Distribution Units cannot be 0', 16, 1); 
    END
	if(@dblPrice = 0)
	BEGIN
       RAISERROR('Distribution Price cannot be 0', 16, 1); 
    END
	
   SET @incDistDetailval = @incDistDetailval + 1;
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