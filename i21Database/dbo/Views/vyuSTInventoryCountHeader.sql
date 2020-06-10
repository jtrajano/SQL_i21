CREATE VIEW vyuSTInventoryCountHeader
AS
SELECT 
	   InvCount.intInventoryCountId
	   , InvCount.strCountNo COLLATE Latin1_General_CI_AS AS strCountNo
	   , CONVERT(NVARCHAR(10), InvCount.dtmCountDate, 111) COLLATE Latin1_General_CI_AS AS strCountDate
	   , InvCount.intLocationId
	   , InvCount.ysnPosted
	   , CASE 
			WHEN InvCount.intStatus = 1
				THEN 'Open'
			WHEN InvCount.intStatus = 2
				THEN 'Count Sheet Printed'
			WHEN InvCount.intStatus = 3
				THEN 'Inventory Locked'
			WHEN InvCount.intStatus = 4
				THEN 'Closed' 
		END COLLATE Latin1_General_CI_AS AS strCountStatus
		, CL.strLocationName
		, Store.intStoreId
		, Store.intStoreNo
FROM tblICInventoryCount InvCount
INNER JOIN tblSMCompanyLocation CL
	ON InvCount.intLocationId = CL.intCompanyLocationId
INNER JOIN tblSTStore Store
	ON InvCount.intLocationId = Store.intCompanyLocationId