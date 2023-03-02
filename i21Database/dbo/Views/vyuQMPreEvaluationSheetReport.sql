CREATE VIEW vyuQMPreEvaluationSheetReport
AS
SELECT intBatchId			= B.intBatchId 
	 , strLocationCode1		= B.strPlant
	 , strLocationCode2		= IL.strSubLocationName
	 , strL1PONo			= B.strERPPONumber
	 , strSupplierCode		= E.strName
	 , strShipmentNo		= CAST('SHIP#123' AS NVARCHAR(100))
	 , dtmDeliveryDate		= CAST(GETDATE() AS DATE)
	 , dtmLandedDate		= CAST(GETDATE() AS DATE)	 
	 , strContainerNumber	= B.strContainerNumber
	 , intTealingoItemId	= B.intTealingoItemId
	 , strTeaLingo			= I.strItemNo
	 , strTeaLingoDesc		= I.strDescription
	 , strBatchId			= B.strBatchId
	 , strTasteRange		= CAST(CAST(ISNULL(TASTE.dblMinValue, 0) AS DECIMAL(18,1)) AS NVARCHAR(100)) + '-' + CAST(CAST(ISNULL(TASTE.dblMaxValue, 0) AS DECIMAL(18,1)) AS NVARCHAR(100))
	 , strLeafDescription	= B.strLeafStyle
	 , strLeafSize			= B.strLeafSize
	 , strGardenMark		= GM.strGardenMark
	 , strChopNo			= B.strTeaGardenChopInvoiceNumber
	 , dblPrice				= ISNULL(B.dblLandedPrice, 0)
	 , dblTasteScore		= ISNULL(B.dblTeaTaste, 0)
	 , dblHueScore			= ISNULL(B.dblTeaHue, 0)
	 , dblIntensityScore	= ISNULL(B.dblTeaIntensity, 0)
	 , dblMouthFeelScore	= ISNULL(B.dblTeaMouthFeel, 0)
	 , strComment			= B.strTasterComments
	 , strCompanyName		= COMP.strCompanyName
	 , strCompanyAddress	= COMP.strAddress
	 , strCityStateZip		= COMP.strCity + ', ' + COMP.strState + ', ' + COMP.strZip
	 , strCompanyCountry	= COMP.strCountry	 
FROM tblMFBatch B
LEFT JOIN tblICItem I ON B.intTealingoItemId = I.intItemId
LEFT JOIN tblQMGardenMark GM ON B.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblSMCompanyLocationSubLocation IL ON B.intStorageLocationId = IL.intCompanyLocationSubLocationId
LEFT JOIN tblLGLoadDetail LD ON B.intBatchId = LD.intBatchId
LEFT JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
OUTER APPLY (
	SELECT dblMinValue	= MIN(PPV.dblMinValue)
		 , dblMaxValue 	= MAX(PPV.dblMaxValue)
	FROM tblQMProduct PRD
	INNER JOIN tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
	INNER JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
	INNER JOIN tblQMProductTest PT ON PT.intProductId = PP.intProductId AND PT.intProductId = PRD.intProductId
	INNER JOIN tblQMTest T ON T.intTestId = PP.intTestId AND T.intTestId = PT.intTestId
	INNER JOIN tblQMTestProperty TP ON TP.intPropertyId = PP.intPropertyId
					   			   AND TP.intTestId = PP.intTestId
								   AND TP.intTestId = T.intTestId
								   AND TP.intTestId = PT.intTestId
	INNER JOIN tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId AND PRT.intPropertyId = TP.intPropertyId
	INNER JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
	WHERE PRD.intProductTypeId = 2
	  AND PRD.intProductValueId = B.intTealingoItemId
	  AND PRD.ysnActive = 1
	  AND PRT.strPropertyName ='Taste'
) TASTE
OUTER APPLY (
	SELECT TOP 1 *
	FROM tblSMCompanySetup
	ORDER BY intCompanySetupID ASC
) COMP
WHERE B.strContainerNumber != ''
  AND B.strContainerNumber IS NOT NULL
  AND B.intLocationId = B.intBuyingCenterLocationId