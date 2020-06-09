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
			@intDonorHeaderId				INT,
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
			@ysnIsHedged					BIT,
			@intReassignAllocationId		INT,
			@intAllocationDetailId			INT,
			@intAllocationHeaderId			INT,
			@dblReassignAllocation			NUMERIC(18,6),
			@ysnFullyAllocation				INT,
			@intContractTypeId				INT,
			@dblReassignRecipientUOM		NUMERIC(18,6),
			@intUnitMeasureId				INT,
			@intNewAllocationDetailId		INT,
			@strTagRelaceXML				NVARCHAR(MAX),
			@intItemId						INT,
			@dblRecipientQty				NUMERIC(18,6),
			@dblDonorQty					NUMERIC(18,6),
			@dblDonorNoOfLots				NUMERIC(18,6),
			@ysnMultiplePriceFixation		BIT,
			@dblDeductedLots				NUMERIC(18,6),
			@intDeductedFutOptTransactionId		INT

	SELECT @intContractTypeId = intContractTypeId FROM tblCTReassign WHERE intReassignId = @intReassignId

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

	DECLARE	@tblAllocation TABLE
	(
		intReassignAllocationId		INT,
		intAllocationDetailId		INT,
		intAllocationHeaderId		INT,
		dblReassign					NUMERIC(18,6),
		ysnFullyAllocation			INT,
		intContractTypeId			INT,
		dblReassignRecipientUOM		NUMERIC(18,6),
		intUnitMeasureId			INT,
		dblReassignInDonorUOM		NUMERIC(18,6)
	)

	SELECT	@intRecipientId			=	RE.intRecipientId,
			@intRecipientHeaderId	=	DR.intContractHeaderId,
			@intDonorId				=	RE.intDonorId,
			@intDonorHeaderId		=	DD.intContractHeaderId,
			@dblRecipientBasis		=	DR.dblBasis,
			@dblRecipientNoOfLots	=	CASE	WHEN	DR.ysnMultiplePriceFixation = 1
												THEN	(SELECT dblNoOfLots FROM tblCTContractHeader WHERE intContractHeaderId = DR.intContractHeaderId) 
												ELSE	DR.dblNoOfLots
										END,
			@intRecipientBookId		=	DR.intBookId,
			@intRecipientSubBookId	=	DR.intSubBookId,
			@dblRecipientQty		=	CASE	WHEN	DR.ysnMultiplePriceFixation = 1
												THEN	(SELECT dblQuantity FROM tblCTContractHeader WHERE intContractHeaderId = DR.intContractHeaderId) 
												ELSE	DR.dblQuantity
										END,
			@dblDonorQty			=	CASE	WHEN	DD.ysnMultiplePriceFixation = 1
												THEN	(SELECT dblQuantity FROM tblCTContractHeader WHERE intContractHeaderId = DD.intContractHeaderId) 
												ELSE	DD.dblQuantity
										END,
			@dblDonorNoOfLots		=	CASE	WHEN	DD.ysnMultiplePriceFixation = 1
												THEN	(SELECT dblNoOfLots FROM tblCTContractHeader WHERE intContractHeaderId = DD.intContractHeaderId) 
												ELSE	DD.dblQuantity
										END,
			@ysnMultiplePriceFixation	=	DD.ysnMultiplePriceFixation

	FROM	tblCTReassign			RE
	JOIN	vyuCTContractSequence	DR	ON	DR.intContractDetailId	=	RE.intRecipientId
	JOIN	vyuCTContractSequence	DD	ON	DD.intContractDetailId	=	RE.intDonorId
	WHERE	RE.intReassignId	=	@intReassignId
	
	INSERT	INTO @tblPricing
	SELECT	RP.intReassignPricingId,
			RP.dblReassign,
			RP.intPriceFixationDetailId,
			F1.intPriceFixationId,
			F1.[dblNoOfLots],
			CAST(ISNULL(F2.intPriceFixationDetailId,0)/ISNULL(F2.intPriceFixationDetailId,1) AS INT) AS ysnFullyPricingReassign,
			F1.intFutOptTransactionId
	FROM	tblCTReassignPricing RP
	JOIN	tblCTPriceFixationDetail	F1	ON	F1.intPriceFixationDetailId	=	RP.intPriceFixationDetailId	LEFT
	JOIN	tblCTPriceFixationDetail	F2	ON	F2.intPriceFixationDetailId =	RP.intPriceFixationDetailId	AND 
											F2.[dblNoOfLots]				=	RP.dblReassign
	WHERE	RP.intReassignId = @intReassignId AND ISNULL(RP.dblReassign,0) > 0
	
	INSERT	INTO @tblFutures
	SELECT	RP.intReassignFutureId,
			RP.dblReassign,
			ISNULL(F1.dblAssignedLots,0) + ISNULL(F1.dblHedgedLots,0),
			CAST(ISNULL(F2.intAssignFuturesToContractSummaryId,0)/ISNULL(F2.intAssignFuturesToContractSummaryId,1) AS INT) AS ysnFullyPricingFutures,
			F1.intFutOptTransactionId,
			RP.intAssignFuturesToContractSummaryId
	FROM	tblCTReassignFuture			RP
	JOIN	tblRKAssignFuturesToContractSummary	F1	ON	F1.intAssignFuturesToContractSummaryId	=	RP.intAssignFuturesToContractSummaryId	LEFT
	JOIN	tblRKAssignFuturesToContractSummary	F2	ON	F2.intAssignFuturesToContractSummaryId	=	RP.intAssignFuturesToContractSummaryId	AND 
														ISNULL(F2.dblAssignedLots,0) + 
														ISNULL(F2.dblHedgedLots,0)				=	RP.dblReassign
	WHERE	RP.intReassignId = @intReassignId AND ISNULL(RP.dblReassign,0) > 0 AND RP.intPriceFixationDetailId IS NULL

	INSERT	INTO  @tblAllocation
	SELECT	RA.intReassignAllocationId,
			RA.intAllocationDetailId,
			AD.intAllocationHeaderId,
			RA.dblReassign,
			CASE	WHEN	CASE	WHEN	RN.intContractTypeId = 1 
									THEN	AD.dblSAllocatedQty - RA.dblReassign
									ELSE	AD.dblPAllocatedQty - RA.dblReassign
							END	=	0 
					THEN 1 
					ELSE 0 
			END,
			RN.intContractTypeId,
			dbo.fnCTConvertQuantityToTargetItemUOM(DR.intItemId,AQ.intUnitMeasureId,RQ.intUnitMeasureId,RA.dblReassign),
			RQ.intUnitMeasureId,
			dbo.fnCTConvertQuantityToTargetItemUOM(DD.intItemId,AQ.intUnitMeasureId,DQ.intUnitMeasureId,RA.dblReassign)
	FROM	tblCTReassignAllocation RA
	JOIN	tblCTReassign			RN	ON	RN.intReassignId			=	RA.intReassignId
	JOIN	tblLGAllocationDetail	AD	ON	RA.intAllocationDetailId	=	AD.intAllocationDetailId
	JOIN	tblCTContractDetail		DR	ON	DR.intContractDetailId		=	RN.intRecipientId
	JOIN	tblICItemUOM			RQ	ON	RQ.intItemUOMId				=	DR.intItemUOMId
	JOIN	tblCTContractDetail		DD	ON	DD.intContractDetailId		=	RN.intDonorId
	JOIN	tblICItemUOM			DQ	ON	DQ.intItemUOMId				=	DD.intItemUOMId
	JOIN	tblICItemUOM			AQ	ON	AQ.intItemUOMId				=	RA.intReassignUOMId
	WHERE	RA.intReassignId = @intReassignId AND ISNULL(RA.dblReassign,0) > 0

	---------------------------------------Pircing------------------------------
	UPDATE	FD
	SET		FD.[dblNoOfLots]	=	FD.[dblNoOfLots] - PR.dblReassign,
			FD.[dblHedgeNoOfLots]	=	FD.[dblHedgeNoOfLots] - PR.dblReassign,
			FD.dblQuantity  = (FD.dblQuantity / FD.[dblNoOfLots]) * (FD.dblNoOfLots - PR.dblReassign)  
			--FD.dblQuantity		=	(@dblDonorQty / @dblDonorNoOfLots) * (FD.dblNoOfLots - PR.dblReassign)
	FROM	tblCTPriceFixationDetail	FD
	JOIN	@tblPricing					PR	ON	PR.intPriceFixationDetailId = FD.intPriceFixationDetailId
	WHERE	PR.ysnFullyPricingReassign = 0
		
	

	SET @strTagRelaceXML =  
	'<root>
		<tags>
			<toFind>&lt;intContractDetailId&gt;'+LTRIM(@intDonorId)+'&lt;/intContractDetailId&gt;</toFind>
			<toReplace>&lt;intContractDetailId&gt;'+LTRIM(@intRecipientId)+'&lt;/intContractDetailId&gt;</toReplace>
		</tags>
		<tags>
			<toFind>&lt;intContractHeaderId&gt;'+LTRIM(@intDonorHeaderId)+'&lt;/intContractHeaderId&gt;</toFind>
			<toReplace>&lt;intContractHeaderId&gt;'+LTRIM(@intRecipientHeaderId)+'&lt;/intContractHeaderId&gt;</toReplace>
		</tags>
	</root>'

	SELECT	@intReassignPricingId = MIN(intReassignPricingId) FROM @tblPricing

	SELECT	@intPriceFixationDetailId	=	intPriceFixationDetailId,
			@dblReassignPricing			=	dblReassign,
			@intPriceFixationId			=	intPriceFixationId,
			@ysnFullyPricingReassign	=	ysnFullyPricingReassign,
			@intFutOptTransactionId		=	intFutOptTransactionId
	FROM	@tblPricing
	WHERE	intReassignPricingId = @intReassignPricingId

	IF ISNULL(@intPriceFixationId,0) > 0
		EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixation',@intPriceFixationId,@intNewPriceFixationId OUTPUT,NULL,@strTagRelaceXML

	UPDATE	tblCTPriceFixation 
	SET		dblOriginalBasis	=	@dblRecipientBasis,
			dblFinalPrice		=	dblPriceWORollArb - dblOriginalBasis - ISNULL(dblRollArb,0) - ISNULL(dblAdditionalCost,0) + @dblRecipientBasis,
			dblRollArb			=	NULL,
			dblAdditionalCost	=	NULL
	WHERE	intPriceFixationId	=	@intNewPriceFixationId

	WHILE	ISNULL(@intReassignPricingId,0) > 0
	BEGIN

		SELECT	@intPriceFixationDetailId		=	NULL,
				@intFutOptTransactionId			=	NULL,
				@intAssignFuturesToContractSummaryId = NULL,
				@ysnFullyPricingReassign		=	NULL,
				@intNewPriceFixationDetailId	=	NULL

		SELECT	@intPriceFixationDetailId	=	intPriceFixationDetailId,
				@dblReassignPricing			=	dblReassign,
				@intPriceFixationId			=	intPriceFixationId,
				@ysnFullyPricingReassign	=	ysnFullyPricingReassign,
				@intFutOptTransactionId		=	intFutOptTransactionId
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

			IF	NOT EXISTS(SELECT TOP 1 1 FROM tblCTSpreadArbitrage WHERE intPriceFixationId = @intPriceFixationId) AND
				NOT EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId)
			BEGIN
				EXEC uspCTPriceFixationSave	@intPriceFixationId, 'Delete', @intUserId
				DELETE FROM tblCTPriceFixation WHERE intPriceFixationId = @intPriceFixationId
			END

			UPDATE	SY
			SET		intContractHeaderId = @intRecipientHeaderId,
					intContractDetailId = @intRecipientId
			FROM	tblRKAssignFuturesToContractSummary SY
			WHERE	intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
		END
		ELSE
		BEGIN

			EXEC  uspCTGetStartingNumber 'Price Fixation Trade No', @strTradeNo OUTPUT

			SET @strXML = '<root>'
			SET @strXML +=		'<toUpdate>' 
			SET @strXML +=			'<strTradeNo>'+@strTradeNo+'</strTradeNo>' 
			SET @strXML +=		'</toUpdate>' 
			SET @strXML += '</root>' 

			EXEC  uspCTCreateADuplicateRecord 'tblCTPriceFixationDetail',@intPriceFixationDetailId,@intNewPriceFixationDetailId OUTPUT,@strXML

			UPDATE	tblCTPriceFixationDetail
			SET		intPriceFixationId	=	@intNewPriceFixationId,
					dblNoOfLots			=	@dblReassignPricing,
					dblHedgeNoOfLots	=	@dblReassignPricing,
					dblQuantity			=	(@dblRecipientQty / @dblRecipientNoOfLots) * @dblReassignPricing
			WHERE	intPriceFixationDetailId = @intNewPriceFixationDetailId
			
			IF ISNULL(@intAssignFuturesToContractSummaryId,0) > 0
			BEGIN
				UPDATE	SY
				SET		dblHedgedLots = dblHedgedLots - @dblReassignPricing
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
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dblNoOfContract/text())[1] with sql:variable("@dblReassignPricing")')
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

				EXEC uspRKAutoHedge @strXML,@intUserId,@intNewFutOptTransactionId OUTPUT

				UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intNewFutOptTransactionId WHERE intPriceFixationDetailId = @intNewPriceFixationDetailId

				/*CT-3724*/

				select @dblDeductedLots = dblNoOfContract - @dblReassignPricing from tblRKFutOptTransaction where intFutOptTransactionId = @intFutOptTransactionId;

				SELECT	@strCondition = 'intFutOptTransactionId = ' + LTRIM(@intFutOptTransactionId)
				EXEC	uspCTGetTableDataInXML 'tblRKFutOptTransaction', @strCondition,@strXML OUTPUT
				SELECT	@XML = @strXML
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmTransactionDate/text())[1] with sql:variable("@dtmCurrentDate")')
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dtmFilledDate/text())[1] with sql:variable("@dtmCurrentDate")')
				SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dblNoOfContract/text())[1] with sql:variable("@dblDeductedLots")')

				SELECT	@strXML = CAST(@XML AS NVARCHAR(MAX))
					
				SELECT @strXML = REPLACE(@strXML,'<tblRKFutOptTransactions>','')
				SELECT @strXML = REPLACE(@strXML,'</tblRKFutOptTransactions>','')
				SELECT @strXML = REPLACE(@strXML,'tblRKFutOptTransaction','root')

				EXEC uspRKAutoHedge @strXML,@intUserId,@intDeductedFutOptTransactionId OUTPUT

				/*End of CT-3724*/
			END
		END

		SELECT	@intReassignPricingId = MIN(intReassignPricingId) FROM @tblPricing WHERE intReassignPricingId > @intReassignPricingId
	END

	UPDATE	PF
	SET		PF.dblPriceWORollArb	=	FD.dblPriceWORollArb,
			PF.[dblLotsFixed]		=	FD.intLotsFixed,
			PF.dblFinalPrice		=	PF.dblFinalPrice - ISNULL(PF.dblPriceWORollArb,0) +  ISNULL(FD.dblPriceWORollArb,0)
	FROM	tblCTPriceFixation			PF
	CROSS APPLY(
			SELECT	intPriceFixationId,
					SUM([dblNoOfLots] * dblFutures)/SUM([dblNoOfLots]) dblPriceWORollArb,
					SUM([dblNoOfLots]) intLotsFixed
		
			FROM	tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
	)	FD		
	WHERE	FD.intPriceFixationId	=	PF.intPriceFixationId AND PF.intPriceFixationId	= @intPriceFixationId

	SELECT	@intLotsHedged	= SUM([dblNoOfLots]) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND ysnHedge = 1

	UPDATE	tblCTPriceFixation 
	SET		intLotsHedged = @intLotsHedged,
			dblTotalLots =	CASE	WHEN @ysnMultiplePriceFixation = 1
								THEN	(SELECT dblNoOfLots FROM tblCTContractHeader WHERE intContractHeaderId = @intDonorHeaderId)  
								ELSE	(SELECT dblNoOfLots FROM tblCTContractDetail WHERE intContractDetailId = @intDonorId)  
							END	
	WHERE intPriceFixationId = @intPriceFixationId

	UPDATE	PF
	SET		PF.dblPriceWORollArb	=	FD.dblPriceWORollArb,
			PF.[dblTotalLots]		=	@dblRecipientNoOfLots,
			PF.[dblLotsFixed]		=	FD.intLotsFixed,
			PF.dblFinalPrice		=	FD.dblPriceWORollArb +  PF.dblOriginalBasis
	FROM	tblCTPriceFixation			PF
	CROSS APPLY(
			SELECT	intPriceFixationId,
					SUM([dblNoOfLots] * dblFutures)/SUM([dblNoOfLots]) dblPriceWORollArb,
					SUM([dblNoOfLots]) intLotsFixed
		
			FROM	tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
	)	FD		
	WHERE	FD.intPriceFixationId	=	PF.intPriceFixationId AND PF.intPriceFixationId	=	@intNewPriceFixationId
		
	SELECT	@intLotsHedged	= SUM([dblNoOfLots]) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intNewPriceFixationId AND ysnHedge = 1
	UPDATE	tblCTPriceFixation SET intLotsHedged = @intLotsHedged  WHERE intPriceFixationId = @intNewPriceFixationId

	EXEC uspCTPriceFixationSave	@intPriceFixationId, 'Save', @intUserId
	EXEC uspCTPriceFixationSave	@intNewPriceFixationId, 'Save', @intUserId

	EXEC uspCTUpdateAdditionalCost @intRecipientHeaderId
	
	
	---------------------------------------End Pricing---------------------------

	---------------------------------------Futures-------------------------------
		
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
					dblHedgedLots = dblHedgedLots - CASE WHEN ISNULL(dblHedgedLots,0) = 0 THEN 0 ElSE @dblReassignFutures END,
					@ysnIsHedged = CAST(CASE WHEN ISNULL(dblHedgedLots,0) > ISNULL(dblAssignedLots,0) THEN 1 ELSE 0 END AS INT)
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
			SET		@XML.modify('replace value of (/tblRKFutOptTransactions/tblRKFutOptTransaction/dblNoOfContract/text())[1] with sql:variable("@dblReassignFutures")')

			IF ISNULL(@intRecipientBookId,0) > 0
				SET		@XML.modify('insert <intBookId>{ xs:string(sql:variable("@intRecipientBookId")) }</intBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
			IF ISNULL(@intRecipientSubBookId,0) > 0
				SET		@XML.modify('insert <intSubBookId>{ xs:string(sql:variable("@intRecipientSubBookId")) }</intSubBookId> into (/tblRKFutOptTransactions/tblRKFutOptTransaction)[1]')
					
			SELECT	@strXML = CAST(@XML AS NVARCHAR(MAX))
					
			SELECT @strXML = REPLACE(@strXML,'<tblRKFutOptTransactions>','')
			SELECT @strXML = REPLACE(@strXML,'</tblRKFutOptTransactions>','')
			SELECT @strXML = REPLACE(@strXML,'tblRKFutOptTransaction','root')

			EXEC uspRKAutoHedge @strXML,@intUserId,@intNewFutOptTransactionId OUTPUT

			SET @strXML = '<root><Transaction>';
			SET @strXML = @strXML + '<intContractHeaderId>' + LTRIM(@intRecipientHeaderId) + '</intContractHeaderId>'
			SET @strXML = @strXML + '<intContractDetailId>' + LTRIM(@intRecipientId) + '</intContractDetailId>'
			SET @strXML = @strXML + '<dtmMatchDate>' + LTRIM(GETDATE()) + '</dtmMatchDate>'
			SET @strXML = @strXML + '<intFutOptTransactionId>' + LTRIM(@intNewFutOptTransactionId) + '</intFutOptTransactionId>'
			SET @strXML = @strXML + '<dblHedgedLots>' + LTRIM(CAST(@dblReassignFutures AS INT) * @ysnIsHedged) + '</dblHedgedLots>'
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
	
	---------------------------------------End Futures---------------------------

	---------------------------------------Allocation----------------------------

	UPDATE	AD 
	SET		AD.intPContractDetailId	=	CASE WHEN AN.intContractTypeId = 1 THEN @intRecipientId ELSE AD.intPContractDetailId END,
			AD.intPUnitMeasureId	=	CASE WHEN AN.intContractTypeId = 1 THEN AN.intUnitMeasureId ELSE AD.intPUnitMeasureId END,
			AD.dblPAllocatedQty		=	CASE WHEN AN.intContractTypeId = 1 THEN AN.dblReassignRecipientUOM ELSE AD.dblPAllocatedQty END,

			AD.intSContractDetailId	=	CASE WHEN AN.intContractTypeId = 2 THEN @intRecipientId ELSE AD.intSContractDetailId END,
			AD.intSUnitMeasureId	=	CASE WHEN AN.intContractTypeId = 2 THEN AN.intUnitMeasureId ELSE AD.intSUnitMeasureId END,
			AD.dblSAllocatedQty		=	CASE WHEN AN.intContractTypeId = 2 THEN AN.dblReassignRecipientUOM ELSE AD.dblSAllocatedQty END,

			AD.dtmAllocatedDate		=	GETDATE()
	FROM	tblLGAllocationDetail	AD
	JOIN	@tblAllocation			AN	ON	AD.intAllocationDetailId = AN.intAllocationDetailId
	WHERE	AN.ysnFullyAllocation	=	1

	UPDATE	AD 
	SET		AD.dblPAllocatedQty		=	AD.dblPAllocatedQty - CASE WHEN AN.intContractTypeId = 1 THEN AN.dblReassignInDonorUOM ELSE AN.dblReassign END,
			AD.dblSAllocatedQty		=	AD.dblSAllocatedQty - CASE WHEN AN.intContractTypeId = 2 THEN AN.dblReassignInDonorUOM ELSE AN.dblReassign END

	FROM	tblLGAllocationDetail	AD
	JOIN	@tblAllocation			AN	ON	AD.intAllocationDetailId = AN.intAllocationDetailId
	WHERE	AN.ysnFullyAllocation	=	0

	INSERT INTO tblLGAllocationDetail
	(
		intConcurrencyId,
		intAllocationHeaderId,
		intPContractDetailId,
		intSContractDetailId,
		dblPAllocatedQty,
		dblSAllocatedQty,
		intPUnitMeasureId,
		intSUnitMeasureId,
		dtmAllocatedDate,
		intUserSecurityId
	)
	SELECT	1,
			AD.intAllocationHeaderId,
			CASE WHEN AN.intContractTypeId = 1 THEN @intRecipientId ELSE AD.intPContractDetailId END,
			CASE WHEN AN.intContractTypeId = 2 THEN @intRecipientId ELSE AD.intSContractDetailId END,
			CASE WHEN AN.intContractTypeId = 1 THEN AN.dblReassignRecipientUOM ELSE AN.dblReassign END,
			CASE WHEN AN.intContractTypeId = 2 THEN AN.dblReassignRecipientUOM ELSE AN.dblReassign END,
			CASE WHEN AN.intContractTypeId = 1 THEN AN.intUnitMeasureId ELSE AD.intPUnitMeasureId END,
			CASE WHEN AN.intContractTypeId = 2 THEN AN.intUnitMeasureId ELSE AD.intSUnitMeasureId END,
			GEtDATE(),
			@intUserId
	FROM	tblLGAllocationDetail	AD
	JOIN	@tblAllocation			AN	ON	AD.intAllocationDetailId = AN.intAllocationDetailId
	WHERE	AN.ysnFullyAllocation	=	0

	IF @intContractTypeId = 1 
	BEGIN
		SELECT @intUnitMeasureId = intUnitMeasureId,@intItemId = intItemId FROM vyuCTContractSequence WHERE intContractDetailId = @intDonorId
		UPDATE tblCTContractDetail 
		SET dblAllocatedQty = (SELECT SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intPUnitMeasureId,@intUnitMeasureId,dblPAllocatedQty)) FROM tblLGAllocationDetail WHERE intPContractDetailId = @intDonorId)	
		WHERE intContractDetailId = @intDonorId

		SELECT @intUnitMeasureId = intUnitMeasureId,@intItemId = intItemId FROM vyuCTContractSequence WHERE intContractDetailId = @intRecipientId
		UPDATE tblCTContractDetail 
		SET dblAllocatedQty = (SELECT SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intPUnitMeasureId,@intUnitMeasureId,dblPAllocatedQty)) FROM tblLGAllocationDetail WHERE intPContractDetailId = @intRecipientId)	
		WHERE intContractDetailId = @intRecipientId
	END
	ELSE
	BEGIN
		SELECT @intUnitMeasureId = intUnitMeasureId,@intItemId = intItemId FROM vyuCTContractSequence WHERE intContractDetailId = @intDonorId
		UPDATE tblCTContractDetail 
		SET dblAllocatedQty = (SELECT SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intSUnitMeasureId,@intUnitMeasureId,dblSAllocatedQty)) FROM tblLGAllocationDetail WHERE intSContractDetailId = @intDonorId)	
		WHERE intContractDetailId = @intDonorId

		SELECT @intUnitMeasureId = intUnitMeasureId,@intItemId = intItemId FROM vyuCTContractSequence WHERE intContractDetailId = @intRecipientId
		UPDATE tblCTContractDetail 
		SET dblAllocatedQty = (SELECT SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intSUnitMeasureId,@intUnitMeasureId,dblSAllocatedQty)) FROM tblLGAllocationDetail WHERE intSContractDetailId = @intRecipientId)	
		WHERE intContractDetailId = @intRecipientId
	END
	
	---------------------------------------End Allocation-------------------------

	EXEC	uspCTCreateDetailHistory	@intContractHeaderId = NULL, 
										@intContractDetailId = @intDonorId,
										@strSource			 = 'Contract',
										@strProcess		     = 'Reassign Save',
										@intUserId			 = @intUserId
	EXEC	uspCTCreateDetailHistory	@intContractHeaderId = NULL, 
										@intContractDetailId = @intRecipientId,
										@strSource			 = 'Contract',
										@strProcess		  	 = 'Reassign Save',
										@intUserId			 = @intUserId
	--COMMIT TRAN
END TRY
BEGIN CATCH
	--ROLLBACK TRAN
	SELECT @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg,16,1)
END CATCH	
