CREATE VIEW vyuMFGetPMUsage
AS
SELECT DISTINCT RTRIM(CONVERT(CHAR, W.dtmPlannedDate, 101)) COLLATE Latin1_General_CI_AS AS [Dump Date]
			  , I.strItemNo					AS [Product]
			  , I.strDescription			AS [Product Description]
			  , (SELECT TOP 1 strParentLotNumber
				 FROM dbo.tblMFWorkOrderProducedLot WP
				 WHERE WP.intWorkOrderId = W.intWorkOrderId
				)							AS [Production Lot]
			  , MC.strCellName				AS Line
			  , W.strWorkOrderNo			AS [Work Order #]
			  , W.strReferenceNo			AS [Job #]
			  , I1.strItemNo				AS [WSI Item]
			  , I1.strDescription			AS [WSI Item Description]
		 	  , (SELECT TOP 1 CC.dblRequiredQty
				 FROM tblMFProcessCycleCount CC
				 JOIN tblMFProcessCycleCountSession PCC ON PCC.intCycleCountSessionId = CC.intCycleCountSessionId
				 WHERE PCC.intWorkOrderId = W.intWorkOrderId AND CC.intItemId = WC.intItemId
				) AS dblRequiredQty
			  , ROUND(SUM(WC.dblIssuedQuantity) + ISNULL((SELECT Round(SUM(IsNULL(WC1.dblIssuedQuantity, 0)), 0)
														  FROM dbo.tblMFWorkOrderConsumedLot WC1
														  WHERE WC1.intWorkOrderId = W.intWorkOrderId AND WC1.intItemId = WC.intItemId AND WC1.intSequenceNo = 9999), 0), 0) AS [Total Consumed Quantity]
			  , SUM(WC.dblIssuedQuantity)	AS [Used in Packaging]
			  , UM1.strUnitMeasure			AS [UOM]
			  , ISNULL((SELECT Round(SUM(IsNULL(WC1.dblIssuedQuantity, 0)), 0)
						FROM dbo.tblMFWorkOrderConsumedLot WC1
						WHERE WC1.intWorkOrderId = W.intWorkOrderId AND WC1.intItemId = WC.intItemId AND WC1.intSequenceNo = 9999
			    ), 0) AS [Damaged]
			  , W.intWorkOrderId
			  , RTRIM(CONVERT(CHAR, W.dtmPlannedDate, 23)) COLLATE Latin1_General_CI_AS AS dtmPlannedDate 
			  , W.intLocationId			
			  , CompanyLocation.strLocationName
			  , Category.strCategoryCode
			  , Category.strDescription
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderId = W.intWorkOrderId AND intSequenceNo <> 9999 AND W.intStatusId = 13
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WC.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICItem I1 ON I1.intItemId = WC.intItemId
JOIN dbo.tblSMCompanyLocation AS CompanyLocation ON W.intLocationId = CompanyLocation.intCompanyLocationId
JOIN dbo.tblICCategory AS Category ON I1.intCategoryId = Category.intCategoryId
WHERE I1.intCategoryId IN 
(
	SELECT PA.strAttributeValue
	FROM tblMFManufacturingProcessAttribute PA
	WHERE PA.intManufacturingProcessId = W.intManufacturingProcessId AND PA.intLocationId = W.intLocationId AND PA.intAttributeId = 46
)
GROUP BY W.dtmPlannedDate
	   , I.strItemNo
	   , I.strDescription
	   , MC.strCellName
	   , W.strWorkOrderNo
	   , W.strReferenceNo
	   , I1.strItemNo
	   , I1.strDescription
	   , UM1.strUnitMeasure
	   , W.intWorkOrderId
	   , WC.intItemId
	   , W.intWorkOrderId
	   , W.intLocationId			
	   , CompanyLocation.strLocationName
	   , Category.strCategoryCode
	   , Category.strDescription
