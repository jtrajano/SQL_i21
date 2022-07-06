CREATE PROCEDURE [dbo].[uspARUpdateLotReleased]
	 @InvoiceId	INT
    ,@UserId	INT
    ,@Post		BIT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToRelease 		dbo.LotReleaseTableType;
DECLARE @intLotTransactionType 	INT

SELECT TOP 1 @intLotTransactionType = intTransactionTypeId
FROM dbo.tblICInventoryTransactionType
WHERE strName = 'Invoice'

INSERT INTO @ItemsToRelease (
	 intItemId
	,intItemLocationId
	,intItemUOMId
	,intLotId
	,intSubLocationId
	,intStorageLocationId
	,dblQty
	,intTransactionId
	,strTransactionId
	,intTransactionTypeId
	,dtmDate
)
SELECT 
	 intItemId				= ARGIDL.intItemId
	,intItemLocationId		= ARGIDL.intItemLocationId
	,intItemUOMId			= ARGIDL.intItemUOMId
	,intLotId				= ARGIDL.intLotId
	,intSubLocationId		= ARGIDL.intSubLocationId
	,intStorageLocationId	= ARGIDL.intStorageLocationId
	,dblQty					= CASE WHEN @Post = 1 THEN ICL.dblReleasedQty - SUM(dblQuantityShipped) ELSE ICL.dblReleasedQty + SUM(dblQuantityShipped) END
	,intTransactionId		= ARGIDL.intInvoiceId
	,strTransactionId		= ARGIDL.strInvoiceNumber
	,intTransactionTypeId	= @intLotTransactionType
	,dtmDate				= GETDATE()
FROM vyuARGetInvoiceDetailLot ARGIDL
INNER JOIN tblICLot ICL ON ARGIDL.intLotId = ICL.intLotId
WHERE intInvoiceId = @InvoiceId
GROUP BY
	 ARGIDL.intItemId
	,ARGIDL.intItemLocationId
	,ARGIDL.intItemUOMId
	,ARGIDL.intLotId
	,ARGIDL.intSubLocationId
	,ARGIDL.intStorageLocationId
	,ICL.dblReleasedQty
	,ARGIDL.dblQuantityShipped
	,ARGIDL.intInvoiceId
	,ARGIDL.strInvoiceNumber
 
EXEC [uspICCreateLotRelease]
	 @LotsToRelease 		= @ItemsToRelease
	,@intTransactionId 		= @InvoiceId
	,@intTransactionTypeId 	= @intLotTransactionType
	,@intUserId 			= @UserId

END