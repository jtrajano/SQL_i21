CREATE VIEW [dbo].[vyuLGLoadShippingLineRank]
AS
SELECT 
	SLR.*
	,strShippingLine = SL.strName
	,strServiceContractNumber = SLSCD.strServiceContractNumber
	,strRank = CASE SLR.intRank 
		WHEN 1 THEN 'First' 
		WHEN 2 THEN 'Second' 
		WHEN 3 THEN 'Third' 
		ELSE '' END COLLATE Latin1_General_CI_AS
FROM
	tblLGLoadShippingLineRank SLR
	LEFT JOIN tblEMEntity SL ON SL.intEntityId = SLR.intShippingLineEntityId
	LEFT JOIN tblLGShippingLineServiceContractDetail SLSCD ON SLSCD.intShippingLineServiceContractDetailId = SLR.intShippingLineServiceContractDetailId

GO