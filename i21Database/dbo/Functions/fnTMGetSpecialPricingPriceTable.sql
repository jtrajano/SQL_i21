CREATE FUNCTION [dbo].[fnTMGetSpecialPricingPriceTable](
	@strCustomerNumber AS NVARCHAR(20)
	,@strItemNumber NVARCHAR(20)
	,@strLocation NVARCHAR(20)
	,@strItemClass NVARCHAR(20)
	,@dtmOrderDate DATETIME
	,@dblQuantityParam DECIMAL(18,6)
	,@strContractNumber NVARCHAR(20)
	,@intSiteId INT
)
RETURNS @tblSpecialPriceTableReturn TABLE(
	dblPrice NUMERIC(18,6)
)
AS
BEGIN 
	DECLARE @dblPrice NUMERIC(18,6)
	DECLARE @strSpecialPricing NVARCHAR(50)
	DECLARE @intProductId INT
	DECLARE @intLocationId INT
	DECLARE @intEntityCustomerId INT
	DECLARE @dblQuantity DECIMAL(18,6)

	SET @dblQuantity = @dblQuantityParam
	SELECT 
		@intProductId = A.intProduct
		,@intLocationId = A.intLocationId
		,@intEntityCustomerId = B.intCustomerNumber
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	WHERE intSiteID = @intSiteId

	SET @strSpecialPricing = dbo.fnGetItemPricing(@intProductId,@intEntityCustomerId,@intLocationId,NULL,GETDATE(),@dblQuantity,':')
	SET @dblPrice = CAST(LEFT(@strSpecialPricing,CHARINDEX(':',@strSpecialPricing)- 1) AS DECIMAL(18,6))
	


	INSERT INTO @tblSpecialPriceTableReturn (dblPrice)
	SELECT ISNULL(@dblPrice,0.0)

	RETURN 

END	
GO