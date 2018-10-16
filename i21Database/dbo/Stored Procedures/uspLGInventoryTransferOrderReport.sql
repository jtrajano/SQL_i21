CREATE PROCEDURE [dbo].[uspLGInventoryTransferOrderReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intInventoryTransferId INT
	DECLARE @query NVARCHAR(MAX);
	DECLARE @xmlDocumentId AS INT;

	IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN
		--SET @xmlParam = NULL 
		SELECT *
			,CAST(0 AS BIT) ysnHasHeaderLogo
		FROM [vyuICGetInventoryTransferDetail]
		WHERE intInventoryTransferId = 1 --RETURN NOTHING TO RETURN SCHEMA
	END

	-- Create a table variable to hold the XML data. 		
	DECLARE @temp_xml_table TABLE (
		id INT IDENTITY(1, 1)
		,[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[datatype] NVARCHAR(50)
		)

	-- Prepare the XML 
	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam


	IF ISNULL(@xmlParam,'') = ''
	BEGIN
		SELECT 
		 NULL intInventoryTransferId	
		,NULL intInventoryTransferDetailId	
		,NULL intFromLocationId	
		,NULL intToLocationId	
		,NULL strTransferNo	
		,NULL strTransferType	
		,NULL intSourceType	
		,NULL strSourceType	
		,NULL intSourceId	
		,NULL strSourceNumber	
		,NULL intItemId	
		,NULL strItemNo	
		,NULL strItemDescription	
		,NULL strLotTracking	
		,NULL intCommodityId	
		,NULL intLotId	
		,NULL strLotNumber	
		,NULL intParentLotId	
		,NULL strParentLotNumber	
		,NULL intLifeTime	
		,NULL strLifeTimeType	
		,NULL intFromSubLocationId	
		,NULL strFromSubLocationName	
		,NULL intToSubLocationId	
		,NULL strToSubLocationName	
		,NULL intFromStorageLocationId	
		,NULL strFromStorageLocationName	
		,NULL intToStorageLocationId	
		,NULL strToStorageLocationName	
		,NULL intItemUOMId	
		,NULL strItemUOM	
		,NULL strUnitMeasure	
		,NULL strUnitMeasureSymbol	
		,NULL dblItemUOMCF	
		,NULL intWeightUOMId	
		,NULL strWeightUOM	
		,NULL dblWeightUOMCF	
		,NULL strTaxCode	
		,NULL strAvailableUOM	
		,NULL dblLastCost	
		,NULL dblOnHand	
		,NULL dblOnOrder	
		,NULL dblReservedQty	
		,NULL dblAvailableQty	
		,NULL dblQuantity	
		,NULL dblOriginalAvailableQty	
		,NULL dblOriginalStorageQty	
		,NULL intOwnershipType	
		,NULL strOwnershipType	
		,NULL ysnPosted	
		,NULL dblCost	
		,NULL ysnWeights	
		,NULL strDescription	
		,NULL strItemType	
		,NULL dblGross	
		,NULL dblNet	
		,NULL dblTare	
		,NULL intGrossNetUOMId	
		,NULL strGrossNetUOM	
		,NULL strNewLotId	
		,NULL strGrossNetUOMSymbol	
		,NULL dblGrossNetUnitQty	
		,NULL dblItemUnitQty	
		,NULL dtmTransferDate	
		,NULL ysnShipmentRequired	
		,NULL strTransferredBy	
		,NULL strFromLocationName	
		,NULL strToLocationName	
		,NULL strStatus	
		,NULL strTransferFromAddress	
		,NULL strFromInternalNotes	
		,NULL strTransferToAddress	
		,NULL strToInternalNotes	
		,NULL strLotCondition	
		,NULL intNewLotStatusId	
		,NULL strNewLotStatus	
		,NULL dblWeightPerQty	
		,NULL intCostingMethod	
		,NULL strWarehouseRefNo	
		,NULL strNewWarehouseRefNo	
		,NULL strCostingMethod	
		,NULL intConcurrencyId	
		,NULL strContainerNumber	
		,NULL strMarks	
		,NULL blbFullHeaderLogo	
		,NULL blbFullFooterLogo	
		,NULL ysnFullHeaderLogo	
		,NULL intReportLogoHeight	
		,NULL intReportLogoWidth	
		,NULL strContractNumberSeq
		,NULL strFromEmail
		,NULL strFromPhoneFax
		,NULL strToEmail
		,NULL strToPhoneFax
	END

	-- Insert the XML to the xml table. 		
	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,[condition] NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[datatype] NVARCHAR(50)
			)

	DECLARE @strTransferNo NVARCHAR(100)

	SELECT @strTransferNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTransferNo'

	IF ISNULL(@xmlParam,'') <> ''
	BEGIN
		SELECT TransferDetail.intInventoryTransferId
			,TransferDetail.intInventoryTransferDetailId
			,[Transfer].intFromLocationId
			,[Transfer].intToLocationId
			,[Transfer].strTransferNo
			,[Transfer].strTransferType
			,[Transfer].intSourceType
			,strSourceType = CASE 
				WHEN [Transfer].intSourceType = 1
					THEN 'Scale'
				WHEN [Transfer].intSourceType = 2
					THEN 'Inbound Shipment'
				WHEN [Transfer].intSourceType = 3
					THEN 'Transports'
				ELSE 'None'
				END
			,TransferDetail.intSourceId
			,strSourceNumber = (
				CASE 
					WHEN [Transfer].intSourceType = 1 -- Scale
						THEN (
								SELECT TOP 1 strTicketNumber
								FROM tblSCTicket
								WHERE intTicketId = TransferDetail.intSourceId
								)
					WHEN [Transfer].intSourceType = 2 -- Inbound Shipment
						THEN (
								SELECT TOP 1 CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!') AS NVARCHAR(50))
								FROM tblLGShipment
								WHERE intShipmentId = TransferDetail.intSourceId
								)
					WHEN [Transfer].intSourceType = 3 -- Transports
						THEN (
								SELECT TOP 1 CAST(ISNULL(TransportView.strTransaction, 'Transport not found!') AS NVARCHAR(50))
								FROM vyuTRGetLoadReceipt TransportView
								WHERE TransportView.intLoadReceiptId = TransferDetail.intSourceId
								)
					ELSE NULL
					END
				)
			,TransferDetail.intItemId
			,Item.strItemNo
			,strItemDescription = Item.strDescription
			,Item.strLotTracking
			,Item.intCommodityId
			,TransferDetail.intLotId
			,Lot.strLotNumber
			,ParentLot.intParentLotId
			,ParentLot.strParentLotNumber
			,Item.intLifeTime
			,Item.strLifeTimeType
			,TransferDetail.intFromSubLocationId
			,strFromSubLocationName = ISNULL(FromVendor.strName,FromSubLocation.strSubLocationName)
			,TransferDetail.intToSubLocationId
			,strToSubLocationName = ISNULL(ToVendor.strName,ToSubLocation.strSubLocationName)
			,TransferDetail.intFromStorageLocationId
			,strFromStorageLocationName = FromStorageLocation.strName
			,TransferDetail.intToStorageLocationId
			,strToStorageLocationName = ToStorageLocation.strName
			,TransferDetail.intItemUOMId
			,strItemUOM = ItemUOM.strUnitMeasure
			,strUnitMeasure = ItemUOM.strUnitMeasure
			,strUnitMeasureSymbol = COALESCE(NULLIF(ItemUOM.strSymbol, ''), NULLIF(ItemUOM.strUnitMeasure, ''))
			,dblItemUOMCF = ItemUOM.dblUnitQty
			,intWeightUOMId = TransferDetail.intItemWeightUOMId
			,strWeightUOM = ItemWeightUOM.strUnitMeasure
			,dblWeightUOMCF = ItemWeightUOM.dblUnitQty
			,TaxCode.strTaxCode
			,strAvailableUOM = CASE 
				WHEN ISNULL(Lot.intLotId, '') = ''
					THEN StockFrom.strUnitMeasure
				ELSE Lot.strItemUOM
				END
			,StockFrom.dblLastCost
			,StockFrom.dblOnHand
			,StockFrom.dblOnOrder
			,StockFrom.dblReservedQty
			,dblAvailableQty =
			--CASE	WHEN [Transfer].ysnPosted = 1 THEN 						
			CASE 
				WHEN TransferDetail.intOwnershipType = 1
					THEN -- Own
						TransferDetail.dblOriginalAvailableQty
				WHEN TransferDetail.intOwnershipType = 2
					THEN -- Storage
						TransferDetail.dblOriginalStorageQty
				ELSE -- Consigned Purchase
					TransferDetail.dblOriginalAvailableQty
				END
			,TransferDetail.dblQuantity
			,TransferDetail.dblOriginalAvailableQty
			,TransferDetail.dblOriginalStorageQty
			,TransferDetail.intOwnershipType
			,strOwnershipType = (
				CASE 
					WHEN TransferDetail.intOwnershipType = 1
						THEN 'Own'
					WHEN TransferDetail.intOwnershipType = 2
						THEN 'Storage'
					WHEN TransferDetail.intOwnershipType = 3
						THEN 'Consigned Purchase'
					ELSE NULL
					END
				)
			,[Transfer].ysnPosted
			,TransferDetail.dblCost
			,ysnWeights
			,[Transfer].strDescription
			,COALESCE(TransferDetail.strItemType, Item.strType) AS strItemType
			,TransferDetail.dblGross
			,TransferDetail.dblNet
			,TransferDetail.dblTare
			,TransferDetail.intGrossNetUOMId
			,strGrossNetUOM = GrossNetUOM.strUnitMeasure
			,strNewLotId = ISNULL(TransferDetail.strNewLotId, '')
			,strGrossNetUOMSymbol = COALESCE(GrossNetUOM.strSymbol, GrossNetUOM.strUnitMeasure)
			,dblGrossNetUnitQty = TransferDetail.dblGrossNetUnitQty
			,dblItemUnitQty = TransferDetail.dblItemUnitQty
			,[Transfer].dtmTransferDate
			,[Transfer].ysnShipmentRequired
			,strTransferredBy = e.strName
			,strFromLocationName = FromLoc.strLocationName
			,strToLocationName = ToLoc.strLocationName
			,stat.strStatus
			,strTransferFromAddress = FromVendor.strAddress + CHAR(13) + 
									  FromVendor.strCity + ', ' + FromVendor.strState + CHAR(13) +
									  FromVendor.strZipCode + ', ' +  FromVendor.strCountry
			,FET.strInternalNotes AS strFromInternalNotes
			,FET.strEmail AS strFromEmail
			,strFromPhoneFax = 'Tel : ' + FET.strPhone + ' Fax: ' + FEL.strFax

			,strTransferToAddress =   ToVendor.strAddress + CHAR(13) + 
									  ToVendor.strCity + ', ' + ToVendor.strState + CHAR(13) +
									  ToVendor.strZipCode + ', ' +  ToVendor.strCountry
			,TET.strInternalNotes AS strToInternalNotes
			,TET.strEmail strToEmail
			,strToPhoneFax = 'Tel : ' + TET.strPhone + ' Fax: ' + TEL.strFax
			

			,TransferDetail.strLotCondition
			,TransferDetail.intNewLotStatusId
			,strNewLotStatus = NewLotStatus.strPrimaryStatus
			,TransferDetail.dblWeightPerQty
			,TransferDetail.intCostingMethod
			,TransferDetail.strWarehouseRefNo
			,TransferDetail.strNewWarehouseRefNo
			,strCostingMethod = ISNULL(CostingMethod.strCostingMethod, '')
			,TransferDetail.intConcurrencyId
			,LC.strContainerNumber
			,LC.strMarks
			,dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo
			,dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo
			,CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END ysnFullHeaderLogo
			,ISNULL(CP.intReportLogoHeight,0) AS intReportLogoHeight
			,ISNULL(CP.intReportLogoWidth,0) AS intReportLogoWidth
			,CH.strContractNumber + ' / ' + LTRIM(CD.intContractSeq) AS strContractNumberSeq
		FROM tblICInventoryTransferDetail TransferDetail
		LEFT JOIN tblICInventoryTransfer [Transfer] ON [Transfer].intInventoryTransferId = TransferDetail.intInventoryTransferId
		LEFT JOIN tblEMEntity e ON e.intEntityId = [Transfer].intTransferredById
		LEFT JOIN tblICItem Item ON Item.intItemId = TransferDetail.intItemId
		LEFT JOIN tblICStatus stat ON stat.intStatusId = [Transfer].intStatusId
		LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = TransferDetail.intLotId
		LEFT JOIN tblSMCompanyLocation FromLoc ON FromLoc.intCompanyLocationId = [Transfer].intFromLocationId
		LEFT JOIN tblSMCompanyLocation ToLoc ON ToLoc.intCompanyLocationId = [Transfer].intToLocationId

		LEFT JOIN tblSMCompanyLocationSubLocation FromSubLocation ON FromSubLocation.intCompanyLocationSubLocationId = TransferDetail.intFromSubLocationId
		LEFT JOIN vyuAPVendor FromVendor ON FromVendor.intEntityId = FromSubLocation.intVendorId
		LEFT JOIN tblEMEntityToContact FETC ON FETC.intEntityId = FromVendor.intEntityId AND FETC.ysnDefaultContact = 1
		LEFT JOIN tblEMEntity FET ON FET.intEntityId = FETC.intEntityContactId
		JOIN tblEMEntityLocation FEL ON FEL.intEntityId = FromVendor.intEntityId AND FEL.ysnDefaultLocation = 1

		LEFT JOIN tblSMCompanyLocationSubLocation ToSubLocation ON ToSubLocation.intCompanyLocationSubLocationId = TransferDetail.intToSubLocationId
		LEFT JOIN vyuAPVendor ToVendor ON ToVendor.intEntityId = ToSubLocation.intVendorId
		LEFT JOIN tblEMEntityToContact TETC ON TETC.intEntityId = ToVendor.intEntityId AND TETC.ysnDefaultContact = 1
		LEFT JOIN tblEMEntity TET ON TET.intEntityId = TETC.intEntityContactId
		JOIN tblEMEntityLocation TEL ON TEL.intEntityId = ToVendor.intEntityId AND TEL.ysnDefaultLocation = 1

		LEFT JOIN tblICStorageLocation FromStorageLocation ON FromStorageLocation.intStorageLocationId = TransferDetail.intFromStorageLocationId
		LEFT JOIN tblICStorageLocation ToStorageLocation ON ToStorageLocation.intStorageLocationId = TransferDetail.intToStorageLocationId
		LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
		LEFT JOIN vyuICGetItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = TransferDetail.intItemWeightUOMId
		LEFT JOIN vyuICGetItemUOM GrossNetUOM ON GrossNetUOM.intItemUOMId = TransferDetail.intGrossNetUOMId
		LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = TransferDetail.intTaxCodeId
		LEFT JOIN vyuICGetItemStockUOM StockFrom ON StockFrom.intItemId = TransferDetail.intItemId
			AND StockFrom.intLocationId = [Transfer].intFromLocationId
			AND StockFrom.intItemUOMId = TransferDetail.intItemUOMId
			AND ISNULL(StockFrom.intSubLocationId, 0) = ISNULL(TransferDetail.intFromSubLocationId, 0)
			AND ISNULL(StockFrom.intStorageLocationId, 0) = ISNULL(TransferDetail.intFromStorageLocationId, 0)
			AND StockFrom.intLotId = Lot.intLotId
		LEFT JOIN (
			tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			) ON ReceiptItem.intOrderId = [Transfer].intInventoryTransferId
			AND Receipt.strReceiptType = 'Transfer Order'
		LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId
			AND ParentLot.intItemId = TransferDetail.intItemId
			AND TransferDetail.intLotId = Lot.intLotId
		LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = Lot.intLotId
		LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = IRI.intLineNo
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = IRI.intContainerId
		LEFT JOIN tblICCostingMethod CostingMethod ON CostingMethod.intCostingMethodId = TransferDetail.intCostingMethod
		LEFT JOIN tblICLotStatus NewLotStatus ON NewLotStatus.intLotStatusId = TransferDetail.intNewLotStatusId
		LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = [Transfer].intFromLocationId
		CROSS APPLY tblLGCompanyPreference CP 
		WHERE [Transfer].strTransferNo = @strTransferNo
		ORDER BY dtmTransferDate DESC
	END
END
