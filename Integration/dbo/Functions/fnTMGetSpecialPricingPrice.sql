GO

IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricingPrice]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetSpecialPricingPrice]
GO 

IF (EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricing]') AND type IN (N'FN')))
BEGIN
	EXEC('
	CREATE FUNCTION [dbo].[fnTMGetSpecialPricingPrice](
		@strCustomerNumber AS NVARCHAR(20)
		,@strItemNumber NVARCHAR(20)
		,@strLocation NVARCHAR(20)
		,@strItemClass NVARCHAR(20)
		,@dtmOrderDate DATETIME
		,@dblQuantity DECIMAL(18,6)
		,@strContractNumber NVARCHAR(20)
	)
	RETURNS DECIMAL(18,6)
	AS
	BEGIN 
		DECLARE @dblPrice NUMERIC(18,6)
		DECLARE @strSpecialPricing NVARCHAR(50)
		
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