CREATE VIEW vyuLGLoadPickLotDetails
AS
SELECT PLH.intPickLotHeaderId,
	   PLD.intPickLotDetailId,
	   PLH.strPickLotNumber,
	   LD.intLoadDetailId,
	   L.intLoadId,
	   L.strLoadNumber,
	   ysnDelivered = CONVERT(BIT,(CASE WHEN ISNULL(L.strLoadNumber,'') = '' THEN 0 ELSE 1 END))
FROM tblLGPickLotHeader PLH
JOIN tblLGPickLotDetail PLD ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
LEFT JOIN tblLGLoadDetail LD ON LD.intPickLotDetailId = PLD.intPickLotDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId