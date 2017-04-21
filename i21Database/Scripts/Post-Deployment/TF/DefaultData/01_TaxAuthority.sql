-- Tax Authority
/* Generate script for Tax Authority 
select 'UNION ALL SELECT intTaxAuthorityId = ' + CAST(intTaxAuthorityId AS NVARCHAR(10)) 
	+ ', strTaxAuthorityCode = ''' + ISNULL(strTaxAuthorityCode, 'NULL')
	+ ''', strDescription = '''+ ISNULL(strDescription, 'NULL')
	+''', ysnPaperVersionAvailable = ' + CAST(ysnPaperVersionAvailable AS NVARCHAR(5)) 
	+ ', ysnElectronicVersionAvailable = ' + CAST(ysnElectronicVersionAvailable AS NVARCHAR(5)) 
	+ ', ysnFilingForThisTA = ' + CAST(ysnFilingForThisTA AS NVARCHAR(5))
from tblTFTaxAuthority
*/
SELECT *
INTO #tmpTaxAuthority
FROM (
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxAuthorityId = 1, strTaxAuthorityCode = 'AL', strDescription = 'Alabama', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 2, strTaxAuthorityCode = 'AK', strDescription = 'Alaska', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 3, strTaxAuthorityCode = 'AZ', strDescription = 'Arizona', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 4, strTaxAuthorityCode = 'AR', strDescription = 'Arkansas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 5, strTaxAuthorityCode = 'CA', strDescription = 'California', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 6, strTaxAuthorityCode = 'CO', strDescription = 'Colorado', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 7, strTaxAuthorityCode = 'CT', strDescription = 'Connecticut', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 8, strTaxAuthorityCode = 'DE', strDescription = 'Delaware', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 9, strTaxAuthorityCode = 'FL', strDescription = 'Florida', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 10, strTaxAuthorityCode = 'GA', strDescription = 'Georgia', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 11, strTaxAuthorityCode = 'HI', strDescription = 'Hawaii', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 12, strTaxAuthorityCode = 'ID', strDescription = 'Idaho', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 13, strTaxAuthorityCode = 'IL', strDescription = 'Illinois', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 14, strTaxAuthorityCode = 'IN', strDescription = 'Indiana', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 15, strTaxAuthorityCode = 'IA', strDescription = 'Iowa', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 16, strTaxAuthorityCode = 'KS', strDescription = 'Kansas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 17, strTaxAuthorityCode = 'KY', strDescription = 'Kentucky', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 18, strTaxAuthorityCode = 'LA', strDescription = 'Louisiana', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 19, strTaxAuthorityCode = 'ME', strDescription = 'Maine', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 20, strTaxAuthorityCode = 'MD', strDescription = 'Maryland', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 21, strTaxAuthorityCode = 'MA', strDescription = 'Massachusetts', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 22, strTaxAuthorityCode = 'MI', strDescription = 'Michigan', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 23, strTaxAuthorityCode = 'MN', strDescription = 'Minnesota', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 24, strTaxAuthorityCode = 'MS', strDescription = 'Mississippi', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 25, strTaxAuthorityCode = 'MO', strDescription = 'Missouri', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 26, strTaxAuthorityCode = 'MT', strDescription = 'Montana', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 27, strTaxAuthorityCode = 'NE', strDescription = 'Nebraska', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 28, strTaxAuthorityCode = 'NV', strDescription = 'Nevada', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 29, strTaxAuthorityCode = 'NH', strDescription = 'New Hampshire', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 30, strTaxAuthorityCode = 'NJ', strDescription = 'New Jersey', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 31, strTaxAuthorityCode = 'NM', strDescription = 'New Mexico', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 32, strTaxAuthorityCode = 'NY', strDescription = 'New York', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 33, strTaxAuthorityCode = 'NC', strDescription = 'North Carolina', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 34, strTaxAuthorityCode = 'ND', strDescription = 'North Dakota', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 35, strTaxAuthorityCode = 'OH', strDescription = 'Ohio', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 36, strTaxAuthorityCode = 'OK', strDescription = 'Oklahoma', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 37, strTaxAuthorityCode = 'OR', strDescription = 'Oregon', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 38, strTaxAuthorityCode = 'PA', strDescription = 'Pennsylvania', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 39, strTaxAuthorityCode = 'RI', strDescription = 'Rhode Island', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 40, strTaxAuthorityCode = 'SC', strDescription = 'South Carolina', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 41, strTaxAuthorityCode = 'SD', strDescription = 'South Dakota', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 42, strTaxAuthorityCode = 'TN', strDescription = 'Tennessee', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1
UNION ALL SELECT intTaxAuthorityId = 43, strTaxAuthorityCode = 'TX', strDescription = 'Texas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 44, strTaxAuthorityCode = 'UT', strDescription = 'Utah', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 45, strTaxAuthorityCode = 'VT', strDescription = 'Vermont', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 46, strTaxAuthorityCode = 'VA', strDescription = 'Virginia', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 47, strTaxAuthorityCode = 'WA', strDescription = 'Washington', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 48, strTaxAuthorityCode = 'WV', strDescription = 'West Virginia', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 49, strTaxAuthorityCode = 'WI', strDescription = 'Wisconsin', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 50, strTaxAuthorityCode = 'WY', strDescription = 'Wyoming', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
UNION ALL SELECT intTaxAuthorityId = 51, strTaxAuthorityCode = 'US', strDescription = 'Federal Government', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0
) tblPatch

SET IDENTITY_INSERT tblTFTaxAuthority ON

MERGE	
INTO	tblTFTaxAuthority 
WITH	(HOLDLOCK) 
AS		TARGET
USING (
	SELECT * FROM #tmpTaxAuthority
) AS SOURCE
	ON TARGET.strTaxAuthorityCode COLLATE Latin1_General_CI_AS = SOURCE.strTaxAuthorityCode COLLATE Latin1_General_CI_AS

WHEN MATCHED THEN 
	UPDATE
	SET 
		strDescription					= SOURCE.strDescription
		, ysnPaperVersionAvailable		= SOURCE.ysnPaperVersionAvailable
		, ysnElectronicVersionAvailable	= SOURCE.ysnElectronicVersionAvailable
WHEN NOT MATCHED THEN 
	INSERT (
		intTaxAuthorityId
		, strTaxAuthorityCode
		, strDescription
		, ysnPaperVersionAvailable
		, ysnElectronicVersionAvailable
		, ysnFilingForThisTA
	)
	VALUES (
		SOURCE.intTaxAuthorityId
		, SOURCE.strTaxAuthorityCode
		, SOURCE.strDescription
		, SOURCE.ysnPaperVersionAvailable
		, SOURCE.ysnElectronicVersionAvailable
		, SOURCE.ysnFilingForThisTA
	);

DROP TABLE #tmpTaxAuthority

SET IDENTITY_INSERT tblTFTaxAuthority OFF