CREATE PROCEDURE uspRKFutOptAssignedSave
	@intContractDetailId INT = NULL
	, @dtmMatchDate DATETIME
	, @intFutOptTransactionId INT
	, @intAssignedLots INT
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
		, @ysnMultiplePriceFixation INT
		, @BalanceLot INT
		
	IF (ISNULL(@strContractNumber, '') <> '')
	BEGIN
		SELECT @ysnMultiplePriceFixation = ISNULL(ysnMultiplePriceFixation, 0)
		FROM tblCTContractHeader
		WHERE intContractHeaderId = @intContractHeaderId
	END
	
	IF (ISNULL(@strContractSeq, '') <> '')
	BEGIN
		SELECT @ysnMultiplePriceFixation = ISNULL(ysnMultiplePriceFixation, 0)
		FROM tblCTContractDetail cd
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE intContractDetailId = @intContractDetailId
	END

	IF (ISNULL(@ysnMultiplePriceFixation, 0) = 0)
	BEGIN
		SELECT @BalanceLot = ISNULL(dblAvailableLot, 0)
		FROM (
			SELECT cd.intContractDetailId
				, dblAvailableLot = ISNULL(SUM(cd.dblNoOfLots), 0)
			FROM vyuCTContractDetailView cd
			WHERE cd.intFutureMarketId IS NOT NULL
				AND cd.intFutureMonthId IS NOT NULL
				AND cd.intContractDetailId = @intContractDetailId
				AND cd.intContractStatusId NOT IN (2, 3)
				AND ISNULL(ysnMultiplePriceFixation, 0) = 0
			GROUP BY strContractNumber
				, cd.intContractDetailId
				, intContractSeq
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, cd.strContractType) t
	END
	ELSE
	BEGIN
		SELECT @BalanceLot = ISNULL(dblAvailableLot, 0)
		FROM (
			SELECT dblAvailableLot = ISNULL(SUM(cd.dblNoOfLots), 0)
			FROM tblCTContractHeader cd
			INNER JOIN tblEMEntity e ON cd.intEntityId = e.intEntityId
			INNER JOIN tblCTContractType ct ON ct.intContractTypeId = cd.intContractTypeId
			WHERE cd.intContractHeaderId = @intContractHeaderId
				AND cd.intFutureMarketId IS NOT NULL
				AND cd.intFutureMonthId IS NOT NULL
				AND intContractHeaderId NOT IN (
					SELECT TOP 1 intContractHeaderId
					FROM tblCTContractDetail
					WHERE intContractStatusId NOT IN (2, 3)
					)
				AND ISNULL(ysnMultiplePriceFixation, 0) = 1
			GROUP BY strContractNumber
				, cd.intContractHeaderId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, ct.strContractType, e.strName) t
	END
	
	--Create a Header
	IF (ISNULL(@ysnMultiplePriceFixation, 0) = 0)
	BEGIN
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
					, intHedgedLots
					, ysnIsHedged
					, intFutOptAssignedId)
				SELECT @intAssignFuturesToContractHeaderId
					, 1
					, NULL
					, @intContractDetailId
					, @dtmMatchDate
					, @intFutOptTransactionId
					, @intAssignedLots
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
					, intHedgedLots
					, ysnIsHedged
					, intFutOptAssignedId)
				SELECT @intAssignFuturesToContractHeaderId
					, 1
					, @intContractHeaderId
					, NULL
					, @dtmMatchDate
					, @intFutOptTransactionId
					, @intAssignedLots
					, 0
					, 0
					, @intFutOptTransactionId
			END
		END
	END
	ELSE IF (ISNULL(@ysnMultiplePriceFixation, 0) = 1)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId)
		BEGIN
			IF (ISNULL(@strContractNumber,'') <> '')
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
					, intHedgedLots
					, ysnIsHedged
					, intFutOptAssignedId)
				SELECT @intAssignFuturesToContractHeaderId
					, 1
					, @intContractHeaderId
					, NULL
					, @dtmMatchDate
					, @intFutOptTransactionId
					, @intAssignedLots
					, 0
					, 0
					, @intFutOptTransactionId
			END
			ELSE IF (ISNULL(@strContractSeq,'') <> '')
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
					, intHedgedLots
					, ysnIsHedged
					, intFutOptAssignedId)
				SELECT @intAssignFuturesToContractHeaderId
					, 1
					, NULL
					, @intContractDetailId
					, @dtmMatchDate
					, @intFutOptTransactionId
					, @intAssignedLots
					, 0
					, 0
					, @intFutOptTransactionId
			END
		END
	END
	
	-- Create a detail
	IF (ISNULL(@ysnMultiplePriceFixation, 0) = 0)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId)
		BEGIN
			IF (ISNULL(@strContractSeq,'') <> '')
			BEGIN
				DECLARE @ExistingContractDetailId INT = NULL
				
				SELECT @ExistingContractDetailId = intContractDetailId
				FROM tblRKAssignFuturesToContractSummary
				WHERE intFutOptAssignedId = @intFutOptTransactionId
				
				IF (ISNULL(@ExistingContractDetailId,0) <> ISNULL(@intContractDetailId,0))
				BEGIN
					UPDATE tblRKAssignFuturesToContractSummary
					SET intContractDetailId = @intContractDetailId
						, dblAssignedLots = @intAssignedLots
						, intContractHeaderId = NULL
					WHERE intFutOptAssignedId = @intFutOptTransactionId
				END
			END
		END
	END
	
	IF (ISNULL(@ysnMultiplePriceFixation, 0) = 1)
	BEGIN
		IF (ISNULL(@strContractNumber,'') <> '')
		BEGIN
			DECLARE @intExistingContractHeaderId INT = NULL
			
			SELECT @intExistingContractHeaderId = intContractHeaderId
			FROM tblRKAssignFuturesToContractSummary
			WHERE intFutOptAssignedId = @intFutOptTransactionId
			
			IF (ISNULL(@intExistingContractHeaderId,0) <> ISNULL(@intContractHeaderId,0))
			BEGIN
				UPDATE tblRKAssignFuturesToContractSummary
				SET intContractHeaderId = @intContractHeaderId
					, dblAssignedLots = @intAssignedLots
					, intContractDetailId = NULL
				WHERE intFutOptAssignedId = @intFutOptTransactionId
			END
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