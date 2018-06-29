CREATE VIEW [dbo].[vyuTRGetTransportLoadReceipt]
	AS
	with LoadSchedule as (
	select
		LD.intLoadDetailId
		,dblQuantity = CASE WHEN ISNULL(LDCL.dblQuantity,0) = 0 THEN LD.dblQuantity ELSE LDCL.dblQuantity END
	from
		tblLGLoadDetail LD
		left join tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	)
	SELECT Receipt.intLoadReceiptId
			, Header.strTransaction
			, dblOrderedQuantity  = CASE WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Net' THEN Receipt.dblNet
									WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Gross' THEN Receipt.dblGross
									WHEN ISNULL(LoadSchedule.dblQuantity,0) != 0 THEN LoadSchedule.dblQuantity END
			, Receipt.dblGross
	FROM tblTRLoadReceipt Receipt
	LEFT JOIN tblTRLoadHeader Header ON Header.intLoadHeaderId = Receipt.intLoadHeaderId
	left join tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = Receipt.intSupplyPointId
	LEFT JOIN LoadSchedule ON LoadSchedule.intLoadDetailId = Receipt.intLoadDetailId
	--LEFT JOIN vyuTRTerminal Terminal ON Terminal.intEntityVendorId = Receipt.intTerminalId
	--LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = Receipt.intSupplyPointId
	--LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = Receipt.intCompanyLocationId
	--LEFT JOIN tblICItem Item ON Item.intItemId = Receipt.intItemId
	--LEFT JOIN vyuCTContractDetailView Contract ON Contract.intContractDetailId = Receipt.intContractDetailId
	--LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = Receipt.intInventoryReceiptId
	--LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = Receipt.intInventoryTransferId
	--LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = Receipt.intTaxGroupId

	/*
	BEGIN Fix for IC-4601
	(1) Original code: LEFT JOIN vyuLGLoadDetailView LoadSchedule ON LoadSchedule.intLoadDetailId = Receipt.intLoadDetailId 
	(2) Replaced it with the code below. Replace vyuLGLoadDetailView with vyuLGLoadContainerLookup. 
	vyuLGLoadDetailView is running slow. 
	*/
	--LEFT JOIN vyuLGLoadContainerLookup LoadSchedule ON LoadSchedule.intLoadDetailId = Receipt.intLoadDetailId
	/*END Fix for IC-4601*/