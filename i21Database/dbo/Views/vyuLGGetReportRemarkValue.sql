CREATE VIEW [dbo].[vyuLGGetReportRemarkValue]

AS

SELECT intRowId = ROW_NUMBER() OVER (ORDER BY strType, intValueId) 
	, *
FROM (

	SELECT intValueId = intItemId
		, strValue = strItemNo
		, strType = 'Item'
	FROM tblICItem I

	UNION ALL 
	
	SELECT intValueId = EL.intEntityId
		, strValue = EL.strName
		, strType = 'Entity'
	FROM tblEMEntity EL
	JOIN tblEMEntityType ET ON ET.intEntityId = EL.intEntityId AND ET.strType IN ('Vendor', 'Customer')

	UNION ALL

	SELECT
		intValueId = BF.intBorrowingFacilityId,
		strValue = BF.strBorrowingFacilityId + ' / ' + B.strBankName + ' / ' + BF.strBankReferenceNo,
		strType = 'Borrowing Facility'
	FROM tblCMBorrowingFacility BF
	JOIN tblCMBank B ON B.intBankId = BF.intBankId
) tbl