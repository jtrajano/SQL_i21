CREATE VIEW [dbo].[vyuEMETExportCustomerTaxExemption]
	AS

SELECT 
	CustomerNumber	= CustomerNumber,
	ItemNumber		= ItemNumber,
	State			= State,
	Authority1		= Authority1,
	Authority2		= Authority2,	
	FETCharge		= CASE WHEN SUM(ISNULL(FETCharge,0)) > 0 THEN 'Y' ELSE 'N' END,
	SETCharge		= CASE WHEN SUM(ISNULL(SETCharge,0)) > 0 THEN 'Y' ELSE 'N' END,
	SSTCharge		= CASE WHEN SUM(ISNULL(SSTCharge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale1Charge	= CASE WHEN SUM(ISNULL(Locale1Charge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale2Charge	= CASE WHEN SUM(ISNULL(Locale2Charge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale3Charge	= CASE WHEN SUM(ISNULL(Locale3Charge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale4Charge	= CASE WHEN SUM(ISNULL(Locale4Charge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale5Charge	= CASE WHEN SUM(ISNULL(Locale5Charge,0)) > 0 THEN 'Y' ELSE 'N' END,
	Locale6Charge	= CASE WHEN SUM(ISNULL(Locale6Charge,0)) > 0 THEN 'Y' ELSE 'N' END
FROM
(
SELECT
	 CustomerNumber		= ARC.strCustomerNumber
	,ItemNumber			= ICI.strItemNo
	,State				= Substring(TC.strTaxGroup, 1, 2)
	,Authority1			= TC.intTaxGroupId
	,Authority2			= ''
	,FETCharge			= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'FET') THEN 1 ELSE 0 END)
	,SETCharge			= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'SET') THEN 1 ELSE 0 END)
	,SSTCharge			= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'SST') THEN 1 ELSE 0 END)
	,Locale1Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC1') THEN 1 ELSE 0 END)
	,Locale2Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC2') THEN 1 ELSE 0 END)
	,Locale3Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC3') THEN 1 ELSE 0 END)
	,Locale4Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC4') THEN 1 ELSE 0 END)
	,Locale5Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC5') THEN 1 ELSE 0 END)
	,Locale6Charge		= (CASE WHEN TC.[ysnTaxExempt] = 0 AND EXISTS(SELECT NULL FROM tblETExportTaxCodeMapping ET WHERE ET.intTaxCodeId = TC.intTaxCodeId AND ET.strTaxCodeReference = 'LC6') THEN 1 ELSE 0 END)
	,intTaxGroupId		= TC.intTaxGroupId
	,intTaxCodeId		= TC.intTaxCodeId
	,intTaxClassId		= TC.intTaxClassId
	,intCategoryId		= ARTE.intCategoryId
FROM
	tblARCustomerTaxingTaxException ARTE
INNER JOIN
	tblARCustomer ARC
		ON ARTE.intEntityCustomerId = ARC.intEntityId
INNER JOIN
	tblEMEntityLocation EMEL
		ON ARC.intEntityId = EMEL.intEntityId 
		AND EMEL.ysnDefaultLocation = 1
--INNER JOIN
LEFT OUTER JOIN
	tblSMCompanyLocation SMCL
		ON EMEL.intWarehouseId = SMCL.intCompanyLocationId
INNER JOIN
	tblICItem ICI
		ON ARTE.intItemId = ICI.intItemId		
CROSS APPLY
	[dbo].[fnGetTaxGroupTaxCodesForCustomer]
		(
		[dbo].[fnGetTaxGroupIdForCustomer](ARC.intEntityId, SMCL.intCompanyLocationId, ICI.intItemId, ARC.intShipToId, NULL, NULL)
		,ARC.intEntityId
		,GETDATE()
		,ICI.intItemId
		,ARC.intShipToId
		,1
		,NULL
		,NULL
		,NULL
		,0
		,[dbo].[fnGetItemStockUOM](ICI.intItemId)
		,NULL
		,EMEL.intWarehouseId
		,NULL
		,NULL
		,1
		) TC
) T
GROUP BY 
	CustomerNumber,
	ItemNumber,
	State,	
	Authority1,
	Authority2

--SELECT DISTINCT 
--	CustomerNumber,
--	ItemNumber,
--	state =Substring(G.strTaxGroup, 1, 2),	
--	Authority1 = G.intTaxGroupId,
--	Authority2,
--	FETCharge,
--	SETCharge,
--	SSTCharge,
--	Locale1Charge,
--	Locale2Charge,
--	Locale3Charge,
--	Locale4Charge,
--	Locale5Charge,
--	Locale6Charge
	
--	FROM	
--(
--SELECT 
--	 --(ISNULL(D.intTaxGroupId, E.intTaxGroupId)),
--	CustomerNumber = B.strCustomerNumber,
--	ItemNumber = C.strItemNo,	
--	--state = 'test',
--	--Authority1 = E.intTaxGroupId,
--	Authority2 = '',
--	FETCharge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'FET'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	[SETCharge] = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'SET'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	SSTCharge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'SST'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale1Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC1'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale2Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC2'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale3Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC3'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale4Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC4'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale5Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC5'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),

--	Locale6Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
--				JOIN tblICCategoryTax sict1
--					ON sic1.intCategoryId = sict1.intCategoryId
--				JOIN tblSMTaxCode sst1
--					ON sst1.intTaxClassId = sict1.intTaxClassId
--				JOIN tblSMTaxGroupCode ssg1	
--					ON ssg1.intTaxCodeId = sst1.intTaxCodeId and ssg1.intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId))
--				JOIN tblETExportTaxCodeMapping sem1
--					ON sem1.intTaxCodeId = ssg1.intTaxCodeId 			
--						AND sem1.strTaxCodeReference = 'LC6'
--			WHERE sic1.intCategoryId = A.intCategoryId  AND ssg1.intTaxCodeId <> A.intTaxCodeId) , 'N'),
	
--	intTaxGroupId = isnull(D.intTaxGroupId, E.intTaxGroupId)
--	FROM 
--		tblARCustomerTaxingTaxException A
--			JOIN tblARCustomer B
--				ON A.intEntityCustomerId = B.intEntityId
--			JOIN tblICItem C
--				ON A.intItemId = C.intItemId
--			JOIN tblEMEntityLocation D
--				ON A.intEntityCustomerId = D.intEntityId --AND D.ysnDefaultLocation = 1
--			LEFT JOIN tblSMCompanyLocation E
--				on D.intWarehouseId = E.intCompanyLocationId			
--	WHERE (A.intItemId in (select intItemId from tblETExportFilterItem) or A.intCategoryId in (select intCategoryId from tblETExportFilterCategory ))			
--			AND A.intTaxCodeId IN (SELECT intTaxCodeId FROM tblSMTaxGroupCode WHERE intTaxGroupId = (ISNULL(D.intTaxGroupId, E.intTaxGroupId)))
--) A 
--LEFT JOIN tblSMTaxGroup G
--			on A.intTaxGroupId = G.intTaxGroupId