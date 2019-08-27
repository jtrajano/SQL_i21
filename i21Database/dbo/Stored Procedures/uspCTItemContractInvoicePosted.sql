CREATE PROCEDURE [dbo].[uspCTItemContractInvoicePosted]
	 @ItemsFromInvoice CTItemContractTable READONLY
	,@intUserId  INT
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @tblToProcess TABLE
	(
		[intUniqueId]							INT IDENTITY(1,1) NOT NULL,
		[intItemContractHeaderId]				[int] NULL,	
		[intItemContractDetailId]				[int] NULL,	
		[intLineNo]								[int] NULL,	
		[intItemId]								[int] NULL,	
		[strItemDescription]					[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,

		[dtmDeliveryDate]						[datetime] NULL,
		[dtmOldLastDeliveryDate]				[datetime] NULL,	
		[dtmNewLastDeliveryDate]				[datetime] NULL,	

		[dblOldContracted]						[numeric](18, 6) NULL,
		[dblOldScheduled]						[numeric](18, 6) NULL,
		[dblOldAvailable]						[numeric](18, 6) NULL,
		[dblOldApplied]							[numeric](18, 6) NULL,
		[dblOldBalance]							[numeric](18, 6) NULL,
		[dblOldTax]								[numeric](18, 6) NULL,
		[dblOldPrice]							[numeric](18, 6) NULL,
		[dblOldTotal]							[numeric](18, 6) NULL,

		[dblNewContracted]						[numeric](18, 6) NULL,
		[dblNewScheduled]						[numeric](18, 6) NULL,
		[dblNewAvailable]						[numeric](18, 6) NULL,
		[dblNewApplied]							[numeric](18, 6) NULL,
		[dblNewBalance]							[numeric](18, 6) NULL,
		[dblNewTax]								[numeric](18, 6) NULL,
		[dblNewPrice]							[numeric](18, 6) NULL,
		[dblNewTotal]							[numeric](18, 6) NULL,

		[intOldContractStatusId]				[int] NULL,
		[intNewContractStatusId]				[int] NULL,

		[intItemUOMId]							[int] NULL,		
		[intTaxGroupId]							[int] NULL,

		[strTransactionId]						[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,
		[intTransactionId]						[int] NULL,
		[intTransactionDetailId]				[int] NULL,
		[intEntityId]							[int] NULL,
		[strTransactionType]					[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,
		[dtmTransactionDate]					[datetime] NULL,
		[intConcurrencyId]						[int] NULL
	)

	INSERT INTO @tblToProcess(
		  [intItemContractHeaderId]	
		 ,[intItemContractDetailId]	
		 ,[intLineNo]					
		 ,[intItemId]					
		 ,[strItemDescription]		
		 
		 ,[dtmDeliveryDate]			
		 ,[dtmOldLastDeliveryDate]	
		 ,[dtmNewLastDeliveryDate]	
		 
		 ,[dblOldContracted]			
		 ,[dblOldScheduled]			
		 ,[dblOldAvailable]			
		 ,[dblOldApplied]				
		 ,[dblOldBalance]				
		 ,[dblOldTax]					
		 ,[dblOldPrice]				
		 ,[dblOldTotal]				
		 
		 ,[dblNewContracted]			
		 ,[dblNewScheduled]			
		 ,[dblNewAvailable]			
		 ,[dblNewApplied]				
		 ,[dblNewBalance]				
		 ,[dblNewTax]					
		 ,[dblNewPrice]				
		 ,[dblNewTotal]				
		
		 ,[intOldContractStatusId]	
		 ,[intNewContractStatusId]	
		 
		 ,[intItemUOMId]				
		 ,[intTaxGroupId]				
		 
		 ,[strTransactionId]			
		 ,[intTransactionId]			
		 ,[intTransactionDetailId]	
		 ,[intEntityId]				
		 ,[strTransactionType]		
		 ,[dtmTransactionDate]		
		 ,[intConcurrencyId]
		 )
	SELECT
		  I.[intItemContractHeaderId]	
		 ,I.[intItemContractDetailId]	
		 ,D.[intLineNo]					
		 ,I.[intItemId]					
		 ,I.[strItemDescription]		
		 
		 ,D.[dtmDeliveryDate]			
		 ,D.[dtmLastDeliveryDate]	
		 ,GETDATE()
		 
		 ,D.[dblContracted]			
		 ,D.[dblScheduled]			
		 ,D.[dblAvailable]			
		 ,D.[dblApplied]				
		 ,D.[dblBalance]				
		 ,D.[dblTax]					
		 ,D.[dblPrice]				
		 ,D.[dblTotal]				
		 
		 ,(D.[dblContracted])
		 ,(D.[dblScheduled]) - (I.dblQtyShipped)
		 ,(D.[dblContracted] - (D.[dblScheduled] - I.dblQtyShipped)) - (D.[dblApplied] + I.dblQtyShipped)
		 ,(D.[dblApplied]) + (I.dblQtyShipped)
		 ,(D.[dblContracted] - ((D.[dblApplied]) + (I.dblQtyShipped)))
		 ,(D.[dblTax])
		 ,(D.[dblPrice])
		 ,(D.[dblTotal])
		
		 ,D.[intContractStatusId]	
		 ,CASE WHEN D.[dblBalance] = 0 THEN 5 WHEN D.[intContractStatusId] = 5 THEN 1 ELSE D.[intContractStatusId] END
		 
		 ,D.[intItemUOMId]				
		 ,D.[intTaxGroupId]				
		 
		 ,I.[strTransactionId]			
		 ,I.[intTransactionId]			
		 ,I.[intInvoiceDetailId]	
		 ,@intUserId
		 ,I.[strTransactionType]		
		 ,GETDATE()
		 ,1
	FROM
		@ItemsFromInvoice I
		LEFT JOIN tblCTItemContractDetail D ON I.intItemContractDetailId = D.intItemContractDetailId

	WHILE EXISTS(SELECT 1 FROM @tblToProcess)
	BEGIN

		DECLARE 				
				@dblNewContracted			NUMERIC(18,6),
				@dblNewScheduled			NUMERIC(18,6),
				@dblNewAvailable			NUMERIC(18,6),
				@dblNewApplied				NUMERIC(18,6),
				@dblNewBalance				NUMERIC(18,6),

				@strBalance					NVARCHAR(100),
				@strAvailable				NVARCHAR(100),
				@strQuantityToUpdate		NVARCHAR(100),

				@dblQuantityToUpdate		NUMERIC(18,6),
				@dblTolerance				NUMERIC(18,6) = 0.0001,
				@ysnAllowOverSchedule		BIT,
				@intOldContractStatusId		INT,
				@intNewContractStatusId		INT,
				@dtmNewLastDeliveryDate		DATETIME,
				@intLineNo					INT,
				@intItemContractDetailId	INT,
				@strItemContractNumber		NVARCHAR(50),
				@strTransactionId			NVARCHAR(50),
				@intTransactionId			INT,
				@intTransactionDetailId		INT,
				@strTransactionType			NVARCHAR(50),
				@strReason					NVARCHAR(50),
				@ErrMsg						NVARCHAR(MAX)

		SELECT TOP 1 
				@intItemContractDetailId = intItemContractDetailId, 
				@dblNewContracted		 = dblNewContracted, 
				@dblNewScheduled		 = dblNewScheduled,
				@dblNewAvailable		 = dblNewAvailable,
				@dblNewApplied			 = dblNewApplied,
				@dblNewBalance			 = dblNewBalance,
				@intNewContractStatusId	 = CASE WHEN [dblNewBalance] = 0 THEN 5 WHEN [intNewContractStatusId] = 5 THEN 1  ELSE [intNewContractStatusId] END,
				@dtmNewLastDeliveryDate  = dtmNewLastDeliveryDate,
				@strTransactionType		 = strTransactionType,
				@intTransactionDetailId	 = intTransactionDetailId,
				@intTransactionId		 = intTransactionId,
				@strTransactionId		 = strTransactionId
		FROM @tblToProcess

		IF NOT EXISTS(SELECT * FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
		BEGIN
			RAISERROR('Item contract is deleted by other user.',16,1)
		END 	
		
		-- SCREEN / MODULE SWITCHER
		IF @strTransactionType = 'Invoice'
		BEGIN
			SELECT @strTransactionId		=	B.strInvoiceNumber,
				   @intTransactionId		=	A.intInvoiceId,
				   @dtmNewLastDeliveryDate	=	CASE WHEN B.ysnPosted = 1 THEN B.dtmShipDate ELSE NULL END
				FROM tblARInvoiceDetail A
				LEFT JOIN tblARInvoice B ON A.intInvoiceId = B.intInvoiceId
					WHERE A.intInvoiceDetailId = @intTransactionDetailId
		END


		-- INSERT HISTORY
		EXEC uspCTItemContractCreateHistory 
				@intItemContractDetailId	=	@intItemContractDetailId, 
				@intTransactionId			=	@intTransactionId, 
				@intTransactionDetailId		=	@intTransactionDetailId,
				@strTransactionId			=	@strTransactionId,
				@intUserId					=	@intUserId,
				@strTransactionType			=	@strTransactionType,
				@dblNewContracted			=	@dblNewContracted,
				@dblNewScheduled			=	@dblNewScheduled,
				@dblNewAvailable			=	@dblNewAvailable,
				@dblNewApplied				=	@dblNewApplied,
				@dblNewBalance				=	@dblNewBalance,
				@intNewContractStatusId		=	@intNewContractStatusId,
				@dtmNewLastDeliveryDate		=	@dtmNewLastDeliveryDate


		-- UPDATE ITEM CONTRACT
		UPDATE 	tblCTItemContractDetail
		SET		dblScheduled			= 	ISNULL(@dblNewScheduled,0),
				dblApplied				=	ISNULL(@dblNewApplied,0),
				dblAvailable			=	ISNULL(@dblNewAvailable,0),
				dblBalance				=	ISNULL(@dblNewBalance,0),
				dtmLastDeliveryDate		=	@dtmNewLastDeliveryDate,
				intContractStatusId		=	@intNewContractStatusId,
				intConcurrencyId		=	intConcurrencyId + 1
		WHERE	intItemContractDetailId =	@intItemContractDetailId


		DELETE @tblToProcess WHERE intItemContractDetailId = @intItemContractDetailId

	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH


