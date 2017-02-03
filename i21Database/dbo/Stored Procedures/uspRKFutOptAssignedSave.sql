CREATE PROCEDURE uspRKFutOptAssignedSave 
			@intContractDetailId INT = NULL, 
			@dtmMatchDate DATETIME, 
			@intFutOptTransactionId INT, 
			@intAssignedLots INT, 
			@intContractHeaderId INT = NULL, 
			@strContractSeq NVARCHAR(50) = NULL, 
			@strContractNumber NVARCHAR(50) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intAssignFuturesToContractHeaderId INT
	DECLARE @ysnMultiplePriceFixation INT
	DECLARE @BalanceLot INT
		
	IF ISNULL(@strContractNumber, '') <> ''
	BEGIN
		SELECT @ysnMultiplePriceFixation = isnull(ysnMultiplePriceFixation, 0)
		FROM tblCTContractHeader
		WHERE intContractHeaderId = @intContractHeaderId
	END

IF ISNULL(@strContractSeq, '') <> ''
	BEGIN
		SELECT @ysnMultiplePriceFixation = isnull(ysnMultiplePriceFixation, 0)
		FROM tblCTContractDetail cd
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE intContractDetailId = @intContractDetailId
	END

	IF isnull(@ysnMultiplePriceFixation, 0) = 0
	BEGIN
		SELECT @BalanceLot = isnull(dblAvailableLot, 0)
		FROM (
			SELECT cd.intContractDetailId, isnull(SUM(cd.dblNoOfLots), 0) AS dblAvailableLot
			FROM vyuCTContractDetailView cd
			WHERE cd.intFutureMarketId IS NOT NULL AND cd.intFutureMonthId IS NOT NULL AND cd.intContractDetailId = @intContractDetailId AND cd.intContractStatusId NOT IN (2, 3) AND isnull(ysnMultiplePriceFixation, 0) = 0
			GROUP BY strContractNumber, cd.intContractDetailId, intContractSeq, cd.intFutureMarketId, cd.intFutureMonthId, cd.strContractType
			) t
	END
	ELSE
	BEGIN
		SELECT @BalanceLot = isnull(dblAvailableLot, 0)
		FROM (
			SELECT isnull(SUM(cd.dblNoOfLots), 0) AS dblAvailableLot
			FROM tblCTContractHeader cd
			INNER JOIN tblEMEntity e ON cd.intEntityId = e.intEntityId
			INNER JOIN tblCTContractType ct ON ct.intContractTypeId = cd.intContractTypeId
			WHERE cd.intContractHeaderId = @intContractHeaderId AND cd.intFutureMarketId IS NOT NULL AND cd.intFutureMonthId IS NOT NULL AND intContractHeaderId NOT IN (
					SELECT TOP 1 intContractHeaderId
					FROM tblCTContractDetail
					WHERE intContractStatusId NOT IN (2, 3)
					) AND isnull(ysnMultiplePriceFixation, 0) = 1
			GROUP BY strContractNumber, cd.intContractHeaderId, cd.intFutureMarketId, cd.intFutureMonthId, ct.strContractType, e.strName
			) t
	END

	BEGIN TRANSACTION

 --Create a Header
	IF (isnull(@ysnMultiplePriceFixation, 0) = 0)
	BEGIN

	IF NOT EXISTS (SELECT * FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId)
				BEGIN

					IF (isnull(@strContractSeq,'') <> '')
					BEGIN
						INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId) VALUES (1)

						SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();

						INSERT INTO tblRKAssignFuturesToContractSummary (intAssignFuturesToContractHeaderId, intConcurrencyId, intContractHeaderId, intContractDetailId, dtmMatchDate, intFutOptTransactionId, dblAssignedLots, intHedgedLots, ysnIsHedged, intFutOptAssignedId)
						SELECT @intAssignFuturesToContractHeaderId, 1, NULL, @intContractDetailId, @dtmMatchDate, @intFutOptTransactionId, @intAssignedLots, 0, 0, @intFutOptTransactionId
					END
				END
	END

	ELSE IF (isnull(@ysnMultiplePriceFixation, 0) = 1)
	BEGIN

	IF NOT EXISTS (SELECT * FROM tblRKAssignFuturesToContractSummary WHERE  intFutOptAssignedId = @intFutOptTransactionId)
		BEGIN

		   IF (isnull(@strContractNumber,'') <> '')
		   BEGIN
				INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId)
				VALUES (1)

				SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();

				INSERT INTO tblRKAssignFuturesToContractSummary (intAssignFuturesToContractHeaderId, intConcurrencyId, intContractHeaderId, intContractDetailId, dtmMatchDate, intFutOptTransactionId, dblAssignedLots, intHedgedLots, ysnIsHedged, intFutOptAssignedId)
				SELECT @intAssignFuturesToContractHeaderId, 1, @intContractHeaderId, NULL, @dtmMatchDate, @intFutOptTransactionId, @intAssignedLots, 0, 0, @intFutOptTransactionId
			END
		END
	END

-- Create a detail
	IF (isnull(@ysnMultiplePriceFixation, 0) = 0)
		BEGIN

		IF EXISTS(SELECT *	FROM tblRKAssignFuturesToContractSummary WHERE  intFutOptAssignedId = @intFutOptTransactionId)
			BEGIN	
				IF (isnull(@strContractSeq,'') <> '')
					DECLARE @ExistingContractDetailId INT = null

					SELECT @ExistingContractDetailId = intContractDetailId
					FROM tblRKAssignFuturesToContractSummary 
					WHERE intFutOptAssignedId = @intFutOptTransactionId
	
					IF (isnull(@ExistingContractDetailId,0) <> isnull(@intContractDetailId,0))
					BEGIN
						UPDATE tblRKAssignFuturesToContractSummary
						SET intContractDetailId = @intContractDetailId, dblAssignedLots = @intAssignedLots,intContractHeaderId = null WHERE intFutOptAssignedId = @intFutOptTransactionId
					END				
			END
		END

		IF (isnull(@ysnMultiplePriceFixation, 0) = 1)
		BEGIN   	
			IF (isnull(@strContractNumber,'') <> '')
			BEGIN
				DECLARE @intExistingContractHeaderId INT = null
			
				SELECT @intExistingContractHeaderId = intContractHeaderId FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId = @intFutOptTransactionId

				IF (isnull(@intExistingContractHeaderId,0) <> isnull(@intContractHeaderId,0))
				BEGIN
					UPDATE tblRKAssignFuturesToContractSummary
					SET intContractHeaderId = @intContractHeaderId, dblAssignedLots = @intAssignedLots,intContractDetailId= null where intFutOptAssignedId = @intFutOptTransactionId
				END
			END
		 END

				IF EXISTS (	SELECT * FROM tblRKAssignFuturesToContractSummary 
							WHERE intFutOptAssignedId = @intFutOptTransactionId AND isnull(@strContractNumber, '') = ''	and isnull(@strContractSeq, '') = '')
				BEGIN				
					DELETE	FROM tblRKAssignFuturesToContractSummary
					WHERE intFutOptAssignedId = @intFutOptTransactionId 			

				END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH