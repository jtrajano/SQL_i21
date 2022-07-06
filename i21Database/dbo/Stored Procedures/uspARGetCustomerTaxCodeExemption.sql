CREATE PROCEDURE dbo.uspARGetCustomerTaxCodeExemption
	@CustomerTaxCodeExemptionParam		CustomerTaxCodeExemptionParam READONLY
AS

DECLARE @CustomerTaxCodeExemption	CustomerTaxCodeExemptionParam

INSERT INTO @CustomerTaxCodeExemption
SELECT * FROM @CustomerTaxCodeExemptionParam

UPDATE @CustomerTaxCodeExemption
SET ysnDisregardExemptionSetup = 0
WHERE ysnDisregardExemptionSetup IS NULL

IF(OBJECT_ID('tempdb..##TAXCODEEXEMPTIONS') IS NOT NULL) DROP TABLE ##TAXCODEEXEMPTIONS
CREATE TABLE ##TAXCODEEXEMPTIONS (
	  [ysnTaxExempt]			BIT
	, [ysnInvalidSetup]			BIT
	, [strExemptionNotes]		NVARCHAR(500)
	, [dblExemptionPercent]		NUMERIC(18,6)
	, [intCustomerId]			INT NULL
	, [intTaxGroupId]			INT NULL
	, [intTaxCodeId]			INT NULL
	, [intTaxClassId]			INT NULL
	, [intItemId]				INT NULL
	, [intLineItemId]			INT NULL
)

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 0
	, strExemptionNotes		= 'Customer is tax exempted; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
	, dblExemptionPercent	= 0
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
INNER JOIN tblARCustomer C ON P.intCustomerId = C.intEntityId
WHERE C.ysnTaxExempt = 1
  AND P.ysnDisregardExemptionSetup <> 1

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 0
	, strExemptionNotes		= 'Customer Site is non sales-taxable; Date: ' + CONVERT(NVARCHAR(20), GETDATE(), 101) + ' ' + CONVERT(NVARCHAR(20), GETDATE(), 114)
	, dblExemptionPercent	= 0
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
CROSS APPLY (
	SELECT TOP 1 SMTGC.*
	FROM tblSMTaxGroupCode SMTGC 
	INNER JOIN tblSMTaxGroup SMTG ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
	INNER JOIN tblSMTaxCode SMTC ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
	INNER JOIN tblSMTaxClass SMTCL ON SMTC.[intTaxClassId] = SMTCL.[intTaxClassId]
	WHERE SMTGC.intTaxCodeId = P.intTaxCodeId 
	  AND SMTGC.intTaxGroupId = P.intTaxGroupId
	  AND SMTCL.strTaxClass LIKE '%Sales Tax%'
) TAX
WHERE P.ysnCustomerSiteTaxable = 0
  AND P.ysnCustomerSiteTaxable IS NOT NULL

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 0
	, strExemptionNotes		= 'Tax Code ''' + TAX.[strTaxCode] +  ''' under Tax Group  ''' + TAX.strTaxGroup + ''' has an exemption set for item category ''' + TAX.[strCategoryCode] + ''''
	, dblExemptionPercent	= 0
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
CROSS APPLY (
	SELECT TOP 1 SMTC.strTaxCode
		 , SMTG.strTaxGroup
		 , ICC.strCategoryCode
	FROM tblSMTaxGroupCode SMTGC 
	INNER JOIN tblSMTaxGroupCodeCategoryExemption SMTGCE ON SMTGCE.intTaxGroupCodeId = SMTGC.intTaxGroupCodeId
	INNER JOIN tblSMTaxGroup SMTG ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
	INNER JOIN tblSMTaxCode SMTC ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
	INNER JOIN tblICCategory ICC ON SMTGCE.[intCategoryId] = ICC.[intCategoryId]
	WHERE SMTGC.intTaxCodeId = P.intTaxCodeId 
	  AND SMTGC.intTaxGroupId = P.intTaxGroupId
	  AND SMTGCE.intCategoryId = P.intItemCategoryId
) TAX
WHERE P.ysnDisregardExemptionSetup <> 1

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 1
	, strExemptionNotes		= ISNULL('Tax Class ''' + TC.strTaxClass, '') + ISNULL(''' is not included in Item Category ''' + CAT.strCategoryCode + ''' tax class setup.', '')
	, dblExemptionPercent	= 0
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId	
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
INNER JOIN tblSMTaxClass TC ON TC.intTaxClassId = P.intTaxClassId
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = P.intItemCategoryId
OUTER APPLY (
	SELECT DISTINCT TOP 1 ICCT.intTaxClassId
	FROM tblICItem ICI
	INNER JOIN tblICCategory ICC ON ICI.[intCategoryId] = ICC.[intCategoryId]
	INNER JOIN tblICCategoryTax ICCT ON ICC.[intCategoryId] = ICCT.[intCategoryId]
	WHERE ICI.intItemId = P.intItemId
	  AND ICC.intCategoryId = P.intItemCategoryId
	  AND ICCT.intTaxClassId = P.intTaxClassId	
) TCLASS
WHERE P.intItemId IS NOT NULL
  AND P.intItemCategoryId IS NOT NULL  
  AND TCLASS.intTaxClassId IS NULL

UPDATE P
SET intSiteNumber = TM.intSiteNumber
FROM @CustomerTaxCodeExemption P
INNER JOIN tblTMSite TM ON P.intSiteId = TM.intSiteID

UPDATE P
SET strState = CF.strTaxState
FROM @CustomerTaxCodeExemption P
INNER JOIN tblSMFreightTerms FT ON FT.intFreightTermId = P.intFreightTermId
INNER JOIN tblCFSite CF ON CF.intSiteId = P.intSiteId
WHERE P.intSiteId IS NOT NULL
  AND (P.ysnDeliver = 0 OR FT.strFobPoint = 'origin')

UPDATE P
SET strState = EL.strState
FROM @CustomerTaxCodeExemption P
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = P.intFreightTermId
INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = P.intShipToLocationId
WHERE P.intShipToLocationId IS NOT NULL
  AND ((P.intFreightTermId IS NOT NULL AND FT.strFobPoint <> 'origin') OR (P.intFreightTermId IS NULL AND ysnDeliver = 1))
  AND P.intSiteId IS NULL

UPDATE P
SET strState = SL.strStateProvince
FROM @CustomerTaxCodeExemption P
INNER JOIN tblSMFreightTerms FT ON FT.intFreightTermId = P.intFreightTermId
INNER JOIN tblSMCompanyLocation SL ON SL.intCompanyLocationId = P.intCompanyLocationId
WHERE P.intCompanyLocationId IS NOT NULL
  AND P.intFreightTermId IS NOT NULL 
  AND FT.strFobPoint = 'origin'
  AND P.intSiteId IS NULL

UPDATE @CustomerTaxCodeExemption
SET strState = strTaxState
WHERE strState IS NULL

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 1
	, strExemptionNotes		=  'Tax Exemption > '
								+ ISNULL('Number: ' + CAST(TAX.[intCustomerTaxingTaxExceptionId] AS NVARCHAR(250)) +  ' - ' + ISNULL(TAX.[strException], ''), '') 
								+ ISNULL('; Start Date: ' + CONVERT(NVARCHAR(25), TAX.[dtmStartDate], 101), '')
								+ ISNULL('; End Date: ' + CONVERT(NVARCHAR(25), TAX.[dtmEndDate], 101), '')
								+ ISNULL('; Card: ' + TAX.[strCardNumber], '')
								+ ISNULL('; Vehicle: ' + TAX.[strVehicleNumber], '')
								+ ISNULL('; Site No: ' + TAX.[intSiteNumber], '')
								+ ISNULL('; Customer Location: ' + TAX.[strLocationName], '')
								+ ISNULL('; Item No: ' + TAX.[strItemNo], '')
								+ ISNULL('; Item Category: ' + TAX.[strCategoryCode], '')
								+ ISNULL('; Tax Code: ' + TAX.[strTaxCode], '')
								+ ISNULL('; Tax Class: ' + TAX.[strTaxClass], '')
								+ ISNULL('; Tax State: ' + TAX.[strState], '')
	, dblExemptionPercent	= TAX.[dblPartialTax] 
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
CROSS APPLY (
	SELECT TOP 1 TE.intCustomerTaxingTaxExceptionId
		       , TE.strException
			   , TE.dtmStartDate
			   , TE.dtmEndDate
			   , CFC.strCardNumber
			   , CFV.strVehicleNumber
			   , intSiteNumber	= REPLACE(STR(TMS.[intSiteNumber], 4), SPACE(1), '0')
			   , EL.strLocationName
			   , IC.strItemNo
			   , ICC.strCategoryCode
			   , TC.strTaxCode
			   , TCL.strTaxClass
			   , TE.strState
			   , TE.dblPartialTax
	FROM tblARCustomerTaxingTaxException TE 
	LEFT OUTER JOIN tblSMTaxCode TC ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
	LEFT OUTER JOIN [tblEMEntityLocation] EL ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
	LEFT OUTER JOIN tblSMTaxClass TCL ON TE.[intTaxClassId] = TCL.[intTaxClassId]
	LEFT OUTER JOIN tblICItem  IC ON TE.[intItemId] = IC.[intItemId]
	LEFT OUTER JOIN tblICCategory ICC ON TE.[intCategoryId] = ICC.[intCategoryId]
	LEFT OUTER JOIN tblCFCard CFC ON TE.[intCardId] = CFC.[intCardId]
	LEFT OUTER JOIN tblCFVehicle CFV ON TE.[intVehicleId] = CFV.[intVehicleId] 
	LEFT OUTER JOIN tblTMSite TMS ON TE.[intSiteNumber] = TMS.[intSiteNumber]
	WHERE TE.intEntityCustomerId = P.intCustomerId
	    AND CAST(P.dtmTransactionDate AS DATE) BETWEEN CAST(ISNULL(TE.[dtmStartDate], P.dtmTransactionDate) AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], P.dtmTransactionDate) AS DATE)
		AND (ISNULL(TE.[intEntityCustomerLocationId], 0) = 0 OR TE.[intEntityCustomerLocationId] = P.intShipToLocationId)
		AND (ISNULL(TE.[intItemId], 0) = 0 OR TE.[intItemId] = P.intItemId)
		AND (ISNULL(TE.[intCategoryId], 0) = 0 OR TE.[intCategoryId] = P.intItemCategoryId)
		AND (ISNULL(TE.[intTaxCodeId], 0) = 0 OR TE.[intTaxCodeId] = P.intTaxCodeId)
		AND (ISNULL(TE.[intTaxClassId], 0) = 0 OR TE.[intTaxClassId] = P.intTaxClassId)	
		AND (ISNULL(TE.[intSiteNumber], 0) = 0 OR TE.[intSiteNumber] = P.intSiteNumber)
		AND (
				(
					(ISNULL(TE.[intCardId], 0) <> 0 AND ISNULL(TE.[intVehicleId], 0) <> 0 AND TE.[intCardId] = P.intCardId AND TE.[intVehicleId] = P.intVehicleId)
					OR
					(ISNULL(TE.[intCardId], 0) = 0 AND ISNULL(TE.[intVehicleId], 0) <> 0 AND TE.[intVehicleId] = P.intVehicleId)
					OR
					(ISNULL(TE.[intVehicleId], 0) = 0 AND ISNULL(TE.[intCardId], 0) <> 0 AND TE.[intCardId] = P.intCardId)
					OR
					(ISNULL(TE.[intCardId], 0) = 0 AND ISNULL(TE.[intVehicleId], 0) = 0)
				)
				OR
				(
					ISNULL(P.ysnCFQuote, 0) = 1
				)

			)
		AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR (TE.[strState] = P.strState AND P.strState = P.strTaxState) OR LEN(LTRIM(RTRIM(ISNULL(P.strState,'')))) <= 0 )		
		AND P.ysnDisregardExemptionSetup <> 1
	ORDER BY
		(
			(CASE WHEN ISNULL(TE.[intCardId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intVehicleId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intSiteNumber],0) = 0 THEN 0 ELSE 1 END)		
		) DESC
		,(
			(CASE WHEN ISNULL(TE.[intEntityCustomerLocationId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intItemId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intCategoryId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intTaxCodeId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN ISNULL(TE.[intTaxClassId],0) = 0 THEN 0 ELSE 1 END)
			+
			(CASE WHEN LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 THEN 0 ELSE 1 END)
		) DESC
		,ISNULL(TE.[dtmStartDate], P.dtmTransactionDate) ASC
		,ISNULL(TE.[dtmEndDate], P.dtmTransactionDate) DESC
) TAX

INSERT INTO ##TAXCODEEXEMPTIONS (
	  ysnTaxExempt
    , ysnInvalidSetup
	, strExemptionNotes
	, dblExemptionPercent
	, intCustomerId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, intItemId
	, intLineItemId
)
SELECT ysnTaxExempt			= 1
    , ysnInvalidSetup		= 1
	, strExemptionNotes		= 'Invalid Sales Tax Account for Tax Code ''' + TAX.[strTaxCode] + ''''
	, dblExemptionPercent	= 0
	, intCustomerId			= P.intCustomerId
	, intTaxGroupId			= P.intTaxGroupId
	, intTaxCodeId			= P.intTaxCodeId
	, intTaxClassId			= P.intTaxClassId
	, intItemId				= P.intItemId
	, intLineItemId			= P.intLineItemId
FROM @CustomerTaxCodeExemption P
CROSS APPLY (
	SELECT TOP 1 TC.strTaxCode
	FROM tblSMTaxCode TC 
	WHERE TC.intTaxCodeId = P.intTaxCodeId
	  AND TC.intSalesTaxAccountId IS NULL
) TAX
WHERE P.intTaxCodeId IS NOT NULL
  AND P.ysnDisregardExemptionSetup <> 1  

IF NOT EXISTS (SELECT TOP 1 NULL FROM ##TAXCODEEXEMPTIONS)
	BEGIN
		INSERT INTO ##TAXCODEEXEMPTIONS (
			  ysnTaxExempt
			, ysnInvalidSetup
			, strExemptionNotes
			, dblExemptionPercent
			, intCustomerId
			, intTaxGroupId
			, intTaxCodeId
			, intTaxClassId
			, intItemId
			, intLineItemId
		)
		SELECT ysnTaxExempt			= 0
			, ysnInvalidSetup		= 0
			, strExemptionNotes		= NULL
			, dblExemptionPercent	= 0
			, intCustomerId
			, intTaxGroupId
			, intTaxCodeId
			, intTaxClassId
			, intItemId
			, intLineItemId
		FROM @CustomerTaxCodeExemption
	END

--SELECT * FROM @returntable