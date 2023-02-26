CREATE VIEW vyuQMPreEvaluationSheetReport
AS
SELECT intBatchId			= B.intBatchId 
	 , strLocationCode1		= B.strPlant
	 , strLocationCode2		= IL.strName
	 , strL1PONo			= B.strERPPOLineNo
	 , strSupplierCode		= E.strEntityNo
	 , strShipmentNo		= B.strERPPONumber
	 , dtmDeliveryDate		= CAST(GETDATE() AS DATE)
	 , dtmLandedDate		= CAST(GETDATE() AS DATE)	 
	 , strContainerNumber	= B.strContainerNumber
	 , intTealingoItemId	= B.intTealingoItemId
	 , strTeaLingo			= I.strItemNo
	 , strTeaLingoDesc		= I.strDescription
	 , strBatchId			= B.strBatchId
	 , strTasteRange		= CAST('0-100' AS NVARCHAR(100))
	 , strLeafDescription	= B.strLeafStyle
	 , strLeafSize			= B.strLeafSize
	 , strGardenMark		= GM.strGardenMark
	 , strChopNo			= CAST('CHOP#123' AS NVARCHAR(100))
	 , dblPrice				= B.dblBoughtPrice
	 , dblTasteScore		= CAST(1 AS NUMERIC(18, 6))
	 , dblHueScore			= CAST(1 AS NUMERIC(18, 6))
	 , dblIntensityScore	= CAST(1 AS NUMERIC(18, 6))
	 , dblMouthFeelScore	= CAST(1 AS NUMERIC(18, 6))
	 , strComment			= B.strTasterComments
	 , strCompanyName		= COMP.strCompanyName
	 , strCompanyAddress	= COMP.strAddress
	 , strCityStateZip		= COMP.strCity + ', ' + COMP.strState + ', ' + COMP.strZip
	 , strCompanyCountry	= COMP.strCountry
FROM tblMFBatch B
LEFT JOIN tblICItem I ON B.intTealingoItemId = I.intItemId
LEFT JOIN tblQMGardenMark GM ON B.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblICStorageLocation IL ON B.intStorageLocationId = IL.intStorageLocationId
LEFT JOIN tblEMEntity E ON B.intBrokerId = E.intEntityId
OUTER APPLY (
	SELECT TOP 1 *
	FROM tblSMCompanySetup
	ORDER BY intCompanySetupID ASC
) COMP