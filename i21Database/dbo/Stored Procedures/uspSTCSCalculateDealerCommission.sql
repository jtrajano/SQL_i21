CREATE PROCEDURE [dbo].[uspSTCSCalculateDealerCommission] (
    @intCheckoutId INT,
	@intCheckoutProcessId INT
)
AS
SET NOCOUNT ON;

DECLARE @Cost DECIMAL(18,6)  
DECLARE @dblMargin DECIMAL(18,6)  
DECLARE @dblCommission DECIMAL(18,6)  
DECLARE @dblQty DECIMAL(18,6)  
DECLARE @dblPrice DECIMAL(18,6)  
DECLARE @dblMarkUp DECIMAL(18,6)  
DECLARE @dblDealerPercentage DECIMAL(18,6)  
DECLARE @intItemId INT  
DECLARE @intCompanyLocationId INT  
DECLARE @intItemUOMId INT  
DECLARE @intStoreId INT  
DECLARE @dblTotalCommission DECIMAL (18,6) = 0  
DECLARE @strItemNo NVARCHAR(250)  
DECLARE @strItemDescription NVARCHAR(500) 
DECLARE @strMessage NVARCHAR(MAX)  

DECLARE @intPumpTotalsId int  
  
DECLARE MY_CURSOR CURSOR   
    LOCAL STATIC READ_ONLY FORWARD_ONLY  
FOR  
  
SELECT intPumpTotalsId  
FROM  
dbo.tblSTCheckoutPumpTotals CPT  
WHERE CPT.intCheckoutId = @intCheckoutId  
  
SELECT @intStoreId = CH.intStoreId  
FROM  
dbo.tblSTCheckoutHeader CH  
WHERE CH.intCheckoutId = @intCheckoutId  
  
SELECT   
@dblMarkUp = ST.dblConsCommissionRawMarkup  
, @dblDealerPercentage = ST.dblConsCommissionDealerPercentage  
FROM tblSTStore ST  
WHERE ST.intStoreId = @intStoreId  
  
OPEN MY_CURSOR  
FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId  
WHILE @@FETCH_STATUS = 0  
BEGIN   
	SELECT 
	@intItemId = Item.intItemId  
	, @strItemNo = Item.strItemNo
	, @strItemDescription = Item.strDescription
	, @intCompanyLocationId = ST.intCompanyLocationId  
	, @dblQty = CPT.dblQuantity  
	, @dblPrice = CPT.dblPrice  
	, @intItemUOMId = UOM.intItemUOMId 
	FROM
	dbo.tblSTCheckoutPumpTotals CPT
	INNER JOIN tblSTCheckoutHeader CH
		ON CPT.intCheckoutId = CH.intCheckoutId
	INNER JOIN tblSTStore ST
		ON CH.intStoreId = ST.intStoreId
	INNER JOIN tblICItemUOM UOM
		ON CPT.intPumpCardCouponId = UOM.intItemUOMId
	INNER JOIN tblICItem Item
		ON UOM.intItemId = Item.intItemId
	WHERE CPT.intPumpTotalsId = @intPumpTotalsId  

	--- START INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
	-- MARGIN = ((Qty Sold) * (Unit Price)) - (Cost in Inventory)  - ((Qty Sold) * (Consignor Markup/dblConsCommissionRawMarkup))  
	-- COMMISSION = (MARGIN) * (Commission Rate/dblConsCommissionDealerPercentage)      
	--BEGIN TRAN  
	EXEC [dbo].[uspICCalculateCost] @intItemId, @intCompanyLocationId, @dblQty, NULL, @Cost OUT, @intItemUOMId  
	--ROLLBACK

	IF @Cost = NULL
	BEGIN
		DECLARE @ysnAutoBlend BIT
		SELECT @ysnAutoBlend = i.ysnAutoBlend FROM tblICItem i WHERE i.intItemId = @intItemId

		IF @ysnAutoBlend = 1
		BEGIN
			SELECT @Cost = SUM(r.dblCost * r.dblQuantity)
			FROM vyuMFGetRecipeItem r 
			WHERE 
			r.intLocationId = @intCompanyLocationId 
			AND strRecipeItemNo = @strItemNo
			AND r.strRecipeItemType = 'INPUT'
		END
	END	

	SET @dblMargin = (@dblQty * @dblPrice) - (ISNULL(@Cost,0) * @dblQty) - (@dblQty * @dblMarkUp)  
	SET @dblCommission = @dblMargin * @dblDealerPercentage  
	SET @dblTotalCommission += @dblCommission  

	IF @dblCommission < 0
	BEGIN
		SET @strMessage = 'Negative Dealer commissions have been calculated for fuel grade ' + @strItemNo + '-' + @strItemDescription + ' which is an indication that this fuel''s cost basis isn''t correctly set. Please correct the cost basis before processing this day.'
		INSERT tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, intCheckoutId, strMessageType, strMessage, intConcurrencyId)
		VALUES (@intCheckoutProcessId, @intCheckoutId, 'F', @strMessage, 1) 
	END

	SET @Cost = NULL;
  
	--- END INSERT FORMULA FOR CALCULATING DEALER COMMISSION HERE....  
	FETCH NEXT FROM MY_CURSOR INTO @intPumpTotalsId  
END  
CLOSE MY_CURSOR  
DEALLOCATE MY_CURSOR  
  
UPDATE tblSTCheckoutHeader			 SET dblDealerCommission = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId  
UPDATE tblSTCheckoutDealerCommission SET dblCommissionAmount = @dblTotalCommission WHERE intCheckoutId = @intCheckoutId 

--ROLLBACK