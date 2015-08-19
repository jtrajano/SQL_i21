
CREATE VIEW [dbo].[vyuTRTransportReceipt]
	AS 
SELECT    
	TL.intTransportLoadId,
	TR.intTransportReceiptId,
    CT.intContractHeaderId,
	TR.intContractDetailId,
	CT.strContractNumber,
	TL.strTransaction,
	dblOrderedQuantity  = CASE
								  WHEN isNull(LG.dblQuantity,0) = 0 and SP.strGrossOrNet = 'Net'
								  THEN TR.dblNet
								  WHEN isNull(LG.dblQuantity,0) = 0 and SP.strGrossOrNet = 'Gross'
								  THEN TR.dblGross
								  WHEN isNull(LG.dblQuantity,0) != 0
								  THEN LG.dblQuantity
								  END,
	dblReceivedQuantity     = CASE
								  WHEN SP.strGrossOrNet = 'Gross'
								  THEN TR.dblGross
								  WHEN SP.strGrossOrNet = 'Net'
								  THEN TR.dblNet
								  END
FROM
    
	 dbo.tblTRTransportLoad TL
	JOIN dbo.tblTRTransportReceipt TR
		ON TL.intTransportLoadId = TR.intTransportLoadId 
    JOIN dbo.tblTRSupplyPoint SP
	     ON SP.intSupplyPointId = TR.intSupplyPointId
	LEFT JOIN dbo.vyuCTContractDetailView CT 
	    on TR.intContractDetailId = CT.intContractDetailId
    LEFT JOIN dbo.vyuLGLoadView LG
	    on LG.intLoadId = TL.intLoadId
		
	
	


