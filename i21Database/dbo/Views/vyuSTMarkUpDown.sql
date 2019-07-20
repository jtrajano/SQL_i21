CREATE VIEW [dbo].[vyuSTMarkUpDown]
AS
SELECT 
	mud.intMarkUpDownId
	, mud.strMarkUpDownNumber
	, store.intStoreNo
	, mud.dtmMarkUpDownDate
	, mud.intShiftNo
	, mud.strType
	, mud.strAdjustmentType
	, store.intCompanyLocationId
	, mud.ysnIsPosted
FROM tblSTMarkUpDown mud 
INNER JOIN tblSTStore store
	ON mud.intStoreId = store.intStoreId