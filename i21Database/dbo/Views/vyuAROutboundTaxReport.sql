CREATE VIEW [dbo].[vyuAROutboundTaxReport]
AS

SELECT
       TD.intInvoiceId
     , TD.strInvoiceNumber
     , TD.intEntityCustomerId
     , TD.intCompanyLocationId
     , TD.intEntitySalespersonId
     , TD.dtmDate
     , TD.intInvoiceDetailId
     , TD.intItemId
     , TD.strItemDescription
     , TD.dblQtyShipped
     , TD.dblPrice
     , TD.dblTotalTax
     , TD.dblTotal
     , ISNULL(TD.intTaxGroupId, RT.intTaxGroupId) intTaxGroupId
     , RT.dblCheckoffTax
     , RT.dblCitySalesTax
     , RT.dblCityExciseTax
     , RT.dblCountySalesTax
     , RT.dblCountyExciseTax
     , RT.dblFederalExciseTax
     , RT.dblFederalLustTax
     , RT.dblFederalOilSpillTax
     , RT.dblFederalOtherTax
     , RT.dblLocalOtherTax
     , RT.dblPrepaidSalesTax
     , RT.dblStateExciseTax
     , RT.dblStateOtherTax
     , RT.dblStateSalesTax
     , RT.dblTonnageTax
     , RT.dblSSTOnCheckoffTax
     , RT.dblSSTOnCitySalesTax
     , RT.dblSSTOnCityExciseTax
     , RT.dblSSTOnCountySalesTax
     , RT.dblSSTOnCountyExciseTax
     , RT.dblSSTOnFederalExciseTax
     , RT.dblSSTOnFederalLustTax
     , RT.dblSSTOnFederalOilSpillTax
     , RT.dblSSTOnFederalOtherTax
     , RT.dblSSTOnLocalOtherTax
     , RT.dblSSTOnPrepaidSalesTax
     , RT.dblSSTOnStateExciseTax
     , RT.dblSSTOnStateOtherTax
     , RT.dblSSTOnTonnageTax
  FROM (
       SELECT
              ARI.intInvoiceId
            , ARI.strInvoiceNumber
            , ARI.intEntityCustomerId
            , ARI.intCompanyLocationId
            , ARI.intEntitySalespersonId
            , ARI.dtmDate
            , ARID.intInvoiceDetailId
            , ARID.intItemId
            , ARID.strItemDescription
            , ARID.dblQtyShipped
            , ARID.dblPrice
            , ARID.dblTotalTax
            , ARID.dblTotal
            , ARID.intTaxGroupId
         FROM tblARInvoiceDetail ARID
              INNER JOIN tblARInvoice ARI
                         ON ARID.intInvoiceId = ARI.intInvoiceId
						AND ARI.ysnPosted = CAST(1 AS BIT)       
        ) TD
          INNER JOIN (
                     SELECT
                            ARIDT.intInvoiceDetailId
                          , ARIDT.intTaxGroupId
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCheckoffTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCitySalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCityExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCountySalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblCountyExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalLustTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalOilSpillTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblFederalOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblLocalOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblPrepaidSalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 14 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblStateSalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN ARIDT.dblAdjustedTax ELSE 0.000000 END)) AS dblTonnageTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCheckoffTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCitySalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCityExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCountySalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnCountyExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalLustTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalOilSpillTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnFederalOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnLocalOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnPrepaidSalesTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnStateExciseTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnStateOtherTax
                          , SUM((CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN 0.000000 ELSE 0.000000 END)) AS dblSSTOnTonnageTax
                       FROM tblARInvoiceDetailTax ARIDT
                            INNER JOIN tblSMTaxClass SMTC
                                       ON ARIDT.intTaxClassId = SMTC.intTaxClassId
                            INNER JOIN tblSMTaxReportType SMTRT
                                       ON SMTC.intTaxReportTypeId = SMTRT.intTaxReportTypeId
                      GROUP BY
                            ARIDT.intInvoiceDetailId
                          , ARIDT.intTaxGroupId
                          , SMTRT.intTaxReportTypeId
                          , SMTRT.strType
                     ) RT
	                 ON TD.intInvoiceDetailId = RT.intInvoiceDetailId
