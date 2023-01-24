CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentConditionsReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	SELECT 
		strCondition = CTC.strConditionName + ': ' + CTC.strConditionDesc
	FROM tblLGLoad L
	LEFT JOIN tblLGLoadCondition LGC ON LGC.intLoadId = L.intLoadId
	LEFT JOIN tblCTCondition CTC ON CTC.intConditionId = LGC.intConditionId
	WHERE L.strLoadNumber = @xmlParam AND CTC.strType = 'Instore Letter'
END