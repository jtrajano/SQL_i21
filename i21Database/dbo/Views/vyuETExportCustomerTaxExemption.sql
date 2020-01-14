﻿CREATE VIEW [dbo].[vyuETExportCustomerTaxExemption]  
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
						,CustomerNumber = Exemp.strCustomerNumber 
						,CustomerExemptAll = ysnTaxExempt
						,Exemp.intItemId
						,Exemp.strItemNo ItemNumber
						,Exemp.intCategoryId
						,Authority1 = ETTaxGroupCode.intTaxGroupId 
						,Authority2 = ''
						,ETTaxGroupCode.intTaxCodeId
						,ETTaxGroupCode.strTaxGroup 
						,ETTaxGroupCode.intTaxClassId
						,strTaxCodeReference = ETTaxGroupCode.strTaxCodeReference 
						,Substring(ETTaxGroupCode.strTaxGroup, 1, 2) State
						,ETTaxGroupCode.strState
						,ETTaxGroupCode.intSalesTaxAccountId
		FROM 

		(
			SELECT DISTINCT B.strCustomerNumber,A.intEntityCustomerId,B.ysnTaxExempt,ETItemsAll.intItemId, B.intEntityId, ETItemsAll.strItemNo , ETItemsAll.intCategoryId,B.intShipToId , ISNULL(TC.intTaxCodeId,TC2.intTaxCodeId)  intTaxCodeId
			FROM tblARCustomerTaxingTaxException A  
			INNER JOIN tblARCustomer  B ON A.intEntityCustomerId = B.intEntityId  
			LEFT JOIN vyuETExportItem ETItemsAll  ON (A.intItemId IS NULL AND A.intCategoryId IS NULL)  
			LEFT JOIN vyuETExportItem ETItemsAll2 ON  (A.intItemId IS NOT NULL AND A.intItemId = ETItemsAll2.intItemId)  
			LEFT JOIN vyuETExportItem ETItemsAll3  ON (A.intItemId IS NULL AND A.intCategoryId IS NOT NULL AND A.intCategoryId = ETItemsAll3.intItemId )  
			LEFT JOIN tblSMTaxCode TC ON (A.intTaxCodeId IS NOT NULL AND A.intTaxCodeId = TC.intTaxCodeId)
			LEFT JOIN tblSMTaxCode TC2 ON (A.intTaxCodeId IS NULL)
		)Exemp

		INNER JOIN tblEMEntityLocation EMEL ON Exemp.intEntityId = EMEL.intEntityId AND EMEL.ysnDefaultLocation = 1
		LEFT OUTER JOIN tblSMCompanyLocation SMCL ON EMEL.intWarehouseId = SMCL.intCompanyLocationId

		INNER JOIN (

		
		--CROSS APPLY(
			SELECT DISTINCT TGC.intTaxGroupId,TGC.[intTaxCodeId] ,TaxGroup.strTaxGroup, ETTC.strTaxCodeReference ,TaxCode.strState , TaxCode.intTaxClassId, TaxCode.intSalesTaxAccountId , CatTax.intCategoryId intCategory FROM tblSMTaxGroupCode TGC 
			INNER JOIN tblSMTaxCode TaxCode ON TGC.intTaxCodeId = TaxCode.intTaxCodeId
			INNER JOIN tblICCategoryTax CatTax ON TaxCode.intTaxClassId =  CatTax.intTaxClassId --AND CatTax.intCategoryId = Exemp.intCategoryId
			INNER JOIN tblSMTaxGroup TaxGroup ON TGC.intTaxGroupId =  TaxGroup.intTaxGroupId
			                                     --AND TaxGroup.intTaxGroupId =  [dbo].[fnGetTaxGroupIdForCustomer](Exemp.intEntityId, SMCL.intCompanyLocationId, Exemp.intItemId, Exemp.intShipToId, NULL, NULL)  	        
			INNER JOIN (SELECT DISTINCT intTaxCodeId,strTaxCodeReference FROM tblETExportTaxCodeMapping) ETTC ON TGC.intTaxCodeId = ETTC.intTaxCodeId 
			INNER JOIN tblETExportFilterTaxGroup ETTG ON TGC.intTaxGroupId = ETTG.intTaxGroupId
		) ETTaxGroupCode  ON intCategoryId = Exemp.intCategoryId
					AND ETTaxGroupCode.intTaxCodeId = Exemp.intTaxCodeId

	)
--END OF CTE Construct

/******************************************************************************************************************************************************************************/



SELECT 
CustomerNumber	
,CAST(ItemNumber AS VARCHAR(15)) ItemNumber
,State			
,Authority1		
,Authority2  COLLATE Latin1_General_CI_AS AS Authority2
,FETCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'FET' AND Charge = 0 THEN 1 ELSE  0 END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,SETCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'SET' AND Charge = 0 THEN 1 ELSE  0 END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,SSTCharge		= CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'SST' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale1Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC1' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale2Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC2' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale3Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC3' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale4Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC4' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale5Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC5' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale6Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC6' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale7Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC7' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale8Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC8' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale9Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC9' AND Charge = 0 THEN 1 ELSE  0	END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale10Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC10' AND Charge = 0 THEN 1 ELSE 0 END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale11Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC11' AND Charge = 0 THEN 1 ELSE 0 END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,Locale12Charge  = CASE WHEN SUM(CASE WHEN strTaxCodeReference = 'LC12' AND Charge = 0 THEN 1 ELSE 0 END) > 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS
,intEntityCustomerId
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
											AND (LEN(LTRIM(RTRIM(ISNULL(TE.[strState],'')))) <= 0 OR (TE.[strState] = A.strState AND A.strState = A.strState) OR LEN(LTRIM(RTRIM(ISNULL(A.strState,'')))) <= 0 )

								
											ORDER BY (
												(CASE WHEN ISNULL(TE.[intCardId],0) = 0 THEN 0 ELSE 1 END)	+
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


INNER JOIN

(
	SELECT DISTINCT A.intTaxStateID TaxGroupID ,C.intEntityId
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B ON A.intCustomerID = B.intCustomerID AND A.intTaxStateID IS NOT NULL AND A.ysnActive = 1
	INNER JOIN (SELECT 
					Ent.strEntityNo
					,Ent.intEntityId
					,Cus.ysnActive
					,Loc.intTermsId
					,Trm.strTermCode
					,Trm.strTerm
				FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.[intEntityId] AND Cus.ysnActive = 1
				INNER JOIN [tblEMEntityLocation] Loc ON Ent.intEntityId = Loc.intEntityId and Loc.ysnDefaultLocation = 1
				LEFT JOIN tblSMTerm Trm ON Trm.intTermID = Loc.intTermsId) C ON B.intCustomerNumber = C.intEntityId
	
	UNION 
	
	SELECT DISTINCT TaxGroupId,intEntityId FROM [vyuETExportCustomer] WHERE ISNULL(NULLIF(TaxGroupId, ''),0) <> 0

) CustomerSiteAndDefaultTaxGroup ON ALLTaxCodes.intEntityCustomerId = CustomerSiteAndDefaultTaxGroup.intEntityId AND ALLTaxCodes.Authority1 = CustomerSiteAndDefaultTaxGroup.TaxGroupID
		
GROUP BY 
	intEntityCustomerId	,
	CustomerNumber
	--,intEntityCustomerId
	--,intItemId 
	, ItemNumber
	,Authority1
	,Authority2 
	, State