CREATE PROCEDURE [dbo].[uspARInvoiceProductRecapReport]
	@strCustomerName NVARCHAR(100)	
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT DISTINCT
	ABC.intEntityCustomerId,
	ARC.strName,
	ABC.intCompanyLocationId,
	SMCL.strLocationNumber,
	ABC.intItemId,
	ABC.intTaxCodeId,
	strProductNo					= CASE WHEN ABC.strTransactionType = 'Items' THEN ABC.strItemNo  
										   WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 'RCV' 
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN ABC.strTaxCode
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 'Service Charges'
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 'DEBIT MEMO'
									  END,
	intSortNo					= CASE WHEN ABC.strTransactionType = 'Items' THEN 4
										   WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 1
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN 5
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 2
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 3
									  END,
	ABC.strDescription,	
	ABC.strTransactionType,
	ABC.strType,
	dblUnits						= ABC.dblQtyShipped,
	dblAmounts						= ABC.dblInvoiceTotal
FROM 
(
	--- Items
	SELECT 
		Items.intEntityCustomerId,
		Items.intCompanyLocationId,
		Items.strTransactionType,
		Items.strType,
		Items.dblInvoiceTotal,
		Items.intItemId,
		strItemNo						= ISNULL(ICI.strItemNo, 'MISC'),
		strDescription					= ISNULL(ICI.strDescription, Items.strItemDescription),
		Items.dblQtyShipped,
		Items.intTaxCodeId,
		strTaxCode						= NULL
	FROM 
	(
		SELECT 
			intEntityCustomerId			=	ARI.intEntityCustomerId,			
			intCompanyLocationId		=	ARI.intCompanyLocationId,
			strTransactionType			=	'Items',
			strType						=	NULL,
			dblInvoiceTotal				=	0.000000,
			intItemId					=	ARID.intItemId,	
			strItemDescription			=	ARID.strItemDescription,
			dblQtyShipped				=	SUM(ARID.dblQtyShipped),
			intTaxCodeId				=	NULL		

		FROM 
			tblARInvoice ARI
		INNER JOIN 
			(SELECT 
				intInvoiceId,
				intInvoiceDetailId,
				intItemId,	
				strItemDescription		= CASE WHEN ISNULL(strItemDescription,'') = '' THEN 'MISC' ELSE strItemDescription END,		
				dblQtyShipped,
				intTaxGroupId	
			 FROM 
				tblARInvoiceDetail WHERE intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE intEntityCustomerId = 8)) ARID ON ARI.intInvoiceId = ARID.intInvoiceId	
		GROUP BY		 
			ARI.intEntityCustomerId,
			ARI.intCompanyLocationId,
			ARID.intItemId,
			ARID.strItemDescription
	) Items
	LEFT JOIN 
	(SELECT
		intItemId,
		strItemNo,
		strDescription					
	 FROM
		tblICItem) ICI ON Items.intItemId = ICI.intItemId
	
	UNION ALL

	--- Tax Codes 
	SELECT 
		Taxes.intEntityCustomerId,
		Taxes.intCompanyLocationId,
		Taxes.strTransactionType,
		Taxes.strType,
		Taxes.dblInvoiceTotal,
		Taxes.intItemId,
		strItemNo						= NULL,
		strDescription					= SMTC.strDescription,
		Taxes.dblQtyShipped,
		Taxes.intTaxCodeId,
		strTaxCode						= SMTC.strTaxCode
	FROM 
	(
		SELECT 
		intEntityCustomerId			=	ARI.intEntityCustomerId,		
		intCompanyLocationId		=	ARI.intCompanyLocationId,
		strTransactionType			=	'TaxCodes',
		strType						=	NULL,
		dblInvoiceTotal				=	SUM(ARIDT.dblAdjustedTax),
		intItemId					=	NULL,	
		dblQtyShipped				=	0.000000,
		intTaxCodeId				=	ARIDT.intTaxCodeId		
	FROM 
		tblARInvoice ARI
	INNER JOIN 
		(SELECT 
			intInvoiceId,
			intInvoiceDetailId,
			intItemId,
			dblQtyShipped,
			intTaxGroupId	
		 FROM 
			tblARInvoiceDetail ) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
	INNER JOIN 
		(SELECT 
			ART.intInvoiceDetailId,
			ART.intTaxGroupId,
			ART.intTaxCodeId,
			SMTC.strTaxCode,
			ART.dblAdjustedTax
		 FROM
			tblARInvoiceDetailTax ART
		 INNER JOIN 
			(SELECT 
				intTaxCodeId, 
				strTaxCode,
				strDescription 
			FROM 
				tblSMTaxCode) SMTC ON ART.intTaxCodeId = SMTC.intTaxCodeId
		) ARIDT ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId AND ARID.intTaxGroupId = ARIDT.intTaxGroupId
	WHERE 
		ARI.strType NOT IN ('Service Charge')
		AND ARI.strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Debit Memo')
		AND ARIDT.intTaxCodeId IS NOT NULL		
	GROUP BY		
		ARI.intEntityCustomerId,
		ARI.intCompanyLocationId,
		ARIDT.intTaxCodeId
	) Taxes
	LEFT JOIN 
		(SELECT
			intTaxCodeId,
			strTaxCode,
			strDescription
		 FROM
			tblSMTaxCode) SMTC ON Taxes.intTaxCodeId = SMTC.intTaxCodeId

	UNION ALL

	--- Debit Memo
	SELECT 
		intEntityCustomerId			=	ARI.intEntityCustomerId,		
		intCompanyLocationId		=	ARI.intCompanyLocationId,
		strTransactionType			=	ARI.strTransactionType,
		strType						=	NULL,
		dblInvoiceTotal				=	SUM(ARI.dblInvoiceSubtotal),
		intItemId					=	NULL,	
		strItemNo					=	NULL,
		strDescription				=	'Debit Memos',
		dblQtyShipped				=	0.000000,
		intTaxCodeId				=	NULL,
		strTaxCode					=	NULL
	FROM 
		tblARInvoice ARI
	INNER JOIN 
		(SELECT 
			intInvoiceId,
			intInvoiceDetailId,
			intItemId,
			dblQtyShipped,
			intTaxGroupId	
		 FROM 
			tblARInvoiceDetail ) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
	LEFT JOIN 
		(SELECT 
			intInvoiceDetailId,
			intTaxGroupId,
			intTaxCodeId,
			dblAdjustedTax
		 FROM
			tblARInvoiceDetailTax
		) ARIDT ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId AND ARID.intTaxGroupId = ARIDT.intTaxGroupId
	WHERE 
		ARI.strType NOT IN ('Service Charge')
		AND ARI.strTransactionType IN ('Debit Memo')		
	GROUP BY		
		ARI.intEntityCustomerId,
		ARI.intCompanyLocationId,
		ARI.strTransactionType		
	 
	UNION ALL

	--- Overpayment,  Customer Prepayment
	SELECT 
		intEntityCustomerId			=	ARI.intEntityCustomerId,		
		intCompanyLocationId		=	ARI.intCompanyLocationId,
		strTransactionType			=	ARI.strTransactionType,
		strType						=	NULL,
		dblInvoiceTotal				=	SUM(ARI.dblInvoiceSubtotal),
		intItemId					=	NULL,	
		strItemNo					=	NULL,		
		strDescription				=	'RCV' + ' - ' + ARI.strTransactionType,
		dblQtyShipped				=	0.000000,
		intTaxCodeId				=	NULL,
		strTaxCode					=	NULL
	FROM 
		tblARInvoice ARI
	WHERE 
		ARI.strTransactionType IN ('Overpayment', 'Customer Prepayment')		
	GROUP BY		
		ARI.intEntityCustomerId,
		ARI.intCompanyLocationId,
		ARI.strTransactionType	
		
	UNION ALL

	--- Payments
	SELECT 
		intEntityCustomerId			=	ARI.intEntityCustomerId,		
		intCompanyLocationId		=	ARI.intCompanyLocationId,
		strTransactionType			=	'Payments',
		strType						=	NULL,
		dblInvoiceTotal				=	SUM(ARI.dblPayment),
		intItemId					=	NULL,	
		strImportFormat				=	NULL,
		strDescription				=	'RCV' + ' - ' + 'Payments',
		dblQtyShipped				=	0.000000,
		intTaxCodeId				=	NULL,
		strTaxCode					=	NULL
	FROM 
		tblARInvoice ARI
	WHERE 
		ARI.strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Debit Memo')				
	GROUP BY		
		ARI.intEntityCustomerId,
		ARI.intCompanyLocationId

	UNION ALL

	--- Service Charges
	SELECT 
		intEntityCustomerId			=	ARI.intEntityCustomerId,		
		intCompanyLocationId		=	ARI.intCompanyLocationId,
		strTransactionType			=	ARI.strType,
		strType						=	ARI.strType,
		dblInvoiceTotal				=	SUM(ARI.dblInvoiceSubtotal),
		intItemId					=	NULL,	
		strItemNo					=	NULL,
		strDescription				=	ARI.strType,
		dblQtyShipped				=	0.000000,
		intTaxCodeId				=	NULL,
		strTaxCode					=	NULL
	FROM 
		tblARInvoice ARI
	WHERE 
		ARI.strType IN ('Service Charge')			
	GROUP BY		
		ARI.intEntityCustomerId,
		ARI.intCompanyLocationId,		
		ARI.strType
		
) ABC
INNER JOIN
	(SELECT 
		ARC.intEntityId,
		EME.strName
	 FROM
		tblARCustomer ARC
	 INNER JOIN
		(SELECT
			intEntityId,
			strName
		 FROM
			tblEMEntity
	 WHERE 
		(@strCustomerName IS NULL OR strName LIKE '%'+@strCustomerName+'%')) EME ON ARC.intEntityId = EME.intEntityId) ARC ON ABC.intEntityCustomerId = ARC.intEntityId
LEFT JOIN
	(SELECT 
		intCompanyLocationId,
		strLocationNumber,
		strLocationName
	 FROM 
		tblSMCompanyLocation) SMCL ON ABC.intCompanyLocationId = SMCL.intCompanyLocationId
ORDER BY 
	ABC.intCompanyLocationId, intSortNo