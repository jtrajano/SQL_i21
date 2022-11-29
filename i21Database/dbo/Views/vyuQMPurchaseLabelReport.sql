CREATE VIEW vyuQMPurchaseLabelReport  
AS  
SELECT   
A.intSampleId,
intBatchId,  
strBatchId,  
dtmSaleDate,  
B.strBroker,  
strTeaGardenChopInvoiceNumber,  
strLeafGrade,  
dblPackagesBought,  
strGardenMark,  
strTeaType,  
dblWeightPerUnit,  
dblWeightPerUnit* dblTotalQuantity dblTotalWeight,
strRepresentLotNumber,
strSaleNumber,
dblB1Price,
strMixingUnitLocation,
replace(strLeafStyle +  ' ' + strLeafSize  + ' ' + Taste.Val, '  ', ' ') strTestResult,
IC.strItemNo
FROM vyuQMSampleList A JOIN vyuMFBatch B ON A.intSampleId = B.intSampleId
LEFT JOIN tblICItem IC on IC.intItemId = A.intItemId
OUTER APPLY(
	SELECT TOP 1 strPropertyValue Val FROM tblQMTestResult T JOIN
	tblQMProperty P ON P.intPropertyId = T.intPropertyId
	WHERE T.intSampleId = A.intSampleId
	AND P.strPropertyName = 'Taste'
)Taste