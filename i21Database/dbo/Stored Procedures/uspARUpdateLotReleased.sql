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
	 intItemId				= intItemId
	,intItemLocationId		= intItemLocationId
	,intItemUOMId			= intItemUOMId
	,intLotId				= intLotId
	,intSubLocationId		= intSubLocationId
	,intStorageLocationId	= intStorageLocationId
	,dblQty					= SUM(dblQuantityShipped) * CASE WHEN @Post = 1 THEN 1 ELSE -1  END
	,intTransactionId		= intInvoiceId
	,strTransactionId		= strInvoiceNumber
	,intTransactionTypeId	= @intLotTransactionType
	,dtmDate				= GETDATE()
FROM vyuARGetInvoiceDetailLot
WHERE intInvoiceId = @InvoiceId
GROUP BY
	 intItemId
	,intItemLocationId
	,intItemUOMId
	,intLotId
	,intSubLocationId
	,intStorageLocationId
	,dblQuantityShipped
	,intInvoiceId
	,strInvoiceNumber
 
EXEC [uspICCreateLotRelease]
	 @LotsToRelease 		= @ItemsToRelease
	,@intTransactionId 		= @InvoiceId
	,@intTransactionTypeId 	= @intLotTransactionType
	,@intUserId 			= @UserId

END