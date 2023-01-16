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
		@intCompanyLocationPricingLevelId INT = NULL,
		@strOriginalPricingMethod NVARCHAR(100) = NULL

	SELECT @intSiteId = S.intSiteID
		, @intDispatchId = D.intDispatchID
		, @intItemId = D.intProductID
		, @strOrderNumber = D.strOrderNumber
		, @strPricingMethod = D.strPricingMethod
		, @intContractDetailId = D.intContractId
		, @dblQuantity = CASE WHEN ISNULL(D.dblMinimumQuantity,0) = 0 THEN D.dblQuantity ELSE D.dblMinimumQuantity END
		, @dblPrice = D.dblPrice
		, @dblTotal = D.dblTotal
		, @intCustomerId = E.intEntityId
		, @intLocationId = S.intLocationId
		, @intCompanyLocationPricingLevelId = intCompanyLocationPricingLevelId
		, @strOriginalPricingMethod = D.strOriginalPricingMethod
	FROM tblTMDispatch D
	INNER JOIN tblTMSite S ON S.intSiteID = D.intSiteID
	INNER JOIN tblTMCustomer C ON C.intCustomerID = S.intCustomerID 
	LEFT JOIN tblEMEntity E ON E.intEntityId =  C.intCustomerNumber
	WHERE D.intDispatchID = @intDispatchId
	AND D.strWillCallStatus = 'Generated' --IN ('Dispatched', 'Routed')

	-- DELETE IF THERE IS EXISTING DISPATCH RECORD
	DELETE tblTMOrder WHERE intDispatchId = @intDispatchId

	IF(@strSource COLLATE Latin1_General_CI_AS = 'TM - Generate Order')
	BEGIN
		IF(ISNULL(@intContractDetailId,0) > 0)
		BEGIN
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
			SELECT 
					A.intDispatchID
					,A.intSiteID
					,A.intProductID
					,A.strOrderNumber
					,A.strPricingMethod
					,A.intContractId
					,dblQuantity = (CASE WHEN ISNULL(A.dblMinimumQuantity, 0) = 0 THEN A.dblQuantity ELSE A.dblMinimumQuantity END) - A.dblOverageQty
					,A.dblPrice
					,A.dblTotal
					,@strSource COLLATE Latin1_General_CI_AS
					,GETDATE()
			FROM tblTMDispatch A
			INNER JOIN tblCTContractDetail B
				ON A.intContractId = B.intContractDetailId
			WHERE intDispatchID = @intDispatchId

			---Overrage
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
					,ysnOverage
				)
			SELECT 
					A.intDispatchID
					,A.intSiteID
					,A.intProductID
					,A.strOrderNumber
					,A.strPricingMethod
					,A.intContractId
					,dblQuantity = A.dblOverageQty
					,dblPrice = A.dblOveragePrice
					,A.dblTotal
					,@strSource COLLATE Latin1_General_CI_AS
					,GETDATE()
					,ysnOverage = 1
			FROM tblTMDispatch A
			WHERE intDispatchID = @intDispatchId
				AND A.dblOverageQty > 0
				AND A.dblOverageQty IS NOT NULL
		END
		ELSE
		BEGIN
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
			SELECT 
					A.intDispatchID
					,A.intSiteID
					,A.intProductID
					,A.strOrderNumber
					,A.strPricingMethod
					,A.intContractId
					,dblQuantity = CASE WHEN ISNULL(A.dblMinimumQuantity, 0) = 0 THEN A.dblQuantity ELSE A.dblMinimumQuantity END
					,A.dblPrice
					,A.dblTotal
					,@strSource COLLATE Latin1_General_CI_AS
					,GETDATE()
			FROM tblTMDispatch A
			WHERE intDispatchID = @intDispatchId
		END
	END
	ELSE
	BEGIN
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
					@strSource COLLATE Latin1_General_CI_AS,
					GETDATE()
				)

				IF(@dblRemainingQty > 0)
				BEGIN
					DECLARE @intUOMId INT = NULL

					SELECT @dblItemPrice = dblRegularPrice FROM tblTMDispatch WHERE intDispatchID = @intDispatchId
					
					-- SELECT @intUOMId = intIssueUOMId 
					-- FROM tblICItemLocation WHERE intItemId = @intItemId
					-- AND intLocationId = @intLocationId

					-- EXEC dbo.uspARGetItemPrice
					--  @ItemUOMId = @intUOMId
					-- ,@ItemId =  @intItemId
					-- ,@CustomerId = @intCustomerId
					-- ,@LocationId = @intLocationId
					-- ,@Quantity = @dblRemainingQty
					-- ,@PricingLevelId = @intCompanyLocationPricingLevelId
					-- ,@InvoiceType = 'Tank Delivery'
					-- ,@ExcludeContractPricing = 1
					-- ,@Price = @dblItemPrice OUT
					-- ,@Pricing = @strPricing OUT

					-- IF(@dblItemPrice IS NULL)
					-- BEGIN
					-- 	SET @dblItemPrice = 0
					-- 	SET @strPricingMethod = 'Regular'
					-- END
					-- ELSE IF(@strPricing = 'Standard Pricing')
					-- BEGIN
					-- 	SET @strPricingMethod = 'Regular'
					-- END
					-- ELSE
					-- BEGIN
					-- 	SET @strPricingMethod = 'Special'
					-- END

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
						@strOriginalPricingMethod,
						@dblRemainingQty,
						@dblItemPrice,
						@dblTotal,
						@strSource COLLATE Latin1_General_CI_AS,
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
					@dblQuantity,
					@dblPrice,
					@dblTotal,
					@strSource COLLATE Latin1_General_CI_AS,
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
					@strSource COLLATE Latin1_General_CI_AS,
					GETDATE()
				)
		END
	END
END

GO