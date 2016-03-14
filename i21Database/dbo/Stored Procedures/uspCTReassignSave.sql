CREATE PROCEDURE [dbo].[uspCTReassignSave]
	@intReassignId	INT,
	@intUserId		INT
			
AS

BEGIN TRY
	--BEGIN TRAN
	DECLARE	@intReassignPricingId			INT,
			@intPriceFixationDetailId		INT,
			@intPriceFixationId				INT,
			@dblReassignPricing				NUMERIC(18,6),
			@dblReassignFutures				NUMERIC(18,6),
			@ysnFullyPricingReassign		INT,
			@ysnFullyPricingFutures			INT,
			@intRecipientId					INT,
			@intRecipientHeaderId			INT,
			@intDonorId						INT,
			@dblRecipientBasis				NUMERIC(18,6),
			@intNewPriceFixationId			INT,
			@strTradeNo						NVARCHAR(100),
			@strXML							NVARCHAR(MAX),
			@intNewPriceFixationDetailId	INT,
			@dblRecipientNoOfLots			NUMERIC(18,6),
			@intFutOptTransactionId			INT,
			@intAssignFuturesToContractSummaryId INT,
			@XML							XML,
			@strCondition					NVARCHAR(100),
			@dtmCurrentDate					DATETIME = GETDATE(),
			@intRecipientBookId				INT,
			@intRecipientSubBookId			INT,
			@intNewFutOptTransactionId		INT,
			@ErrMsg							NVARCHAR(MAX),
			@intLotsHedged					INT,
			@intReassignFutureId			INT,
			@ysnIsHedged					BIT

	DECLARE	@tblPricing TABLE
	(
		intReassignPricingId		INT,
		dblReassign					NUMERIC(18,6),
		intPriceFixationDetailId	INT,
		intPriceFixationId			INT,
		intNoOfLots					INT,
		ysnFullyPricingReassign		INT,
		intFutOptTransactionId		INT
	)

	DECLARE	@tblFutures TABLE
	(
		intReassignFutureId			INT,
		dblReassign					NUMERIC(18,6),
		intNoOfLots					INT,
		ysnFullyPricingFutures		INT,
		intFutOptTransactionId		INT,
		intAssignFuturesToContractSummaryId INT
	)

	SELECT	@intRecipientId			=	RE.intRecipientId,
			@intRecipientHeaderId	=	HR.intContractHeaderId,
			@intDonorId				=	RE.intDonorId,
			@dblRecipientBasis		=	DR.dblBasis,
			@dblRecipientNoOfLots	=	DR.dblNoOfLots,
			@intRecipientBookId		=	DR.intBookId,
			@intRecipientSubBookId	=	DR.intSubBookId
	FROM	tblCTReassign		RE
	JOIN	tblCTContractDetail	DR	ON	DR.intContractDetailId	=	RE.intRecipientId
	JOIN	tblCTContractHeader HR	ON	HR.intContractHeaderId	=	DR.intContractHeaderId
	WHERE	RE.intReassignId	=	@intReassignId
	
	INSERT	INTO @tblPricing
	SELECT	RP.intReassignPricingId,
			RP.dblReassign,
			RP.intPriceFixationDetailId,
			F1.intPriceFixationId,
			F1.intNoOfLots,
			CAST(ISNULL(F2.intPriceFixationDetailId,0)/ISNULL(F2.intPriceFixationDetailId,1) AS INT) AS ysnFullyPricingReassign,
			F1.intFutOptTransactionId
	FROM	tblCTReassignPricing RP
	JOIN	tblCTPriceFixationDetail	F1	ON	F1.intPriceFixationDetailId	=	RP.intPriceFixationDetailId	LEFT
	JOIN	tblCTPriceFixationDetail	F2	ON	F2.intPriceFixationDetailId =	RP.intPriceFixationDetailId	AND 
											F2.intNoOfLots				=	RP.dblReassign
	WHERE	RP.intReassignId = @intReassignId AND ISNULL(RP.dblReassign,0) > 0
	
	INSERT	INTO @tblFutures
	SELECT	RP.intReassignFutureId,
			RP.dblReassign,
			ISNULL(F1.dblAssignedLots,0) + ISNULL(F1.intHedgedLots,0),
			CAST(ISNULL(F2.intAssignFuturesToContractSummaryId,0)/ISNULL(F2.intAssignFuturesToContractSummaryId,1) AS INT) AS ysnFullyPricingFutures,
			F1.intFutOptTransactionId,
			RP.intAssignFuturesToContractSummaryId
	FROM	tblCTReassignFuture			RP
	JOIN	tblRKAssignFuturesToContractSummary	F1	ON	F1.intAssignFuturesToContractSummaryId	=	RP.intAssignFuturesToContractSummaryId	LEFT
	JOIN	tblRKAssignFuturesToContractSummary	F2	ON	F2.intAssignFuturesToContractSummaryId	=	RP.intAssignFuturesToContractSummaryId	AND 
														ISNULL(F2.dblAssignedLots,0) + 
														ISNULL(F2.intHedgedLots,0)				=	RP.dblReassign
	WHERE	RP.intReassignId = @intReassignId AND ISNULL(RP.dblReassign,0) > 0 AND RP.intPriceFixationDetailId IS NULL

	UPDATE	FD
	SET		FD.intNoOfLots = FD.intNoOfLots - PR.dblReassign
	FROM	tblCTPriceFixationDetail	FD
	JOIN	@tblPricing					PR	ON	PR.intPriceFixationDetailId = FD.intPriceFixationDetailId
	WHERE	PR.ysnFullyPricingReassign = 0
		
	SELECT	@ysnFullyPricingReassign = MIN(ysnFullyPricingReassign),@intPriceFixationId = MIN(intPriceFixationId),@intReassignPricingId = MIN(intReassignPricingId) FROM @tblPricing

	EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixation',@intPriceFixationId,@intNewPriceFixationId OUTPUT

	UPDATE	tblCTPriceFixation 
	SET		intContractDetailId =	@intRecipientId,
			intContractHeaderId	=	@intRecipientHeaderId,
			dblOriginalBasis	=	@dblRecipientBasis,
			dblFinalPrice		=	dblPriceWORollArb - dblOriginalBasis - ISNULL(dblRollArb,0) - ISNULL(dblAdditionalCost,0) + @dblRecipientBasis,
			dblRollArb			=	NULL,
			dblAdditionalCost	=	NULL
	WHERE	intPriceFixationId	=	@intNewPriceFixationId

	IF	@ysnFullyPricingReassign = 1
	BEGIN

		UPDATE	tblCTPriceFixationDetail 
		SET		intPriceFixationId	=	@intNewPriceFixationId
		WHERE	intPriceFixationId	=	@intPriceFixationId

		IF EXISTS(SELECT TOP 1 1 FROM tblCTSpreadArbitrage WHERE intPriceFixationId = @intPriceFixationId)
		BEGIN
			EXEC uspCTPriceFixationSave	@intPriceFixationId, 'Save', @intUserId
		END
		ELSE
		BEGIN
			EXEC uspCTPriceFixationSave	@intPriceFixationId, 'Delete', @intUserId
			DELETE FROM tblCTPriceFixation WHERE intPriceFixationId = @intPriceFixationId
		END

		EXEC uspCTPriceFixationSave	@intNewPriceFixationId, 'Save', @intUserId
		EXEC uspCTUpdateAdditionalCost @intRecipientHeaderId

		UPDATE	SY
		SET		intContractHeaderId = @intRecipientHeaderId,
				intContractDetailId = @intRecipientId
		FROM	tblRKAssignFuturesToContractSummary SY
		JOIN	@tblPricing PR	ON	PR.intFutOptTransactionId	=	SY.intFutOptTransactionId AND
									SY.intContractDetailId		=	@intDonorId
	END
	ELSE
	BEGIN
		WHILE	ISNULL(@intReassignPricingId,0) > 0
		BEGIN
			SELECT	@intPriceFixationDetailId = NULL,
					@intFutOptTransactionId = NULL,
					@intAssignFuturesToContractSummaryId = NULL,
					@ysnFullyPricingReassign = NULL,
					@intNewPriceFixationDetailId = NULL

			SELECT	@intPriceFixationDetailId = intPriceFixationDetailId,
					@dblReassignPricing = dblReassign,
					@intPriceFixationId = intPriceFixationId,
					@ysnFullyPricingReassign = ysnFullyPricingReassign,
					@intFutOptTransactionId  = intFutOptTransactionId
			FROM	@tblPricing
			WHERE	intReassignPricingId = @intReassignPricingId

			IF ISNULL(@intFutOptTransactionId,0) > 0
			BEGIN
				SELECT @intAssignFuturesToContractSummaryId = intAssignFuturesToContractSummaryId FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId = @intFutOptTransactionId AND ysnIsHedged = 1 		
			END

			IF @ysnFullyPricingReassign = 1
			BEGIN
				UPDATE	tblCTPriceFixationDetail
				SET		intPriceFixationId = @intNewPriceFixationId
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

				UPDATE	SY
				SET		intContractHeaderId = @intRecipientHeaderId,
						intContractDetailId = @intRecipientId
				FROM	tblRKAssignFuturesToContractSummary SY
				WHERE	intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
			END
			ELSE
			BEGIN

				EXEC  @strTradeNo =  uspCTGetStartingNumber 'Price Fixation Trade No'

				SET @strXML = '<root>'
				SET @strXML +=		'<toUpdate>' 
				SET @strXML +=			'<strTradeNo>'+@strTradeNo+'</strTradeNo>' 
				SET @strXML +=		'</toUpdate>' 
				SET @strXML += '</root>' 

				EXEC  uspCTCreateADuplicateRecord 'tblCTPriceFixationDetail',@intPriceFixationDetailId,@intNewPriceFixationDetailId OUTPUT,@strXML

				UPDATE	tblCTPriceFixationDetail
				SET		intPriceFixationId = @intNewPriceFixationId,
						intNoOfLots = @dblReassignPricing
				WHERE	intPriceFixationDetailId = @intNewPriceFixationDetailId

				IF ISNULL(@intAssignFuturesToContractSummaryId,0) > 0
				BEGIN
					UPDATE	SY
					SET		intHedgedLots = intHedgedLots - @dblReassignPricing
					FROM	tblRKAssignFuturesToContractSummary SY
					WHERE	intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId

					SELECT	@strCondition = 'intFutOptTransactionId = ' + LTRIM(@intFutOptTransactionId)
					EXEC	uspCTGetTableDataInXML 'tblRKFutOptTransaction', @strCondition,@strXML OUTPUT
					SELECT	@XML = @strXML
					SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intFutOptTransactionId)[1]')
					SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/strInternalTradeNo)[1]')
					SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intBookId)[1]')
					SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intSubBookId)[1]')
					SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmTransactionDate/text())[1] with sql:variable("@dtmCurrentDate")')
					SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmFilledDate/text())[1] with sql:variable("@dtmCurrentDate")')
					SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/intNoOfContract/text())[1] with sql:variable("@dblReassignPricing")')
					SET		@XML.modify('insert <intContractHeaderId>{ xs:string(sql:variable("@intRecipientHeaderId")) }</intContractHeaderId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
					SET		@XML.modify('insert <intContractDetailId>{ xs:string(sql:variable("@intRecipientId")) }</intContractDetailId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')

					IF ISNULL(@intRecipientBookId,0) > 0
						SET		@XML.modify('insert <intBookId>{ xs:string(sql:variable("@intRecipientBookId")) }</intBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
					IF ISNULL(@intRecipientSubBookId,0) > 0
						SET		@XML.modify('insert <intSubBookId>{ xs:string(sql:variable("@intRecipientSubBookId")) }</intSubBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
					
					SELECT	@strXML = CAST(@XML AS NVARCHAR(MAX))
					
					SELECT @strXML = REPLACE(@strXML,'<tblRKFutOptTransactions>','')
					SELECT @strXML = REPLACE(@strXML,'</tblRKFutOptTransactions>','')
					SELECT @strXML = REPLACE(@strXML,'tblRKFutOptTransaction','root')

					EXEC uspRKAutoHedge @strXML,@intNewFutOptTransactionId OUTPUT

					UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intNewFutOptTransactionId WHERE intPriceFixationDetailId = @intNewPriceFixationDetailId
				END
			END

			SELECT	@intReassignPricingId = MIN(intReassignPricingId) FROM @tblPricing WHERE intReassignPricingId > @intReassignPricingId
		END

		UPDATE	PF
		SET		PF.dblPriceWORollArb	=	FD.dblPriceWORollArb,
				PF.intLotsFixed			=	FD.intLotsFixed,
				PF.dblFinalPrice		=	PF.dblFinalPrice - ISNULL(PF.dblPriceWORollArb,0) +  ISNULL(FD.dblPriceWORollArb,0)
		FROM	tblCTPriceFixation			PF
		CROSS APPLY(
				SELECT	intPriceFixationId,
						SUM(intNoOfLots * dblFutures)/SUM(intNoOfLots) dblPriceWORollArb,
						SUM(intNoOfLots) intLotsFixed
		
				FROM	tblCTPriceFixationDetail
				GROUP BY intPriceFixationId
		)	FD		
		WHERE	FD.intPriceFixationId	=	PF.intPriceFixationId AND PF.intPriceFixationId	= @intPriceFixationId

		SELECT	@intLotsHedged	= SUM(intNoOfLots) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND ysnHedge = 1
		UPDATE	tblCTPriceFixation SET intLotsHedged = @intLotsHedged  WHERE intPriceFixationId = @intPriceFixationId

		UPDATE	PF
		SET		PF.dblPriceWORollArb	=	FD.dblPriceWORollArb,
				PF.intTotalLots			=	@dblRecipientNoOfLots,
				PF.intLotsFixed			=	FD.intLotsFixed,
				PF.dblFinalPrice		=	FD.dblPriceWORollArb +  PF.dblOriginalBasis
		FROM	tblCTPriceFixation			PF
		CROSS APPLY(
				SELECT	intPriceFixationId,
						SUM(intNoOfLots * dblFutures)/SUM(intNoOfLots) dblPriceWORollArb,
						SUM(intNoOfLots) intLotsFixed
		
				FROM	tblCTPriceFixationDetail
				GROUP BY intPriceFixationId
		)	FD		
		WHERE	FD.intPriceFixationId	=	PF.intPriceFixationId AND PF.intPriceFixationId	=	@intNewPriceFixationId
		
		SELECT	@intLotsHedged	= SUM(intNoOfLots) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intNewPriceFixationId AND ysnHedge = 1
		UPDATE	tblCTPriceFixation SET intLotsHedged = @intLotsHedged  WHERE intPriceFixationId = @intNewPriceFixationId

		EXEC uspCTPriceFixationSave	@intPriceFixationId, 'Save', @intUserId
		EXEC uspCTPriceFixationSave	@intNewPriceFixationId, 'Save', @intUserId

		EXEC uspCTUpdateAdditionalCost @intRecipientHeaderId

		SELECT @intReassignFutureId = MIN(intReassignFutureId) FROM @tblFutures

		WHILE ISNULL(@intReassignFutureId,0) > 0
		BEGIN
			SELECT	@intAssignFuturesToContractSummaryId = NULL,
					@ysnFullyPricingReassign = NULL

			SELECT	@intAssignFuturesToContractSummaryId	=	intAssignFuturesToContractSummaryId,
					@ysnFullyPricingReassign				=	ysnFullyPricingFutures,
					@dblReassignFutures						=	dblReassign,
					@intFutOptTransactionId					=	intFutOptTransactionId
			FROM	@tblFutures 
			WHERE	intReassignFutureId = @intReassignFutureId

			IF @ysnFullyPricingReassign = 1
			BEGIN
				UPDATE tblRKAssignFuturesToContractSummary SET intContractHeaderId = @intRecipientHeaderId,intContractDetailId = @intRecipientId WHERE intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
			END
			ELSE
			BEGIN
				UPDATE	tblRKAssignFuturesToContractSummary 
				SET		dblAssignedLots = dblAssignedLots - CASE WHEN ISNULL(dblAssignedLots,0) = 0 THEN  0 ElSE @dblReassignFutures END,
						intHedgedLots = intHedgedLots - CASE WHEN ISNULL(intHedgedLots,0) = 0 THEN 0 ElSE @dblReassignFutures END,
						@ysnIsHedged = CAST(CASE WHEN ISNULL(intHedgedLots,0) > ISNULL(dblAssignedLots,0) THEN 1 ELSE 0 END AS INT)
				WHERE	intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId

				SELECT	@strCondition = 'intFutOptTransactionId = ' + LTRIM(@intFutOptTransactionId)
				EXEC	uspCTGetTableDataInXML 'tblRKFutOptTransaction', @strCondition,@strXML OUTPUT
				SELECT	@XML = @strXML
				SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intFutOptTransactionId)[1]')
				SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/strInternalTradeNo)[1]')
				SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intBookId)[1]')
				SET		@XML.modify('delete (/tblRKFutOptTransactions/tblRKFutOptTransaction/intSubBookId)[1]')
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmTransactionDate/text())[1] with sql:variable("@dtmCurrentDate")')
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmFilledDate/text())[1] with sql:variable("@dtmCurrentDate")')
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/intNoOfContract/text())[1] with sql:variable("@dblReassignFutures")')

				IF ISNULL(@intRecipientBookId,0) > 0
					SET		@XML.modify('insert <intBookId>{ xs:string(sql:variable("@intRecipientBookId")) }</intBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
				IF ISNULL(@intRecipientSubBookId,0) > 0
					SET		@XML.modify('insert <intSubBookId>{ xs:string(sql:variable("@intRecipientSubBookId")) }</intSubBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
					
				SELECT	@strXML = CAST(@XML AS NVARCHAR(MAX))
					
				SELECT @strXML = REPLACE(@strXML,'<tblRKFutOptTransactions>','')
				SELECT @strXML = REPLACE(@strXML,'</tblRKFutOptTransactions>','')
				SELECT @strXML = REPLACE(@strXML,'tblRKFutOptTransaction','root')

				EXEC uspRKAutoHedge @strXML,@intNewFutOptTransactionId OUTPUT

				SET @strXML = '<root><Transaction>';
				SET @strXML = @strXML + '<intContractHeaderId>' + LTRIM(@intRecipientHeaderId) + '</intContractHeaderId>'
				SET @strXML = @strXML + '<intContractDetailId>' + LTRIM(@intRecipientId) + '</intContractDetailId>'
				SET @strXML = @strXML + '<dtmMatchDate>' + LTRIM(GETDATE()) + '</dtmMatchDate>'
				SET @strXML = @strXML + '<intFutOptTransactionId>' + LTRIM(@intNewFutOptTransactionId) + '</intFutOptTransactionId>'
				SET @strXML = @strXML + '<intHedgedLots>' + LTRIM(CAST(@dblReassignFutures AS INT) * @ysnIsHedged) + '</intHedgedLots>'
				IF	@ysnIsHedged = 0
					SET @strXML = @strXML + '<dblAssignedLots>'+LTRIM(@dblReassignFutures)+'</dblAssignedLots>'
				ElSE
					SET @strXML = @strXML + '<dblAssignedLots>0</dblAssignedLots>'
				SET @strXML = @strXML + '<ysnIsHedged>'+LTRIM(@ysnIsHedged)+'</ysnIsHedged>'
				SET @strXML = @strXML + '</Transaction></root>'

				EXEC uspRKAssignFuturesToContractSummarySave @strXML
			END

			SELECT	@intReassignFutureId = MIN(intReassignFutureId) FROM @tblFutures WHERE intReassignFutureId > @intReassignFutureId
		END
	END
	--COMMIT TRAN
END TRY
BEGIN CATCH
	--ROLLBACK TRAN
	SELECT @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg,16,1)
END CATCH	
