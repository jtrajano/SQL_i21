CREATE VIEW [dbo].[vyuAPInboundTaxReport]
AS

SELECT
       TD.intBillId
     , TD.intEntityVendorId
     , TD.intLocationId
     , TD.intOrderById
     , TD.intBillDetailId
     , TD.intItemId
     , TD.strMiscDescription
     , TD.dblQtyReceived
     , TD.dblCost
     , TD.dblTax
     , TD.dblTotal
     , ISNULL(TD.intTaxGroupId, RT.intTaxGroupId) intTaxGroupId
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
               APB.intBillId
            ,  APB.intEntityVendorId
            , APBD.intLocationId
            ,  APB.intOrderById
            , APBD.intBillDetailId
            , APBD.intItemId
            , APBD.strMiscDescription
            , APBD.dblQtyReceived
            , APBD.dblCost
            , APBD.dblTax
            , APBD.dblTotal
            , APBD.intTaxGroupId
         FROM tblAPBillDetail APBD
              INNER JOIN tblAPBill APB
                         ON APBD.intBillId = APB.intBillId
						AND APB.ysnPosted = CAST(1 AS BIT)       
        ) TD
          INNER JOIN (
                     SELECT
                            APBDT.intBillDetailId
                          , APBDT.intTaxGroupId
                          , APBDT.ysnTaxExempt
                          , 0 as ysnInvalidSetup
                          , (CASE WHEN APBDT.ysnTaxAdjusted = CAST(1 AS BIT) AND APBDT.dblAdjustedTax = 0.000000 AND APBDT.dblTax <> 0.000000 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END) ysnManualTaxExempt
                          , STC.intTaxCodeId
                          , STC.strTaxCode
                          , STC.strState
                          , SMTC.intTaxClassId
                          , SMTC.strTaxClass
                          , SMTRT.intTaxReportTypeId
                          , SMTRT.strType
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 1 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblCheckoffTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 2 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblCitySalesTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 3 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblCityExciseTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 4 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblCountySalesTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 5 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblCountyExciseTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 6 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalExciseTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 7 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalLustTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 8 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalOilSpillTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 9 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblFederalOtherTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 10 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblLocalOtherTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 11 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblPrepaidSalesTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 12 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateExciseTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 13 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateOtherTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 14 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblStateSalesTax
                          , (CASE WHEN SMTRT.intTaxReportTypeId = 15 THEN APBDT.dblAdjustedTax ELSE 0.000000 END) AS dblTonnageTax
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
                       FROM tblAPBillDetailTax APBDT
                            LEFT JOIN tblSMTaxCode STC
                                       ON APBDT.intTaxCodeId = STC.intTaxCodeId
                            LEFT JOIN tblSMTaxClass SMTC
                                       ON APBDT.intTaxClassId = SMTC.intTaxClassId
                            LEFT JOIN tblSMTaxReportType SMTRT
                                       ON SMTC.intTaxReportTypeId = SMTRT.intTaxReportTypeId
                     ) RT
	                 ON TD.intBillDetailId = RT.intBillDetailId
          LEFT OUTER JOIN tblSMTaxGroup SMTG
                          ON ISNULL(TD.intTaxGroupId, RT.intTaxGroupId) = SMTG.intTaxGroupId


GO


