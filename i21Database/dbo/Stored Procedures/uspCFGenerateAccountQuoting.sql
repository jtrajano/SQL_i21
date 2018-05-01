CREATE PROCEDURE [dbo].[uspCFGenerateAccountQuoting](
	  @intCustomerId				INT  
	 ,@intCustomerGroupId			INT
	 ,@dtmQuoteDate					DATETIME
)
AS
BEGIN

	DECLARE @intAccounId INT

	SELECT TOP 1 @intAccounId = intAccountId FROM tblCFAccount where intCustomerId = @intCustomerId
	IF(ISNULL(@intAccounId,0) != 0)
	BEGIN
		
		DELETE FROM tblCFAccountQuote

		DECLARE @tblCFTempAccountQuoteSite TABLE(
			 intAccountQuoteSiteId		INT
			,intSiteId					INT
			,intAccountId				INT
			,intConcurrencyId			INT
		)

		DECLARE @intQuoteProduct1Id		INT
		DECLARE @intQuoteProduct2Id		INT
		DECLARE @intQuoteProduct3Id		INT
		DECLARE @intQuoteProduct4Id		INT
		DECLARE @intQuoteProduct5Id		INT
		DECLARE @ysnQuoteTaxExempt		BIT
		DECLARE @intAccountId			INT

		SELECT TOP 1
		 @intQuoteProduct1Id	= intQuoteProduct1Id
		,@intQuoteProduct2Id	= intQuoteProduct2Id
		,@intQuoteProduct3Id	= intQuoteProduct3Id
		,@intQuoteProduct4Id	= intQuoteProduct4Id
		,@intQuoteProduct5Id	= intQuoteProduct5Id
		,@ysnQuoteTaxExempt		= ysnQuoteTaxExempt
		,@intAccountId			= intAccountId
		FROM tblCFAccount
		WHERE intCustomerId = @intCustomerId 
		AND  intCustomerGroupId = @intCustomerGroupId

		INSERT INTO @tblCFTempAccountQuoteSite(
			 intAccountQuoteSiteId	
			,intSiteId				
			,intAccountId			
			,intConcurrencyId		
		)
		SELECT 
			 intAccountQuoteSiteId	
			,intSiteId				
			,intAccountId			
			,intConcurrencyId		
		FROM tblCFAccountQuoteSite
		WHERE intAccountId = @intAccountId


		DECLARE @intLoopAccountQuoteSiteId	INT
		DECLARE @intLoopSiteId				INT
		WHILE (EXISTS(SELECT 1 FROM @tblCFTempAccountQuoteSite))
		BEGIN

			SELECT 
			 @intLoopAccountQuoteSiteId	= intAccountQuoteSiteId
			,@intLoopSiteId				= intSiteId
			FROM @tblCFTempAccountQuoteSite
			
			IF(ISNULL(@intQuoteProduct1Id,0) != 0)
			BEGIN
				EXEC [dbo].[uspCFGenerateQuoting]
				@intCustomerId		= @intCustomerId,
				@intSiteId			= @intLoopSiteId,
				@intProductId		= @intQuoteProduct1Id,
				@dtmDate			= @dtmQuoteDate,
				@ysnAccountQuote	= 1,
				@intItemSequence	= 1
			END

			IF(ISNULL(@intQuoteProduct2Id,0) != 0)
			BEGIN
				EXEC [dbo].[uspCFGenerateQuoting]
				@intCustomerId		= @intCustomerId,
				@intSiteId			= @intLoopSiteId,
				@intProductId		= @intQuoteProduct2Id,
				@dtmDate			= @dtmQuoteDate,
				@ysnAccountQuote	= 1,
				@intItemSequence	= 2
			END

			IF(ISNULL(@intQuoteProduct3Id,0) != 0)
			BEGIN
				EXEC [dbo].[uspCFGenerateQuoting]
				@intCustomerId		= @intCustomerId,
				@intSiteId			= @intLoopSiteId,
				@intProductId		= @intQuoteProduct3Id,
				@dtmDate			= @dtmQuoteDate,
				@ysnAccountQuote	= 1,
				@intItemSequence	= 3
			END

			IF(ISNULL(@intQuoteProduct4Id,0) != 0)
			BEGIN
				EXEC [dbo].[uspCFGenerateQuoting]
				@intCustomerId		= @intCustomerId,
				@intSiteId			= @intLoopSiteId,
				@intProductId		= @intQuoteProduct4Id,
				@dtmDate			= @dtmQuoteDate,
				@ysnAccountQuote	= 1,
				@intItemSequence	= 4
			END

			IF(ISNULL(@intQuoteProduct5Id,0) != 0)
			BEGIN
				EXEC [dbo].[uspCFGenerateQuoting]
				@intCustomerId		= @intCustomerId,
				@intSiteId			= @intLoopSiteId,
				@intProductId		= @intQuoteProduct5Id,
				@dtmDate			= @dtmQuoteDate,
				@ysnAccountQuote	= 1,
				@intItemSequence	= 5
			END


			DELETE FROM  @tblCFTempAccountQuoteSite
			WHERE intAccountQuoteSiteId= @intLoopAccountQuoteSiteId		
		
		END

	END
	ELSE
	BEGIN
		RAISERROR('Cutomer doenst have CF account',16,1);

	END

END