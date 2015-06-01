CREATE PROCEDURE uspCTUpdationFromTicketDistribution

	@intTicketId	INT,
	@intEntityId	INT,
	@dblNetUnits	NUMERIC(10,3),
	@intContractId	INT,
	@intUserId		INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@dblBalance			NUMERIC(12,4),			
			@intItemId			INT,
			@dblNewBalance		NUMERIC(12,4),
			@strInOutFlag		NVARCHAR(4),
			@dblQuantity		NUMERIC(12,4),
			@strAdjustmentNo	NVARCHAR(50),
			@dblCost			NUMERIC(9,4)

	DECLARE @Processed TABLE
	(
			intContractDetailId INT,
			dblUnitsDistributed NUMERIC(12,4),
			dblUnitsRemaining	NUMERIC(12,4),
			dblOldQuantity		NUMERIC(12,4),
			dblOldBalance		NUMERIC(12,4),			
			dblAdjAmount		NUMERIC(12,4),			
			dblNewBalance		NUMERIC(12,4),				
			dblNewQuantity		NUMERIC(12,4),	
			strAdjustmentNo		NVARCHAR(50),
			dblCost				NUMERIC(9,4)
	)			
	
	IF NOT EXISTS(SELECT * FROM tblSCTicket WHERE intTicketId = @intTicketId)
	BEGIN
		RAISERROR ('Ticket is deleted by other user.',16,1,'WITH NOWAIT')  
	END
	
	SELECT	@intItemId		=	intItemId,
			@strInOutFlag	=	strInOutFlag 
	FROM	tblSCTicket
	WHERE	intTicketId = @intTicketId
	
	
	IF	ISNULL(@intContractId,0) = 0
	BEGIN
		SELECT	TOP	1	@intContractId	=	intContractDetailId
		FROM	tblCTContractDetail CD
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		WHERE	CH.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CH.intEntityId		=	@intEntityId
		AND		CD.intItemId		=	@intItemId
		AND		CD.intPricingTypeId	=	1
		AND		CD.dblBalance		>	0
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
	END
	
	IF	ISNULL(@intContractId,0) = 0
	BEGIN
		SELECT	TOP	1	@intContractId	=	intContractDetailId
		FROM	tblCTContractDetail CD
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		WHERE	CH.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CH.intEntityId		=	@intEntityId
		AND		CD.intItemId		=	@intItemId
		AND		CD.intPricingTypeId	=	2
		AND		CD.dblBalance		>	0
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
	END
		
	WHILE	@dblNetUnits > 0 AND ISNULL(@intContractId,0) > 0
	BEGIN
		SELECT	@dblBalance		=	dblBalance,
				@dblQuantity	=	dblQuantity,
				@dblCost		=	ISNULL(dblBasis,0)+ISNULL(dblFutures,0)
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId = @intContractId

		IF NOT @dblBalance > 0
		BEGIN
			GOTO CONTINUEISH
		END

		SELECT	@strAdjustmentNo = strPrefix+LTRIM(intNumber) 
		FROM	tblSMStartingNumber 
		WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'

		UPDATE	tblSMStartingNumber
		SET		intNumber = intNumber+1
		WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'

		IF	@dblNetUnits <= @dblBalance
		BEGIN
			UPDATE	tblCTContractDetail 
			SET		dblBalance = @dblBalance - @dblNetUnits
			WHERE	intContractDetailId = @intContractId
			
			INSERT	INTO @Processed SELECT @intContractId,@dblNetUnits,NULL,@dblQuantity,@dblBalance,@dblNetUnits,@dblBalance - @dblNetUnits,@dblQuantity,@strAdjustmentNo,@dblCost

			SELECT	@dblNetUnits = 0

			BREAK
		END
		ELSE
		BEGIN
			UPDATE	tblCTContractDetail 
			SET		dblBalance	=	0
			WHERE	intContractDetailId = @intContractId
			
			INSERT	INTO @Processed SELECT @intContractId,@dblBalance,NULL,@dblQuantity,@dblBalance,@dblBalance,0,@dblQuantity,@strAdjustmentNo,@dblCost

			SELECT	@dblNetUnits	=	@dblNetUnits - @dblBalance					
		END
		
		CONTINUEISH:

		SELECT	@intContractId = NULL
		
		SELECT	TOP	1	@intContractId	=	intContractDetailId
		FROM	tblCTContractDetail CD
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		WHERE	CH.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CH.intEntityId		=	@intEntityId
		AND		CD.intItemId		=	@intItemId
		AND		CD.intPricingTypeId	=	1
		AND		CD.dblBalance		>	0
		AND		CD.intContractDetailId NOT IN (SELECT intContractDetailId FROM @Processed)
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC

		IF	ISNULL(@intContractId,0) = 0
		BEGIN
			SELECT	TOP	1	@intContractId	=	intContractDetailId
			FROM	tblCTContractDetail CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
			WHERE	CH.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
			AND		CH.intEntityId		=	@intEntityId
			AND		CD.intItemId		=	@intItemId
			AND		CD.intPricingTypeId	=	2
			AND		CD.dblBalance		>	0
			AND		CD.intContractDetailId NOT IN (SELECT intContractDetailId FROM @Processed)
			ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
		END
	END	
	
	UPDATE	@Processed SET dblUnitsRemaining = @dblNetUnits
	
	INSERT INTO tblCTContractAdjustment
	(
			intContractDetailId,	strAdjustmentNo,		dtmAdjustmentDate,			strComment,						ysnAdjustment,		dblOldQuantity,
			dblOldBalance,			dblAdjAmount,			dblNewBalance,				dblNewQuantity,					dblContractPrice,	dblCancellationPrice,
			dblGainLossPerUnit,		dblCancelFeePerUnit,	dblCancelFeeFlatAmount,		dblTotalGainLoss,				intUserId,			dtmCreatedDate,intTicketId
	)
	SELECT	intContractDetailId,	strAdjustmentNo,		GETDATE(),					NULL,							0,					dblOldQuantity,
			dblOldBalance,			dblAdjAmount,			dblNewBalance,				dblNewQuantity,					NULL,				NULL,
			NULL,					NULL,					NULL,						NULL,							@intUserId,			GETDATE(),@intTicketId
			
	FROM	@Processed

	UPDATE	@Processed SET dblUnitsRemaining = @dblNetUnits
	
	SELECT	intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost
	FROM	@Processed
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateBalanceFromScale - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO