CREATE PROCEDURE [dbo].[uspTRLoadProcessContracts]
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

DECLARE @intContractDetailId AS INT,
		@dblQuantity AS NUMERIC(18, 6),
		@intReceiptId INT,
		@intDistributionId INT

BEGIN TRY
	
	--Receipts which used Contract
	SELECT TR.intContractDetailId
		, dblQuantity = CASE WHEN SP.strGrossOrNet = 'Gross' THEN TR.dblGross
							WHEN SP.strGrossOrNet = 'Net' THEN TR.dblNet END
		, intLoadReceiptId
	INTO #tmpReceipt
	FROM tblTRLoadReceipt TR
	LEFT JOIN tblTRLoadHeader TL ON TL.intLoadHeaderId = TR.intLoadHeaderId
	LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = TR.intSupplyPointId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId AND ISNULL(TR.intContractDetailId, '') <> ''
				
    WHILE EXISTS (SELECT TOP 1 1 FROM #tmpReceipt)
    BEGIN
		SELECT TOP 1 @dblQuantity = dblQuantity
			, @intContractDetailId = intContractDetailId
			, @intReceiptId = intLoadReceiptId
		FROM #tmpReceipt
		
		IF (@action = 'Delete')
		BEGIN
			SET @dblQuantity = @dblQuantity * -1
		END
		
		EXEC uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity, @intUserId, @intReceiptId, 'Transport Purchase'
		
		DELETE FROM #tmpReceipt WHERE intLoadReceiptId = @intReceiptId
    END
  
	--Distribution which used Contract
	SELECT DD.intContractDetailId
		,DD.dblUnits
		,DD.intLoadDistributionDetailId
	INTO #tmpDistribution
	FROM tblTRLoadHeader TL
	JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
	JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId AND ISNULL(DD.intContractDetailId, '') <> ''
				
    WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDistribution)
    BEGIN
		SELECT TOP 1 @dblQuantity = dblUnits
			, @intContractDetailId = intContractDetailId
			, @intDistributionId = intLoadDistributionDetailId
		FROM #tmpDistribution
		
		IF (@action = 'Delete')
		BEGIN
			SET @dblQuantity = @dblQuantity * -1
		END
		
		EXEC uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity, @intUserId, @intDistributionId, 'Transport Sale'
		
		DELETE FROM #tmpDistribution WHERE intLoadDistributionDetailId = @intDistributionId
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