CREATE VIEW vyuQMTINLabelReport
AS
SELECT intBatchId					= B.intBatchId
	, strBatchId					= B.strBatchId
	, intGardenMarkId				= B.intGardenMarkId
	, strGardenMark					= GM.strGardenMark
	, strTeaGardenChopInvoiceNumber	= B.strTeaGardenChopInvoiceNumber
	, intMixingUnitLocationId		= B.intMixingUnitLocationId
	, strMixingUnit					= CL.strLocationNumber
	, intTealingoItemId				= B.intTealingoItemId
	, strTealingoItem				= I.strItemNo
	, dtmExpiryDate					= B.dtmExpiration
	, strERPPONumber				= SUBSTRING(ISNULL(B.strERPPONumber, ''), LEN(ISNULL(B.strERPPONumber, '')) - 4, LEN(ISNULL(B.strERPPONumber, '')))
	, strContainerNumber			= B.strContainerNumber
	, strBOLNo						= B.strBOLNo
FROM tblMFBatch B
LEFT JOIN tblQMGardenMark GM ON B.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblSMCompanyLocation CL ON B.intMixingUnitLocationId = CL.intCompanyLocationId
LEFT JOIN tblICItem I ON B.intTealingoItemId = I.intItemId
WHERE B.strContainerNumber IS NOT NULL
 AND B.strContainerNumber <> ''