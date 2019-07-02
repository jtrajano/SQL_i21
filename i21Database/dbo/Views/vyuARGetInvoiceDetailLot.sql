CREATE VIEW [dbo].[vyuARGetInvoiceDetailLot]
AS 
SELECT intInvoiceDetailId			= IDL.intInvoiceDetailId
	 , intInvoiceDetailLotId		= IDL.intInvoiceDetailLotId
	 , intLotId						= IDL.intLotId
	 , intSort						= IDL.intSort
	 , intCreatedByUserId			= IDL.intCreatedByUserId
	 , intModifiedByUserId			= IDL.intModifiedByUserId
	 , intConcurrencyId				= IDL.intConcurrencyId
	 , intWeightUOMId				= CASE WHEN ISNULL(LSLOT.intLoadDetailId, 0) <> 0 THEN LSLOT.intWeightUOMId ELSE ICLOT.intWeightUOMId END
	 , dblQuantityShipped			= IDL.dblQuantityShipped
	 , dblGrossWeight				= IDL.dblGrossWeight
	 , dblTareWeight				= IDL.dblTareWeight
	 , dblWeightPerQty				= IDL.dblWeightPerQty
	 , dblAvailableQty				= ICLOT.dblAvailableQty
	 , strLotNumber					= ICLOT.strLotNumber
	 , strWarehouseCargoNumber		= IDL.strWarehouseCargoNumber
	 , strItemUOM					= ICLOT.strItemUOM
	 , strWeightUOM					= CASE WHEN ISNULL(LSLOT.intLoadDetailId, 0) <> 0 THEN LSLOT.strWeightUnitMeasure ELSE ICLOT.strWeightUOM END
	 , strStorageLocation			= ICLOT.strStorageLocation
	 , dtmDateCreated				= IDL.dtmDateCreated
	 , dtmDateModified				= IDL.dtmDateModified
FROM tblARInvoiceDetailLot IDL
INNER JOIN tblARInvoiceDetail ID ON IDL.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN vyuICGetLot ICLOT ON IDL.intLotId = ICLOT.intLotId
LEFT JOIN vyuLGLoadDetailLotsView LSLOT ON IDL.intLotId = LSLOT.intLotId AND ID.intLoadDetailId = LSLOT.intLoadDetailId
