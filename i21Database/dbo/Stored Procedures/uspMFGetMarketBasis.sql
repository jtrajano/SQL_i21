CREATE PROCEDURE uspMFGetMarketBasis @intM2MBasisId INT = NULL
	,@intAdditionalBasisId INT = NULL
	,@dblArbitrage NUMERIC(18, 6) = NULL
	,@intCurrencyId INT = NULL
	,@intUnitMeasureId INT = NULL
	,@intLocationId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,IsNULL(BD.dblBasisOrDiscount, 0) + IsNULL(AB.dblBasis, 0) AS dblTotalCost
		,BD.dblBasisOrDiscount AS dblBasis
		,AB.dblBasis AS dblAdditionalBasis
		,C.strCurrency + '/' + UM.strUnitMeasure AS strUOM
		,BD.intCurrencyId
		,BD.intUnitMeasureId
	FROM tblRKM2MBasisDetail BD
	JOIN tblICItem I ON I.intItemId = BD.intItemId
		AND BD.intM2MBasisId = @intM2MBasisId
	JOIN tblSMCurrency C ON C.intCurrencyID = BD.intCurrencyId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = BD.intUnitMeasureId
	LEFT JOIN (
		SELECT ABD.intItemId
			,sum(dblBasis) dblBasis
		FROM tblMFAdditionalBasisDetail ABD
		JOIN tblMFAdditionalBasisOtherCharges OC ON OC.intAdditionalBasisDetailId = ABD.intAdditionalBasisDetailId
		WHERE ABD.intAdditionalBasisId = @intAdditionalBasisId
		GROUP BY ABD.intItemId
		) AB ON AB.intItemId = BD.intItemId
END
