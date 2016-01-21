CREATE PROCEDURE [dbo].[uspTRLoadProcessLogisticsLoad]
	 @strTransaction AS nvarchar(50),
	 @action as nvarchar(50),
	 @intUserId as int
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE  @intLoadHeaderId AS INT,
         @intLoadDetailId as int;
DECLARE @intPContractDetailId as int,
        @intSContractDetailId as int,
		@total int,
		@incval int,
        @dblQuantity as float;

DECLARE @LoadTable TABLE
(
    intId INT IDENTITY PRIMARY KEY CLUSTERED,
	[intLoadDetailId] INT NULL
)

BEGIN TRY
  select @intLoadHeaderId = intLoadHeaderId from tblTRLoadHeader where strTransaction = @strTransaction

  insert into @LoadTable select distinct intLoadDetailId from tblTRLoadReceipt where intLoadHeaderId = @intLoadHeaderId and isNUll(intLoadDetailId ,0 ) !=0
--Update the Logistics Load for InProgress 
	
select @total = count(*) from @LoadTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
     select @intLoadDetailId =intLoadDetailId  from @LoadTable where @incval = intId

    IF (isNull(@intLoadDetailId,0) != 0)
	BEGIN
	   if (@action = 'Added')
	   BEGIN
        Exec dbo.uspLGUpdateLoadDetails @intLoadDetailId,1,@intLoadHeaderId,null,null
       END
		SELECT @intPContractDetailId = intPContractDetailId, @intSContractDetailId = intSContractDetailId,@dblQuantity = dblQuantity from tblLGLoadDetail WHERE intLoadDetailId=@intLoadDetailId
		if (@action = 'Added')
		    BEGIN
		        set @dblQuantity = @dblQuantity * -1
		    END
		IF (isNull(@intPContractDetailId,0) != 0)
		  Begin		    
		     exec uspCTUpdateScheduleQuantity @intPContractDetailId, @dblQuantity,@intUserId,@intLoadDetailId,'Load Schedule'
		  END

	   IF (isNull(@intSContractDetailId,0) != 0)
		  Begin		    
		    exec uspCTUpdateScheduleQuantity @intSContractDetailId, @dblQuantity,@intUserId,@intLoadDetailId,'Load Schedule'
		  END

	   if (@action = 'Delete')
	   BEGIN
	      UPDATE tblLGLoad SET 
			intLoadHeaderId=null,
			ysnInProgress = 0,
			intConcurrencyId	=	intConcurrencyId + 1
		  WHERE intLoadId=@intLoadDetailId
		  UPDATE tblTRLoadReceipt SET 
			intLoadDetailId = null
		  WHERE intLoadDetailId=@intLoadDetailId
		  UPDATE tblTRLoadDistributionDetail SET 
			intLoadDetailId = null
		  WHERE intLoadDetailId=@intLoadDetailId
	   END
	END
	set @incval = @incval + 1;
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