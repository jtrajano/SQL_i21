CREATE VIEW [dbo].[vyuTMConsumptionSiteFee]  
AS  
  
SELECT   
intConsumptionSiteFeeId,
dtmDateTime,
strType,
strDecription,
dblFee,
intSiteId
from [dbo].[tblTMConsumptionSiteFee] 