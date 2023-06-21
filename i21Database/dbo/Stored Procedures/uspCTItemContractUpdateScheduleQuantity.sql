CREATE PROCEDURE [dbo].[uspCTItemContractUpdateScheduleQuantity]

	@intItemContractDetailId	INT, 
	@dblQuantityToUpdate		NUMERIC(18,6),
	@intUserId					INT,
	@intTransactionDetailId		INT,
	@strScreenName				NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE 
			@dblOrigContracted			NUMERIC(18,6),
			@dblOrigScheduled			NUMERIC(18,6),
			@dblOrigAvailable			NUMERIC(18,6),
			@dblOrigApplied				NUMERIC(18,6),
			@dblOrigBalance				NUMERIC(18,6),
			@dblNewContracted			NUMERIC(18,6),
			@dblNewScheduled			NUMERIC(18,6),
			@dblNewAvailable			NUMERIC(18,6),
			@dblNewApplied				NUMERIC(18,6),
			@dblNewBalance				NUMERIC(18,6),

			@strBalance					NVARCHAR(100),
			@strAvailable				NVARCHAR(100),
			@strQuantityToUpdate		NVARCHAR(100),

			@dblTolerance				NUMERIC(18,6) = 0.0001,
			@intContractStatusId		INT,
			@dtmOrigLastDeliveryDate	DATETIME,
			@intLineNo					INT,
			@strLineNo					NVARCHAR(50),
			@strItemContractNumber		NVARCHAR(50),
			@strTransactionId			NVARCHAR(50),
			@intTransactionId			INT,
			@strReason					NVARCHAR(50),
			@ErrMsg						NVARCHAR(MAX),
			@dtmTransactionDate			DATETIME

	IF NOT EXISTS(SELECT * FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
	BEGIN
		RAISERROR('Item contract is deleted by other user.',16,1)
	END 	

	BEGINING:

	SELECT	@dblOrigContracted			=	ISNULL(D.dblContracted,0),
			@dblOrigScheduled			=	ISNULL(D.dblScheduled,0),
			@dblOrigAvailable			=	ISNULL(D.dblAvailable,0),
			@dblOrigApplied				=	ISNULL(D.dblApplied,0),
			@dblOrigBalance				=	ISNULL(D.dblBalance,0),
			@intContractStatusId		=	D.intContractStatusId,
			@intLineNo					=	D.intLineNo,
			@dtmOrigLastDeliveryDate	=	D.dtmLastDeliveryDate,

			@strItemContractNumber		=	H.strContractNumber

	FROM	tblCTItemContractDetail		D
	JOIN	tblCTItemContractHeader		H	ON	H.intItemContractHeaderId	=	D.intItemContractHeaderId 
	WHERE	intItemContractDetailId	=	@intItemContractDetailId

	SET @strBalance = LTRIM(CAST(@dblOrigBalance AS NVARCHAR(100)))
	SET @strAvailable = LTRIM(CAST(@dblOrigAvailable AS NVARCHAR(100)))
	SET @strQuantityToUpdate = @dblQuantityToUpdate
	SET @strLineNo = LTRIM(CAST(@intLineNo AS NVARCHAR(50)))

	-- VALIDATION #1
	IF @dblOrigScheduled + @dblQuantityToUpdate > @dblOrigBalance
	BEGIN		
		IF ((@dblOrigScheduled + @dblQuantityToUpdate) - @dblOrigBalance) > @dblTolerance
		BEGIN
			RAISERROR('Available quantity for the item contract %s and line number %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strItemContractNumber,@strLineNo,@strAvailable,@strQuantityToUpdate)
		END
		ELSE
		BEGIN
			SET @dblQuantityToUpdate = ISNULL(@dblQuantityToUpdate,0) - ((ISNULL(@dblOrigScheduled,0) + ISNULL(@dblQuantityToUpdate,0)) - ISNULL(@dblOrigBalance,0))
		END
	END

	-- VALIDATION #2
	IF	@dblOrigScheduled + @dblQuantityToUpdate < 0 
	BEGIN		
		IF ABS(@dblOrigScheduled + @dblQuantityToUpdate) > @dblTolerance
		BEGIN
			IF @intContractStatusId IN (5,6) AND @strScreenName = 'Load Schedule'
			BEGIN
				SET @dblQuantityToUpdate = ISNULL(@dblQuantityToUpdate,0) - (ISNULL(@dblOrigScheduled,0) + ISNULL(@dblQuantityToUpdate,0))
			END
			ELSE
			BEGIN
				SET @ErrMsg = 'Total scheduled quantity cannot be less than zero for item contract '+ @strItemContractNumber + ' and line number ' +	@strLineNo	+'.'
				RAISERROR(@ErrMsg,16,1)
			END
		END
		ELSE
		BEGIN
			SET @dblQuantityToUpdate = ISNULL(@dblQuantityToUpdate,0) - (ISNULL(@dblOrigScheduled,0) + ISNULL(@dblQuantityToUpdate,0))
		END 
	END

	SELECT	@dblNewScheduled =	ISNULL(@dblOrigScheduled,0) + ISNULL(@dblQuantityToUpdate,0)	
	SELECT	@dblNewAvailable =	(ISNULL(@dblOrigContracted,0) - ISNULL(@dblNewScheduled,0)) - ISNULL(@dblNewApplied,0)


	-- SCREEN / MODULE SWITCHER
	IF @strScreenName = 'Invoice'
	BEGIN
		SELECT @strTransactionId	=	B.strInvoiceNumber,
			   @intTransactionId	=	A.intInvoiceId
			FROM tblARInvoiceDetail A
			LEFT JOIN tblARInvoice B ON A.intInvoiceId = B.intInvoiceId
				WHERE A.intInvoiceDetailId = @intTransactionDetailId
	END

	set @dtmTransactionDate = getdate();


	-- INSERT HISTORY
	EXEC uspCTItemContractCreateHistory 
			@intItemContractDetailId	=	@intItemContractDetailId, 
			@intTransactionId			=	@intTransactionId, 
			@intTransactionDetailId		=	@intTransactionDetailId,
			@strTransactionId			=	@strTransactionId,
			@intUserId					=	@intUserId,
			@strTransactionType			=	@strScreenName,
			@dblNewContracted			=	@dblOrigContracted,
			@dblNewScheduled			=	@dblNewScheduled,
			@dblNewAvailable			=	@dblOrigAvailable,
			@dblNewApplied				=	@dblOrigApplied,
			@dblNewBalance				=	@dblOrigBalance,
			@intNewContractStatusId		=	@intContractStatusId,
			@dtmNewLastDeliveryDate		=	@dtmOrigLastDeliveryDate,
			@dtmTransactionDate			=	@dtmTransactionDate


	-- UPDATE ITEM CONTRACT
	UPDATE 	tblCTItemContractDetail
	SET		dblScheduled			=	ISNULL(@dblNewScheduled,0),
			dblAvailable			=	ISNULL(@dblNewAvailable,0),
			intConcurrencyId		=	intConcurrencyId + 1
	WHERE	intItemContractDetailId =	@intItemContractDetailId


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO