CREATE VIEW [dbo].[vyuTRTransportReceipt_New]
AS 

SELECT	TL.intTransportLoadId
		,TR.intTransportReceiptId
		,TR.intContractDetailId
		,TL.strTransaction
		,dblOrderedQuantity = 
			CASE	WHEN ISNULL(LG.dblQuantity,0) = 0 and SP.strGrossOrNet = 'Net'	THEN 
						TR.dblNet
					WHEN ISNULL(LG.dblQuantity,0) = 0 and SP.strGrossOrNet = 'Gross' THEN 
						TR.dblGross
					WHEN ISNULL(LG.dblQuantity,0) != 0 THEN 
						LG.dblQuantity
			END
		,dblReceivedQuantity = 
			CASE	WHEN SP.strGrossOrNet = 'Gross' THEN 
						TR.dblGross
					WHEN SP.strGrossOrNet = 'Net' THEN 
						TR.dblNet
			END
FROM	dbo.tblTRTransportLoad TL INNER JOIN dbo.tblTRTransportReceipt TR
			ON TL.intTransportLoadId = TR.intTransportLoadId 
		INNER JOIN dbo.tblTRSupplyPoint SP
			ON SP.intSupplyPointId = TR.intSupplyPointId
		LEFT JOIN dbo.tblLGLoad LG
			ON LG.intLoadId = TL.intLoadId
