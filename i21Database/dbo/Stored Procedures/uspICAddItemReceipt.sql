CREATE PROCEDURE [dbo].[uspICAddItemReceipt]
	 @ReceiptEntries ReceiptStagingTable READONLY	
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @total as INT;
DECLARE @incval as INT;
DECLARE @ReceiptNumber as nvarchar(50);
Declare @InventoryReceiptId as int;
DECLARE @temp TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
    Vendor int,
    BillOfLadding nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	ReceiptType nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	Location int,
	ShipVia int,
	ShipFrom int,
	Currency int,
    ReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL
    )

insert into @temp(Vendor ,
				  BillOfLadding,
				  ReceiptType,
				  Location,
				  ShipVia,
				  ShipFrom,
				  Currency,
				  ReceiptNumber 
				  )
		select RE.intEntityVendorId,RE.strBillOfLadding,RE.strReceiptType,RE.intLocationId,RE.intShipViaId,RE.intShipFromId,RE.intCurrencyId,null from @ReceiptEntries RE
				       group by RE.intEntityVendorId,RE.strBillOfLadding,RE.strReceiptType,RE.intLocationId,RE.intShipViaId,RE.intShipFromId,RE.intCurrencyId;

select @total = count(*) from @temp;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

   IF @ReceiptNumber IS NULL 
   BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	   RAISERROR(50030, 11, 1);
	   RETURN;
   END 
   update @temp 
       set ReceiptNumber = @ReceiptNumber
         where intId = @incval 
   SET @incval = @incval + 1;
END;

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intEntityVendorId
		,strReceiptType
		,intBlanketRelease
		,intLocationId
		,strVendorRefNo
		,strBillOfLading
		,intShipViaId
		,intShipFromId
		,intReceiverId
		,intCurrencyId
		,strVessel
		,intFreightTermId
		,strAllocateFreight
		,intShiftNumber
		,dblInvoiceAmount
		,ysnInvoicePaid
		,intCheckNo
		,dtmCheckDate
		,intTrailerTypeId
		,dtmTrailerArrivalDate
		,dtmTrailerArrivalTime
		,strSealNo
		,strSealStatus
		,dtmReceiveTime
		,dblActualTempReading
		,intConcurrencyId
		,intEntityId
		,intCreatedUserId
		,ysnPosted
)
SELECT 	 strReceiptNumber       = TE.ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= RE.intEntityVendorId
		,strReceiptType			= RE.strReceiptType
		,intBlanketRelease		= NULL
		,intLocationId			= RE.intLocationId
		,strVendorRefNo			= NULL
		,strBillOfLading		= RE.strBillOfLadding
		,intShipViaId			= RE.intShipViaId
		,intShipFromId			= RE.intShipFromId
		,intReceiverId			= @intUserId 
		,intCurrencyId			= RE.intCurrencyId
		,strVessel				= NULL
		,intFreightTermId		= NULL
		,strAllocateFreight		= 'No' -- Default is No
		,intShiftNumber			= NULL 
		,dblInvoiceAmount		= 0
		,ysnInvoicePaid			= 0 
		,intCheckNo				= NULL 
		,dteCheckDate			= NULL 
		,intTrailerTypeId		= NULL 
		,dteTrailerArrivalDate	= NULL 
		,dteTrailerArrivalTime	= NULL 
		,strSealNo				= NULL 
		,strSealStatus			= NULL 
		,dteReceiveTime			= NULL 
		,dblActualTempReading	= NULL 
		,intConcurrencyId		= 1
		,intEntityId			= (SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WHERE intUserSecurityID = @intUserId)
		,intCreatedUserId		= @intUserId
		,ysnPosted				= 0
FROM	@ReceiptEntries RE
        JOIN @temp TE on TE.Vendor = RE.intEntityVendorId 
		             and IsNull(TE.BillOfLadding,0) = IsNull(RE.strBillOfLadding,0) 
					 and IsNull(TE.Currency,0) = IsNull(RE.intCurrencyId,0)
					 and IsNull(TE.Location,0) = IsNull(RE.intLocationId,0)
					 and IsNull(TE.ReceiptType,0) = IsNull(RE.strReceiptType,0)
					 and IsNull(TE.ShipFrom,0) = IsNull(RE.intShipFromId,0)
					 and IsNull(TE.ShipVia,0) = IsNull(RE.intShipViaId,0)		           
        group by  RE.intEntityVendorId,RE.strBillOfLadding,TE.ReceiptNumber,RE.strReceiptType,RE.intLocationId,RE.intShipViaId,RE.intShipFromId,RE.intCurrencyId

-- Get the identity value from tblICInventoryReceipt to check if the insert was with no errors 
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

IF @InventoryReceiptId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	RAISERROR(50031, 11, 1);
	RETURN;
END

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intOrderId
	,intSourceId
    ,intItemId
	,intSubLocationId
	,dblOrderQty
	,dblOpenReceive
	,dblReceived
    ,intUnitMeasureId
	,intWeightUOMId
    ,dblUnitCost
	,dblLineTotal
    ,intSort
    ,intConcurrencyId
	,intOwnershipType
)
SELECT	intInventoryReceiptId	= IE.intInventoryReceiptId
		,intLineNo				= RE.intContractDetailId
		,intOrderId				= RE.intContractDetailId
		,intSourceId			= RE.intSourceId
		,intItemId				= RE.intItemId
		,intSubLocationId		= NUll
		,dblOrderQty			= RE.dblQty
		,dblOpenReceive			= RE.dblQty
		,dblReceived			= RE.dblQty
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = RE.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType = 'Weight'
												AND dbo.fnGetItemLotType(RE.intItemId) IN (1,2)
									)
		,dblUnitCost			= RE.dblCost
		,dblLineTotal			= RE.dblQty * RE.dblCost
		,intSort				= 1
		,intConcurrencyId		= 1
		,intOwnershipType       = CASE
								  WHEN RE.ysnIsCustody = 0
								  THEN 1
								  WHEN RE.ysnIsCustody = 1
								  THEN 2
								  END
FROM	@ReceiptEntries RE
JOIN @temp TE on TE.Vendor = RE.intEntityVendorId 
		             and IsNull(TE.BillOfLadding,0) = IsNull(RE.strBillOfLadding,0) 
					 and IsNull(TE.Currency,0) = IsNull(RE.intCurrencyId,0)
					 and IsNull(TE.Location,0) = IsNull(RE.intLocationId,0)
					 and IsNull(TE.ReceiptType,0) = IsNull(RE.strReceiptType,0)
					 and IsNull(TE.ShipFrom,0) = IsNull(RE.intShipFromId,0)
					 and IsNull(TE.ShipVia,0) = IsNull(RE.intShipViaId,0)		   
		JOIN tblICInventoryReceipt IE on IE.strReceiptNumber = TE.ReceiptNumber			 	       
        INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = RE.intItemId  AND ItemUOM.intItemUOMId = RE.intItemUOMId			
		INNER JOIN dbo.tblICUnitMeasure UOM
		    ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	

-- Re-update the total cost 
UPDATE	Receipt
SET		dblInvoiceAmount = (
			SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
			FROM	dbo.tblICInventoryReceiptItem ReceiptItem
			WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
		)
FROM	dbo.tblICInventoryReceipt Receipt 
        JOIN @ReceiptEntries RE 
             ON RE.intEntityVendorId = Receipt.intEntityVendorId 
			  and RE.strBillOfLadding = Receipt.strBillOfLading


-- Output the values to calling SP
select 
		 RE.intSourceId	
		,IE.intInventoryReceiptId	
FROM	@ReceiptEntries RE
JOIN @temp TE on TE.Vendor = RE.intEntityVendorId 
		             and IsNull(TE.BillOfLadding,0) = IsNull(RE.strBillOfLadding,0) 
					 and IsNull(TE.Currency,0) = IsNull(RE.intCurrencyId,0)
					 and IsNull(TE.Location,0) = IsNull(RE.intLocationId,0)
					 and IsNull(TE.ReceiptType,0) = IsNull(RE.strReceiptType,0)
					 and IsNull(TE.ShipFrom,0) = IsNull(RE.intShipFromId,0)
					 and IsNull(TE.ShipVia,0) = IsNull(RE.intShipViaId,0)		   
		JOIN tblICInventoryReceipt IE on IE.strReceiptNumber = TE.ReceiptNumber			 	       

