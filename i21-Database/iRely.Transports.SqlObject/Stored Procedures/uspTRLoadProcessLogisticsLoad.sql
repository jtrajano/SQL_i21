CREATE PROCEDURE [dbo].[uspTRLoadProcessLogisticsLoad]
	 @intLoadHeaderId AS INT,
	 @action AS NVARCHAR(50),
	 @intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

DECLARE  @intLoadId AS INT,
         @intLoadDetailId AS INT,
		 @intPContractDetailId AS INT,
		 @intSContractDetailId AS INT,
		 @dblQuantity AS NUMERIC(18,6),
		 @dblDeleteQuantity AS NUMERIC(18,6)

BEGIN TRY

	SELECT @intLoadId = intLoadId FROM tblTRLoadHeader WHERE intLoadHeaderId = @intLoadHeaderId
	SELECT DISTINCT intLoadDetailId
	INTO #LoadTable
	FROM tblTRLoadReceipt
	WHERE intLoadHeaderId = @intLoadHeaderId AND ISNULL(intLoadDetailId,'') <> ''
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #LoadTable)
	BEGIN
		SELECT TOP 1 @intLoadDetailId = intLoadDetailId FROM #LoadTable
		
		IF (@action = 'Added')
		BEGIN
			EXEC uspLGUpdateLoadDetails @intLoadDetailId, 1, @intLoadHeaderId, null, null
		END
		
		SELECT @intPContractDetailId = intPContractDetailId
			, @intSContractDetailId = intSContractDetailId
			, @dblQuantity = dblQuantity
			, @dblDeleteQuantity = dblQuantity * -1
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		IF (@action = 'Delete')
		BEGIN
			UPDATE tblLGLoad
			SET intLoadHeaderId = NULL,
				ysnInProgress = 0,
				intConcurrencyId = intConcurrencyId + 1
			WHERE intLoadId=@intLoadId
			
			UPDATE tblTRLoadReceipt
			SET intLoadDetailId = NULL
			WHERE intLoadDetailId = @intLoadDetailId
			
			UPDATE tblTRLoadDistributionDetail
			SET intLoadDetailId = NULL
			WHERE intLoadDetailId = @intLoadDetailId

			IF (ISNULL(@intPContractDetailId, '') <> '')
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intPContractDetailId, @dblDeleteQuantity, @intUserId, @intLoadDetailId, 'Transport Purchase'
				EXEC uspCTUpdateScheduleQuantity @intPContractDetailId, @dblQuantity, @intUserId, @intLoadDetailId, 'Load Schedule'
			END
			IF (ISNULL(@intSContractDetailId, '') <> '')
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intSContractDetailId, @dblDeleteQuantity, @intUserId, @intLoadDetailId, 'Transport Sale'
				EXEC uspCTUpdateScheduleQuantity @intSContractDetailId, @dblQuantity, @intUserId, @intLoadDetailId, 'Load Schedule'
			END
		END
		ELSE IF (@action = 'Added')
		BEGIN
			IF (ISNULL(@intPContractDetailId, '') <> '')
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intPContractDetailId, @dblDeleteQuantity, @intUserId, @intLoadDetailId, 'Load Schedule'
			END
		
			IF (ISNULL(@intSContractDetailId, '') <> '')
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intSContractDetailId, @dblDeleteQuantity, @intUserId, @intLoadDetailId, 'Load Schedule'
			END
		END		

		DELETE FROM #LoadTable WHERE intLoadDetailId = @intLoadDetailId
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