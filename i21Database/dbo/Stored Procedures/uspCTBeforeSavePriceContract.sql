CREATE PROCEDURE [dbo].[uspCTBeforeSavePriceContract]
		
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX),
	@ysnDeleteFromInvoice bit = 0
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@intUniqueId				INT,
			@intPriceFixationId			INT,
			@intContractHeaderId		INT,
			@intContractDetailId		INT,			
			@intUserId					INT,
			@strRowState				NVARCHAR(50),
			@Condition					NVARCHAR(MAX),
			@intPriceFixationDetailId	INT,
			@intPriceFixationTicketId	INT,
			@intFutOptTransactionId		INT,
			@strAction					NVARCHAR(50) = '',
			@intFutOptTransactionHeaderId INT = NULL,
			@intContractTypeId 			INT

	--IF @strXML = 'Delete'
	--BEGIN
	--	IF EXISTS(SELECT TOP 1 1 FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM tblAPBillDetail WHERE intContractDetailId IN (SELECT intContractDetailId FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId)) AND ysnPosted = 1)
	--	BEGIN

	--		DECLARE @TransactionID NVARCHAR(MAX)
	--		SELECT @TransactionID = COALESCE(@TransactionID + ', ', '') + strBillId FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM tblAPBillDetail WHERE intContractDetailId IN (SELECT intContractDetailId FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId)) AND ysnPosted = 1
			
	--		SET @ErrMsg = 'Cannot delete pricing as following Invoice/Vouchers are available. ' + @TransactionID + '. Unpost those Invoice/Voucher to continue delete the price.'
	--		RAISERROR(@ErrMsg,16,1)
	--	END
	--END

	SELECT @intContractTypeId = b.intContractTypeId
	FROM tblCTPriceFixation a
	INNER JOIN tblCTContractHeader b on a.intContractHeaderId = b.intContractHeaderId
	WHERE a.intPriceContractId = @intPriceContractId

	IF @strXML = 'Delete'
	BEGIN
		SET	@strAction = @strXML
		SET @Condition = 'intPriceContractId = ' + LTRIM(@intPriceContractId)
		EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTPriceFixation', @Condition, @strXML OUTPUT,null,'intPriceFixationId,intContractHeaderId,intContractDetailId,''Delete'' AS strRowState'
		
		EXEC [dbo].[uspCTInterCompanyPriceContract] @intPriceContractId = @intPriceContractId
													,@ysnApprove = 0
													,@strRowState = 'Delete'
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML

	IF OBJECT_ID('tempdb..#ProcessFixation') IS NOT NULL  	
		DROP TABLE #ProcessFixation	

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixation
	FROM OPENXML(@idoc,'tblCTPriceFixations/tblCTPriceFixation',2)          
	WITH
	(
		intPriceFixationId	INT,
		strRowState			NVARCHAR(50)
	)      

	IF OBJECT_ID('tempdb..#ProcessFixationDetail') IS NOT NULL  	
		DROP TABLE #ProcessFixationDetail

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixationDetail
	FROM OPENXML(@idoc,'tblCTPriceFixationDetails/tblCTPriceFixationDetail',2)
	WITH
	(
		intPriceFixationDetailId	INT,
		strRowState					NVARCHAR(50)
	) 
	
	IF OBJECT_ID('tempdb..#ProcessFixationTicket') IS NOT NULL  	
	DROP TABLE #ProcessFixationTicket

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixationTicket
	FROM OPENXML(@idoc,'tblCTPriceFixationTickets/tblCTPriceFixationTicket',2)
	WITH
	(
		intPriceFixationTicketId	INT,
		strRowState					NVARCHAR(50)
	)     

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@strRowState			=	NULL,
				@intPriceFixationDetailId = NULL

		SELECT	@intPriceFixationId		=	intPriceFixationId,
				@strRowState			=	strRowState
		FROM	#ProcessFixation 
		WHERE	intUniqueId				=	 @intUniqueId
		
		IF @strRowState = 'Delete'
		BEGIN
			EXEC uspCTValidatePriceFixationDetailUpdateDelete @intPriceFixationId = @intPriceFixationId
			EXEC uspCTPriceFixationDetailDelete @intPriceFixationId = @intPriceFixationId, @intUserId = @intUserId
		END

		SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
		
		WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
		
			SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId	
			FROM	tblCTPriceFixationDetail	FD
			WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

			IF @strRowState = 'Delete' AND ISNULL(@intFutOptTransactionId,0) > 0
			BEGIN
				-- DERIVATIVE ENTRY HISTORY
				SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
				EXEC uspRKFutOptTransactionHistory @intFutOptTransactionId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'DELETE'
				UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
				EXEC uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
			END
			 
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
		END
		
		EXEC uspCTPriceFixationSave @intPriceFixationId,@strRowState,@intUserId

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation WHERE intUniqueId > @intUniqueId
	END

	SELECT @intUniqueId = NULL
	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationDetail

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@strRowState			=	NULL,
				@intPriceFixationDetailId = NULL,
				@intFutOptTransactionId	=	NULL

		SELECT	@intPriceFixationDetailId	=	intPriceFixationDetailId,
				@strRowState				=	strRowState
		FROM	#ProcessFixationDetail 
		WHERE	intUniqueId				=	 @intUniqueId
		
		SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId	
		FROM	tblCTPriceFixationDetail	FD
		WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId
		
		IF @strRowState = 'Delete'
		BEGIN
			EXEC uspCTValidatePriceFixationDetailUpdateDelete @intPriceFixationDetailId = @intPriceFixationDetailId
			EXEC uspCTPriceFixationDetailDelete @intPriceFixationDetailId = @intPriceFixationDetailId, @intUserId = @intUserId
		END

		IF @strRowState = 'Delete' AND ISNULL(@intFutOptTransactionId,0) > 0
		BEGIN
			-- DERIVATIVE ENTRY HISTORY
			SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
			EXEC uspRKFutOptTransactionHistory @intFutOptTransactionId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'DELETE'
			UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
			EXEC uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
		END
		
		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationDetail WHERE intUniqueId > @intUniqueId
	END

	SELECT @intUniqueId = NULL
	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationTicket

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId			=	NULL,
				@strRowState				=	NULL,
				@intPriceFixationTicketId	=	NULL,
				@intFutOptTransactionId		=	NULL

		SELECT	@intPriceFixationTicketId	=	intPriceFixationTicketId,
				@strRowState				=	strRowState
		FROM	#ProcessFixationTicket
		WHERE	intUniqueId					=	 @intUniqueId
		
		IF @strRowState = 'Delete'
		BEGIN
			EXEC uspCTValidatePriceFixationDetailUpdateDelete @intPriceFixationTicketId = @intPriceFixationTicketId
			EXEC uspCTPriceFixationDetailDelete @intPriceFixationTicketId = @intPriceFixationTicketId, @intUserId = @intUserId
		END
				
		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationTicket WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH