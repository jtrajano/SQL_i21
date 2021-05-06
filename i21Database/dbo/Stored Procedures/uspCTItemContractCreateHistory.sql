﻿CREATE PROCEDURE [dbo].[uspCTItemContractCreateHistory]
	@intItemContractDetailId	INT, 
	@intTransactionId			INT,
	@intTransactionDetailId		INT,
	@strTransactionId			NVARCHAR(50),
	@intUserId					INT,
	@strTransactionType			NVARCHAR(50),
	@dblNewContracted			NUMERIC(18,6),
	@dblNewScheduled			NUMERIC(18,6),
	@dblNewAvailable			NUMERIC(18,6),
	@dblNewApplied				NUMERIC(18,6),
	@dblNewBalance				NUMERIC(18,6),
	@intNewContractStatusId		INT,
	@dtmNewLastDeliveryDate		DATETIME,
	@dtmTransactionDate			DATETIME,
	@ysnUsageLog				BIT = 0
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg				NVARCHAR(MAX),
			@dblContracted		NUMERIC(18,6),
			@dblOldContracted	NUMERIC(18,6),
			@dblOldScheduled	NUMERIC(18,6),
			@dblOldAvailable	NUMERIC(18,6),
			@dblOldApplied		NUMERIC(18,6),
			@dblOldBalance		NUMERIC(18,6),
			@dblOldTax			NUMERIC(18,6),
			@dblOldPrice		NUMERIC(18,6),
			@dblOldTotal		NUMERIC(18,6)

	SELECT TOP 1 
	@dblContracted		=	 dblNewContracted,
	@dblOldContracted	=	 dblNewContracted,
	@dblOldScheduled	=	 ISNULL(dblNewScheduled, 0),
	@dblOldAvailable	=	 dblNewAvailable,
	@dblOldApplied		=	 dblNewApplied,
	@dblOldBalance		=	 dblNewBalance,
	@dblOldTax			=	 dblNewTax,
	@dblOldPrice		=	 dblNewPrice,
	@dblOldTotal		=	 dblNewTotal
	FROM tblCTItemContractHistory
	WHERE intItemContractDetailId = @intItemContractDetailId
	ORDER BY intItemContractDetailId, dtmTransactionDate DESC

	INSERT INTO tblCTItemContractHistory (
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
		 ,[dtmCreatedDate]
		 ,[ysnUsageLog]
		 ,[intConcurrencyId])
	SELECT 
		  D.[intItemContractHeaderId]
		 ,D.[intItemContractDetailId]
		 ,D.[intLineNo]					
		 ,D.[intItemId]					
		 ,D.[strItemDescription]		
		 ,D.[dtmDeliveryDate]			
		 ,D.[dtmLastDeliveryDate]	
		 ,@dtmNewLastDeliveryDate	
		 ,[dblContracted] = @dblOldContracted
		 ,[dblScheduled] = @dblOldScheduled
		 ,[dblAvailable] = @dblOldAvailable
		 ,[dblApplied] = @dblOldApplied
		 ,[dblBalance] = @dblOldBalance
		 ,[dblTax] = @dblOldTax
		 ,[dblPrice] = @dblOldPrice
		 ,[dblTotal] = @dblOldTotal
		 ,@dblNewContracted			
		 ,@dblNewScheduled			
		 ,@dblNewAvailable
		 ,@dblNewApplied				
		 ,@dblNewBalance
		 ,D.[dblTax]					
		 ,D.[dblPrice]				
		 ,D.[dblTotal]				
		 ,D.[intContractStatusId]	
		 ,@intNewContractStatusId	
		 ,D.[intItemUOMId]				
		 ,D.[intTaxGroupId]				
		 ,@strTransactionId			
		 ,@intTransactionId			
		 ,@intTransactionDetailId	
		 ,@intUserId
		 ,@strTransactionType
		 ,@dtmTransactionDate		
		 ,GETUTCDATE()
		 ,@ysnUsageLog
		 ,1
	FROM tblCTItemContractDetail D
		LEFT JOIN tblCTItemContractHeader H ON D.intItemContractHeaderId = H.intItemContractHeaderId
		WHERE D.intItemContractDetailId = @intItemContractDetailId
			

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 