CREATE PROCEDURE [dbo].[uspSAPCreatePoHeader]
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrMsg NVARCHAR(MAX);

BEGIN TRY
	UPDATE tblLGLoadDetailContainerLink
	SET ysnExported = 0
	WHERE intLoadDetailContainerLinkId IN (
			SELECT intLoadDetailContainerLinkId
			FROM tblLGLoadDetailContainerLink
			WHERE ysnExported IS NULL
				AND strIntegrationNumber IS NOT NULL
			);

	SELECT DISTINCT PO_NUMBER = ch.strContractNumber
		,PO_REF_NUMBER = lk.strIntegrationNumber
		,ORDER_DATE = CONVERT(VARCHAR(10), ch.dtmContractDate, 112)
		,SAP_VENDOR_CODE = v.strVendorAccountNum
		,NULL ITEM_NAME
		,NULL SAP_MATERIAL_CODE
		,NULL PO_ITEM_TYPE
		,NULL PO_ITEM_ORIGIN
		,NULL PO_GRADE
		,PO_TRADER = ch.strSalespersonId
		,PO_POSITION = ch.strPosition
		,INSURANCE_BY = ch.strInsuranceBy
		,WEIGHTS = ch.strWeight
		,NULL SHIPMENT_NET_QTY_IN_LB
		,NULL SHIPMENT_NET_QTY_UNIT
		,NULL NET_SHIPMENT_PRICE
		,NULL NET_SHIPMENT_PRICE_UNIT
		,PO_SHIPMENT_TO = ''
		,PO_ARRIVAL_TO = ''
		,PO_DELIVERY_TO = CONVERT(VARCHAR(10), cd.dtmEndDate, 112)
		,PO_PRICE_BASIS = CASE ch.strPricingType
			WHEN 'Basis'
				THEN 'PTBF'
			ELSE 'Outright'
			END
		,PO_TERMINAL = fm.strFutMarketName
		,NULL DIFFERENTIAL
		,NULL DIFFERENTIAL_AMOUNT
		,NULL DIFFERENTIAL_CURRENCY
		,PO_FUTURE_MONTH = mo.strFutureMonth
		,FIXATION_BY = cd.strFixationBy
		,LAST_FIXATION_DATE = CONVERT(VARCHAR(10), pfd.dtmFixationDate, 112)
		,PO_CONTRACT_TYPE = ch.strContractBasis
		,PO_APPROVALBASIS_NAME = isnull(ch.strGrade, '-')
		,PAYMENT_TERMS = ch.strTerm
		,ASSOCIATION = asoc.strName
		,NULL
		,PO_SUPPLIER_REF = ch.strCustomerContract
	FROM (
		SELECT *
		FROM tblLGLoadDetailContainerLink
		WHERE ysnExported = 0
			AND strIntegrationNumber IS NOT NULL
		) lk
	INNER JOIN tblLGLoadContainer lc ON lk.intLoadContainerId = lc.intLoadContainerId
	INNER JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = lk.intLoadDetailId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ld.intPContractDetailId
	INNER JOIN vyuCTContractHeaderView ch ON cd.intContractHeaderId = ch.intContractHeaderId
	LEFT OUTER JOIN tblCTPriceFixation pf ON pf.intContractDetailId = cd.intContractDetailId
	LEFT OUTER JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId
	INNER JOIN tblEMEntity et ON ch.intEntityId = et.intEntityId
	INNER JOIN tblAPVendor v ON v.intEntityId = et.intEntityId
	LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth mo ON mo.intFutureMonthId = cd.intFutureMonthId
	LEFT OUTER JOIN tblCTAssociation asoc ON asoc.intAssociationId = ch.intAssociationId;
END TRY

BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()
		,@ErrorSeverity = ERROR_SEVERITY()
		,@ErrorState = ERROR_STATE();

	RAISERROR (
			@ErrorMessage
			,@ErrorSeverity
			,@ErrorState
			);
END CATCH
