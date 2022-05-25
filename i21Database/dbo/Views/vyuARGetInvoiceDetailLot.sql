CREATE VIEW [dbo].[vyuARGetInvoiceDetailLot]
AS 
SELECT 
	 intInvoiceId			= I.intInvoiceId
	,strInvoiceNumber		= I.strInvoiceNumber
	,intInvoiceDetailId		= IDL.intInvoiceDetailId
	,intInvoiceDetailLotId	= IDL.intInvoiceDetailLotId
	,intItemId				= ID.intItemId
	,intItemLocationId		= ICLOT.intItemLocationId
	,intSubLocationId		= ICLOT.intSubLocationId
	,intStorageLocationId	= ICLOT.intStorageLocationId
	,intLotId				= IDL.intLotId
	,intSort				= IDL.intSort
	,intCreatedByUserId		= IDL.intCreatedByUserId
	,intModifiedByUserId	= IDL.intModifiedByUserId
	,intConcurrencyId		= IDL.intConcurrencyId
	,intWeightUOMId			= CASE WHEN ISNULL(ID.intLoadDetailId, 0) <> 0 THEN LG.intWeightUnitMeasureId ELSE ICLOT.intWeightUOMId END
	,dblQuantityShipped		= IDL.dblQuantityShipped
	,dblGrossWeight			= IDL.dblGrossWeight
	,dblTareWeight			= IDL.dblTareWeight
	,dblWeightPerQty		= IDL.dblWeightPerQty
	,dblAvailableQty		= CAST(ICLOT.dblAvailableQty AS NUMERIC(18, 6))
	,strLotNumber			= ICLOT.strLotNumber
	,strWarehouseCargoNumber= IDL.strWarehouseCargoNumber
	,strItemUOM				= ICLOT.strItemUOM
	,intItemUOMId			= ICLOT.intItemUOMId
	,strWeightUOM			= CASE WHEN ISNULL(ID.intLoadDetailId, 0) <> 0 THEN UM.strUnitMeasure ELSE ICLOT.strWeightUOM END
	,strStorageLocation		= ICLOT.strStorageLocation
	,dtmDateCreated			= IDL.dtmDateCreated
	,dtmDateModified		= IDL.dtmDateModified
FROM tblARInvoiceDetailLot IDL
INNER JOIN tblARInvoiceDetail ID ON IDL.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId 
INNER JOIN vyuICGetLot ICLOT ON IDL.intLotId = ICLOT.intLotId
LEFT JOIN tblLGLoad LG ON I.intLoadId = LG.intLoadId
LEFT JOIN tblICUnitMeasure UM ON LG.intWeightUnitMeasureId = UM.intUnitMeasureId