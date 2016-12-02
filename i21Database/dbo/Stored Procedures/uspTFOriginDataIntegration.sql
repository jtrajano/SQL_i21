﻿CREATE PROCEDURE [dbo].[uspTFOriginDataIntegration]

@Guid NVARCHAR(150),
@CompanyName NVARCHAR(250),
@System NVARCHAR(100),
@State NVARCHAR(20),
@DateFrom NVARCHAR(80),
@DateTo NVARCHAR(80),
@ImportedCount INT OUTPUT,
@ErrorCount INT OUTPUT

AS

DECLARE @query NVARCHAR(MAX)
TRUNCATE TABLE tblTFIntegrationError

SET @query = 'SELECT DISTINCT CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt) + ''_'' + REPLACE(pxrpt_ord_no, ''   '', '''')  + ''_'' + pxrpt_trans_type + ''_'' + CONVERT(NVARCHAR(50), pxrpt_seq_no) AS strSourceRecordConcatKey, 
				pxrpt_itm_no, (CASE TaxAuthority
  				WHEN ''pxrpt_pur_txc_in_prod_cd'' THEN ''IN''
				WHEN ''pxrpt_sls_txc_in_prod_cd'' THEN ''IN'' 
				END) AS ''TaxAuthority'', ProductCode, 0
				FROM (SELECT * FROM pxrptmst) px UNPIVOT (ProductCode FOR TaxAuthority IN 
				([pxrpt_pur_txc_in_prod_cd],
				[pxrpt_sls_txc_in_prod_cd]))AS unpvt where ProductCode <> '''' 
				AND NOT EXISTS (SELECT * FROM tblTFIntegrationItemProductCode
				WHERE CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt) + ''_'' + REPLACE(pxrpt_ord_no, ''   '', '''')  + ''_'' + pxrpt_trans_type + ''_'' + CONVERT(NVARCHAR(50), pxrpt_seq_no) COLLATE Latin1_General_CI_AS = strSourceRecordConcatKey)
				AND convert(datetime, convert(varchar(20), pxrpt_trans_rev_dt), 112) >= CONVERT(NVARCHAR(20), ''' + @DateFrom + ''')
				AND convert(datetime, convert(varchar(20), pxrpt_trans_rev_dt), 112) <= CONVERT(NVARCHAR(20), ''' + @DateTo + ''')
				AND EXISTS (select * from tblTFProductCode where strProductCode COLLATE Latin1_General_CI_AS = ProductCode)'

INSERT INTO tblTFIntegrationItemProductCode
EXEC (@query)

--START ERROR INTEGRATION--
DECLARE @qPCException NVARCHAR(MAX)


SET @qPCException = 'SELECT * FROM (
					SELECT DISTINCT CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt) + ''_'' + REPLACE(pxrpt_ord_no COLLATE Latin1_General_CI_AS, ''   '', '''')  + ''_'' + pxrpt_trans_type + ''_'' + CONVERT(NVARCHAR(50), pxrpt_seq_no) AS strSourceRecordConcatKey,  
					''Cannot find value Product Code for value in column '' + 
					(CASE ErrorMessage 
						WHEN ''pxrpt_pur_txc_in_prod_cd'' THEN ''pxrpt_pur_txc_in_prod_cd''
						WHEN ''pxrpt_sls_txc_in_prod_cd'' THEN ''pxrpt_sls_txc_in_prod_cd''
						END) AS strErrorMessage,
						Row_number() OVER(PARTITION BY pxrpt_ord_no ORDER BY pxrpt_ord_no) rn
					FROM (SELECT * FROM pxrptmst) px UNPIVOT
						 (ProductCode FOR ErrorMessage IN 
						 ([pxrpt_pur_txc_in_prod_cd], [pxrpt_sls_txc_in_prod_cd]))AS unpvt where ProductCode <> ''''
						 AND NOT EXISTS (SELECT intIntegrationErrorId FROM tblTFIntegrationError
						 WHERE strSourceRecordConcatKey = CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt) + ''_'' + REPLACE(pxrpt_ord_no COLLATE Latin1_General_CI_AS, ''   '', '''')  + ''_'' + pxrpt_trans_type + ''_'' + CONVERT(NVARCHAR(50), pxrpt_seq_no))
						 AND NOT EXISTS (SELECT * FROM tblTFIntegrationItemProductCode
									WHERE (pxrpt_itm_no COLLATE Latin1_General_CI_AS = strItemNumber AND strProductCode COLLATE Latin1_General_CI_AS = ProductCode))
									AND convert(datetime, convert(varchar(20), pxrpt_trans_rev_dt), 112) >= CONVERT(NVARCHAR(20), ''' + @DateFrom + ''')
									AND convert(datetime, convert(varchar(20), pxrpt_trans_rev_dt), 112) <= CONVERT(NVARCHAR(20), ''' + @DateTo + ''')
									AND NOT EXISTS (select * from tblTFProductCode where strProductCode COLLATE Latin1_General_CI_AS = ProductCode)) t
									WHERE rn = 1'
INSERT INTO tblTFIntegrationError
EXEC (@qPCException)
SELECT @ErrorCount = @@ROWCOUNT
--END ERROR INTEGRATION--

INSERT tblTFIntegrationTransaction (strTransactionGuid,
strSourceRecordConcatKey,
dtmTransactionDate
, strTransactionNumber
, strTransactionType
, strTransactionSubNumber
, strSourceSystem
, strItemNumber
, strItemLocation
, strItemDescription
, strItemDyedIndicator
, strCustomerNumber
, strCustomerName
, strCustomerAddress1
, strCustomerAddress2
, strCustomerCity
, strCustomerState
, strCustomerTaxID1
, strCustomerTaxID2
, strCustomerTaxID3
, strCustomerSalesTaxID
, strCustomerAuthorityID1
, strCustomerAuthorityID2
, strCustomerAccountStatusCode
, strCustomerPhone
, strCustomerContact
, strVendorNumber
, strVendorName
, strVendorAddress1
, strVendorAddress2
, strVendorCity
, strVendorState
, strVendorSalesTaxID
, strVendorAuthorityID1
, strVendorAuthorityID2
, strVendorFuelDealerID1
, strVendorFuelDealerID2
, strVendorTaxState
, strVendorTerminalControlNumber
, strVendorPhone
, strCarrierNumber
, strCarrierName
, strCarrierAddress1
, strCarrierCity
, strCarrierState
, strCarrierFEIN
, strCarrierTransportationMode
, strCarrierLicenseNumber1
, strCarrierIFTANumber
, dblTransactionInboundGrossGals
, dblTransactionInboundNetGals
, dblTaxInboundFET
, dblTaxInboundSET
, dblTaxInboundInspectionFee
, dblTaxInboundSST
, dblTaxInboudLocale1
, dblTaxInboudLocale2
, dblTaxInboudLocale3
, dblTaxInboudLocale4
, dblTaxInboudLocale5
, dblTaxInboudLocale6
, dblTaxInboudLocale7
, dblTaxInboudLocale8
, dblTaxInboudLocale9
, dblTaxInboudLocale10
, dblTaxInboudLocale11
, dblTaxInboudLocale12
, strTransactionBillOfLading
, strTransactionFreightIndicator
, strTransactionVendorInvoiceNumber
, strTransactionSalesInvoiceNumber
, dblTransactionOutboundBilledGals
, dblTaxOutboundFET
, dblTaxOutboundSET
, dblTaxOutboundSST
, dblTaxOutboudLocale1
, dblTaxOutboudLocale2
, dblTaxOutboudLocale3
, dblTaxOutboudLocale4
, dblTaxOutboudLocale5
, dblTaxOutboudLocale6
, dblTaxOutboudLocale7
, dblTaxOutboudLocale8
, dblTaxOutboudLocale9
, dblTaxOutboudLocale10
, dblTaxOutboudLocale11
, dblTaxOutboudLocale12
, strTransactionCustomerPONumber
, dblTransactionOutboundGrossGals
, dblTransactionOutboundNetGals
, strTransactionConsignedInventoryIndicator
, dblTransactionOutboundSSTExemptGals
, dblTransactionOutboundSETExemptGals
, strDiversionNumber
, strDiversionOriginalDestinationState
, strCarrierCompanyOwnedIndicator)
  SELECT
    @Guid,
    (CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt) + '_' + REPLACE(pxrpt_ord_no, '   ', '') + '_' + pxrpt_trans_type + '_' + CONVERT(NVARCHAR(20), pxrpt_seq_no)),
    CONVERT(NVARCHAR(30), pxrpt_trans_rev_dt),
    pxrpt_ord_no,
    pxrpt_trans_type,
    pxrpt_seq_no,
    pxrpt_src_sys,
    pxrpt_itm_no,
    pxrpt_itm_loc_no,
    pxrpt_itm_desc,
    pxrpt_itm_dyed_yn,
    pxrpt_cus_no,
    pxrpt_cus_name,
    pxrpt_cus_addr,
    pxrpt_cus_addr2,
    pxrpt_cus_city,
    pxrpt_cus_state,
    pxrpt_cus_tax_id1,
    pxrpt_cus_tax_id2,
    pxrpt_cus_tax_id3,
    pxrpt_cus_sls_tax_id,
    pxrpt_cus_auth_id1,
    pxrpt_cus_auth_id2,
    pxrpt_cus_acct_stat,
    pxrpt_cus_phone,
    pxrpt_cus_contact,
    pxrpt_vnd_no,
    pxrpt_vnd_name,
    pxrpt_vnd_addr1,
    pxrpt_vnd_addr,
    pxrpt_vnd_city,
    pxrpt_vnd_state,
    pxrpt_vnd_sales_tax_id,
    pxrpt_vnd_auth_id1,
    pxrpt_vnd_auth_id2,
    vnd_fuel_dlr_1,
    vnd_fuel_dlr_2,
    pxrpt_vnd_tax_state,
    pxrpt_vnd_terminal_no,
    pxrpt_vnd_phone,
    pxrpt_car_no,
    pxrpt_car_name,
    pxrpt_car_addr,
    pxrpt_car_city,
    pxrpt_car_state,
    pxrpt_car_fed_id,
    pxrpt_car_trans_mode,
    pxrpt_car_trans_lic_no,
    pxrpt_car_ifta_no,
    pxrpt_pur_gross_un,
    pxrpt_pur_net_un,
    pxrpt_pur_fet_amt,
    pxrpt_pur_set_amt,
    pxrpt_pur_if_amt,
    pxrpt_pur_sst_amt,
    pxrpt_pur_lc1_amt,
    pxrpt_pur_lc2_amt,
    pxrpt_pur_lc3_amt,
    pxrpt_pur_lc4_amt,
    pxrpt_pur_lc5_amt,
    pxrpt_pur_lc6_amt,
    pxrpt_pur_lc7_amt,
    pxrpt_pur_lc8_amt,
    pxrpt_pur_lc9_amt,
    pxrpt_pur_lc10_amt,
    pxrpt_pur_lc11_amt,
    pxrpt_pur_lc12_amt,
    pxrpt_pur_lading_no,
    pxrpt_pur_frt_only_un,
    pxrpt_pur_vnd_ivc_no,
    pxrpt_sls_ivc_no,
    pxrpt_sls_trans_gals,
    pxrpt_sls_fet_amt,
    pxrpt_sls_set_amt,
    pxrpt_sls_sst_amt,
    pxrpt_sls_lc1_amt,
    pxrpt_sls_lc2_amt,
    pxrpt_sls_lc3_amt,
    pxrpt_sls_lc4_amt,
    pxrpt_sls_lc5_amt,
    pxrpt_sls_lc6_amt,
    pxrpt_sls_lc7_amt,
    pxrpt_sls_lc8_amt,
    pxrpt_sls_lc9_amt,
    pxrpt_sls_lc10_amt,
    pxrpt_sls_lc11_amt,
    pxrpt_sls_lc12_amt,
    pxrpt_sls_cus_po_no,
    pxrpt_sls_un,
    pxrpt_sls_net_gals,
    pxrpt_sls_consg_invt_yn,
    pxrpt_sls_sst_exempt_qty,
    pxrpt_sls_set_exempt_qty,
    pxrpt_diver_no2_6,
    pxrpt_diversion_orig_st,
	pxrpt_car_in_sf401_yn
  FROM pxrptmst px
  WHERE NOT EXISTS (SELECT *
  FROM tblTFIntegrationTransaction tr
  WHERE CONVERT(DATETIME, CONVERT(NVARCHAR(50), px.pxrpt_trans_rev_dt), 112) = tr.dtmTransactionDate
  AND px.pxrpt_ord_no COLLATE Latin1_General_CI_AS = tr.strTransactionNumber
  AND px.pxrpt_trans_type COLLATE Latin1_General_CI_AS = tr.strTransactionType
  AND px.pxrpt_seq_no = tr.strTransactionSubNumber)
  AND CONVERT(DATETIME, CONVERT(NVARCHAR(50), px.pxrpt_trans_rev_dt), 112) >= CONVERT(NVARCHAR(50), @DateFrom)
  AND CONVERT(DATETIME, CONVERT(NVARCHAR(50), px.pxrpt_trans_rev_dt), 112) <= CONVERT(NVARCHAR(50), @DateTo)
  AND NOT EXISTS (SELECT
    strSourceRecordConcatKey
  FROM tblTFIntegrationError AS err
  WHERE (strSourceRecordConcatKey = CONVERT(NVARCHAR(30), px.pxrpt_trans_rev_dt) + '_' + REPLACE(px.pxrpt_ord_no COLLATE Latin1_General_CI_AS, '   ', '') + '_' + px.pxrpt_trans_type + '_' + CONVERT(NVARCHAR(50), px.pxrpt_seq_no)))
  SELECT @ImportedCount = @@ROWCOUNT

	TRUNCATE TABLE tblTFTransactions
	INSERT INTO tblTFTransactions (uniqTransactionGuid,
	intTaxAuthorityId,
	strTaxAuthority,
	strFormCode,
	strScheduleCode,
	strProductCode,
	strType,
	intProductCodeId,
	intItemId,
	dblQtyShipped,
	dblGross,
	dblNet,
	dblBillQty,
	dblTax,
	dblTaxExempt,
	strInvoiceNumber,
	strPONumber,
	strBOLNumber,
	dtmDate,
	strDestinationCity,
	strDestinationState,
	strOriginCity,
	strOriginState,
	--strAccountStatusCode,
	strShipVia,
	strTransporterLicense,
	strTransportationMode,
	strTransporterName,
	strTransporterFederalTaxId,
	strConsignorName,
	strConsignorFederalTaxId,
	strCustomerName,
	strCustomerFederalTaxId,
	--strTaxCategory,
	strTerminalControlNumber,
	strVendorName,
	strVendorFederalTaxId,
	strTaxPayerName,
	strTaxPayerAddress,
	strCity,
	strState,
	strZipCode,
	strTelephoneNumber,
	strTaxPayerIdentificationNumber,
	strTaxPayerFEIN,
	dtmReportingPeriodBegin,
	dtmReportingPeriodEnd,
	strItemNo,
	intIntegrationError,
	leaf)
  SELECT
    @Guid,
    (SELECT TOP 1 intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'),
    tblTFIntegrationItemProductCode.strTaxAuthority,
    'SF-401' AS strFormcode,
    NULL AS strScheduleCode,
    tblTFIntegrationItemProductCode.strProductCode,
    tr.strTransactionType AS strType,
    NULL AS intProductCodeId,
    NULL AS intItemId,
    tr.dblTransactionOutboundGrossGals AS dblQtyShipped,
    tr.dblTransactionOutboundGrossGals AS dblGross,
    tr.dblTransactionOutboundNetGals AS dblNet,
    tr.dblTransactionOutboundBilledGals AS dblQuantity,
    NULL AS dblTax,
    NULL AS dblTaxExempt,
    NULL AS strInvoiceNumber,
    NULL AS strPONumber,
    tr.strTransactionBillOfLading,
    CONVERT(nvarchar(50), tr.dtmTransactionDate),
    tr.strCustomerCity AS strDestinationCity,
    tr.strCustomerState AS strDestinationState,
    tr.strVendorCity AS strOriginCity,
    tr.strVendorState AS strOriginState,
    tr.strCarrierTransportationMode AS strShipVia,
    tr.strCarrierLicenseNumber1 AS strTransporterLicense,
    tr.strCarrierTransportationMode AS strTransportationMode,
    tr.strCarrierName AS strTransporterName,
    tr.strCarrierFEIN AS strTransporterFEIN,
    tr.strCarrierName AS strConsignorName,
    tr.strCarrierFEIN AS strConsignorFEIN,
	tr.strCustomerName,
	tr.strCustomerFEIN,
    tr.strVendorTerminalControlNumber AS strTerminalControlNumber,
    tr.strVendorName,
    tr.strVendorFEIN,
    cl.strCompanyName,
    cl.strAddress,
    cl.strCity,
    cl.strState,
    cl.strZip,
    cl.strPhone,
    cl.strStateTaxID,
    cl.strFederalTaxID,
    NULL,
    NULL,
    tr.strItemNumber,
	(SELECt COUNT(strSourceRecordConcatKey) FROM tblTFIntegrationError),
    0
  FROM tblTFIntegrationTransaction AS tr
  LEFT OUTER JOIN tblTFIntegrationItemProductCode
  ON tr.strSourceRecordConcatKey = tblTFIntegrationItemProductCode.strSourceRecordConcatKey
  CROSS JOIN tblSMCompanySetup AS cl