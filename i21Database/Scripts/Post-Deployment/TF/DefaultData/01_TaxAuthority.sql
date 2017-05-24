-- Tax Authority
/* Generate script for Tax Authority 
select 'UNION ALL SELECT intTaxAuthorityId = ' + CAST(intTaxAuthorityId AS NVARCHAR(10)) 
	+ ', strTaxAuthorityCode = ''' + ISNULL(strTaxAuthorityCode, 'NULL')
	+ ''', strDescription = '''+ ISNULL(strDescription, 'NULL')
	+''', ysnPaperVersionAvailable = ' + CAST(ysnPaperVersionAvailable AS NVARCHAR(5)) 
	+ ', ysnElectronicVersionAvailable = ' + CAST(ysnElectronicVersionAvailable AS NVARCHAR(5)) 
	+ ', ysnFilingForThisTA = ' + CAST(ysnFilingForThisTA AS NVARCHAR(5))
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId) ELSE intMasterId END) AS NVARCHAR(20))
from tblTFTaxAuthority
*/
SELECT *
INTO #tmpTaxAuthority
FROM (
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxAuthorityId = 1, strTaxAuthorityCode = 'AL', strDescription = 'Alabama', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 1
UNION ALL SELECT intTaxAuthorityId = 2, strTaxAuthorityCode = 'AK', strDescription = 'Alaska', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 2
UNION ALL SELECT intTaxAuthorityId = 3, strTaxAuthorityCode = 'AZ', strDescription = 'Arizona', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 3
UNION ALL SELECT intTaxAuthorityId = 4, strTaxAuthorityCode = 'AR', strDescription = 'Arkansas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 4
UNION ALL SELECT intTaxAuthorityId = 5, strTaxAuthorityCode = 'CA', strDescription = 'California', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 5
UNION ALL SELECT intTaxAuthorityId = 6, strTaxAuthorityCode = 'CO', strDescription = 'Colorado', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 6
UNION ALL SELECT intTaxAuthorityId = 7, strTaxAuthorityCode = 'CT', strDescription = 'Connecticut', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 7
UNION ALL SELECT intTaxAuthorityId = 8, strTaxAuthorityCode = 'DE', strDescription = 'Delaware', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 8
UNION ALL SELECT intTaxAuthorityId = 9, strTaxAuthorityCode = 'FL', strDescription = 'Florida', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 9
UNION ALL SELECT intTaxAuthorityId = 10, strTaxAuthorityCode = 'GA', strDescription = 'Georgia', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 10
UNION ALL SELECT intTaxAuthorityId = 11, strTaxAuthorityCode = 'HI', strDescription = 'Hawaii', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 11
UNION ALL SELECT intTaxAuthorityId = 12, strTaxAuthorityCode = 'ID', strDescription = 'Idaho', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 12
UNION ALL SELECT intTaxAuthorityId = 13, strTaxAuthorityCode = 'IL', strDescription = 'Illinois', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 13
UNION ALL SELECT intTaxAuthorityId = 14, strTaxAuthorityCode = 'IN', strDescription = 'Indiana', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 14
UNION ALL SELECT intTaxAuthorityId = 15, strTaxAuthorityCode = 'IA', strDescription = 'Iowa', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 1, intMasterId = 15
UNION ALL SELECT intTaxAuthorityId = 16, strTaxAuthorityCode = 'KS', strDescription = 'Kansas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 16
UNION ALL SELECT intTaxAuthorityId = 17, strTaxAuthorityCode = 'KY', strDescription = 'Kentucky', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 17
UNION ALL SELECT intTaxAuthorityId = 18, strTaxAuthorityCode = 'LA', strDescription = 'Louisiana', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 18
UNION ALL SELECT intTaxAuthorityId = 19, strTaxAuthorityCode = 'ME', strDescription = 'Maine', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 19
UNION ALL SELECT intTaxAuthorityId = 20, strTaxAuthorityCode = 'MD', strDescription = 'Maryland', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 20
UNION ALL SELECT intTaxAuthorityId = 21, strTaxAuthorityCode = 'MA', strDescription = 'Massachusetts', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 21
UNION ALL SELECT intTaxAuthorityId = 22, strTaxAuthorityCode = 'MI', strDescription = 'Michigan', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 22
UNION ALL SELECT intTaxAuthorityId = 23, strTaxAuthorityCode = 'MN', strDescription = 'Minnesota', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 23
UNION ALL SELECT intTaxAuthorityId = 24, strTaxAuthorityCode = 'MS', strDescription = 'Mississippi', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 24
UNION ALL SELECT intTaxAuthorityId = 25, strTaxAuthorityCode = 'MO', strDescription = 'Missouri', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 25
UNION ALL SELECT intTaxAuthorityId = 26, strTaxAuthorityCode = 'MT', strDescription = 'Montana', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 26
UNION ALL SELECT intTaxAuthorityId = 27, strTaxAuthorityCode = 'NE', strDescription = 'Nebraska', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 27
UNION ALL SELECT intTaxAuthorityId = 28, strTaxAuthorityCode = 'NV', strDescription = 'Nevada', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 28
UNION ALL SELECT intTaxAuthorityId = 29, strTaxAuthorityCode = 'NH', strDescription = 'New Hampshire', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 29
UNION ALL SELECT intTaxAuthorityId = 30, strTaxAuthorityCode = 'NJ', strDescription = 'New Jersey', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 30
UNION ALL SELECT intTaxAuthorityId = 31, strTaxAuthorityCode = 'NM', strDescription = 'New Mexico', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 31
UNION ALL SELECT intTaxAuthorityId = 32, strTaxAuthorityCode = 'NY', strDescription = 'New York', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 32
UNION ALL SELECT intTaxAuthorityId = 33, strTaxAuthorityCode = 'NC', strDescription = 'North Carolina', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 33
UNION ALL SELECT intTaxAuthorityId = 34, strTaxAuthorityCode = 'ND', strDescription = 'North Dakota', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 34
UNION ALL SELECT intTaxAuthorityId = 35, strTaxAuthorityCode = 'OH', strDescription = 'Ohio', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 35
UNION ALL SELECT intTaxAuthorityId = 36, strTaxAuthorityCode = 'OK', strDescription = 'Oklahoma', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 36
UNION ALL SELECT intTaxAuthorityId = 37, strTaxAuthorityCode = 'OR', strDescription = 'Oregon', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 37
UNION ALL SELECT intTaxAuthorityId = 38, strTaxAuthorityCode = 'PA', strDescription = 'Pennsylvania', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 38
UNION ALL SELECT intTaxAuthorityId = 39, strTaxAuthorityCode = 'RI', strDescription = 'Rhode Island', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 39
UNION ALL SELECT intTaxAuthorityId = 40, strTaxAuthorityCode = 'SC', strDescription = 'South Carolina', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 40
UNION ALL SELECT intTaxAuthorityId = 41, strTaxAuthorityCode = 'SD', strDescription = 'South Dakota', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 41
UNION ALL SELECT intTaxAuthorityId = 42, strTaxAuthorityCode = 'TN', strDescription = 'Tennessee', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 1, intMasterId = 42
UNION ALL SELECT intTaxAuthorityId = 43, strTaxAuthorityCode = 'TX', strDescription = 'Texas', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 43
UNION ALL SELECT intTaxAuthorityId = 44, strTaxAuthorityCode = 'UT', strDescription = 'Utah', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 44
UNION ALL SELECT intTaxAuthorityId = 45, strTaxAuthorityCode = 'VT', strDescription = 'Vermont', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 45
UNION ALL SELECT intTaxAuthorityId = 46, strTaxAuthorityCode = 'VA', strDescription = 'Virginia', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 1, ysnFilingForThisTA = 0, intMasterId = 46
UNION ALL SELECT intTaxAuthorityId = 47, strTaxAuthorityCode = 'WA', strDescription = 'Washington', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 47
UNION ALL SELECT intTaxAuthorityId = 48, strTaxAuthorityCode = 'WV', strDescription = 'West Virginia', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 48
UNION ALL SELECT intTaxAuthorityId = 49, strTaxAuthorityCode = 'WI', strDescription = 'Wisconsin', ysnPaperVersionAvailable = 0, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 49
UNION ALL SELECT intTaxAuthorityId = 50, strTaxAuthorityCode = 'WY', strDescription = 'Wyoming', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 50
UNION ALL SELECT intTaxAuthorityId = 51, strTaxAuthorityCode = 'US', strDescription = 'Federal Government', ysnPaperVersionAvailable = 1, ysnElectronicVersionAvailable = 0, ysnFilingForThisTA = 0, intMasterId = 51
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

GO

-- Origin/Destination State
/* Generate script for Origin/Destination States.
select 'UNION ALL SELECT intOriginDestinationStateId = ' + CAST(intOriginDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN strOriginDestinationState IS NULL THEN ', strOriginDestinationState = NULL' ELSE ', strOriginDestinationState = ''' + strOriginDestinationState + ''''  END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN ROW_NUMBER() OVER(ORDER BY intOriginDestinationStateId) ELSE intMasterId END) AS NVARCHAR(20))
from tblTFOriginDestinationState
*/
DECLARE @OriginDestinationStates AS TFOriginDestinationStates

INSERT INTO @OriginDestinationStates (
	intOriginDestinationStateId
    , strOriginDestinationState
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intOriginDestinationStateId = 1, strOriginDestinationState = 'AL', intMasterId = 1
UNION ALL SELECT intOriginDestinationStateId = 2, strOriginDestinationState = 'AK', intMasterId = 2
UNION ALL SELECT intOriginDestinationStateId = 3, strOriginDestinationState = 'AZ', intMasterId = 3
UNION ALL SELECT intOriginDestinationStateId = 4, strOriginDestinationState = 'AR', intMasterId = 4
UNION ALL SELECT intOriginDestinationStateId = 5, strOriginDestinationState = 'CA', intMasterId = 5
UNION ALL SELECT intOriginDestinationStateId = 6, strOriginDestinationState = 'CO', intMasterId = 6
UNION ALL SELECT intOriginDestinationStateId = 7, strOriginDestinationState = 'CT', intMasterId = 7
UNION ALL SELECT intOriginDestinationStateId = 8, strOriginDestinationState = 'DE', intMasterId = 8
UNION ALL SELECT intOriginDestinationStateId = 9, strOriginDestinationState = 'FL', intMasterId = 9
UNION ALL SELECT intOriginDestinationStateId = 10, strOriginDestinationState = 'GA', intMasterId = 10
UNION ALL SELECT intOriginDestinationStateId = 11, strOriginDestinationState = 'HI', intMasterId = 11
UNION ALL SELECT intOriginDestinationStateId = 12, strOriginDestinationState = 'ID', intMasterId = 12
UNION ALL SELECT intOriginDestinationStateId = 13, strOriginDestinationState = 'IL', intMasterId = 13
UNION ALL SELECT intOriginDestinationStateId = 14, strOriginDestinationState = 'IN', intMasterId = 14
UNION ALL SELECT intOriginDestinationStateId = 15, strOriginDestinationState = 'IA', intMasterId = 15
UNION ALL SELECT intOriginDestinationStateId = 16, strOriginDestinationState = 'KS', intMasterId = 16
UNION ALL SELECT intOriginDestinationStateId = 17, strOriginDestinationState = 'KY', intMasterId = 17
UNION ALL SELECT intOriginDestinationStateId = 18, strOriginDestinationState = 'LA', intMasterId = 18
UNION ALL SELECT intOriginDestinationStateId = 19, strOriginDestinationState = 'ME', intMasterId = 19
UNION ALL SELECT intOriginDestinationStateId = 20, strOriginDestinationState = 'MD', intMasterId = 20
UNION ALL SELECT intOriginDestinationStateId = 21, strOriginDestinationState = 'MA', intMasterId = 21
UNION ALL SELECT intOriginDestinationStateId = 22, strOriginDestinationState = 'MI', intMasterId = 22
UNION ALL SELECT intOriginDestinationStateId = 23, strOriginDestinationState = 'MN', intMasterId = 23
UNION ALL SELECT intOriginDestinationStateId = 24, strOriginDestinationState = 'MS', intMasterId = 24
UNION ALL SELECT intOriginDestinationStateId = 25, strOriginDestinationState = 'MO', intMasterId = 25
UNION ALL SELECT intOriginDestinationStateId = 26, strOriginDestinationState = 'MT', intMasterId = 26
UNION ALL SELECT intOriginDestinationStateId = 27, strOriginDestinationState = 'NE', intMasterId = 27
UNION ALL SELECT intOriginDestinationStateId = 28, strOriginDestinationState = 'NV', intMasterId = 28
UNION ALL SELECT intOriginDestinationStateId = 29, strOriginDestinationState = 'NH', intMasterId = 29
UNION ALL SELECT intOriginDestinationStateId = 30, strOriginDestinationState = 'NJ', intMasterId = 30
UNION ALL SELECT intOriginDestinationStateId = 31, strOriginDestinationState = 'NM', intMasterId = 31
UNION ALL SELECT intOriginDestinationStateId = 32, strOriginDestinationState = 'NY', intMasterId = 32
UNION ALL SELECT intOriginDestinationStateId = 33, strOriginDestinationState = 'NC', intMasterId = 33
UNION ALL SELECT intOriginDestinationStateId = 34, strOriginDestinationState = 'ND', intMasterId = 34
UNION ALL SELECT intOriginDestinationStateId = 35, strOriginDestinationState = 'OH', intMasterId = 35
UNION ALL SELECT intOriginDestinationStateId = 36, strOriginDestinationState = 'OK', intMasterId = 36
UNION ALL SELECT intOriginDestinationStateId = 37, strOriginDestinationState = 'OR', intMasterId = 37
UNION ALL SELECT intOriginDestinationStateId = 38, strOriginDestinationState = 'PA', intMasterId = 38
UNION ALL SELECT intOriginDestinationStateId = 39, strOriginDestinationState = 'RI', intMasterId = 39
UNION ALL SELECT intOriginDestinationStateId = 40, strOriginDestinationState = 'SC', intMasterId = 40
UNION ALL SELECT intOriginDestinationStateId = 41, strOriginDestinationState = 'SD', intMasterId = 41
UNION ALL SELECT intOriginDestinationStateId = 42, strOriginDestinationState = 'TN', intMasterId = 42
UNION ALL SELECT intOriginDestinationStateId = 43, strOriginDestinationState = 'TX', intMasterId = 43
UNION ALL SELECT intOriginDestinationStateId = 44, strOriginDestinationState = 'UT', intMasterId = 44
UNION ALL SELECT intOriginDestinationStateId = 45, strOriginDestinationState = 'VT', intMasterId = 45
UNION ALL SELECT intOriginDestinationStateId = 46, strOriginDestinationState = 'VA', intMasterId = 46
UNION ALL SELECT intOriginDestinationStateId = 47, strOriginDestinationState = 'WA', intMasterId = 47
UNION ALL SELECT intOriginDestinationStateId = 48, strOriginDestinationState = 'WV', intMasterId = 48
UNION ALL SELECT intOriginDestinationStateId = 49, strOriginDestinationState = 'WI', intMasterId = 49
UNION ALL SELECT intOriginDestinationStateId = 50, strOriginDestinationState = 'WY', intMasterId = 50

EXEC uspTFUpgradeOriginDestinationState @OriginDestinationStates = @OriginDestinationStates