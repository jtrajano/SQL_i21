CREATE VIEW [dbo].[vyuTRLinkedReceipts]
	AS 
select		TR.intLoadHeaderId,  
            DD.intLoadDistributionDetailId,          
			TR.strBillOfLading,
			SP.strFuelSupplier,
			SP.strSupplyPoint,
			SM.strLocationName strReceiptCompanyLocation,
			yy.strReceiptNumber,
			yyy.strTransferNo,
			TR.dblUnitCost		
	from tblTRLoadDistributionHeader DH
	     Join tblTRLoadDistributionDetail DD on DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
	     left join tblTRLoadReceipt TR on DH.intLoadHeaderId = TR.intLoadHeaderId and  TR.strReceiptLine in (select Item from fnTRSplit(DD.strReceiptLink,','))
         left join vyuTRSupplyPointView SP on SP.intSupplyPointId = TR.intSupplyPointId
		 left join dbo.tblICInventoryReceipt yy on TR.intInventoryReceiptId = yy.intInventoryReceiptId and TR.intLoadReceiptId = TR.intLoadReceiptId
		 left join dbo.tblICInventoryTransfer yyy on TR.intInventoryTransferId = yyy.intInventoryTransferId  and TR.intLoadReceiptId = TR.intLoadReceiptId
		 left join dbo.tblSMCompanyLocation SM ON SM.intCompanyLocationId = TR.intCompanyLocationId