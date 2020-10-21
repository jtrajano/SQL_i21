CREATE VIEW [dbo].[vyuAROutboundTaxReport]
AS
SELECT TD.intInvoiceId
     , TD.intEntityCustomerId
     , TD.intCompanyLocationId
     , TD.intEntitySalespersonId
     , TD.intInvoiceDetailId
     , TD.intItemId
     , TD.strItemDescription
     , TD.dblQtyShipped
     , TD.dblPrice
     , TD.dblTotalTax
     , TD.dblTotal
     , intTaxGroupId				= ISNULL(TD.intTaxGroupId, RT.intTaxGroupId)
     , SMTG.strTaxGroup
     , RT.intTaxCodeId
     , RT.strTaxCode
     , RT.strState
     , RT.intTaxClassId
     , RT.strTaxClass
     , RT.intTaxReportTypeId
     , RT.strType
     , RT.ysnTaxExempt
     , RT.ysnInvalidSetup
     , RT.ysnManualTaxExempt
     , dblCheckoffTax				= RT.dblCheckoffTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblCitySalesTax				= RT.dblCitySalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblCityExciseTax				= RT.dblCityExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblCountySalesTax			= RT.dblCountySalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblCountyExciseTax			= RT.dblCountyExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblFederalExciseTax			= RT.dblFederalExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblFederalLustTax			= RT.dblFederalLustTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblFederalOilSpillTax		= RT.dblFederalOilSpillTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblFederalOtherTax			= RT.dblFederalOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblLocalOtherTax				= RT.dblLocalOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblPrepaidSalesTax			= RT.dblPrepaidSalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblStateExciseTax			= RT.dblStateExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblStateOtherTax				= RT.dblStateOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblStateSalesTax				= RT.dblStateSalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblTonnageTax				= RT.dblTonnageTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnCheckoffTax			= RT.dblSSTOnCheckoffTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnCitySalesTax			= RT.dblSSTOnCitySalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnCityExciseTax		= RT.dblSSTOnCityExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnCountySalesTax		= RT.dblSSTOnCountySalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnCountyExciseTax		= RT.dblSSTOnCountyExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnFederalExciseTax		= RT.dblSSTOnFederalExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnFederalLustTax		= RT.dblSSTOnFederalLustTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnFederalOilSpillTax	= RT.dblSSTOnFederalOilSpillTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnFederalOtherTax		= RT.dblSSTOnFederalOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnLocalOtherTax		= RT.dblSSTOnLocalOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnPrepaidSalesTax		= RT.dblSSTOnPrepaidSalesTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnStateExciseTax		= RT.dblSSTOnStateExciseTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnStateOtherTax		= RT.dblSSTOnStateOtherTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
     , dblSSTOnTonnageTax			= RT.dblSSTOnTonnageTax * [dbo].[fnARGetInvoiceAmountMultiplier](TD.strTransactionType)
  FROM (
       SELECT ARI.intInvoiceId
            , ARI.intEntityCustomerId
            , ARI.intCompanyLocationId
            , ARI.intEntitySalespersonId
            , ARID.intInvoiceDetailId
            , ARID.intItemId
            , ARID.strItemDescription
            , ARID.dblQtyShipped
            , ARID.dblPrice
            , ARID.dblTotalTax
            , ARID.dblTotal
            , ARID.intTaxGroupId
            , ARI.strTransactionType
		FROM tblARInvoiceDetail ARID
        INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
								   AND ARI.ysnPosted = CAST(1 AS BIT)       
        ) TD
        INNER JOIN (
                SELECT ARIDT.intInvoiceDetailId
                    , ARIDT.intTaxGroupId
                    , ARIDT.ysnTaxExempt
                    , ARIDT.ysnInvalidSetup
                    , (CASE WHEN ARIDT.ysnTaxAdjusted = CAST(1 AS BIT) AND ARIDT.dblAdjustedTax = 0.000000 AND ARIDT.dblTax <> 0.000000 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END) ysnManualTaxExempt
                    , STC.intTaxCodeId
                    , STC.strTaxCode
                    , STC.strState
                    , SMTC.intTaxClassId
                    , SMTC.strTaxClass
                    , SMTRT.intTaxReportTypeId
                    , SMTRT.strType
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblCheckoffTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblCitySalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblCityExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblCountySalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblCountyExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalLustTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalOilSpillTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblLocalOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblPrepaidSalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 14 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateSalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END) AS dblTonnageTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnCheckoffTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnCitySalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnCityExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnCountySalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnCountyExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnFederalExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnFederalLustTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnFederalOilSpillTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnFederalOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnLocalOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnPrepaidSalesTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnStateExciseTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnStateOtherTax
                    , (CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN 0.000000 ELSE 0.000000 END) AS dblSSTOnTonnageTax
				FROM tblARInvoiceDetailTax ARIDT
                INNER JOIN tblSMTaxCode STC ON ARIDT.intTaxCodeId = STC.intTaxCodeId
                INNER JOIN tblSMTaxClass SMTC ON ARIDT.intTaxClassId = SMTC.intTaxClassId
                INNER JOIN tblSMTaxReportType SMTRT ON SMTC.intTaxReportTypeId = SMTRT.intTaxReportTypeId
        ) RT ON TD.intInvoiceDetailId = RT.intInvoiceDetailId
    LEFT OUTER JOIN tblSMTaxGroup SMTG ON ISNULL(TD.intTaxGroupId, RT.intTaxGroupId) = SMTG.intTaxGroupId
