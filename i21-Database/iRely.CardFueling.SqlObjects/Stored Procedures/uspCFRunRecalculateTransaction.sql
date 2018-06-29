
CREATE PROCEDURE [dbo].[uspCFRunRecalculateTransaction]
@TransactionId					INT	
,@ContractsOverfill				INT = 0
AS
BEGIN
DECLARE @intTransactionId		INT
DECLARE @strTransactionId		NVARCHAR(MAX)
DECLARE @intProductId			INT
DECLARE @intVehicleId			INT
DECLARE @intCardId				INT
DECLARE @intSiteId				INT
DECLARE @dtmTransactionDate		DATETIME
DECLARE @dblQuantity			NUMERIC(18,6)
DECLARE @dblOriginalPrice		NUMERIC(18,6)
DECLARE @strTransactionType		NVARCHAR(MAX)
DECLARE @intNetworkId			INT
DECLARE @dblTransferCost		NUMERIC(18,6)
DECLARE @ysnCreditCardUsed		BIT
DECLARE @intPumpId				INT
DECLARE @intInvoiceId			INT


SELECT TOP 1  ---------------CHANGE THIS------------
 @intTransactionId = t.intTransactionId	
,@strTransactionId = strTransactionId	
,@intProductId = intProductId		
,@intVehicleId = intVehicleId		
,@intCardId = intCardId			
,@intSiteId = intSiteId			
,@dtmTransactionDate = dtmTransactionDate	
,@dblQuantity = dblQuantity		
,@dblOriginalPrice = t.dblOriginalGrossPrice
,@strTransactionType = t.strTransactionType	
,@intNetworkId = intNetworkId		
,@dblTransferCost = dblTransferCost	
,@ysnCreditCardUsed = ysnCreditCardUsed	
,@intPumpId = intPumpNumber	
,@intInvoiceId = t.intInvoiceId			
FROM tblCFTransaction t
WHERE t.intTransactionId = @TransactionId


EXEC dbo.uspCFRecalculateTransaciton
 @ProductId				= @intProductId
,@VehicleId				= @intVehicleId		
,@CardId				= @intCardId			
,@SiteId				= @intSiteId			
,@TransactionDate		= @dtmTransactionDate
,@Quantity				= @dblQuantity		
,@OriginalPrice			= @dblOriginalPrice	
,@TransactionType		= @strTransactionType
,@NetworkId				= @intNetworkId		
,@TransferCost			= @dblTransferCost	
,@TransactionId			= @intTransactionId	
,@CreditCardUsed		= @ysnCreditCardUsed	
,@PumpId				= @intPumpId
,@BatchRecalculate		= 1


IF(ISNULL(@ContractsOverfill,0) = 0)
BEGIN
	
	SELECT * FROM tblCFBatchRecalculateStagingTable where intTransactionId =  @intTransactionId
END


END