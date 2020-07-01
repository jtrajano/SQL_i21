CREATE VIEW [dbo].[vyuGRDestinationWeightVarianceReportView]
	AS
	SELECT
		SC.intTicketId
		,SC.strTicketNumber
		,[intParentTicketId] = ORIGIN_SC.intTicketId
        ,CUSTOMER.intEntityId
		,SPLIT.intTicketId AS [intTicketSplit]
		,SPLIT.intTicketSplitId
        ,SPLIT.intEntityId AS [intSplitEntityId]
		,strSplitDistribution  =  CASE SPLIT.strDistributionOption 
				WHEN 'CNT' THEN 'Contract' 
				WHEN 'LOD' THEN 'Load' 
				WHEN 'SPT' THEN 'Spot Sale' 
				WHEN 'SPL' THEN 'Split' 
				WHEN 'HLD' THEN 'Hold' 
			END   COLLATE Latin1_General_CI_AS  
		,CUSTOMER.strName AS [strCustomerName]
		,SPLIT.strName AS [strSplitCustomerName]
		,SC.dtmTicketDateTime
		,ITEM.intItemId
		,ITEM.strDescription AS strItem
		,COMMODITY.intCommodityId
		,COMMODITY.strDescription AS strCommodity
		,SPLIT.strSplitNumber
		,ISNULL(SPLIT.dblSplitPercent, 100) AS [dblSplitPercent]
		,COMLOC.intCompanyLocationId
		,COMLOC.strLocationName
		,COMLOC.strLocationNumber
		,DISCID.strDiscountId
		,SC.dblTicketFees
		,SC.strCustomerReference
		,SC.strItemUOM
		,SC.intItemUOMIdFrom
		,SC.intItemUOMIdTo

		,[dblDestinationGrossWeight] = SC.dblGrossWeight
		,[dblDestinationGrossWeight1] = SC.dblGrossWeight1
		,[dblDestinationGrossWeight2] = SC.dblGrossWeight2

		,[dblDestinationTareWeight] = SC.dblTareWeight
		,[dblDestinationTareWeight1] = SC.dblTareWeight1
		,[dblDestinationTareWeight2] = SC.dblTareWeight2

		,[dblOriginGrossWeight] = ORIGIN_SC.dblGrossWeight
		,[dblOriginGrossWeight1] = ORIGIN_SC.dblGrossWeight1
		,[dblOriginGrossWeight2] = ORIGIN_SC.dblGrossWeight2

		,[dblOriginTareWeight] = ORIGIN_SC.dblTareWeight
		,[dblOriginTareWeight1] = ORIGIN_SC.dblTareWeight1
		,[dblOriginTareWeight2] = ORIGIN_SC.dblTareWeight2
		-- ,dbo.fnDivide(ICIS.dblGross, SC.dblConvertedUOMQty) AS [dblOriginNetWeight]
		-- ,dbo.fnDivide(ICIS.dblDestinationGross, SC.dblConvertedUOMQty) AS [dblDestinationNetWeight]
		-- ,dbo.fnDivide((ICIS.dblDestinationGross - ICIS.dblGross), SC.dblConvertedUOMQty) AS [dblVarianceWeight]
		-- ,((ICIS.dblDestinationGross - ICIS.dblGross) / ICIS.dblGross) * 100 AS [dblVariancePercentage]
        -- ,[ysnHasVariance] = CAST(CASE WHEN (ICIS.dblDestinationGross - ICIS.dblGross) != 0 THEN 1 ELSE 0 END AS bit)
	FROM tblSCTicket SC
	INNER JOIN tblEMEntity CUSTOMER
		ON SC.intEntityId = CUSTOMER.intEntityId
	INNER JOIN tblICItem ITEM
		ON SC.intItemId = ITEM.intItemId
	INNER JOIN tblICCommodity COMMODITY
		ON ITEM.intCommodityId = COMMODITY.intCommodityId
	INNER JOIN tblSMCompanyLocation COMLOC
		ON COMLOC.intCompanyLocationId = SC.intTicketLocationId
	INNER JOIN tblGRDiscountId DISCID
		ON DISCID.intDiscountId = SC.intDiscountId
	-- CROSS APPLY (
	-- 	SELECT
	-- 		[dblGross] = CASE WHEN LOT.intWeightUOMId IS NULL
	-- 						THEN SUM(ISD.dblGross)
	-- 						ELSE dbo.fnCalculateQtyBetweenUOM(LOT.intWeightUOMId, SC.intItemUOMIdTo, SUM(ISD.dblGross))
	-- 					END
	-- 		-- [dblGross] = dbo.fnCalculateQtyBetweenUOM(, toUOMId, SUM(ISD.dblGross))
	-- 		,[dblDestinationGross] = SUM(ISNULL(ISD.dblDestinationGross, ISD.dblGross))
	-- 		,LOT.intWeightUOMId
	-- 	FROM tblICInventoryShipment ISH
	-- 	INNER JOIN tblICInventoryShipmentItem ISD
	-- 		ON ISH.intInventoryShipmentId = ISD.intInventoryShipmentId
	-- 		AND ISH.intSourceType = 1
	-- 	-- LEFT JOIN tblICInventoryLot LOT
	-- 	-- 	ON LOT.intTransactionId = ISH.intInventoryShipmentId
	-- 	-- 	AND LOT.intTransactionDetailId = ISD.intInventoryShipmentItemId
	-- 	LEFT JOIN tblICLot LOT
	-- 		ON LOT.intLotId = SC.intLotId
	-- 	-- LEFT JOIN tblICItemUOM UOM
	-- 	-- 	ON ISD.intItemId = UOM.intItemId
	-- 	-- 	AND UOM.intItemUOMId = LOT.intItemUOMId
	-- 	WHERE SC.intTicketId = ISD.intSourceId
	-- 		AND SC.intItemId = ISD.intItemId
	-- 	GROUP BY LOT.intWeightUOMId
	-- ) ICIS
	LEFT JOIN tblSCTicket ORIGIN_SC
		ON ORIGIN_SC.intTicketId = SC.intParentTicketId
	LEFT JOIN tblGRStorageType tblGRStorageType
		ON tblGRStorageType.strStorageTypeCode = SC.strDistributionOption
	OUTER APPLY (
		SELECT
			CUSTOMER2.strName
			,EMSPLIT.strSplitNumber
			,SCSPLIT.dblSplitPercent
			,CUSTOMER2.intEntityId
			,SCSPLIT.intTicketId
			,SCSPLIT.intTicketSplitId
			,SCSPLIT.strDistributionOption
		FROM tblSCTicketSplit SCSPLIT
		INNER JOIN tblEMEntity CUSTOMER2
			ON CUSTOMER2.intEntityId = SCSPLIT.intCustomerId
		LEFT JOIN tblEMEntitySplit EMSPLIT
			ON EMSPLIT.intSplitId = SC.intSplitId
		WHERE SCSPLIT.intTicketId = SC.intTicketId
	) SPLIT
	WHERE
		SC.ysnDestinationWeightGradePost = 1
		AND SC.strTicketStatus <> 'V'