CREATE VIEW vyuQMPurchaseLabelReport  
AS  
SELECT   
A.intSampleId,
B.intBatchId,  
B.strBatchId,  
REPLACE(CONVERT(VARCHAR, dtmSaleDate,101),'/','.') AS dtmSaleDate,  
strChopNumber strTeaGardenChopInvoiceNumber,  
A.strBroker,  
CASE WHEN A.strMarketZoneCode= 'AUC' THEN B.strLeafGrade ELSE CT.strLeafGrade END strLeafGrade,  
CASE WHEN intSampleTypeId =2 THEN A.dblB1QtyBought ELSE A.dblRepresentingQty END  dblPackagesBought,  
A.strGardenMark,  
CASE WHEN A.intContractDetailId IS NULL THEN B.strTeaType ELSE CT.strTeaType END strTeaType,  
CASE WHEN A.intContractDetailId IS NULL THEN B.dblWeightPerUnit ELSE CT.dblWeightPerUnit END dblWeightPerUnit,
A.dblSampleQty AS dblTotalWeight,
A.strRepresentLotNumber,
A.strSaleNumber,
A.dblB1Price, 
CASE WHEN A.intContractDetailId IS NULL  THEN B.strMixingUnitLocation ELSE CT.strMixingUnitLocation END strMixingUnitLocation,
CASE WHEN A.intContractDetailId IS NULL  THEN REPLACE(B.strLeafStyle +  ' ' + B.strLeafSize  + ' ' + Taste.Val, '  ', ' ') ELSE replace(CT.strLeafStyle +  ' ' + CT.strLeafSize  + ' ' + Taste.Val, '  ', ' ') END
strTestResult,
IC.strItemNo
FROM vyuQMSampleList A JOIN vyuMFBatch B ON A.intSampleId = B.intSampleId AND A.intLocationId =B.intLocationId 
LEFT JOIN tblICItem IC on IC.intItemId = A.intItemId
OUTER APPLY(
	SELECT TOP 1 strPropertyValue Val FROM tblQMTestResult T JOIN
	tblQMProperty P ON P.intPropertyId = T.intPropertyId
	WHERE T.intSampleId = A.intSampleId
	AND P.strPropertyName = 'Taste'
)Taste
OUTER APPLY(
	SELECT TOP 1 	
	strTeaType, dblWeightPerUnit,dblTotalQuantity,strMixingUnitLocation,strLeafStyle, strLeafSize, strLeafGrade, strTeaGardenChopInvoiceNumber
	FROM tblCTContractDetail C  WHERE intContractDetailId = A.intContractDetailId
) CT
