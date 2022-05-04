CREATE VIEW [dbo].[vyuSTStoreRegister]
AS
SELECT 
 st.intStoreId
 , st.intStoreNo
 , st.strDescription
 , st.strState
 , st.intRegisterId
 , st.intLastShiftNo
 , st.dtmLastShiftOpenDate
 , intNumberOfShifts = ISNULL(st.intNumberOfShifts, 0)
  -- Will be used to load Beg Balance in checkout
 , dblEndingBalanceATMFund  = ISNULL(
   (SELECT TOP 1 dblATMEndBalanceActual 
   FROM tblSTCheckoutHeader 
   where dtmCheckoutDate = (SELECT MAX(dtmCheckoutDate) FROM tblSTCheckoutHeader where intStoreId = st.intStoreId) 
   and intStoreId = st.intStoreId order by intShiftNo desc)  , 0)
         
  -- Will be used to load Beg Balance in checkout
  , dblEndingBalanceChangeFund = ISNULL(
   (SELECT TOP 1 dblChangeFundEndBalance 
   FROM tblSTCheckoutHeader 
   where dtmCheckoutDate = (SELECT MAX(dtmCheckoutDate) FROM tblSTCheckoutHeader where intStoreId = st.intStoreId) 
   and intStoreId = st.intStoreId order by intShiftNo desc) , 0)
 , st.strRegisterCheckoutDataEntry
 , rt.strRegisterName
 , rt.strRegisterClass
 , rt.strSapphireIpAddress
 , rt.strSAPPHIREUserName
 , strSAPPHIREPassword = dbo.fnAESDecrypt(rt.strSAPPHIREPassword)
 , hs.intHandheldScannerId
 , ISNULL(rt.intSAPPHIRECheckoutPullTimePeriodId, 0) AS intSAPPHIRECheckoutPullTimePeriodId
 , CASE
  WHEN rt.intSAPPHIRECheckoutPullTimePeriodId = 1
   THEN 'Shift Close'
  WHEN rt.intSAPPHIRECheckoutPullTimePeriodId = 2
   THEN 'Day Close'
  ELSE ''
  END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimePeriod
  , ISNULL(rt.intSAPPHIRECheckoutPullTimeSetId, 0) AS intSAPPHIRECheckoutPullTimeSetId
  , CASE
  WHEN rt.intSAPPHIRECheckoutPullTimeSetId = 1
   THEN 'Current Data'
  WHEN rt.intSAPPHIRECheckoutPullTimeSetId = 2
   THEN 'Last Close Data'
  WHEN rt.intSAPPHIRECheckoutPullTimeSetId = 3
   THEN 'Last Close Data - 1'
  WHEN rt.intSAPPHIRECheckoutPullTimeSetId = 4
   THEN 'Last Close Data - 2 and on through 9'
   ELSE ''
  END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimeSet
  -- Will be used to load Beg Balance in checkout
   , st.ysnLotterySetupMode
   , st.intCompanyLocationId
FROM tblSTStore st
LEFT JOIN tblSTRegister rt
 ON st.intStoreId = rt.intStoreId AND st.intRegisterId = rt.intRegisterId
LEFT JOIN tblSTHandheldScanner hs
 ON st.intStoreId = hs.intStoreId
 WHERE st.ysnActive = 1