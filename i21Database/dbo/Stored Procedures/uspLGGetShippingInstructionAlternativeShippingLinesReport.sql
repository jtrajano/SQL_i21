CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionAlternativeShippingLinesReport]
	@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
SELECT 
	SLR.strShippingLine,
	SLR.strServiceContractNumber,
	SLR.strRank
FROM vyuLGLoadShippingLineRank SLR
JOIN tblLGLoad L ON L.intLoadId = SLR.intLoadId
WHERE @xmlParam = L.intLoadId AND SLR.strRank != 'First'
END
