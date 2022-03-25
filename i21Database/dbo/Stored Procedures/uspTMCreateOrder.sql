CREATE PROCEDURE [dbo].[uspTMCreateOrder]
	@intDispatchId INT,
	@strSource NVARCHAR(100)
AS
BEGIN

	DECLARE @intSiteId INT = NULL,
		@intItemId INT = NULL,
		@strOrderNumber NVARCHAR(100) = NULL,
		@strPricingMethod NVARCHAR(100) = NULL,
		@intContractDetailId INT = NULL,
		@dblQuantity DECIMAL(18,6) = NULL,
		@dblPrice DECIMAL(18,6) = NULL,
		@dblTotal DECIMAL(18,6) = NULL,
		@intCustomerId INT = NULL,
		@intLocationId INT = NULL,
		@intCompanyLocationPricingLevelId INT = NULL

	SELECT @intSiteId = S.intSiteID
		, @intDispatchId = D.intDispatchID
		, @intItemId = D.intProductID
		, @strOrderNumber = D.strOrderNumber
		, @strPricingMethod = D.strPricingMethod
		, @intContractDetailId = D.intContractId
		, @dblQuantity = CASE WHEN ISNULL(D.dblMinimumQuantity,0) = 0 THEN D.dblQuantity ELSE D.dblMinimumQuantity END
		, @dblPrice = D.dblPrice
		, @dblTotal = D.dblTotal
		, @intCustomerId = S.intCustomerID
		, @intLocationId = S.intLocationId
		, @intCompanyLocationPricingLevelId = intCompanyLocationPricingLevelId	
	FROM tblTMDispatch D
	INNER JOIN tblTMSite S ON S.intSiteID = D.intSiteID
	WHERE D.intDispatchID = @intDispatchId
	AND D.strWillCallStatus IN ('Dispatched', 'Routed')

	-- DELETE IF THERE IS EXISTING DISPATCH RECORD
	DELETE tblTMOrder WHERE intDispatchId = @intDispatchId

	IF(@intContractDetailId IS NOT NULL) 
	BEGIN
		DECLARE @dblBalance DECIMAL(18,6) = NULL,
			@dblCashPrice DECIMAL(18,6) = NULL

		SELECT @dblBalance = B.dblBalance, @dblCashPrice = B.dblCashPrice
		FROM tblCTContractHeader A
		INNER JOIN vyuCTContractHeaderNotMapped H
			ON A.intContractHeaderId = H.intContractHeaderId
		INNER JOIN tblCTContractDetail B
			ON A.intContractHeaderId = B.intContractHeaderId
		WHERE B.intContractDetailId = @intContractDetailId

		IF(@dblQuantity > @dblBalance)
		BEGIN

			DECLARE @dblRemainingQty NUMERIC(18, 6) = NULL,
				@dblItemPrice NUMERIC(18, 6) = NULL,
				@strPricing NVARCHAR(200) = NULL

			SET @dblRemainingQty = @dblQuantity - @dblBalance

			SET @dblTotal = @dblBalance * @dblPrice

			INSERT INTO tblTMOrder (
				intDispatchId,
				intSiteId,
				intItemId,
				strOrderNumber,
				strPricingMethod,
				intContractDetailId,
				dblQuantity,
				dblPrice,
				dblTotal,
				strSource,
				dtmTransactionDate
			)
			VALUES(
				@intDispatchId,
				@intSiteId,
				@intItemId,
				@strOrderNumber,
				@strPricingMethod,
				@intContractDetailId,
				@dblBalance,
				@dblPrice,
				@dblTotal,
				@strSource,
				GETDATE()
			)

			IF(@dblRemainingQty > 0)
			BEGIN
				DECLARE @intUOMId INT = NULL

				SELECT @intUOMId = intIssueUOMId 
                FROM tblICItemLocation WHERE intItemId = @intItemId
                AND intLocationId = @intLocationId

				EXEC dbo.uspARGetItemPrice
				 @ItemUOMId = @intUOMId
				,@ItemId =  @intItemId
				,@CustomerId = @intCustomerId
				,@LocationId = @intLocationId
				,@Quantity = @dblRemainingQty
				,@PricingLevelId = @intCompanyLocationPricingLevelId
				,@InvoiceType = 'Tank Delivery'
				,@ExcludeContractPricing = 1
				,@Price = @dblItemPrice OUT
				,@Pricing = @strPricing OUT

				IF(@dblItemPrice IS NULL)
				BEGIN
					SET @dblItemPrice = 0
					SET @strPricingMethod = 'Regular'
				END
				ELSE IF(@strPricing = 'Standard Pricing')
				BEGIN
					SET @strPricingMethod = 'Regular'
				END
				ELSE
				BEGIN
					SET @strPricingMethod = 'Special'
				END

				SET @dblTotal = @dblRemainingQty * @dblItemPrice
						
				INSERT INTO tblTMOrder (
					intDispatchId,
					intSiteId,
					intItemId,
					strOrderNumber,
					strPricingMethod,
					dblQuantity,
					dblPrice,
					dblTotal,
					strSource,
					dtmTransactionDate,
					ysnOverage
				)
				VALUES(
					@intDispatchId,
					@intSiteId,
					@intItemId,
					@strOrderNumber,
					@strPricingMethod,
					@dblRemainingQty,
					@dblItemPrice,
					@dblTotal,
					@strSource,
					GETDATE(),
					1
				)

				UPDATE tblTMDispatch SET dblOverageQty = @dblRemainingQty, dblOveragePrice = @dblItemPrice
				WHERE intDispatchID = @intDispatchId
				
			END
		END
		ELSE
		BEGIN
			INSERT INTO tblTMOrder (
				intDispatchId,
				intSiteId,
				intItemId,
				strOrderNumber,
				strPricingMethod,
				dblQuantity,
				dblPrice,
				dblTotal,
				strSource,
				dtmTransactionDate
			)
			VALUES(
				@intDispatchId,
				@intSiteId,
				@intItemId,
				@strOrderNumber,
				@strPricingMethod,
				@dblQuantity,
				@dblPrice,
				@dblTotal,
				@strSource,
				GETDATE()
			)
		END

	END
	ELSE
	BEGIN
		INSERT INTO tblTMOrder (
				intDispatchId,
				intSiteId,
				intItemId,
				strOrderNumber,
				strPricingMethod,
				dblQuantity,
				dblPrice,
				dblTotal,
				strSource,
				dtmTransactionDate
			)
			VALUES(
				@intDispatchId,
				@intSiteId,
				@intItemId,
				@strOrderNumber,
				@strPricingMethod,
				@dblQuantity,
				@dblPrice,
				@dblTotal,
				@strSource,
				GETDATE()
			)
	END


END