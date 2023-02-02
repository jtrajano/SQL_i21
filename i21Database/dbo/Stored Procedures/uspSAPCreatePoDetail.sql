CREATE PROCEDURE [dbo].[uspSAPCreatePoDetail]
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
	SELECT PO_REF_NUMBER = lk.strIntegrationNumber
		,PO_LINE_REF_NUMBER = dense_rank() OVER (
			PARTITION BY ch.strContractNumber ORDER BY lk.intLoadContainerId
			)
		,CONTAINER_NET_WT_IN_LB = round(cast(lc.dblNetWt AS FLOAT), 2)
		,CONTAINER_NET_WT_UNIT = lgum.strSymbol
		,NET_CONTAINER_PRICE = round(lc.dblNetWt * round(cd.dblCashPrice * CASE curr.ysnSubCurrency
					WHEN 1
						THEN 1 / cast(curr.intCent AS FLOAT)
					ELSE 1
					END, 2), 2)
		,NET_CONTAINER_PRICE_UNIT = isnull(mcurr.strCurrency, curr.strCurrency)
		,CONTAINER_NUMBER = lc.strContainerNumber
		,CONT_MARKS = lc.strMarks
		,ITEM_NAME = it.strDescription
		,SAP_MATERIAL_CODE = it.strShortName
		,PO_ITEM_TYPE = CASE it.strType
			WHEN 'Inventory'
				THEN att_typ.strDescription
			ELSE NULL
			END
		,PO_ITEM_ORIGIN = att_org.strDescription
		,PO_GRADE = att_grd.strDescription
		,NET_SHIPMENT_PRICE = cd.dblCashPrice * CASE curr.ysnSubCurrency
			WHEN 1
				THEN 1 / cast(curr.intCent AS FLOAT)
			ELSE 1
			END * 1000
		,NET_SHIPMENT_PRICE_UNIT = 1000
		,DIFFERENTIAL = CASE sign(cd.dblBasis)
			WHEN - 1
				THEN 'UNDER'
			WHEN 1
				THEN 'OVER'
			ELSE 'level'
			END
		,DIFFERENTIAL_AMOUNT = cast(abs(cd.dblBasis) AS FLOAT)
		,DIFFERENTIAL_CURRENCY = CASE curr.ysnSubCurrency
			WHEN 1
				THEN 'c'
			ELSE cu.strCurrency
			END + '/' + u2.strUnitMeasure
		,COST_TYPE = ICost.strItemNo
		,AMOUNT = CONVERT(NUMERIC(18, 2), ROUND(LCost.dblAmount / (SELECT COUNT(1) FROM tblLGLoadContainer WHERE intLoadId = ld.intLoadId), 2))
	FROM (
		SELECT *
		FROM tblLGLoadDetailContainerLink
		WHERE ysnExported = 0
			AND strIntegrationNumber IS NOT NULL
		) lk
	INNER JOIN tblLGLoadContainer lc ON lk.intLoadContainerId = lc.intLoadContainerId
	INNER JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = lk.intLoadDetailId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ld.intPContractDetailId
	INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
	INNER JOIN tblICItem it ON it.intItemId = cd.intItemId
	INNER JOIN tblICCommodityAttribute att_typ ON att_typ.intCommodityAttributeId = it.intProductTypeId
	LEFT JOIN tblLGLoadCost LCost ON LCost.intLoadId = ld.intLoadId
	LEFT JOIN tblICItem ICost ON ICost.intItemId = LCost.intItemId
	LEFT OUTER JOIN tblICCommodityAttribute att_grd ON att_grd.intCommodityAttributeId = it.intGradeId
	LEFT OUTER JOIN tblICCommodityAttribute att_org ON att_org.intCommodityAttributeId = it.intOriginId
	LEFT JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId
	LEFT JOIN tblICItemUOM pu ON pu.intItemUOMId = cd.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure u2 ON u2.intUnitMeasureId = pu.intUnitMeasureId
	LEFT OUTER JOIN tblLGCompanyPreference pref ON 1 = 1
	LEFT OUTER JOIN tblICUnitMeasure lgum ON lgum.intUnitMeasureId = pref.intWeightUOMId
	LEFT OUTER JOIN tblSMCurrency curr ON curr.intCurrencyID = cd.intCurrencyId
	LEFT OUTER JOIN tblSMCurrency mcurr ON curr.intMainCurrencyId = mcurr.intCurrencyID;
END TRY

BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()
		,@ErrorSeverity = ERROR_SEVERITY()
		,@ErrorState = ERROR_STATE();

	RAISERROR (
			@ErrorMessage
			,-- Message text.
			@ErrorSeverity
			,-- Severity.
			@ErrorState -- State.
			);
END CATCH
