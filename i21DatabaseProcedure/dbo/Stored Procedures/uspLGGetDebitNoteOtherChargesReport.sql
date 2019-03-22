CREATE PROCEDURE uspLGGetDebitNoteOtherChargesReport
	@intWeightClaimId INT = NULL
AS
DECLARE @xmlDocumentId INT
DECLARE @strUserName NVARCHAR(100)
DECLARE @intLoadId INT

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

SELECT DISTINCT WC.intWeightClaimId
	,WC.strReferenceNumber AS strWeightClaimNumber
	,L.strLoadNumber
	,L.intLoadId
	,WCD.dblQuantity
	,WCD.dblWeight
	,WCD.dblRate
	,ROUND(WCD.dblAmount, 2) AS dblClaimAmount
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,WCD.dblQuantity
	,L.strMVessel
FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimOtherCharges WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
JOIN tblLGLoad L ON WC.intLoadId = L.intLoadId
LEFT JOIN tblICItem I ON I.intItemId = WCD.intItemId
WHERE WC.intWeightClaimId = @intWeightClaimId