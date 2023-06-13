CREATE VIEW [dbo].[vyuTMConsumptionSiteFee]  
AS  
  
SELECT   
intConsumptionSiteFeeId,
dtmDateTime,
strType,
strDescription,
dblFee,
intSiteId
from [dbo].[tblTMConsumptionSiteFee] 