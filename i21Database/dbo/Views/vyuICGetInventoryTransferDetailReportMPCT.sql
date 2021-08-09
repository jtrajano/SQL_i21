CREATE VIEW [dbo].[vyuICGetInventoryTransferDetailReportMPCT]
AS 

SELECT 
	t.strTransferNo
	,t.dtmTransferDate
	,strCarrier = shipVia.strShipVia
	,strAttn = e.strName
	,tfd.intInventoryTransferDetailId
	,dtmDeliveryDate = tfd.dtmDeliveryDate
	,strPONumber = CAST(ch.strContractNumber + '/' + cast(cd.intContractSeq as nvarchar(50)) as nvarchar(500)) 
	,strSupplierRef = ch.strCustomerContract --v.strVendorId
	,strItemNo = i.strItemNo
	,strItemDescription = i.strDescription
	,strMotherLotNumber = pl.strParentLotNumber
	,strLotNumber = l.strLotNumber
	,strContainerNumber = l.strContainerNo
	,strMarks = l.strMarkings
	,dblQuantity = tfd.dblQuantity
	,strQuantityUOM = u.strUnitMeasure
	,dblWeight = dbo.fnMultiply(tfd.dblQuantity, l.dblWeightPerQty) 
	,strWeightUOM = wu.strUnitMeasure
	,dtmReceiptDate = r.dtmReceiptDate	
	,strWarehouse = fromStorageLocation.strSubLocationName
	,strDeliveryInstructions = 
		dbo.fnICFormatErrorMessage (
			'Commodity to be delivered to %s%s%s%s.'
			,ISNULL(toStorageLocation.strSubLocationName, '')
			,ISNULL(toStorageLocation.strCity, '')
			,ISNULL(toStorageLocation.strState, '') 
			,ISNULL(toStorageLocation.strCountry, '') 
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
			,DEFAULT
		)
	,strApproxValue = 
		CASE 
			WHEN ISNULL(approxValue.dblValue, 0) = 0 THEN 
				--COALESCE(currency.strSymbol, currency.strCurrency, '') + ' 0.00'
				'Cost not available. Please post the transfer.'
			ELSE 
				dbo.fnICFormatErrorMessage (
					'%s %f %s %s'
					,COALESCE(currency.strSymbol, currency.strCurrency, '') 
					,ISNULL(approxValue.dblValue, 0.00) 
					,'per'
					,uom.strUnitMeasure
					,DEFAULT
					,DEFAULT
					,DEFAULT
					,DEFAULT
					,DEFAULT
					,DEFAULT			
				)
			END
	,t.strDescription
FROM 
	tblICInventoryTransfer t INNER JOIN tblICInventoryTransferDetail tfd
		ON t.intInventoryTransferId = tfd.intInventoryTransferId
	INNER JOIN tblICItem i 
		ON i.intItemId = tfd.intItemId
	INNER JOIN (
		tblICItemUOM iu INNER JOIN tblICUnitMeasure u
			ON iu.intUnitMeasureId = u.intUnitMeasureId
	)
		ON iu.intItemUOMId = tfd.intItemUOMId
	LEFT JOIN tblICLot l
		ON l.intLotId = tfd.intLotId
	LEFT JOIN (
		tblICItemUOM wiu INNER JOIN tblICUnitMeasure wu
			ON wiu.intUnitMeasureId = wu.intUnitMeasureId	
	)
		ON wiu.intItemUOMId = l.intWeightUOMId
	LEFT JOIN (
		tblICInventoryReceipt r INNER JOIN tblAPVendor v
			ON r.intEntityVendorId = v.intEntityId
	)
		ON r.strReceiptNumber = l.strSourceTransactionId
	LEFT JOIN (
		tblCTContractHeader ch INNER JOIN tblCTContractDetail cd
			ON ch.intContractHeaderId = cd.intContractHeaderId
	)
		ON ch.intContractHeaderId = l.intContractHeaderId
		AND cd.intContractDetailId = l.intContractDetailId
	LEFT JOIN tblICParentLot pl
		ON pl.intParentLotId = l.intParentLotId

	LEFT JOIN tblSMCompanyLocation cl
		ON cl.intCompanyLocationId = t.intFromLocationId

	LEFT JOIN (
		tblSMShipVia shipVia INNER JOIN tblEMEntity e
			ON shipVia.intEntityId = e.intEntityId
	)
		ON shipVia.intEntityId = t.intShipViaId

	OUTER APPLY (
		SELECT TOP 1 
			subLoc.strSubLocationName
		FROM 
			tblSMCompanyLocationSubLocation subLoc INNER JOIN tblICInventoryTransferDetail tfd2
				ON subLoc.intCompanyLocationSubLocationId = tfd2.intFromSubLocationId
		WHERE
			tfd2.intInventoryTransferId = t.intInventoryTransferId
	) fromStorageLocation

	OUTER APPLY (
		SELECT TOP 1 
			strSubLocationName = subLoc.strSubLocationName
			,strCity = ', ' + subLoc.strCity 
			,strState = ', ' + subLoc.strState 
			,strCountry = ', ' + country.strCountry
		FROM 
			tblSMCompanyLocationSubLocation subLoc INNER JOIN tblICInventoryTransferDetail tfd3
				ON subLoc.intCompanyLocationSubLocationId = tfd3.intToSubLocationId
			LEFT JOIN tblSMCountry country
				ON country.intCountryID = subLoc.intCountryId
		WHERE
			tfd3.intInventoryTransferId = t.intInventoryTransferId
	) toStorageLocation

	OUTER APPLY (
		SELECT 
			dblValue = 
				ROUND(
					dbo.fnDivide(
						SUM(ic.dblQty * ic.dblCost + ic.dblValue)
						,SUM(ic.dblQty)
					)	
					,2 
				)
				--ROUND(
				--	SUM(-ic.dblQty * ic.dblCost + ic.dblValue)
				--	,2
				--)
		FROM 
			tblICInventoryTransaction ic
		WHERE
			ic.strTransactionId = t.strTransferNo
			AND ic.ysnIsUnposted = 0 
			AND ic.dblQty < 0 
	) approxValue 

	OUTER APPLY (
		SELECT	
			c.strCurrency
			,c.strSymbol
		FROM tblSMCurrency c
		WHERE 
			c.intCurrencyID = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	) currency

	OUTER APPLY (
		SELECT TOP 1 
			u.strUnitMeasure
		FROM 
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE
			iu.intItemId = tfd.intItemId
			AND iu.ysnStockUnit = 1 
	) uom