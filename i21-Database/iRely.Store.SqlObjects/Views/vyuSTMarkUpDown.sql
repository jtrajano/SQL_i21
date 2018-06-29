CREATE VIEW [dbo].[vyuSTMarkUpDown]
AS

select A.intMarkUpDownId
, B.intStoreNo
, A.dtmMarkUpDownDate
, A.intShiftNo
, A.strType
, A.strAdjustmentType
, B.intCompanyLocationId
, A.ysnIsPosted

from tblSTMarkUpDown A inner join tblSTStore B
on A.intStoreId = B.intStoreId