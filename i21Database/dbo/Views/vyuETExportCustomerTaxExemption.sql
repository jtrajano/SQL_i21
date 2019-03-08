CREATE VIEW [dbo].[vyuETExportCustomerTaxExemption]  
AS  

WITH EXEMPTIONS AS 
(

SELECT TE.*, NULL TaxGroupCodeCategory							
FROM
	tblARCustomerTaxingTaxException TE
LEFT OUTER JOIN
	tblSMTaxCode TC
		ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
LEFT OUTER JOIN
	[tblEMEntityLocation] EL	
		ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
LEFT OUTER JOIN
	tblSMTaxClass TCL
		ON TE.[intTaxClassId] = TCL.[intTaxClassId]
LEFT OUTER JOIN
	tblICItem  IC
		ON TE.[intItemId] = IC.[intItemId]
LEFT OUTER JOIN
	tblICCategory ICC
		ON TE.[intCategoryId] = ICC.[intCategoryId]
LEFT OUTER JOIN
	tblCFCard CFC
		ON TE.[intCardId] = CFC.[intCardId]
LEFT OUTER JOIN
	tblCFVehicle CFV
		ON TE.[intVehicleId] = CFV.[intVehicleId] 		

)							
		
, CategoryExemption AS
(
--CATEGORY Exemptions--------------			
SELECT SMTGCE.*, SMTGC.[intTaxCodeId],SMTGC.[intTaxGroupId]
	FROM
		tblSMTaxGroupCodeCategoryExemption SMTGCE
	INNER JOIN
		tblSMTaxGroupCode SMTGC
			ON SMTGCE.[intTaxGroupCodeId] = SMTGC.[intTaxGroupCodeId]
	INNER JOIN
		tblSMTaxGroup SMTG
			ON SMTGC.[intTaxGroupId] = SMTG.[intTaxGroupId] 
	INNER JOIN
		tblSMTaxCode SMTC
			ON SMTGC.[intTaxCodeId] = SMTC.[intTaxCodeId] 
	INNER JOIN
		tblICCategory ICC
			ON SMTGCE.[intCategoryId] = ICC.[intCategoryId]
)

		
, CustItemTaxCodes AS
	(
		SELECT  DISTINCT Exemp.[intEntityCustomerId] intEntityCustomerId
						,CustomerNumber = strCustomerNumber 
						,CustomerExemptAll = ysnTaxExempt
						,ETItems.intItemId
						,ETItems.strItemNo ItemNumber
						,ETItems.intCategoryId
						,Authority1 = ETTaxGroupCode.intTaxGroupId 
						,Authority2 = ''
						,ETTaxGroupCode.intTaxCodeId
						,ETTaxGroupCode.strTaxGroup 
						,ETTaxGroupCode.intTaxClassId
						,strTaxCodeReference = ETTaxGroupCode.strTaxCodeReference 
						,Substring(ETTaxGroupCode.strTaxGroup, 1, 2) State
						,ETTaxGroupCode.strState
						,ETTaxGroupCode.intSalesTaxAccountId
		FROM (select DISTINCT intEntityCustomerId from [tblARCustomerTaxingTaxException]) Exemp
		INNER JOIN tblARCustomer ARC ON Exemp.intEntityCustomerId = ARC.intEntityId 
		INNER JOIN tblEMEntityLocation EMEL ON ARC.intEntityId = EMEL.intEntityId AND EMEL.ysnDefaultLocation = 1
		LEFT OUTER JOIN tblSMCompanyLocation SMCL ON EMEL.intWarehouseId = SMCL.intCompanyLocationId

		--INNER JOIN [tblARCustomerTaxingTaxException] ExemptionTaxCode ON Exemp.intCustomerTaxingTaxExceptionId = ExemptionTaxCode.intCustomerTaxingTaxExceptionId 
		--SELECT intEntityId,strCustomerNumber,ETItems.intItemId,ETItems.strItemNo FROM tblARCustomer ARC 
		CROSS APPLY (
		SELECT Distinct intItemId			 
						,strItemNo 
						,intCategoryId
		FROM
		[vyuETExportItem]
		) ETItems

		CROSS APPLY(
			SELECT DISTINCT TGC.intTaxGroupId,TGC.[intTaxCodeId] ,TaxGroup.strTaxGroup, ETTC.strTaxCodeReference ,TaxCode.strState , TaxCode.intTaxClassId, TaxCode.intSalesTaxAccountId FROM tblSMTaxGroupCode TGC --ON TC.[intTaxCodeId] = TGC.[intTaxCodeId]  AND TGC.intTaxGroupId = @intTaxGroupId
			INNER JOIN tblSMTaxCode TaxCode ON TGC.intTaxCodeId = TaxCode.intTaxCodeId
			INNER JOIN tblICCategoryTax CatTax ON TaxCode.intTaxClassId =  CatTax.intTaxClassId AND CatTax.intCategoryId = ETItems.intCategoryId
			INNER JOIN tblSMTaxGroup TaxGroup ON TGC.intTaxGroupId =  TaxGroup.intTaxGroupId	        
			INNER JOIN (SELECT DISTINCT intTaxCodeId,strTaxCodeReference FROM tblETExportTaxCodeMapping) ETTC ON TGC.intTaxCodeId = ETTC.intTaxCodeId 
			INNER JOIN tblETExportFilterTaxGroup ETTG ON TGC.intTaxGroupId = ETTG.intTaxGroupId
		) ETTaxGroupCode
	)
--END OF CTE Construct

/******************************************************************************************************************************************************************************/
SELECT 
CustomerNumber	
,ItemNumber		
,State			
,Authority1		
,Authority2  COLLATE Latin1_General_CI_AS AS Authority2
,FETCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'FET' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,SETCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'SET' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,SSTCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'SST' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale1Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC1' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale2Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC2' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale3Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC3' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale4Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC4' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale5Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC5' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale6Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC6' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale7Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC7' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale8Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC8' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale9Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC9' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale10Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC10' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale11Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC11' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
,Locale12Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC12' THEN Charge ELSE  0 END) > 0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS

--,SETCharge		= CASE WHEN SUM(ISNULL(SETCharge,0)) > 0 THEN 'Y' ELSE 'N' END
--,SSTCharge		= CASE WHEN SUM(ISNULL(SSTCharge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale1Charge	= CASE WHEN SUM(ISNULL(Locale1Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale2Charge	= CASE WHEN SUM(ISNULL(Locale2Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale3Charge	= CASE WHEN SUM(ISNULL(Locale3Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale4Charge	= CASE WHEN SUM(ISNULL(Locale4Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale5Charge	= CASE WHEN SUM(ISNULL(Locale5Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,Locale6Charge	= CASE WHEN SUM(ISNULL(Locale6Charge,0)) > 0 THEN 'Y' ELSE 'N' END
FROM  (

/******************************************************************************************************************************************************************************************************/
SELECT 
strTaxCodeReference
,Charge = 
			/*******************************************************************************************************************************************************************/
			~ CAST(
			
			ISNULL(
			
			/*CUSTOMER > Detail >  Tax Exempt(ALL)*/
			(CASE WHEN ISNULL(CustomerExemptAll,0) = 1 THEN 1
			
			/*CATEGORY*/
			WHEN 	ISNULL((SELECT TOP 1 1 FROM CategoryExemption CExempt
									 WHERE CExempt.intCategoryId = A.intCategoryId
									AND CExempt.intTaxCodeId = A.intTaxCodeId
									AND CExempt.intTaxGroupId = Authority1 )	, 0) = 1 THEN 1
			/*CUSTOMER > Taxing - Exemptions*/
			WHEN 
			
			ISNULL((SELECT TOP 1 1 
							FROM EXEMPTIONS TE
								WHERE 
									TE.[intEntityCustomerId] = A.intEntityCustomerId		
									AND	CAST(GETDATE() AS DATE) BETWEEN CAST(ISNULL(TE.[dtmStartDate], GETDATE()) AS DATE) AND CAST(ISNULL(TE.[dtmEndDate], GETDATE()) AS DATE)
									--AND (ISNULL(TE.[intEntityCustomerLocationId], 0) = 0 OR TE.[intEntityCustomerLocationId] = @ShipToLocationId)
									AND (ISNULL(TE.[intItemId], 0) = 0 OR TE.[intItemId] = A.intItemId)
									AND (ISNULL(TE.[intCategoryId], 0) = 0 OR TE.[intCategoryId] = A.intCategoryId)
									AND (ISNULL(TE.[intTaxCodeId], 0) = 0 OR TE.[intTaxCodeId] = A.intTaxCodeId)
									AND (ISNULL(TE.[intTaxClassId], 0) = 0 OR TE.[intTaxClassId] = A.intTaxClassId)
									--AND (ISNULL(TE.[intCardId], 0) = 0 OR TE.[intCardId] = NULL)
									--AND (ISNULL(TE.[intVehicleId], 0) = 0 OR TE.[intVehicleId] = NULL)
								
									--AND (ISNULL(TE.[intCardId], 0) = 0 OR TE.[intCardId] = NULL)
									--AND (ISNULL(TE.[intVehicleId], 0) = 0 OR TE.[intVehicleId] = NULL)
									AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR (TE.[strState] = A.strState AND A.strState = A.strState) OR LEN(LTRIM(RTRIM(ISNULL(A.strState,'')))) <= 0 )

								
									ORDER BY
									(
										(CASE WHEN ISNULL(TE.[intCardId],0) = 0 THEN 0 ELSE 1 END)
										+
										(CASE WHEN ISNULL(TE.[intVehicleId],0) = 0 THEN 0 ELSE 1 END)		
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
									,ISNULL(TE.[dtmStartDate], GETDATE()) ASC
									,ISNULL(TE.[dtmEndDate], GETDATE()) DESC
										)
										,0) = 1 THEN 1
				ELSE 						
                  				(CASE WHEN ISNULL(intSalesTaxAccountId,0) = 0 THEN 1 ELSE 0 END)
				END)	/*CASE END*/
				,0)
			 AS BIT)
			/*******************************************************************************************************************************************************************/
           
,intEntityCustomerId
,CustomerNumber	
,ItemNumber		
,State			
,Authority1		
,Authority2 

		FROM CustItemTaxCodes A
		) ALLTaxCodes
/******************************************************************************************************************************************************************************************************/		--LEFT JOIN EXEMPTIONS B ON B.intEntityCustomerId = A.intEntityCustomerId
		
GROUP BY 
	intEntityCustomerId
	,CustomerNumber
	--,intEntityCustomerId
	--,intItemId 
	, ItemNumber
	,Authority1
	,Authority2 
	, State