CREATE PROCEDURE [dbo].[uspARInvoiceProductRecapReport]
	  @dtmDateFrom		DATETIME = NULL
	, @dtmDateTo		DATETIME = NULL
	, @intEntityUserId	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @dtmDateFrom IS NULL
    SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF @dtmDateTo IS NULL
    SET @dtmDateTo = GETDATE()

DELETE FROM tblARProductRecapStagingTable WHERE ISNULL(intEntityUserId, 0) = 0 OR intEntityUserId = @intEntityUserId
INSERT INTO tblARProductRecapStagingTable (
	  intEntityCustomerId
	, intEntityUserId
	, strCustomerName
	, intCompanyLocationId
	, strLocationNumber
	, strLocationName
	, intItemId
	, intTaxCodeId
	, strProductNo
	, intSortNo	
	, strDescription
	, strTransactionType
	, strType
	, dblUnits
	, dblAmounts
)	
SELECT DISTINCT
	  intEntityCustomerId			= ABC.intEntityCustomerId
	, intEntityUserId				= @intEntityUserId
	, strCustomerName				= ARC.strCustomerName
	, intCompanyLocationId			= ABC.intCompanyLocationId
	, strLocationNumber				= [LOCATION].strLocationNumber
	, strLocationName				= [LOCATION].strLocationName
	, intItemId						= ABC.intItemId
	, intTaxCodeId					= ABC.intTaxCodeId
	, strProductNo					= CASE WHEN ABC.strTransactionType = 'Items' THEN ABC.strItemNo  
										--    WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 'RCV' 
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN ABC.strTaxCode
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 'Service Charges'
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 'DEBIT MEMO'
									  END
	, intSortNo						= CASE WHEN ABC.strTransactionType = 'Items' THEN 4
										--    WHEN ABC.strTransactionType IN ('Payments','Customer Prepayment','Overpayment') THEN 1
										   WHEN ABC.strTransactionType = 'TaxCodes' THEN 5
										   WHEN ABC.strTransactionType = 'Service Charge' THEN 2
										   WHEN ABC.strTransactionType = 'Debit Memo' THEN 3
									  END
	, strDescription				= ABC.strDescription
	, strTransactionType			= ABC.strTransactionType
	, strType						= ABC.strType
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
			  , intCompanyLocationId	=	ARI.intCompanyLocationId
			  , strTransactionType		=	'Items'
			  , strType					=	NULL
			  , dblInvoiceTotal			=	SUM(dblLineItemTotal)
			  , intItemId				=	ARID.intItemId
			  , strItemDescription		=	ARID.strItemDescription
			  , dblQtyShipped			=	SUM(ARID.dblQtyShipped)
			  , intTaxCodeId			=	NULL
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		CROSS APPLY (
			SELECT intInvoiceId
				, intInvoiceDetailId
				, intItemId
				, strItemDescription	= CASE WHEN ISNULL(strItemDescription,'') = '' THEN 'MISC' ELSE strItemDescription END
				, dblLineItemTotal		= (dblQtyShipped * dblPrice) * dbo.fnARGetInvoiceAmountMultiplier(ARI.strTransactionType)
				, dblQtyShipped			= dblQtyShipped  * dbo.fnARGetInvoiceAmountMultiplier(ARI.strTransactionType)
				, intTaxGroupId
			FROM dbo.tblARInvoiceDetail ID
			WHERE ID.intInvoiceId = ARI.intInvoiceId
		) ARID
		WHERE ARI.ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
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
		     , dblInvoiceTotal			= SUM(dbo.fnARGetInvoiceAmountMultiplier(ARI.strTransactionType) * (ARIDT.dblAdjustedTax)) --SUM(ARIDT.dblAdjustedTax)
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
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
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
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
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
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo		
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId
		   , ARI.strTransactionType	
		
	UNION ALL

	--- Payments
	SELECT intEntityCustomerId		= ARI.intEntityCustomerId
		 , intCompanyLocationId		= ARI.intCompanyLocationId
		 , strTransactionType		= 'Payments'
		 , strType					= NULL
		 , dblInvoiceTotal			= SUM(dbo.fnARGetInvoiceAmountMultiplier(ARI.strTransactionType) * (ARI.dblPayment)) --SUM(ARI.dblPayment)
		 , intItemId				= NULL
		 , strImportFormat			= NULL
		 , strDescription			= 'RCV' + ' - ' + 'Payments'
		 , dblQtyShipped			= 0.000000
		 , intTaxCodeId				= NULL
		 , strTaxCode				= NULL
	FROM dbo.tblARInvoice ARI WITH (NOLOCK)
	WHERE ARI.ysnPosted = 1
	  AND ARI.strTransactionType NOT IN ('Overpayment', 'Customer Prepayment', 'Debit Memo')
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
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
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), ARI.dtmDate))) BETWEEN @dtmDateFrom AND @dtmDateTo			
	GROUP BY ARI.intEntityCustomerId
		   , ARI.intCompanyLocationId
		   , ARI.strType
		
) ABC
INNER JOIN (
	SELECT DISTINCT 
		  intEntityCustomerId
		, strCustomerName
	FROM dbo.tblARCustomerActivityStagingTable WITH (NOLOCK)
	WHERE intEntityUserId = @intEntityUserId
) ARC ON ABC.intEntityCustomerId = ARC.intEntityCustomerId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationNumber
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON ABC.intCompanyLocationId = LOCATION.intCompanyLocationId
WHERE ISNULL(ABC.dblQtyShipped, 0) <> 0 OR ISNULL(ABC.dblInvoiceTotal, 0) <> 0 AND ABC.strTransactionType NOT IN ('Payments','Customer Prepayment','Overpayment')
ORDER BY ABC.intCompanyLocationId, intSortNo

