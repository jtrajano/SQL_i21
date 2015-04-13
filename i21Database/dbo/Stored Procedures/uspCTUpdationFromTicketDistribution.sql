CREATE PROCEDURE uspCTUpdationFromTicketDistribution

	@intTicketId INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@dblNetUnits	NUMERIC(10,3),
			@intContractId	INT,
			@intSplitId		INT,
			@dblBalance		NUMERIC(8,4),
			@intEntityId	INT,
			@intItemId		INT,
			@dblNewBalance	NUMERIC(8,4),
			@strInOutFlag	NVARCHAR(4)

	DECLARE @Processed TABLE
	(
		intContractDetailId INT
	)			
	
	IF NOT EXISTS(SELECT * FROM tblSCTicket WHERE intTicketId = @intTicketId)
	BEGIN
		RAISERROR ('Ticket is deleted by other user.',16,1,'WITH NOWAIT')  
	END
	
	SELECT	@dblNetUnits	=	dblNetUnits ,
			@intContractId	=	intContractId ,
			@intSplitId		=	intSplitId ,
			@intEntityId	=	intEntityId,
			@intItemId		=	intItemId,
			@strInOutFlag	=	strInOutFlag 
	FROM	tblSCTicket
	WHERE	intTicketId = @intTicketId
	
	IF	ISNULL(@intSplitId,0) = 0
	BEGIN
		IF	ISNULL(@intContractId,0) = 0
		BEGIN
			SELECT	TOP	1	@intContractId	=	intContractDetailId
			FROM	tblCTContractDetail CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
			WHERE	CH.intPurchaseSale	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
			AND		CH.intEntityId		=	@intEntityId
			AND		CD.intItemId		=	@intItemId
			ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
		END
			
		WHILE	@dblNetUnits > 0 AND ISNULL(@intContractId,0) > 0
		BEGIN
			SELECT	@dblBalance = dblBalance 
			FROM	tblCTContractDetail 
			WHERE	intContractDetailId = @intContractId
	
			IF	@dblNetUnits <= @dblBalance
			BEGIN
				UPDATE	tblCTContractDetail 
				SET		dblBalance = @dblBalance - @dblNetUnits
				WHERE	intContractDetailId = @intContractId
				
				SELECT	@dblNetUnits = 0
				BREAK
			END
			ELSE
			BEGIN
				UPDATE	tblCTContractDetail 
				SET		dblBalance	=	0
				WHERE	intContractDetailId = @intContractId
				
				SELECT	@dblNetUnits	=	@dblNetUnits - @dblBalance					
			END
			
			INSERT	INTO @Processed SELECT @intContractId
		
			SELECT	@intContractId = NULL
			
			SELECT	TOP	1	@intContractId	=	intContractDetailId
			FROM	tblCTContractDetail CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
			WHERE	CH.intPurchaseSale	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
			AND		CH.intEntityId		=	@intEntityId
			AND		CD.intItemId		=	@intItemId
			AND		CD.intContractDetailId NOT IN (SELECT intContractDetailId FROM @Processed)
			ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
		END	
	END
	
	SELECT	@dblNetUnits
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateBalanceFromScale - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO