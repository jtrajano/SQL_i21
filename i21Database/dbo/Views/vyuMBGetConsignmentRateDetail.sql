CREATE VIEW [dbo].[vyuMBGetConsignmentRateDetail]
	AS 
	
SELECT ConRateDetail.intConsignmentRateDetailId
	, ConRateDetail.intConsignmentRateId
	, ConRate.intConsignmentGroupId
	, ConGroup.strConsignmentGroup
	, ConRate.dtmEffectiveDate
	, ConRateDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, ConRateDetail.dblBasePumpPrice
	, ConRateDetail.dblBaseRate
	, ConRateDetail.dblIntervalPumpPrice
	, ConRateDetail.dblIntervalRate
	, ConRateDetail.dblConsignmentFloor
	, ConRateDetail.strRateType
	, ConRateDetail.intSort
FROM tblMBConsignmentRateDetail ConRateDetail
LEFT JOIN tblMBConsignmentRate ConRate ON ConRate.intConsignmentRateId = ConRateDetail.intConsignmentRateId
LEFT JOIN tblMBConsignmentGroup ConGroup ON ConGroup.intConsignmentGroupId = ConRate.intConsignmentGroupId
LEFT JOIN tblICItem Item ON Item.intItemId = ConRateDetail.intItemId