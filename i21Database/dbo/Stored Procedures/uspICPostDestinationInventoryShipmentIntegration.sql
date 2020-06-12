/*
	Parameters:

*/
CREATE PROCEDURE [uspICPostDestinationInventoryShipmentIntegration]
	@DestinationItems AS DestinationShipmentItem READONLY
	,@ysnPost AS BIT 
	,@intEntityUserSecurityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @contractSequenceBalance AS CTContractSequenceBalanceType

IF @ysnPost = 1
BEGIN
	INSERT INTO @contractSequenceBalance (
		 intExternalId 
		, intContractDetailId 
		, dblOldQuantity 
		, dblQuantity 
		, intItemUOMId 
		, strScreenName 
		, intUserId 
	)
	SELECT 
		 intExternalId = si.intInventoryShipmentItemId
		, intContractDetailId = si.intLineNo
		, dblOldQuantity = si.dblQuantity
		, dblQuantity = si.dblDestinationQuantity
		, intItemUOMId = si.intItemUOMId
		, strScreenName = 'Inventory'
		, intUserId = @intEntityUserSecurityId
	FROM	
		tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
			ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN tblICItemLocation l
			ON l.intItemId = si.intItemId
			AND l.intLocationId = s.intShipFromLocationId			
		INNER JOIN @DestinationItems d
			ON s.intInventoryShipmentId = d.intInventoryShipmentId
			AND si.intItemId = d.intItemId
			AND l.intItemLocationId = d.intItemLocationId
			AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 
END 

IF @ysnPost = 0
BEGIN
	INSERT INTO @contractSequenceBalance (
		 intExternalId 
		, intContractDetailId 
		, dblOldQuantity 
		, dblQuantity 
		, intItemUOMId 
		, strScreenName 
		, intUserId 
	)
	SELECT 
		 intExternalId = si.intInventoryShipmentItemId
		, intContractDetailId = si.intLineNo
		, dblOldQuantity = si.dblDestinationQuantity
		, dblQuantity = si.dblQuantity
		, intItemUOMId = si.intItemUOMId
		, strScreenName = 'Inventory'
		, intUserId = @intEntityUserSecurityId
	FROM	
		tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
			ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN tblICItemLocation l
			ON l.intItemId = si.intItemId
			AND l.intLocationId = s.intShipFromLocationId			
		INNER JOIN @DestinationItems d
			ON s.intInventoryShipmentId = d.intInventoryShipmentId
			AND si.intItemId = d.intItemId
			AND l.intItemLocationId = d.intItemLocationId
			AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 
END 


EXEC uspCTUpdateDWGSequenceBalance 
	@ContractSequenceBalance = @contractSequenceBalance
