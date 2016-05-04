CREATE PROCEDURE [dbo].[uspCFRecalculateTransaciton] 

 @ProductId				INT    
,@CardId				INT     
,@SiteId				INT    
,@TransactionDate		DATETIME			    
,@Quantity				NUMERIC(18,6)     
,@OriginalPrice			NUMERIC(18,6)    
,@TransactionType		NVARCHAR(MAX)
,@NetworkId				INT
,@TransferCost			NUMERIC(18,6)   
,@TransactionId			INT				=  NULL

AS

BEGIN
	
	------------ GET ITEM PRICE PARAMETERS  ------------
	DECLARE @intItemId						INT
	DECLARE @intCustomerId					INT
	DECLARE @intLocationId					INT		
	DECLARE @intItemUOMId					INT			
	DECLARE @dtmTransactionDate				DATETIME		
	DECLARE @dblQuantity					NUMERIC(18,6)
	DECLARE @strTransactionType				NVARCHAR(MAX)
	DECLARE @intNetworkId					INT
	DECLARE @intSiteId						INT
	DECLARE @dblTransferCost				NUMERIC(18,6)
	DECLARE @dblOriginalPrice				NUMERIC(18,6)
	DECLARE @intCardId						INT
	DECLARE @intTaxGroupId					INT

	DECLARE @dblPrice						NUMERIC(18,6)
	DECLARE @strPriceBasis					NVARCHAR(MAX)
	DECLARE @strPriceMethod					NVARCHAR(MAX)
	DECLARE @intContractHeaderId			INT	
	DECLARE @intContractDetailId			INT
	DECLARE @intContractNumber				INT
	DECLARE @intContractSeq					INT
	DECLARE @dblAvailableQuantity			NUMERIC(18,6)

	DECLARE @intTransactionId				INT
	DECLARE @guid							NVARCHAR(MAX)
	DECLARE	@runDate						DATETIME

	SET @guid		= NEWID()
	SET	@runDate	= GETDATE()

	SET @intCardId = @CardId
	SET @dblQuantity = @Quantity
	SET @dtmTransactionDate = @TransactionDate
	SET @strTransactionType = @TransactionType
	SET @intNetworkId = @NetworkId
	SET @intSiteId = @SiteId
	SET @dblTransferCost =@TransferCost
	SET @dblOriginalPrice = @OriginalPrice
	SET @intTransactionId = @TransactionId

	IF (@intTransactionId is not null)
	BEGIN
		DELETE tblCFTransactionNote WHERE intTransactionId = @intTransactionId
	END	

	--GET TAX GROUP ID--
	SELECT TOP 1 
	@intTaxGroupId = intTaxGroupId
	FROM tblCFSite WHERE intSiteId = @intSiteId

	--GET CUSTOMER ID--
	SELECT TOP 1
	@intCustomerId = cfAccount.intCustomerId
	FROM tblCFCard as cfCard
	INNER JOIN tblCFAccount as cfAccount
	ON cfCard.intAccountId = cfAccount.intAccountId
	WHERE cfCard.intCardId = @intCardId


	--GET COMPANY LOCATION ID--
	SELECT TOP 1
		@intLocationId = intARLocationId
	FROM tblCFSite as cfSite
	WHERE cfSite.intSiteId = @intSiteId

	--GET IC ITEM ID BY SITE--
	SELECT TOP 1
		@intItemId = cfItem.intARItemId
	FROM tblCFItem as cfItem 
	WHERE cfItem.intSiteId = @intSiteId
	AND cfItem.intItemId = @ProductId
	
	--GET IC ITEM ID BY NETWORK--
	IF (@intItemId IS NULL)
	BEGIN
		SELECT TOP 1
			@intItemId = cfItem.intARItemId
		FROM tblCFItem as cfItem 
		WHERE cfItem.intNetworkId = @intNetworkId
		AND cfItem.intItemId = @ProductId
	END

	--GET IC ITEM UOM ID--
	SELECT TOP 1
		@intItemUOMId = icItemLocation.intIssueUOMId
	FROM tblICItemLocation as icItemLocation
	WHERE icItemLocation.intItemId = @intItemId
	AND icItemLocation.intLocationId = @intLocationId

	EXEC dbo.uspCFGetItemPrice 
	@CFItemId					=	@intItemId,
	@CFCustomerId				=	@intCustomerId,
	@CFLocationId				=	@intLocationId,
	@CFQuantity					=	@dblQuantity,
	@CFItemUOMId				=	@intItemUOMId,
	@CFTransactionDate			=	@dtmTransactionDate,
	@CFTransactionType			=	@strTransactionType,
	@CFNetworkId				=	@intNetworkId,
	@CFSiteId					=	@intSiteId,
	@CFTransferCost				=	@dblTransferCost,
	@CFOriginalPrice			=	@dblOriginalPrice,
	@CFPriceOut					=	@dblPrice				output,
	@CFPricingOut				=	@strPriceMethod			output,
	@CFAvailableQuantity		=	@dblAvailableQuantity	output,
	@CFContractHeaderId			=	@intContractHeaderId	output,
	@CFContractDetailId			=	@intContractDetailId	output,
	@CFContractNumber			=	@intContractNumber		output,
	@CFContractSeq				=	@intContractSeq			output,
	@CFPriceBasis				=	@strPriceBasis			output

	--- SELECT RESULT ---
	SELECT
	 @intItemId					AS intItemId
	,@intCustomerId				AS intCustomerId
	,@intLocationId				AS intLocationId
	,@dblQuantity				AS dblQuantity
	,@intItemUOMId				AS intItemUOMId
	,@dtmTransactionDate		AS dtmTransactionDate
	,@strTransactionType		AS strTransactionType
	,@intNetworkId				AS intNetworkId
	,@intSiteId					AS intSiteId
	,@dblTransferCost			AS dblTransferCost
	,@dblOriginalPrice			AS dblOriginalPrice
	,@dblPrice					AS dblPrice				
	,@strPriceMethod			AS strPriceMethod		
	,@dblAvailableQuantity		AS dblAvailableQuantity	
	,@intContractHeaderId		AS intContractHeaderId	
	,@intContractDetailId		AS intContractDetailId	
	,@intContractNumber			AS intContractNumber		
	,@intContractSeq			AS intContractSeq		
	,@strPriceBasis				AS strPriceBasis	
	
	--TAXES PART--

	-- GET REMOTE TAXES--
	DECLARE @tblTransactionTaxOut	TABLE
	(
		 [intTransactionDetailTaxId]		INT
		,[intInvoiceDetailId]				INT
		,[intTransactionDetailId]  			INT
		,[intTaxGroupMasterId]				INT
		,[intTaxGroupId]					INT
		,[intTaxCodeId]						INT
		,[intTaxClassId]					INT
		,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
		,[strCalculationMethod]				NVARCHAR(MAX)
		,[dblRate]							NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
		,[dblCalculatedTax]					NUMERIC(18,6)
		,[dblOriginalTax]					NUMERIC(18,6)
	)
	DECLARE @tblTransactionTax		TABLE
	(
		 [intTransactionDetailTaxId]		INT
		,[intInvoiceDetailId]				INT
		,[intTransactionDetailId]  			INT
		,[intTaxGroupMasterId]				INT
		,[intTaxGroupId]					INT
		,[intTaxCodeId]						INT
		,[intTaxClassId]					INT
		,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
		,[strCalculationMethod]				NVARCHAR(MAX)
		,[dblRate]							NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
	)
	DECLARE @tblTaxRateTable		TABLE
	(
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strReason]					NVARCHAR(MAX)
		,[strNotes]						NVARCHAR(MAX)
		,[strTaxExemptReason]			NVARCHAR(MAX)
	)
	DECLARE @tblTaxUnitTable		TABLE
	(
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strReason]					NVARCHAR(MAX)
		,[strNotes]						NVARCHAR(MAX)
		,[strTaxExemptReason]			NVARCHAR(MAX)
	)
	DECLARE @strTaxCodes			VARCHAR(MAX) 

	DECLARE @dblOPTotalTax		NUMERIC(18,6) = 0
	DECLARE @dblCPTotalTax		NUMERIC(18,6) = 0
	DECLARE @intLoopTaxGroupID	INT
	DECLARE @intLoopTaxCodeID	INT
	DECLARE @intLoopTaxClassID	INT
	DECLARE	@strLoopTaxCode		NVARCHAR(MAX)
	DECLARE @QxOP				NUMERIC(18,6) = 0
	DECLARE @QxCP				NUMERIC(18,6) = 0
	DECLARE @QxT				NUMERIC(18,6) = 0
	DECLARE @OPTax				NUMERIC(18,6) = 0		
	DECLARE @CPTax				NUMERIC(18,6) = 0	
	DECLARE @Rate				NUMERIC(18,6)
	DECLARE @CalculationMethod  NVARCHAR(MAX)
	DECLARE @ysnLoopTaxExempt	BIT
	DECLARE @ysnLoopTaxCheckOff	BIT

	IF (LOWER(@strTransactionType) like '%remote%')
	BEGIN

		IF (@intTransactionId is not null)
		BEGIN
			SELECT @strTaxCodes = COALESCE(@strTaxCodes + ', ', '') + CONVERT(varchar(10), intTaxCodeId)
			FROM tblCFTransactionTax
			WHERE intTransactionId = @intTransactionId
		END	

		INSERT INTO @tblTransactionTax(
		 [intTransactionDetailTaxId]	
		,[intTransactionDetailId]  		
		,[intTaxGroupMasterId]			
		,[intTaxGroupId]				
		,[intTaxCodeId]					
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]		
		,[strCalculationMethod]			
		,[dblRate]						
		,[dblTax]						
		,[dblAdjustedTax]				
		,[intTaxAccountId]    			
		,[ysnSeparateOnInvoice]			
		,[ysnCheckoffTax]				
		,[strTaxCode]					
		,[ysnTaxExempt]			
		,[strTaxGroup]					
		,[ysnInvalidSetup]					
		,[strReason]					
		,[strTaxExemptReason]			
		)	
		EXEC dbo.[uspCFGetItemTaxes] 
		@intNetworkId				=@intNetworkId,
		@intARItemId				=@intItemId,
		@intARItemLocationId		=@intLocationId,
		@intCustomerLocationId		=@intLocationId,
		@dtmTransactionDate			=@dtmTransactionDate,
		@intCustomerId				=@intCustomerId,
		@strTaxCodeId				=@strTaxCodes,
		@TaxState					=NULL


		SELECT * 
		INTO #ItemTax
		FROM @tblTransactionTax
		WHILE exists (SELECT * FROM #ItemTax)
		BEGIN
			SELECT TOP 1 
				 @intLoopTaxGroupID = intTaxGroupId
				,@intLoopTaxCodeID = intTaxCodeId
				,@intLoopTaxClassID = intTaxClassId
			FROM #ItemTax


			UPDATE @tblTransactionTax 
			SET dblRate = (SELECT TOP 1 dblTaxRate FROM tblCFTransactionTax WHERE intTaxCodeId = @intLoopTaxCodeID AND intTransactionId = @intTransactionId)
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID

			DELETE #ItemTax
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID

		END

		DROP TABLE #ItemTax
	END
	ELSE
	BEGIN 
		INSERT INTO @tblTransactionTax(
			 [intTransactionDetailTaxId]	
			,[intInvoiceDetailId]  		
			,[intTaxGroupMasterId]			
			,[intTaxGroupId]				
			,[intTaxCodeId]					
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]		
			,[strCalculationMethod]			
			,[dblRate]			
			,[dblExemptionPercent]			
			,[dblTax]						
			,[dblAdjustedTax]				
			,[intSalesTaxAccountId]    			
			,[ysnSeparateOnInvoice]			
			,[ysnCheckoffTax]				
			,[strTaxCode]					
			,[ysnTaxExempt]			
			,[ysnInvalidSetup]				
			,[strTaxGroup]					
			,[strNotes]				
		)	
		EXEC uspARGetItemTaxes 
		 @ItemId			=@intItemId
		,@LocationId		=@intLocationId
		,@TransactionDate	=@dtmTransactionDate
		,@TaxGroupId		=@intTaxGroupId
		,@CustomerId		=@intCustomerId
	END

	INSERT INTO @tblTaxRateTable	
	SELECT 
	 [intTransactionDetailTaxId]
	,[intTransactionDetailId]  AS [intInvoiceDetailId]
	,[intTaxGroupMasterId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[intTaxAccountId]    AS [intSalesTaxAccountId]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[strTaxCode]
	,[ysnTaxExempt]
	,[ysnInvalidSetup]
	,[strTaxGroup]
	,[strReason]					
	,[strNotes]						
	,[strTaxExemptReason]								
	FROM @tblTransactionTax
	WHERE LOWER(strCalculationMethod) = 'percentage'
	INSERT INTO @tblTaxUnitTable	
	SELECT 
	[intTransactionDetailTaxId]
	,[intTransactionDetailId]  AS [intInvoiceDetailId]
	,[intTaxGroupMasterId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[intTaxAccountId]    AS [intSalesTaxAccountId]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[strTaxCode]
	,[ysnTaxExempt]
	,[ysnInvalidSetup]
	,[strTaxGroup]
	,[strReason]		
	,[strNotes]			
	,[strTaxExemptReason]
	FROM @tblTransactionTax
	WHERE LOWER(strCalculationMethod) = 'unit'

	--TAX CALCULATION--
	
	SET @QxOP = @dblQuantity * @dblOriginalPrice
	SET @QxCP = @dblQuantity * @dblPrice
	
	DECLARE @strTaxExemptReason		NVARCHAR(MAX)
	DECLARE @strNote				NVARCHAR(MAX)
	DECLARE @strReason				NVARCHAR(MAX)
	DECLARE @ysnCheckoffTax			BIT
	DECLARE @ysnTaxExempt			NVARCHAR(MAX)
	DECLARE @ysnInvalidSetup		NVARCHAR(MAX)
	DECLARE @strTaxCode				NVARCHAR(MAX)

	WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxUnitTable))
	BEGIN

		SELECT TOP 1
		-----------------------TAX CALCULATION----------------------
		 @QxT = ROUND (@dblQuantity * dblRate,2)
		,@QxOP = @QxOP - (@dblQuantity * dblRate)
		,@dblOPTotalTax = @dblOPTotalTax + (@dblQuantity * dblRate)
		------------------------------------------------------------
		,@strLoopTaxCode = strTaxCode
		,@Rate = dblRate
		,@CalculationMethod = strCalculationMethod
		,@ysnLoopTaxExempt = ysnCheckoffTax
		,@ysnLoopTaxExempt = ysnTaxExempt
		,@intLoopTaxGroupID = intTaxGroupId
		,@intLoopTaxCodeID = intTaxCodeId
		,@intLoopTaxClassID = intTaxClassId
		,@strTaxExemptReason	= strTaxExemptReason
		,@strNote				= strNotes
		,@strReason				= strReason
		,@ysnCheckoffTax		= ysnCheckoffTax
		,@ysnTaxExempt			= ysnTaxExempt
		,@ysnInvalidSetup		= ysnInvalidSetup
		,@strTaxCode			= strTaxCode
		FROM @tblTaxUnitTable

		IF(@ysnInvalidSetup = 0)
		BEGIN
			IF (@ysnTaxExempt = 1)
				BEGIN

				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Tax Exempt -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@QxT
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE IF(@ysnCheckoffTax = 1)
				BEGIN

				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Check Off -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@QxT
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE
				BEGIN
				SELECT TOP 1 
				 @QxCP = @QxCP - (@dblQuantity * dblRate)
				,@dblCPTotalTax = @dblCPTotalTax + (@dblQuantity * dblRate)
			FROM @tblTaxUnitTable
				INSERT INTO @tblTransactionTaxOut
			(
				 [intTransactionDetailTaxId]
				,[intInvoiceDetailId]		
				,[intTransactionDetailId]  	
				,[intTaxGroupMasterId]		
				,[intTaxGroupId]			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,[dblRate]					
				,[dblTax]					
				,[dblAdjustedTax]			
				,[dblExemptionPercent]		
				,[intSalesTaxAccountId]    	
				,[intTaxAccountId]    		
				,[ysnSeparateOnInvoice]		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]		
				,[ysnInvalidSetup]				
				,[strTaxGroup]				
				,[ysnInvalid]				
				,[strReason]				
				,[strNotes]					
				,[strTaxExemptReason]		
				,[dblCalculatedTax]	
				,[dblOriginalTax]	
			)
			SELECT TOP 1
				 [intTransactionDetailTaxId]
				,[intInvoiceDetailId]		
				,[intTransactionDetailId]  	
				,[intTaxGroupMasterId]		
				,[intTaxGroupId]			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,[dblRate]					
				,[dblTax]					
				,[dblAdjustedTax]			
				,[dblExemptionPercent]		
				,[intSalesTaxAccountId]    	
				,[intTaxAccountId]    		
				,[ysnSeparateOnInvoice]		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]		
				,[ysnInvalidSetup]				
				,[strTaxGroup]				
				,[ysnInvalid]				
				,[strReason]				
				,[strNotes]					
				,[strTaxExemptReason]		
				,@QxT
				,@QxT
			FROM @tblTransactionTax
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID
			END
		END
		ELSE
		BEGIN
			IF (@intTransactionId is not null)
			BEGIN
				INSERT INTO tblCFTransactionNote (
				 intTransactionId
				,strProcess
				,dtmProcessDate
				,strNote
				,strGuid
			)
			VALUES
			(
				@intTransactionId
				, 'Calculation'
				, @runDate
				, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Invalid Setup -' + @strTaxCode)))
				, @guid
			)
			END
		END

		DELETE FROM @tblTaxUnitTable 
		WHERE intTaxGroupId = @intLoopTaxGroupID
		AND intTaxClassId = @intLoopTaxClassID
		AND intTaxCodeId = @intLoopTaxCodeID

	END
	WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxRateTable))
	BEGIN

		SELECT TOP 1 
		 @intLoopTaxGroupID = intTaxGroupId
		,@intLoopTaxCodeID = intTaxCodeId
		,@intLoopTaxClassID = intTaxClassId
		,@OPTax = ROUND (((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
		,@CPTax = ROUND (((@QxCP / (dblRate/100 +1 )) * (dblRate/100)),2)
		,@dblOPTotalTax = @dblOPTotalTax + ((@QxOP / (dblRate/100 +1 )) * (dblRate/100))
		,@dblCPTotalTax = @dblCPTotalTax + ((@QxCP / (dblRate/100 +1 )) * (dblRate/100))
		,@strLoopTaxCode = strTaxCode
		,@Rate = dblRate
		,@CalculationMethod = strCalculationMethod
		FROM @tblTaxRateTable
		INSERT INTO @tblTransactionTaxOut
		(
			 [intTransactionDetailTaxId]
			,[intInvoiceDetailId]		
			,[intTransactionDetailId]  	
			,[intTaxGroupMasterId]		
			,[intTaxGroupId]			
			,[intTaxCodeId]				
			,[intTaxClassId]			
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[dblTax]					
			,[dblAdjustedTax]			
			,[dblExemptionPercent]		
			,[intSalesTaxAccountId]    	
			,[intTaxAccountId]    		
			,[ysnSeparateOnInvoice]		
			,[ysnCheckoffTax]			
			,[strTaxCode]				
			,[ysnTaxExempt]		
			,[ysnInvalidSetup]				
			,[strTaxGroup]				
			,[ysnInvalid]				
			,[strReason]				
			,[strNotes]					
			,[strTaxExemptReason]			
			,[dblCalculatedTax]	
			,[dblOriginalTax]	
		)
		SELECT TOP 1
			  [intTransactionDetailTaxId]
			 ,[intInvoiceDetailId]		
			 ,[intTransactionDetailId]  	
			 ,[intTaxGroupMasterId]		
			 ,[intTaxGroupId]			
			 ,[intTaxCodeId]				
			 ,[intTaxClassId]			
			 ,[strTaxableByOtherTaxes]	
			 ,[strCalculationMethod]		
			 ,[dblRate]					
			 ,[dblTax]					
			 ,[dblAdjustedTax]			
			 ,[dblExemptionPercent]		
			 ,[intSalesTaxAccountId]    	
			 ,[intTaxAccountId]    		
			 ,[ysnSeparateOnInvoice]		
			 ,[ysnCheckoffTax]			
			 ,[strTaxCode]				
			 ,[ysnTaxExempt]		
			 ,[ysnInvalidSetup]				
			 ,[strTaxGroup]				
			 ,[ysnInvalid]				
			 ,[strReason]				
			 ,[strNotes]					
			 ,[strTaxExemptReason]		
			,@CPTax
			,@OPTax
		FROM @tblTransactionTax
		WHERE intTaxGroupId = @intLoopTaxGroupID
		AND intTaxClassId = @intLoopTaxClassID
		AND intTaxCodeId = @intLoopTaxCodeID

		SELECT TOP 1
		-----------------------TAX CALCULATION----------------------
		 @OPTax = ROUND (((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
		,@dblOPTotalTax = @dblOPTotalTax + ((@QxOP / (dblRate/100 +1 )) * (dblRate/100))
		------------------------------------------------------------
		,@strLoopTaxCode = strTaxCode
		,@Rate = dblRate
		,@CalculationMethod = strCalculationMethod
		,@ysnLoopTaxExempt = ysnCheckoffTax
		,@ysnLoopTaxExempt = ysnTaxExempt
		,@intLoopTaxGroupID = intTaxGroupId
		,@intLoopTaxCodeID = intTaxCodeId
		,@intLoopTaxClassID = intTaxClassId
		,@strTaxExemptReason	= strTaxExemptReason
		,@strNote				= strNotes
		,@strReason				= strReason
		,@ysnCheckoffTax		= ysnCheckoffTax
		,@ysnTaxExempt			= ysnTaxExempt
		,@ysnInvalidSetup		= ysnInvalidSetup
		,@strTaxCode			= strTaxCode
		FROM @tblTaxUnitTable

		IF(@ysnInvalidSetup = 0)
		BEGIN
			IF (@ysnTaxExempt = 1)
				BEGIN
				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Tax Exempt -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@OPTax	
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE IF(@ysnCheckoffTax = 1)
				BEGIN
				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Check Off -' + @strTaxCode)))
					, @guid
				)
				END
				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]				
					,[ysnInvalid]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@OPTax	
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE
				BEGIN
				SELECT TOP 1 
					 @CPTax = ROUND (((@QxCP / (dblRate/100 +1 )) * (dblRate/100)),2)
					,@dblCPTotalTax = @dblCPTotalTax + ((@QxCP / (dblRate/100 +1 )) * (dblRate/100))
			FROM @tblTaxUnitTable
				INSERT INTO @tblTransactionTaxOut
			(
				 [intTransactionDetailTaxId]
				,[intInvoiceDetailId]		
				,[intTransactionDetailId]  	
				,[intTaxGroupMasterId]		
				,[intTaxGroupId]			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,[dblRate]					
				,[dblTax]					
				,[dblAdjustedTax]			
				,[dblExemptionPercent]		
				,[intSalesTaxAccountId]    	
				,[intTaxAccountId]    		
				,[ysnSeparateOnInvoice]		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]		
				,[ysnInvalidSetup]				
				,[strTaxGroup]				
				,[ysnInvalid]				
				,[strReason]				
				,[strNotes]					
				,[strTaxExemptReason]		
				,[dblCalculatedTax]	
				,[dblOriginalTax]	
			)
			SELECT TOP 1
				 [intTransactionDetailTaxId]
				,[intInvoiceDetailId]		
				,[intTransactionDetailId]  	
				,[intTaxGroupMasterId]		
				,[intTaxGroupId]			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,[dblRate]					
				,[dblTax]					
				,[dblAdjustedTax]			
				,[dblExemptionPercent]		
				,[intSalesTaxAccountId]    	
				,[intTaxAccountId]    		
				,[ysnSeparateOnInvoice]		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]		
				,[ysnInvalidSetup]				
				,[strTaxGroup]				
				,[ysnInvalid]				
				,[strReason]				
				,[strNotes]					
				,[strTaxExemptReason]		
				,@CPTax
				,@OPTax
			FROM @tblTransactionTax
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID
			END
		END
		ELSE
		BEGIN
			IF (@intTransactionId is not null)
			BEGIN
				INSERT INTO tblCFTransactionNote (
				 intTransactionId
				,strProcess
				,dtmProcessDate
				,strNote
				,strGuid
			)
			VALUES
			(
				@intTransactionId
				, 'Calculation'
				, @runDate
				, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Invalid Setup -' + @strTaxCode)))
				, @guid
			)
			END
		END

		DELETE FROM @tblTaxUnitTable 
		WHERE intTaxGroupId = @intLoopTaxGroupID
		AND intTaxClassId = @intLoopTaxClassID
		AND intTaxCodeId = @intLoopTaxCodeID

	END


	DECLARE @tblTransactionPrice TABLE(
		 strTransactionPriceId		NVARCHAR(MAX)
		,dblOriginalAmount			NUMERIC(18,6)
		,dblCalculatedAmount		NUMERIC(18,6)
	)
	
	IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0)
	BEGIN
		INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblPrice
		),
		(
			 'Net Price'
			,@dblOriginalPrice - (@dblOPTotalTax / @dblQuantity)
			,@dblPrice - (@dblCPTotalTax / @dblQuantity)
		),
		(
			 'Total Amount'
			,@dblOriginalPrice * @dblQuantity
			,@dblPrice * @dblQuantity
		)
	END
	ELSE
	BEGIN
		INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblPrice + (@dblCPTotalTax / @dblQuantity) 
		),
		(
			 'Net Price'
			,@dblOriginalPrice - (@dblOPTotalTax / @dblQuantity)
			,@dblPrice
		),
		(
			 'Total Amount'
			,@dblOriginalPrice * @dblQuantity
			,(@dblPrice + (@dblCPTotalTax / @dblQuantity)) * @dblQuantity
		)
	END

	

END


SELECT 
 dblCalculatedTax AS 'dblTaxCalculatedAmount'
,dblOriginalTax AS 'dblTaxOriginalAmount'
,intTaxCodeId
,dblRate AS 'dblTaxRate'
,strTaxCode AS 'strTaxCode'
FROM @tblTransactionTaxOut

SELECT * FROM @tblTransactionPrice