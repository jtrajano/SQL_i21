CREATE PROCEDURE [dbo].[uspTRLoadProcessTransportLoad]
	 @intLoadHeaderId AS INT	 
	 ,@ysnPostOrUnPost AS BIT
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
declare @intLoadDetailId int,
        @total int,
		@incval int,
    	        @dtmDeliveredDate DATETIME,@dblDeliveredQuantity DECIMAL(18, 6);
DECLARE @LoadTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadDetailId] INT NULL,
	[dtmDeliveredDate] DATETIME null,
	[dblDeliveredQuantity] decimal(18,6) null	
)

INSERT into @LoadTable
    	select  DD.intLoadDetailId,DH.dtmInvoiceDateTime,dblUnits     
			    from tblTRLoadDistributionHeader DH
				     join tblTRLoadDistributionDetail DD on DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
    			    where DH.intLoadHeaderId = @intLoadHeaderId and isNUll(intLoadDetailId ,0 ) !=0

if @ysnPostOrUnPost = 1
    BEGIN
    --Update the Transport Load as Posted
    	UPDATE	TransportLoad
    	      SET	TransportLoad.ysnPosted = 1
    		  FROM	dbo.tblTRLoadHeader TransportLoad 
    		  WHERE	TransportLoad.intLoadHeaderId = @intLoadHeaderId
    
    --Update the Logistics Load 
    	
       

		select @total = count(*) from @LoadTable
        set @incval = 1 
        WHILE @incval <=@total 
        BEGIN
             select @intLoadDetailId =intLoadDetailId,@dtmDeliveredDate = dtmDeliveredDate,@dblDeliveredQuantity = dblDeliveredQuantity from @LoadTable where @incval = intId

             IF (isNull(@intLoadDetailId,0) != 0)
    	     BEGIN
                 Exec dbo.uspLGUpdateLoadDetails @intLoadDetailId,0,@intLoadHeaderId,@dtmDeliveredDate,@dblDeliveredQuantity
    	     END
    	SET @incval = @incval + 1;
		END
    END
ELSE
    BEGIN
	   --Update the Transport Load as UnPosted
    	UPDATE	TransportLoad
    	      SET	TransportLoad.ysnPosted = 0
    		  FROM	dbo.tblTRLoadHeader TransportLoad 
    		  WHERE	TransportLoad.intLoadHeaderId = @intLoadHeaderId
    
        select @total = count(*) from @LoadTable
        set @incval = 1 
        WHILE @incval <=@total 
        BEGIN
             select @intLoadDetailId =intLoadDetailId,@dtmDeliveredDate = dtmDeliveredDate,@dblDeliveredQuantity = dblDeliveredQuantity from @LoadTable where @incval = intId

             IF (isNull(@intLoadDetailId,0) != 0)
    	     BEGIN
                 Exec dbo.uspLGUpdateLoadDetails @intLoadDetailId,1,@intLoadHeaderId,@dtmDeliveredDate,@dblDeliveredQuantity
    	     END
		   SET @incval = @incval + 1; 
    	END
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