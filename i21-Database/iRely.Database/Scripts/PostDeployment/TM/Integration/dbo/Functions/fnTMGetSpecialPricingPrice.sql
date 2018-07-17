GO

IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricingPrice]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetSpecialPricingPrice]
GO 

IF (EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricing]') AND type IN (N'FN')))
BEGIN
	EXEC('
	CREATE FUNCTION [dbo].[fnTMGetSpecialPricingPrice](
		@strCustomerNumberParam AS NVARCHAR(20)
		,@strItemNumberParam NVARCHAR(20)
		,@strLocationParam NVARCHAR(20)
		,@strItemClassParam NVARCHAR(20)
		,@dtmOrderDateParam DATETIME
		,@dblQuantityParam DECIMAL(18,6)
		,@strContractNumberParam NVARCHAR(20)
	)
	RETURNS DECIMAL(18,6)
	AS
	BEGIN 
		DECLARE @dblPrice NUMERIC(18,6)
		DECLARE @strSpecialPricing NVARCHAR(50)

		DECLARE @strCustomerNumber AS NVARCHAR(20)
		DECLARE @strItemNumber NVARCHAR(20)
		DECLARE @strLocation NVARCHAR(20)
		DECLARE @strItemClass NVARCHAR(20)
		DECLARE @dtmOrderDate DATETIME
		DECLARE @dblQuantity DECIMAL(18,6)
		DECLARE @strContractNumber NVARCHAR(20)

		SET @strCustomerNumber  = @strCustomerNumberParam
		SET	@strItemNumber = @strItemNumberParam
		SET	@strLocation  = @strLocationParam
		SET	@strItemClass = @strItemClassParam
		SET	@dtmOrderDate = @dtmOrderDateParam
		SET	@dblQuantity = @dblQuantityParam
		SET	@strContractNumber = @strContractNumberParam
		
		SET @strSpecialPricing = dbo.fnTMGetSpecialPricing(
						@strCustomerNumber
						,@strItemNumber
						,@strLocation
						,@strItemClass
						,@dtmOrderDate
						,@dblQuantity
						,@strContractNumber)
		SET @dblPrice = CAST(LEFT(@strSpecialPricing,CHARINDEX('':'',@strSpecialPricing)- 1) AS DECIMAL(18,6))
		RETURN ISNULL(@dblPrice,0.0)
	END	
'
)
END
GO