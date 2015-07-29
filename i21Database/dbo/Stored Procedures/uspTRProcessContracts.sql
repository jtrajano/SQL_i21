CREATE PROCEDURE [dbo].[uspTRProcessContracts]
	 @strTransaction AS nvarchar(50),
	 @action as nvarchar(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE  @intTransportLoadId AS INT;
DECLARE @intContractDetailId as int,
        @dblQuantity as float;
Declare @incval int,
        @total int;


BEGIN TRY
  select @intTransportLoadId = intTransportLoadId from tblTRTransportLoad where strTransaction = @strTransaction

--Update the Logistics Load for InProgress 
	
DECLARE @tempReceipt TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intReceiptContractId int,
	dblQuantity float
    )	  
DECLARE @tempDistribution TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intDistributionContractId int,
	dblQuantity float
    )     

	--Receipts which used Contract
	Insert into @tempReceipt(intReceiptContractId,
	                 dblQuantity)
	select TR.intContractDetailId,dblQuantity = CASE
								  WHEN SP.strGrossOrNet = 'Gross'
								  THEN TR.dblGross
								  WHEN SP.strGrossOrNet = 'Net'
								  THEN TR.dblNet
								  END
	 from tblTRTransportLoad TL
	           join tblTRTransportReceipt TR on TR.intTransportLoadId = TL.intTransportLoadId
			   join tblTRSupplyPoint SP on SP.intSupplyPointId = TR.intSupplyPointId
			    where TL.intTransportLoadId = @intTransportLoadId and isNull(TR.intContractDetailId,0) != 0
				
    select @total = count(*) from @tempReceipt;
    set @incval = 1 
    WHILE @incval <=@total 
    BEGIN    
      select @dblQuantity = dblQuantity,@intContractDetailId =intReceiptContractId  from @tempReceipt where @incval = intId    
	  if (@action = 'Delete')
	  BEGIN 
	     set @dblQuantity = @dblQuantity * -1
	  END
      exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity    
      SET @incval = @incval + 1;
    END;
  
--Distribution which used Contract	
    Insert into @tempDistribution(intDistributionContractId,
	                 dblQuantity)
	select DD.intContractDetailId,DD.dblUnits from tblTRTransportLoad TL
	           join tblTRTransportReceipt TR on TR.intTransportLoadId = TL.intTransportLoadId
			   join tblTRDistributionHeader DH on DH.intTransportReceiptId = TR.intTransportReceiptId
			   join tblTRDistributionDetail DD on DD.intDistributionHeaderId = DH.intDistributionHeaderId
			    where TL.intTransportLoadId = @intTransportLoadId and isNull(DD.intContractDetailId,0) != 0
				
    select @total = count(*) from @tempDistribution;
    set @incval = 1 
    WHILE @incval <=@total 
    BEGIN    
      select @dblQuantity = dblQuantity,@intContractDetailId = intDistributionContractId  from @tempDistribution where @incval = intId
	  if (@action = 'Delete')
	  BEGIN 
	     set @dblQuantity = @dblQuantity * -1
	  END      
      exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity    
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