CREATE VIEW dbo.[vyuARGetPrepaidsAndCreditMemos]
AS
SELECT intPrepaidAndCreditId				= PC.intPrepaidAndCreditId
	 , intInvoiceId							= PC.intInvoiceId
	 , intInvoiceDetailId					= PC.intInvoiceDetailId
	 , intPrepaymentId						= PC.intPrepaymentId
	 , intPrepaymentDetailId				= PC.intPrepaymentDetailId
	 , dblPostedAmount						= ISNULL(PC.dblPostedAmount, 0)
	 , dblBasePostedAmount					= ISNULL(PC.dblBasePostedAmount, 0)
	 , dblPostedDetailAmount				= ISNULL(PC.dblPostedDetailAmount, 0)
	 , dblBasePostedDetailAmount			= ISNULL(PC.dblBasePostedDetailAmount, 0)
	 , dblAppliedInvoiceAmount				= ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblBaseAppliedInvoiceAmount			= ISNULL(PC.dblBaseAppliedInvoiceAmount, 0)
	 , dblAppliedInvoiceDetailAmount		= ISNULL(PC.dblAppliedInvoiceDetailAmount, 0)
	 , dblBaseAppliedInvoiceDetailAmount	= ISNULL(PC.dblBaseAppliedInvoiceDetailAmount, 0)
	 , ysnApplied							= ISNULL(PC.ysnApplied, 0)
	 , ysnPosted							= ISNULL(PC.ysnPosted, 0)
	 , intRowNumber							= PC.intRowNumber
	 , intConcurrencyId						= PC.intConcurrencyId
	 , strPrepaymentNumber					= PREPAY.strInvoiceNumber
	 , strPrepayType						= CASE WHEN PREPAYDETAIL.intPrepayTypeId = 1 THEN 'Standard'
												   WHEN PREPAYDETAIL.intPrepayTypeId = 2 THEN 'Unit'
												   WHEN PREPAYDETAIL.intPrepayTypeId = 3 THEN 'Percentage'
											  END
	 , intPrepayTypeId						= PREPAYDETAIL.intPrepayTypeId
	 , ysnRestricted						= ISNULL(PREPAYDETAIL.ysnRestricted, 0)
	 , intContractHeaderId					= PREPAYDETAIL.intContractHeaderId
	 , intContractDetailId					= PREPAYDETAIL.intContractDetailId
	 , intItemContractHeaderId				= PREPAYDETAIL.intItemContractHeaderId
	 , intItemContractDetailId				= PREPAYDETAIL.intItemContractDetailId
	 , intItemCategoryId					= PREPAYDETAIL.intItemCategoryId
	 , intCategoryId						= PREPAYDETAIL.intCategoryId
	 , strContractNumber					= ISNULL(CH.strContractNumber, ICH.strContractNumber)
	 , intContractSeq						= ISNULL(CD.intContractSeq, ICD.intLineNo)
	 , strItemContractNumber				= ICH.strContractNumber
	 , intItemContractSeq					= ICD.intLineNo
	 , intItemId							= PREPAYDETAIL.intItemId
	 , strItemNo							= ITEM.strItemNo
	 , strItemDescription					= PREPAYDETAIL.strItemDescription
     , strCategoryCode						= CAT.strCategoryCode
	 , strCategoryDescription				= CAT.strDescription
	 , dblPrepayRate						= ISNULL(PREPAYDETAIL.dblPrepayRate, 0)
	 , dblLineItemTotal						= ISNULL(PREPAYDETAIL.dblTotal, 0) - ISNULL(TOTALPAID.dblTotalPayment, 0)
	 , dblBaseLineItemTotal					= ISNULL(PREPAYDETAIL.dblBaseTotal, 0) - ISNULL(TOTALPAID.dblBaseTotalPayment, 0)
	 , dblInvoiceTotal						= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblTotal, 0) ELSE ISNULL(PREPAY.dblInvoiceTotal, 0) END
	 , dblBaseInvoiceTotal					= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblTotal, 0) ELSE ISNULL(PREPAY.dblBaseInvoiceTotal, 0) END
	 , dblPrepaidAmount						= CASE WHEN PREPAYDETAIL.intPrepayTypeId = 1 THEN PREPAY.dblInvoiceTotal
												   WHEN PREPAYDETAIL.intPrepayTypeId = 2 THEN PREPAYDETAIL.dblTotal
												   WHEN PREPAYDETAIL.intPrepayTypeId = 3 THEN PREPAYDETAIL.dblTotal * (ISNULL(PREPAYDETAIL.dblPrepayRate, 0) / 100)
												   ELSE 0.000000
											  END
	 , dblBasePrepaidAmount					= CASE WHEN PREPAYDETAIL.intPrepayTypeId = 1 THEN PREPAY.dblBaseInvoiceTotal
												   WHEN PREPAYDETAIL.intPrepayTypeId = 2 THEN PREPAYDETAIL.dblBaseTotal
												   WHEN PREPAYDETAIL.intPrepayTypeId = 3 THEN PREPAYDETAIL.dblBaseTotal * (ISNULL(PREPAYDETAIL.dblPrepayRate, 0) / 100)
												   ELSE 0.000000
											  END
	 , dblInvoiceBalance					= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblTotal, 0) ELSE ISNULL(PREPAY.dblAmountDue, 0) END
	 , dblBaseInvoiceBalance				= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblBaseTotal, 0) ELSE ISNULL(PREPAY.dblBaseAmountDue, 0) END
	 , dblInvoiceDetailBalance				= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblTotal, 0) ELSE ISNULL(PREPAY.dblAmountDue, 0) END
	 , dblBaseInvoiceDetailBalance			= CASE WHEN ISNULL(PREPAYDETAIL.ysnRestricted, 0) = 1 THEN ISNULL(PREPAYDETAIL.dblBaseTotal, 0) ELSE ISNULL(PREPAY.dblBaseAmountDue, 0) END
FROM tblARPrepaidAndCredit PC
LEFT JOIN tblARInvoice PREPAY ON PC.intPrepaymentId = PREPAY.intInvoiceId
LEFT JOIN tblARInvoiceDetail PREPAYDETAIL ON PC.intPrepaymentId = PREPAYDETAIL.intInvoiceId
									   AND ((PC.intPrepaymentDetailId IS NOT NULL AND PC.intPrepaymentDetailId = PREPAYDETAIL.intInvoiceDetailId) OR PC.intPrepaymentDetailId IS NULL)
LEFT JOIN tblCTContractHeader CH ON PREPAYDETAIL.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTContractDetail CD ON PREPAYDETAIL.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTItemContractHeader ICH ON PREPAYDETAIL.intItemContractHeaderId = ICH.intItemContractHeaderId
LEFT JOIN tblCTItemContractDetail ICD ON PREPAYDETAIL.intItemContractDetailId = ICD.intItemContractDetailId
LEFT JOIN tblICCategory CAT ON PREPAYDETAIL.intCategoryId = CAT.intCategoryId
LEFT JOIN tblICItem ITEM ON PREPAYDETAIL.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intPrepaymentId
		 , dblTotalPayment = SUM(dblAppliedInvoiceDetailAmount) 
		 , dblBaseTotalPayment = SUM(dblBaseAppliedInvoiceDetailAmount)
	FROM tblARPrepaidAndCredit 
	WHERE ysnApplied = 1
	GROUP BY intPrepaymentId
) TOTALPAID ON PC.intPrepaymentId = TOTALPAID.intPrepaymentId