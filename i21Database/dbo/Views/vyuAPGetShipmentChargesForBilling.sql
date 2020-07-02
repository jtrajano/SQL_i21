----SHIPMENT OTHER CHARGES
CREATE VIEW [dbo].[vyuAPGetShipmentChargesForBilling]
AS 
SELECT DISTINCT
	intEntityVendorId							=	A.intEntityVendorId
	, intInventoryRecordId						=	A.intInventoryShipmentId
	, intInventoryRecordItemId 					= 	0
	, intInventoryRecordChargeId				=	A.intInventoryShipmentChargeId
	, dtmRecordDate								=	A.dtmDate
	, strLocationName							=	CL.strLocationName
	, strRecordNumber							=	A.strSourceNumber
	, strBillOfLading							=	A.strBillOfLading
	, strOrderType								=	CASE	WHEN IIS.intOrderType = 1 THEN 'Sales Contract'
													  		WHEN IIS.intOrderType = 2 THEN 'Sales Order'
													  		WHEN IIS.intOrderType = 3 THEN 'Transfer Order'
													  		ELSE 'Direct' --A.intOrderType = 4
													END COLLATE Latin1_General_CI_AS
	, strRecordType								=	'Shipment' COLLATE Latin1_General_CI_AS 
	, strOrderNumber							=	A.strContractNumber
	, strItemNo									=	A.strItemNo
	, strItemDescription						=	A.strDescription
	, dblUnitCost								=	A.dblUnitCost
	, dblRecordQty								=	A.dblQuantityToBill
	, dblVoucherQty								=	A.dblQuantityBilled
	, dblRecordLineTotal						=	A.dblShipmentChargeLineTotal
	, dblVoucherLineTotal						=	voucher.LineTotal
	, dblRecordTax								=	0
	, dblVoucherTax								=	ISNULL(Taxes.dblTax,0)
	, dblOpenQty								=	A.dblQuantityToBill - A.dblQuantityBilled
	, dblItemsPayable							=	ROUND(A.dblAmount, 2) - ISNULL(voucher.LineTotal, 0)
	, dblTaxesPayable							=	0
	, dtmLastVoucherDate						=	topVoucher.dtmBillDate
	, intCurrencyId								=	CASE WHEN A.ysnSubCurrency > 0 
		 													THEN (SELECT ISNULL(intMainCurrencyId,A.intCurrencyId) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
		 													ELSE  ISNULL(A.intCurrencyId,0)
		 											END	
	, strCurrency								=	CASE WHEN A.ysnSubCurrency > 0 
		 													THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT ISNULL(intMainCurrencyId, A.intCurrencyId) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0)))
		 													ELSE  (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = A.intCurrencyId)
		 											END
	, strAllVouchers = CAST( ISNULL(allLinkedVoucherId.strVoucherIds, 'New Voucher') AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS 
	, strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS   
	, strItemUOM = ItemUOMName.strUnitMeasure
	, strCostUOM = ItemUOMName.strUnitMeasure
FROM vyuAPShipmentChargesForBilling A
LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = CASE WHEN A.ysnSubCurrency > 0 
																																						THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(A.intCurrencyId,0))
																																						ELSE  ISNULL(A.intCurrencyId,0) END) 
LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId
LEFT JOIN dbo.tblSMCurrency H1 ON H1.intCurrencyID = A.intCurrencyId
LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
INNER JOIN dbo.tblICItem I ON I.intItemId = A.intItemId
LEFT JOIN dbo.tblEMEntityLocation EL ON A.intEntityVendorId = EL.intEntityId AND D1.intShipFromId = EL.intEntityLocationId
LEFT JOIN dbo.tblAPVendorSpecialTax VST ON VST.intEntityVendorId = A.intEntityVendorId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId  FROM tblSMUserRoleCompanyLocationPermission)
LEFT JOIN tblICCategoryTax B ON I.intCategoryId = B.intCategoryId
LEFT JOIN tblSMTaxClass C ON B.intTaxClassId = C.intTaxClassId 
LEFT JOIN tblSMTaxCode D ON D.intTaxClassId = C.intTaxClassId 
LEFT JOIN dbo.tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = A.intForexRateTypeId
OUTER APPLY fnGetItemTaxComputationForVendor(A.intItemId, A.intEntityVendorId, A.dtmDate, A.dblUnitCost, 1, (CASE WHEN VST.intTaxGroupId > 0 THEN VST.intTaxGroupId
																													WHEN CL.intTaxGroupId  > 0 THEN CL.intTaxGroupId 
																													WHEN EL.intTaxGroupId > 0  THEN EL.intTaxGroupId ELSE 0 END), CL.intCompanyLocationId, D1.intShipFromId , 0, 0, NULL, 0, NULL, NULL, NULL, NULL) Taxes
LEFT JOIN dbo.tblICInventoryShipment IIS ON A.intInventoryShipmentId = IIS.intInventoryShipmentId
LEFT JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
		ON ItemUOM.intItemUOMId = A.intCostUnitMeasureId
OUTER APPLY 
(
	SELECT intEntityVendorId,
			ysnPosted
	FROM tblAPBillDetail BD
	LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
	WHERE BD.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId

) Billed
OUTER APPLY 
(
	SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
	INNER JOIN dbo.tblAPBill B ON B.intBillId = H.intBillId
	WHERE H.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
	GROUP BY H.intInventoryShipmentChargeId
			
) Qty

OUTER APPLY (
	SELECT QtyTotal = SUM (ISNULL(BD.dblQtyReceived, 0))									
			, LineTotal = 
				SUM (
				 	ROUND (
				 		ISNULL(BD.dblQtyReceived, 0)		
				 		* ISNULL(BD.dblCost, 0) 
				 		, 2
				 	)
				)
			, TaxTotal = 
				SUM(ISNULL(BD.dblTax, 0))
	FROM tblAPBillDetail BD
	LEFT JOIN dbo.tblAPBill B ON BD.intBillId = B.intBillId
	WHERE BD.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId	
) voucher

OUTER APPLY (					
	SELECT	TOP 1 
			b.dtmBillDate
	FROM	tblAPBill b CROSS APPLY (
				SELECT	TOP  5
						bb.intBillId
				FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
							ON bb.intBillId = bd.intBillId
				WHERE	bd.intInventoryReceiptChargeId = A.intInventoryShipmentChargeId
						AND bb.ysnPosted = 1
			) chargeVouchers
	WHERE	b.intBillId = chargeVouchers.intBillId 
			AND b.intEntityVendorId = A.intEntityVendorId
	ORDER BY b.intBillId DESC 
) topVoucher
OUTER APPLY (
	SELECT strFilterString = 
		LTRIM(
			STUFF(
					' ' + (
						SELECT	CONVERT(NVARCHAR(50), b.intBillId) + '|^|'
						FROM	tblAPBill b CROSS APPLY (
									SELECT	bb.intBillId
									FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
												ON bb.intBillId = bd.intBillId
									WHERE	bd.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
											AND bb.ysnPosted = 0
								) chargeVouchers
						WHERE	b.intBillId = chargeVouchers.intBillId 
								AND b.intEntityVendorId = A.intEntityVendorId
						FOR XML PATH('')
					)
				, 1
				, 1
				, ''
			)
		)
) filterString 
OUTER APPLY (
	SELECT strVoucherIds = 
		STUFF(
				(
					SELECT	', ' + b.strBillId
					FROM	tblAPBill b CROSS APPLY (
								SELECT	bb.intBillId
								FROM	tblAPBill bb INNER JOIN tblAPBillDetail bd
											ON bb.intBillId = bd.intBillId
								WHERE	bd.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
										AND bb.ysnPosted = 0
							) chargeVouchers
					WHERE	b.intBillId = chargeVouchers.intBillId 
							AND b.intEntityVendorId = A.intEntityVendorId
					FOR XML PATH('')
				)
			, 1
			, 1
			, ''
		)
) allLinkedVoucherId
--WHERE A.[intEntityVendorId] NOT IN (Billed.intEntityVendorId) OR (Qty.dblQty IS NULL)
WHERE Billed.ysnPosted = 0 OR (Qty.dblQty IS NULL)