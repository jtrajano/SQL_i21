CREATE PROCEDURE [dbo].[uspTRLoadProcessTransportLoad]
	 @intLoadHeaderId AS INT	 
	 , @ysnPostOrUnPost AS BIT
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

	DECLARE @intLoadDetailId INT
		, @Id INT
		, @dtmDeliveredDate DATETIME
		, @dblDeliveredQuantity DECIMAL(18, 6)

	DECLARE @LoadTable TABLE
	(
		intId INT IDENTITY PRIMARY KEY CLUSTERED
		, [intLoadDetailId] INT NULL
		, [dtmDeliveredDate] DATETIME NULL
		, [dblDeliveredQuantity] DECIMAL(18,6) NULL
	)

	--Update the Transport Load as Posted/Unposted
	UPDATE	TransportLoad
		SET	TransportLoad.ysnPosted = @ysnPostOrUnPost
	FROM	dbo.tblTRLoadHeader TransportLoad
	WHERE	TransportLoad.intLoadHeaderId = @intLoadHeaderId

	INSERT INTO @LoadTable
	SELECT  DD.intLoadDetailId
		, DH.dtmInvoiceDateTime
		, (CASE WHEN LH.ysnPosted = 1 THEN ISNULL(dblUnits, 0)
			ELSE 0 END)
	FROM tblTRLoadDistributionHeader DH
		JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
		JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = DH.intLoadHeaderId
	WHERE DH.intLoadHeaderId = @intLoadHeaderId AND ISNULL(intLoadDetailId, 0) != 0

	WHILE EXISTS(SELECT TOP 1 1 FROM @LoadTable)
	BEGIN
		SELECT TOP 1 @Id = intId
			, @intLoadDetailId =intLoadDetailId
			, @dtmDeliveredDate = dtmDeliveredDate
			, @dblDeliveredQuantity = dblDeliveredQuantity
		FROM @LoadTable

		IF (ISNULL(@intLoadDetailId,0) != 0)
    	BEGIN
			IF (@ysnPostOrUnPost = 1)
			BEGIN
				EXEC dbo.uspLGUpdateLoadDetails @intLoadDetailId,0,@intLoadHeaderId,@dtmDeliveredDate,@dblDeliveredQuantity
			END
			ELSE
			BEGIN
				EXEC dbo.uspLGUpdateLoadDetails @intLoadDetailId,1,@intLoadHeaderId,@dtmDeliveredDate,@dblDeliveredQuantity
			END
    	END
		
		DELETE FROM @LoadTable WHERE intId = @Id
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