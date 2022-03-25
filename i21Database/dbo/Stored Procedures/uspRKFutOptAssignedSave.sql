CREATE PROCEDURE uspRKFutOptAssignedSave
	@intContractDetailId INT = NULL
	, @dtmMatchDate DATETIME = NULL
	, @intFutOptTransactionId INT
	, @dblAssignedLots numeric(18,6)
	, @intContractHeaderId INT = NULL
	, @strContractSeq NVARCHAR(50) = NULL
	, @strContractNumber NVARCHAR(50) = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @intAssignFuturesToContractHeaderId INT


	IF EXISTS(SELECT TOP 1 1 FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId)
	BEGIN
		IF (ISNULL(@strContractSeq,'') <> '')
		BEGIN
			DECLARE @ExistingContractDetailId INT = NULL
			
			SELECT TOP 1 @ExistingContractDetailId = intContractDetailId
			FROM tblRKAssignFuturesToContractSummary
			WHERE intFutOptAssignedId = @intFutOptTransactionId
			
			IF (ISNULL(@ExistingContractDetailId,0) <> ISNULL(@intContractDetailId,0))
			BEGIN
				UPDATE tblRKAssignFuturesToContractSummary
				SET intContractDetailId = @intContractDetailId
					, dblAssignedLots = @dblAssignedLots
					, intContractHeaderId = NULL
				WHERE intFutOptAssignedId = @intFutOptTransactionId
			END
		END
	END

	IF (ISNULL(@strContractNumber,'') <> '')
	BEGIN
		DECLARE @intExistingContractHeaderId INT = NULL
		
		SELECT TOP 1 @intExistingContractHeaderId = intContractHeaderId
		FROM tblRKAssignFuturesToContractSummary
		WHERE intFutOptAssignedId = @intFutOptTransactionId
		
		IF (ISNULL(@intExistingContractHeaderId,0) <> ISNULL(@intContractHeaderId,0))
		BEGIN
			UPDATE tblRKAssignFuturesToContractSummary
			SET intContractHeaderId = @intContractHeaderId
				, dblAssignedLots = @dblAssignedLots
				, intContractDetailId = NULL
			WHERE intFutOptAssignedId = @intFutOptTransactionId
		END
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId)
	BEGIN
		IF (ISNULL(@strContractSeq,'') <> '')
		BEGIN
			INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId) VALUES (1)
			
			SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY()
			
			INSERT INTO tblRKAssignFuturesToContractSummary (intAssignFuturesToContractHeaderId
				, intConcurrencyId
				, intContractHeaderId
				, intContractDetailId
				, dtmMatchDate
				, intFutOptTransactionId
				, dblAssignedLots
				, dblHedgedLots
				, ysnIsHedged
				, intFutOptAssignedId)
			SELECT @intAssignFuturesToContractHeaderId
				, 1
				, @intContractHeaderId
				, @intContractDetailId
				, @dtmMatchDate
				, @intFutOptTransactionId
				, @dblAssignedLots
				, 0
				, 0
				, @intFutOptTransactionId
		END
		ELSE IF (ISNULL(@strContractNumber,'') <> '')
		BEGIN
			INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId) VALUES (1)
			
			SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY()
			
			INSERT INTO tblRKAssignFuturesToContractSummary (intAssignFuturesToContractHeaderId
				, intConcurrencyId
				, intContractHeaderId
				, intContractDetailId
				, dtmMatchDate
				, intFutOptTransactionId
				, dblAssignedLots
				, dblHedgedLots
				, ysnIsHedged
				, intFutOptAssignedId)
			SELECT @intAssignFuturesToContractHeaderId
				, 1
				, @intContractHeaderId
				, NULL
				, @dtmMatchDate
				, @intFutOptTransactionId
				, @dblAssignedLots
				, 0
				, 0
				, @intFutOptTransactionId
		END
	END
	
	IF EXISTS (SELECT TOP 1 1 FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId AND ISNULL(@strContractNumber, '') = '' AND ISNULL(@strContractSeq, '') = '')
	BEGIN
		DELETE FROM tblRKAssignFuturesToContractSummary
		WHERE intFutOptAssignedId = @intFutOptTransactionId
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