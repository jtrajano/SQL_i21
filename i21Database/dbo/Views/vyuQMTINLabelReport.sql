CREATE VIEW vyuQMTINLabelReport
AS
SELECT intBatchId					= B.intBatchId
	, strBatchId					= B.strBatchId
	, intGardenMarkId				= B.intGardenMarkId
	, strGardenMark					= GM.strGardenMark
	, strTeaGardenChopInvoiceNumber	= B.strTeaGardenChopInvoiceNumber
	, intMixingUnitLocationId		= B.intMixingUnitLocationId
	, strMixingUnit					= CL.strLocationName
	, intTealingoItemId				= B.intTealingoItemId
	, strTealingoItem				= I.strItemNo
	, dtmExpiryDate					= Item.dtmExpiration
	, strERPPONumber				= SUBSTRING(ISNULL(B.strERPPONumber, ''), LEN(ISNULL(B.strERPPONumber, '')) - 4, LEN(ISNULL(B.strERPPONumber, '')))
	, strContainerNumber			= B.strContainerNumber
	, strBOLNo						= B.strBOLNo
FROM tblMFBatch B
LEFT JOIN tblQMGardenMark GM ON B.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblSMCompanyLocation CL ON B.intMixingUnitLocationId = CL.intCompanyLocationId
LEFT JOIN tblICItem I ON B.intTealingoItemId = I.intItemId
OUTER APPLY(
    SELECT TOP 1 strItemNo,strDescription, strShortName,
    CASE WHEN ISNULL(intLifeTime,0) > 0 AND B.dtmProductionBatch IS NOT NULL
    THEN
    CASE 
        WHEN  strLifeTimeType = 'Years' THEN DATEADD( YEAR, intLifeTime, B.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Months' THEN DATEADD( MONTH, intLifeTime, B.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Days' THEN DATEADD( DAY, intLifeTime, B.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Hours' THEN DATEADD( HOUR, intLifeTime, B.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Minutes' THEN DATEADD( MINUTE, intLifeTime, B.dtmProductionBatch)
        ELSE NULL END
    ELSE 
    NULL 
    END dtmExpiration
    FROM tblICItem WHERE intItemId = B.intTealingoItemId
)Item
WHERE B.strContainerNumber IS NOT NULL
 AND B.strContainerNumber <> ''