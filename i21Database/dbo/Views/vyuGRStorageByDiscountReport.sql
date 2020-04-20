CREATE VIEW [dbo].[vyuGRStorageByDiscountReport]
AS

WITH cte as (
	SELECT 
		DS.intCommodityId
		,CO.strCommodityCode
		,CS.intCompanyLocationId
		,CL.ysnLicensed
		,CL.strLocationName
		,dblSubTotal = CS.dblOriginalBalance
		,YEAR(CS.dtmDeliveryDate) dtmDeliveryYear
		,IM.strDescription
		,QM.dblGradeReading
	FROM tblQMTicketDiscount QM
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = QM.intTicketFileId
	INNER JOIN tblICItem IM
		ON DSC.intItemId = IM.intItemId
	INNER JOIN tblGRDiscountSchedule DS
		ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
	INNER JOIN tblICCommodity CO
		ON CO.intCommodityId = DS.intCommodityId
	inner JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId		
	
	WHERE	QM.strSourceType = 'Storage'
) ,
cte1 as (
	SELECT	A.intCompanyLocationId, RR.strReadingRange ,strCommodityCode,ysnLicensed,strLocationName,dblSubTotal,dtmDeliveryYear,'TEST WEIGHT' COLLATE Latin1_General_CI_AS as strDiscountCode 
		FROM cte A	
		LEFT JOIN tblGRReadingRanges RR
		ON A.dblGradeReading BETWEEN RR.intMinValue AND RR.intMaxValue
			AND RR.intReadingType = 1
		WHERE A.strDescription = 'TEST WEIGHT' 
	UNION
	SELECT A.intCompanyLocationId, RR.strReadingRange,strCommodityCode,ysnLicensed,strLocationName,dblSubTotal,dtmDeliveryYear,'DOCKAGE' COLLATE Latin1_General_CI_AS as strDiscountCode 
		FROM cte A
		LEFT JOIN tblGRReadingRanges RR
		ON (A.dblGradeReading BETWEEN RR.intMinValue AND RR.intMaxValue)
			AND RR.intReadingType = 2
		
		WHERE  A.strDescription LIKE '%DOCKAGE%' 
)
SELECT 
	TW.intCompanyLocationId intCompanyLocationId,
	TW.strReadingRange strReadingRange
	,TW.strCommodityCode strCommodityCode
	,TW.ysnLicensed
	,replace(replace(TW.strLocationName,'[',''),']','') strLocationName
	,TW.dtmDeliveryYear dtmDeliveryYear
	,strCommodityCode + cast(dtmDeliveryYear as nvarchar(4)) CommodityYear
	,SUM(ISNULL(TW.dblSubTotal,0)) dblSubTotalByLocation
	,TW.strDiscountCode strDiscountCode
	from cte1 TW
GROUP BY TW.intCompanyLocationId
		,TW.strReadingRange
		,TW.strCommodityCode
		,TW.strLocationName
		,TW.ysnLicensed
		,TW.dtmDeliveryYear
		,TW.strDiscountCode
GO
