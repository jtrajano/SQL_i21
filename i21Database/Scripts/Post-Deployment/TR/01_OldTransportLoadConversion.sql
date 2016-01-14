GO
PRINT 'BEGIN Old Transport Load to New Transport Load table conversion'
GO
DECLARE @OldTransportTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
        intTransportLoadId int	
    );

DECLARE @OldReceiptTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
        intTransportLoadId int,	
	intTransportReceiptId int
    );
DECLARE @OldDistributionTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
        intDistributionHeaderId int
    );

DECLARE @OldDistributionDetailTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
        intDistributionHeaderId int,
	intDistributionDetailId int		
    );

DECLARE @NewDistributionTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
        intLoadDistributionHeaderId int,
	intInvoiceId int	
    );

DECLARE @NewLogisticsTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,      
	intLoadHeaderId int,		
	 intLoadNumber int
    );
DECLARE @total int,
        @intLoadHeaderId int,
		@Disttotal int,
		@Ivctotal int,
		@incReceiptval int,
		@Receipttotal int,
		@intTransportReceiptId int,
		@DistDetailtotal int,
		@incDistDetailval int,
		@intDistributionDetailId int,
		@intLoadDistributionDetailId int,
		@intLoadReceiptId int,
		@intInvoiceId int,
		@incIvcval int,
		@Logtotal int,
		@intLoadNumber int,
		@incLogval int,
		@incDistval int,
        @intTransportLoadId int,
		@intDistributionHeaderId int,
		@intLoadDistributionHeaderId int,
        @incval int;
insert into @OldTransportTable select intTransportLoadId from tblTRTransportLoad

select @total = count(*) from @OldTransportTable;
set @incval = 1 
set @incDistval = 1 
set @incDistDetailval = 1
set @incReceiptval = 1
set @incLogval =1
set @incIvcval = 1
-- loop for each Transport Load
WHILE @incval <=@total 
BEGIN
     select @intTransportLoadId = intTransportLoadId  from @OldTransportTable where  intId = @incval 
     INSERT INTO [dbo].[tblTRLoadHeader]
           ([intLoadId]
           ,[strTransaction]
           ,[dtmLoadDateTime]
           ,[intShipViaId]
           ,[intSellerId]
           ,[intDriverId]
           ,[strTractor]
           ,[strTrailer]
           ,[ysnPosted]
           ,[intConcurrencyId])    
     SELECT 
            [intLoadId]
           ,[strTransaction]
           ,[dtmLoadDateTime]
           ,[intShipViaId]
           ,[intSellerId]
           ,[intDriverId]
           ,[strTractor]
           ,[strTrailer]
           ,[ysnPosted]
           ,[intConcurrencyId]
     FROM [dbo].[tblTRTransportLoad] where intTransportLoadId = @intTransportLoadId
          
     SET @intLoadHeaderId = @@IDENTITY


	 insert into @OldReceiptTable select intTransportLoadId,intTransportReceiptId from tblTRTransportReceipt where intTransportLoadId = @intTransportLoadId

     select @Receipttotal = count(*) from @OldReceiptTable;
      
     -- Loop for each Receipt
     WHILE @incReceiptval <=@Receipttotal 
     BEGIN
	      select @intTransportLoadId = intTransportLoadId,@intTransportReceiptId = intTransportReceiptId  from @OldReceiptTable where  intId = @incReceiptval

	      INSERT INTO [dbo].[tblTRLoadReceipt]
                 ([intLoadHeaderId]
                 ,[strOrigin]
                 ,[intTerminalId]
                 ,[intSupplyPointId]
                 ,[intCompanyLocationId]
                 ,[strBillOfLading]
                 ,[intItemId]
                 ,[intContractDetailId]
                 ,[dblGross]
                 ,[dblNet]
                 ,[dblUnitCost]
                 ,[dblFreightRate]
                 ,[dblPurSurcharge]
                 ,[intInventoryReceiptId]
                 ,[ysnFreightInPrice]
                 ,[intTaxGroupId]
                 ,[intInventoryTransferId]
                 ,[strReceiptLine]
                 ,[intConcurrencyId])
           SELECT 
                 @intLoadHeaderId
                 ,[strOrigin]
                 ,[intTerminalId]
                 ,[intSupplyPointId]
                 ,[intCompanyLocationId]
                 ,[strBillOfLadding]
                 ,[intItemId]
                 ,[intContractDetailId]
                 ,[dblGross]
                 ,[dblNet]
                 ,[dblUnitCost]
                 ,[dblFreightRate]
                 ,[dblPurSurcharge]
                 ,[intInventoryReceiptId]
                 ,[ysnFreightInPrice]
                 ,[intTaxGroupId]
                 ,[intInventoryTransferId]
	  	       ,'RL-1'
                 ,[intConcurrencyId]
           FROM [dbo].[tblTRTransportReceipt] where intTransportLoadId = @intTransportLoadId and intTransportReceiptId = @intTransportReceiptId
		   SET @intLoadReceiptId = @@IDENTITY

		   update tblCTSequenceUsageHistory
           set intExternalId = @intLoadReceiptId
           where strScreenName = 'Transport Purchase' and intExternalId = @intTransportReceiptId

		   SET @incReceiptval = @incReceiptval + 1;

	 END
	 insert into @OldDistributionTable select intDistributionHeaderId from tblTRTransportReceipt TR
	                                                                    join tblTRDistributionHeader DH on TR.intTransportReceiptId = DH.intTransportReceiptId
																		where TR.intTransportLoadId = @intTransportLoadId 

     select @Disttotal = count(*) from @OldDistributionTable;
     -- Loop for each Distribution Header
     WHILE @incDistval <=@Disttotal 
     BEGIN
          select @intDistributionHeaderId = intDistributionHeaderId  from @OldDistributionTable where intId = @incDistval  

	      INSERT INTO [dbo].[tblTRLoadDistributionHeader]
                ([intLoadHeaderId]
                ,[strDestination]
                ,[intEntityCustomerId]
                ,[intShipToLocationId]
                ,[intCompanyLocationId]
                ,[intEntitySalespersonId]
                ,[strPurchaseOrder]
                ,[strComments]
                ,[dtmInvoiceDateTime]
                ,[intInvoiceId]
                ,[intConcurrencyId])
          SELECT 
                @intLoadHeaderId
               ,[strDestination]
               ,[intEntityCustomerId]
               ,[intShipToLocationId]
               ,[intCompanyLocationId]
               ,[intEntitySalespersonId]
               ,[strPurchaseOrder]
               ,[strComments]
               ,[dtmInvoiceDateTime]
               ,[intInvoiceId]
               ,[intConcurrencyId]
          FROM [dbo].[tblTRDistributionHeader] where intDistributionHeaderId = @intDistributionHeaderId

		  set @intLoadDistributionHeaderId = @@IDENTITY;

		  insert into @OldDistributionDetailTable select DH.intDistributionHeaderId,DD.intDistributionDetailId from tblTRTransportReceipt TR
	                                                                    join tblTRDistributionHeader DH on TR.intTransportReceiptId = DH.intTransportReceiptId
																		join tblTRDistributionDetail DD on DD.intDistributionHeaderId = DH.intDistributionHeaderId
																		where TR.intTransportLoadId = @intTransportLoadId and  DH.intDistributionHeaderId = @intDistributionHeaderId

          select @DistDetailtotal = count(*) from @OldDistributionDetailTable;
          -- Loop for each Distribution Detail
          WHILE @incDistDetailval <=@DistDetailtotal 
          BEGIN
               select @intDistributionHeaderId = intDistributionHeaderId ,@intDistributionDetailId = intDistributionDetailId from @OldDistributionDetailTable where intId = @incDistDetailval  

		       INSERT INTO [dbo].[tblTRLoadDistributionDetail]
                     ([intLoadDistributionHeaderId]
                     ,[intItemId]
                     ,[intContractDetailId]
                     ,[dblUnits]
                     ,[dblPrice]
                     ,[dblFreightRate]
                     ,[dblDistSurcharge]
                     ,[ysnFreightInPrice]
                     ,[intTaxGroupId]
                     ,[strReceiptLink]
                     ,[intConcurrencyId])
                SELECT 
                      @intLoadDistributionHeaderId
                      ,[intItemId]
                      ,[intContractDetailId]
                      ,[dblUnits]
                      ,[dblPrice]
                      ,[dblFreightRate]
                      ,[dblDistSurcharge]
                      ,[ysnFreightInPrice]
                      ,[intTaxGroupId]
			      	,'RL-1'
                      ,[intConcurrencyId]
                FROM [dbo].[tblTRDistributionDetail] where intDistributionHeaderId = @intDistributionHeaderId and intDistributionDetailId  = @intDistributionDetailId
		        set @intLoadDistributionDetailId = @@IDENTITY;

				update tblCTSequenceUsageHistory
                       set intExternalId = @intLoadDistributionDetailId
                       where strScreenName = 'Transport Sale' and intExternalId = @intDistributionDetailId

				SET @incDistDetailval = @incDistDetailval + 1;
		  END
		SET @incDistval = @incDistval + 1;
     END
     update tblSMAuditLog
	 set strRecordNo = @intLoadHeaderId,strTransactionType = 'Transports.view.TransportLoads'
	 where strRecordNo = @intTransportLoadId and strTransactionType = 'Transports.view.TransportLoad'
	 
     --Next Transport Load
     SET @incval = @incval + 1;

END;

update tblTRTransportReceipt
set intInventoryReceiptId = null, intInventoryTransferId = null

update tblTRDistributionHeader
set intInvoiceId = null

update tblLGLoad
set intTransportLoadId = null

update tblARInvoice
set intDistributionHeaderId = null 

--Invoice link 
insert into @NewDistributionTable select intLoadDistributionHeaderId, intInvoiceId from tblTRLoadDistributionHeader where isNull(intInvoiceId,0) !=0

select @Ivctotal = count(*) from @NewDistributionTable;
     
WHILE @incIvcval <=@Ivctotal 
BEGIN
     select @intLoadDistributionHeaderId = intLoadDistributionHeaderId , @intInvoiceId = intInvoiceId from @NewDistributionTable where intId = @incIvcval  
	 
	 update tblARInvoice
	       set intLoadDistributionHeaderId = @intLoadDistributionHeaderId
	       where intInvoiceId = @intInvoiceId

	 SET @incIvcval = @incIvcval + 1;
END


--Logistics link 
insert into @NewLogisticsTable select TH.intLoadHeaderId, LG.intLoadNumber from tblTRLoadHeader TH
                                                                          join tblLGLoad LG on TH.intLoadId = LG.intLoadId
																		   

select @Logtotal = count(*) from @NewLogisticsTable;
     
WHILE @incLogval <=@Logtotal 
BEGIN
     select @intLoadNumber = intLoadNumber , @intLoadHeaderId = intLoadHeaderId from @NewLogisticsTable where intId = @incLogval  
	 
	 update tblLGLoad
	       set intLoadHeaderId = @intLoadHeaderId
	       where intLoadNumber = @intLoadNumber

	 SET @incLogval = @incLogval + 1;
END


delete from tblTRTransportLoad



