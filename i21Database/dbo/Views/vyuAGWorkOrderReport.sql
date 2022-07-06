CREATE VIEW [dbo].[vyuAGWorkOrderReport]
AS
SELECT 
  (
    'AGRONOMY WORK ORDER ' + strOrderNumber
  ) as strHeader, 
  CONVERT (
    VARCHAR, 
    GETDATE (), 
    7
  ) as strReportDate, 
  CONVERT (VARCHAR, WO.dtmApplyDate, 7) AS dtmApplyDate, 
  TARGET.strTargetName, 
  WO.strOrderNumber, 
  FARM.strLocationName AS strFarm, 
  FARM.strFarmFieldDescription AS strFarmDescription, 
  APPLICATOR.strName AS strApplicatorName, 
  CUSTOMER.strName AS strCustomerName, 
  CUSTOMER.strBillToAddress, 
  WO.intWorkOrderId,
  WO.dblAcres,
  WO.dblAppliedAcres,
  WO.dblApplicationRate,
  WO.dtmStartDate,
  WO.dtmEndDate,
  WO.dtmStartTime,
  WO.dtmEndTime,
  WO.strSeason,
  WO.strWindDirection,
  CONVERT(NVARCHAR(255),ISNULL(CAST(WO.dblWindSpeed AS INT),0)) + (' ') + ISNULL(WO.strWindSpeedUOM,'') AS strWindSpeed,
  CONVERT(NVARCHAR(255),ISNULL(CAST(WO.dblTemperature AS INT),0)) + (' ') + ISNULL(WO.strTemperatureUOM,'') AS strTemperature,


  --details
  WOD.intWorkOrderDetailId,
  WOD.strEPARegNo,
  ITEM.strItemNo,
  ITEM.strItemDescription,
  WOD.dblQtyOrdered AS dblQuantity,
  WOD.dblRate,
  WOD.dblRate AS dblTotalRate


FROM 
  tblAGWorkOrder WO 
  INNER JOIN tblAGWorkOrderDetail WOD ON WOD.intWorkOrderId = WO.intWorkOrderId
  CROSS APPLY
  (
	SELECT strItemNo,
		   strItemDescription 
		  FROM tblICItem WHERE intItemId = WOD.intItemId
  ) ITEM
  LEFT JOIN tblAGApplicationTarget TARGET ON TARGET.intApplicationTargetId = WO.intApplicationTargetId 
  LEFT JOIN vyuEMEntityLocationSearch FARM ON FARM.intEntityLocationId = WO.intFarmFieldId 
  LEFT JOIN tblEMEntity APPLICATOR ON APPLICATOR.intEntityId = WO.intEntityApplicatorId 
  LEFT JOIN vyuEMEntityCustomerSearch CUSTOMER ON CUSTOMER.intEntityId = WO.intEntityCustomerId
