CREATE PROCEDURE [dbo].[uspARInvoiceProductRecapReport]
	@strCustomerName NVARCHAR(MAX)	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)

INSERT INTO @tblCustomers
SELECT C.intEntityId 
	 , C.strCustomerNumber
	 , EC.strName
	 , C.dblCreditLimit
FROM tblARCustomer C WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
	WHERE (@strCustomerName IS NULL OR strName LIKE '%'+ @strCustomerName +'%')
) EC ON C.intEntityId = EC.intEntityId
WHERE ysnActive = 1


SELECT DISTINCT
	  ABC.intEntityCustomerId
	, ARC.strCustomerName
	, ABC.intCompanyLocationId
	, LOCATION.strLocationNumber
	, ABC.intItemId
	, ABC.intTaxCodeId
	, strProductNo					= CASE WHEN ABC.strTransactionType = 'Items' THEN ABC.strItemNo  
										   WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 'RCV' 
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN ABC.strTaxCode
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 'Service Charges'
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 'DEBIT MEMO'
									  END
	, intSortNo					= CASE WHEN ABC.strTransactionType = 'Items' THEN 4
										   WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 1
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN 5
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 2
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 3
									  END
	, ABC.strDescription
	, ABC.strTransactionType
	, ABC.strType
	, dblUnits						= ABC.dblQtyShipped
	, dblAmounts					= ABC.dblInvoiceTotal
FROM 
(
	--- Items
	SELECT Items.intEntityCustomerId
		 , Items.intCompanyLocationId
		 , Items.strTransactionType
		 , Items.strType
		 , Items.dblInvoiceTotal
		 , Items.intItemId
		 , strItemNo						= ISNULL(ICI.strItemNo, 'MISC')
		 , strDescription					= ISNULL(ICI.strDescription, Items.strItemDescription)
		 , Items.dblQtyShipped
		 , Items.intTaxCodeId
		 , strTaxCode						= NULL
	FROM (
		SELECT intEntityCustomerId		=	ARI.intEntityCustomerId
			 , intCompanyLocationId		=	ARI.intCompanyLocationId
			 , strTransactionType		=	'Items'
			 , strType					=	NULL
			 , dblInvoiceTotal			=	SUM(ARID.dblQtyShipped) * SUM(ARID.dblPrice)
			 , intItemId				=	ARID.intItemId
			 , strItemDescription		=	ARID.strItemDescription
			 , dblQtyShipped			=	SUM(ARID.dblQtyShipped)
			 , intTaxCodeId				=	NULL
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN (
			SELECT intInvoiceId
				 , intInvoiceDetailId
				 , intItemId
				 , strItemDescription	= CASE WHEN ISNULL(strItemDescription,'') = '' THEN 'MISC' ELSE strItemDescription END
				 , dblQtyShipped
				 , dblPrice
				 , intTaxGroupId
			 FROM dbo.tblARInvoiceDetail 
		) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
		WHERE ARI.ysnPosted = 1
		GROUP BY ARI.intEntityCustomerId
			   , ARI.intCompanyLocationId
			   , ARID.intItemId
			   , ARID.strItemDescription
	) Items
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
			 , strDescription
		FROM dbo.tblICItem WITH (NOLOCK)
	) ICI ON Items.intItemId = ICI.intItemId
	
	UNION ALL

	--- Tax Codes 
	SELECT TAXES.intEntityCustomerId
		 , TAXES.intCompanyLocationId
		 , TAXES.strTransactionType
		 , TAXES.strType
		 , TAXES.dblInvoiceTotal
		 , TAXES.intItemId
		 , strItemNo					= NULL
		 , strDescription				= SMTC.strDescription
		 , TAXES.dblQtyShipped
		 , TAXES.intTaxCodeId
		 , strTaxCode					= SMTC.strTaxCode
	FROM (
		SELECT intEntityCustomerId		= ARI.intEntityCustomerId
			 , intCompanyLocationId		= ARI.intCompanyLocationId
		     , strTransactionType		= 'TaxCodes'
			 , strType					= NULL
		     , dblInvoiceTotal			= SUM(ARIDT.dblAdjustedTax)
			 , intItemId				= NULL
			 , dblQtyShipped			= 0.000000
			 , intTaxCodeId				= ARIDT.intTaxCodeId
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN (
			SELECT intInvoiceId
				 , intInvoiceDetailId
				 , intItemId
				 , dblQtyShipped
				 , intTaxGroupId	
			FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
		INNER JOIN (
			SELECT ART.intInvoiceDetailId
				 , ART.intTaxGroupId
				 , ART.intTaxCodeId
				 , SMTC.strTaxCode
				 , ART.dblAdjustedTax
				 , ART.dblRate
			FROM dbo.tblARInvoiceDetailTax ART WITH (NOLOCK)
			INNER JOIN (
				SELECT intTaxCodeId
					 , strTaxCode
					 , strDescription
				FROM dbo.tblSMTaxCode WITH (NOLOCK)
			) SMTC ON ART.intTaxCodeId = SMTC.intTaxCodeId
		) ARIDT ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId 
			   AND ARID.intTaxGroupId = ARIDT.intTaxGroupId
		WHERE ARI.ysnPosted = 1
		  AND ARI.strType NOT IN ('Service Charge')
		  AND ARI.strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Debit Memo')
		  AND ARIDT.intTaxCodeId IS NOT NULL		
		GROUP BY ARI.intEntityCustomerId
			   , ARI.intCompanyLocationId
			   , ARIDT.intTaxCodeId
	) TAXES
	LEFT JOIN (
		SELECT intTaxCodeId
			 , strTaxCode
			 , strDescription
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) SMTC ON TAXES.intTaxCodeId = SMTC.intTaxCodeId

	UNION ALL

	--- Debit Memo
	SELECT intEntityCustomerId		= ARI.intEntityCustomerId
		 , intCompanyLocationId		= ARI.intCompanyLocationId
		 , strTransactionType		= ARI.strTransactionType
		 , strType					= NULL
		 , dblInvoiceTotal			= SUM(ARI.dblInvoiceSubtotal)
		 , intItemId				= NULL
		 , strItemNo				= NULL
		 , strDescription			= 'Debit Memos'
		 , dblQtyShipped			= 0.000000
		 , intTaxCodeId				= NULL
		 , strTaxCode				= NULL
	FROM dbo.tblARInvoice ARI WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
			 , intInvoiceDetailId
			 , intItemId
			 , dblQtyShipped
			 , intTaxGroupId	
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
	LEFT JOIN (
		SELECT intInvoiceDetailId
			 , intTaxGroupId
			 , intTaxCodeId
			 , dblAdjustedTax
		 FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
	) ARIDT ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId 
		   AND ARID.intTaxGroupId = ARIDT.intTaxGroupId
	WHERE ARI.ysnPosted = 1
	  AND ARI.strType NOT IN ('Service Charge')
	  AND ARI.strTransactionType IN ('Debit Memo')
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId
		   , ARI.strTransactionType
	 
	UNION ALL

	--- Overpayment,  Customer Prepayment
	SELECT intEntityCustomerId		= ARI.intEntityCustomerId		
		 , intCompanyLocationId		= ARI.intCompanyLocationId
		 , strTransactionType		= ARI.strTransactionType
		 , strType					= NULL
		 , dblInvoiceTotal			= SUM(ARI.dblInvoiceSubtotal)
		 , intItemId				= NULL
		 , strItemNo				= NULL		
		 , strDescription			= 'RCV' + ' - ' + ARI.strTransactionType
		 , dblQtyShipped			= 0.000000
		 , intTaxCodeId				= NULL
		 , strTaxCode				= NULL
	FROM dbo.tblARInvoice ARI WITH (NOLOCK)
	WHERE ARI.ysnPosted = 1 
	  AND ARI.strTransactionType IN ('Overpayment', 'Customer Prepayment')		
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId
		   , ARI.strTransactionType	
		
	UNION ALL

	--- Payments
	SELECT intEntityCustomerId		= ARI.intEntityCustomerId
		 , intCompanyLocationId		= ARI.intCompanyLocationId
		 , strTransactionType		= 'Payments'
		 , strType					= NULL
		 , dblInvoiceTotal			= SUM(ARI.dblPayment)
		 , intItemId				= NULL
		 , strImportFormat			= NULL
		 , strDescription			= 'RCV' + ' - ' + 'Payments'
		 , dblQtyShipped			= 0.000000
		 , intTaxCodeId				= NULL
		 , strTaxCode				= NULL
	FROM dbo.tblARInvoice ARI WITH (NOLOCK)
	WHERE ARI.ysnPosted = 1
	  AND ARI.strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Debit Memo')
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId

	UNION ALL

	--- Service Charges
	SELECT intEntityCustomerId		= ARI.intEntityCustomerId
		 , intCompanyLocationId		= ARI.intCompanyLocationId
		 , strTransactionType		= ARI.strType
		 , strType					= ARI.strType
		 , dblInvoiceTotal			= SUM(ARI.dblInvoiceTotal)
		 , intItemId				= NULL
		 , strItemNo				= NULL
		 , strDescription			= ARI.strType
		 , dblQtyShipped			= 0.000000
		 , intTaxCodeId				= NULL
		 , strTaxCode				= NULL
	FROM dbo.tblARInvoice ARI WITH (NOLOCK)
	WHERE ARI.ysnPosted = 1
	  AND ARI.strType IN ('Service Charge')			
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId
		   , ARI.strType
		
) ABC
INNER JOIN @tblCustomers ARC ON ABC.intEntityCustomerId = ARC.intEntityCustomerId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationNumber
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON ABC.intCompanyLocationId = LOCATION.intCompanyLocationId
WHERE ISNULL(ABC.dblQtyShipped, 0) <> 0 OR ISNULL(ABC.dblInvoiceTotal, 0) <> 0
ORDER BY ABC.intCompanyLocationId, intSortNo