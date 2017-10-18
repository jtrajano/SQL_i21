CREATE VIEW [dbo].[vyuEMETExportCustomerTaxExemption]
	AS 

SELECT DISTINCT 
	CustomerNumber,
	ItemNumber,
	state =Substring(G.strTaxGroup, 1, 2),	
	Authority1 = G.intTaxGroupId,
	Authority2,
	FETCharge,
	SETCharge,
	SSTCharge,
	Locale1Charge,
	Locale2Charge,
	Locale3Charge,
	Locale4Charge,
	Locale5Charge,
	Locale6Charge
	
	FROM	
(
SELECT 
	CustomerNumber = B.strCustomerNumber,
	ItemNumber = C.strItemNo,	
	--state = 'test',
	--Authority1 = E.intTaxGroupId,
	Authority2 = '',
	FETCharge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'FET'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	[SETCharge] = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'SET'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	SSTCharge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'SST'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale1Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC1'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale2Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC2'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale3Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC3'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale4Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC4'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale5Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC5'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),

	Locale6Charge = ISNULL((SELECT TOP 1 'Y'  from tblICCategory sic1 
				JOIN tblICCategoryTax sict1
					ON sic1.intCategoryId = sict1.intCategoryId
				JOIN tblSMTaxCode sst1
					ON sst1.intTaxClassId = sict1.intTaxClassId
				JOIN tblETExportTaxCodeMapping sem1
					ON sem1.intTaxCodeId = sst1.intTaxCodeId			
						AND sem1.strTaxCodeReference = 'LC6'
			WHERE sic1.intCategoryId = A.intCategoryId  ) , 'N'),
	
	intTaxGroupId = isnull(D.intTaxGroupId, E.intTaxGroupId)
	FROM 
		tblARCustomerTaxingTaxException A
			JOIN tblARCustomer B
				ON A.intEntityCustomerId = B.intEntityId
			JOIN tblICItem C
				ON A.intItemId = C.intItemId
			JOIN tblEMEntityLocation D
				ON A.intEntityCustomerId = D.intEntityId 
			LEFT JOIN tblSMCompanyLocation E
				on D.intWarehouseId = E.intCompanyLocationId			
	WHERE A.intItemId in (select intItemId from tblETExportFilterItem) or A.intCategoryId in (select intCategoryId from tblETExportFilterCategory )
) A 
LEFT JOIN tblSMTaxGroup G
			on A.intTaxGroupId = G.intTaxGroupId