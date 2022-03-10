CREATE FUNCTION [dbo].[fnGRCalculateChargeAndPremium](
	@intChargeAndPremiumId INT
	,@intInventoryItemId INT
	,@intCompanyLocationId INT
	,@dblNetUnits DECIMAL(18, 6)
	,@dblGrossUnits DECIMAL(18, 6)
    ,@dblTransactionUnits DECIMAL(18, 6)
    ,@tblQMDiscountIds Id READONLY
    ,@dblCost DECIMAL(18, 6)
    ,@dtmCalculateOn DATETIME
	,@settleStorageChargeAndPremium SettleStorageChargeAndPremium READONLY
	,@intCustomerStorageId INT
)
RETURNS @tblChargeAndPremium TABLE
(
    [intChargeAndPremiumId] INT NOT NULL
    ,[strChargeAndPremiumId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
    ,[intChargeAndPremiumDetailId] INT NOT NULL
	,[intChargeAndPremiumItemId] INT NOT NULL
	,[strChargeAndPremiumItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
    ,[intCalculationTypeId] INT NOT NULL
    ,[strCalculationType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
    ,[dblRate] DECIMAL(38,20) NOT NULL
    ,[strRateType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
	,[dblQty] NUMERIC(38, 20) NOT NULL
    ,[intChargeAndPremiumItemUOMId] INT NOT NULL
    ,[strChargeAndPremiumUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[dblCost] NUMERIC(38, 20) NULL
	,[dblAmount] NUMERIC(38, 20) NULL
    ,[intOtherChargeItemId] INT NULL
	,[strOtherChargeItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intInventoryItemId] INT NULL
	,[strInventoryItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[ysnDeductVendor] BIT
)
AS
BEGIN
    -- Main Query
    INSERT INTO @tblChargeAndPremium
    SELECT
        [intChargeAndPremiumId]             =   CAP.intChargeAndPremiumId
        ,[strChargeAndPremiumId]            =   CAP.strChargeAndPremiumId
        ,[intChargeAndPremiumDetailId]      =   CAPD.intChargeAndPremiumDetailId
        ,[intChargeAndPremiumItemId]        =   CAP_ITEM.intItemId
        ,[strChargeAndPremiumItemNo]        =   CAP_ITEM.strItemNo
        ,[intCalculationTypeId]             =   CT.intCalculationTypeId
        ,[strCalculationType]               =   CT.strCalculationType
        ,[dblRate]                          =   CASE CAPD.intCalculationTypeId
													WHEN 5 THEN ISNULL(FIXED_RATE.dblRate, 0)
													WHEN 4 THEN ISNULL(PERCENTAGE_BY_DISCOUNT.dblRate, 0)
													WHEN 3 THEN ISNULL(PERCENTAGE_BY_ITEM.dblRate, 0)
													WHEN 2 THEN ISNULL(RANGE_BY_GRADEREADING.dblRate, 0)
													WHEN 1 THEN ISNULL(RANGE_BY_UNITS.dblRate, 0)
													ELSE 0
												END
        ,[strRateType]                      =   CAPD.strRateType
        ,[dblQty]                           =   (CASE CAPD.intCalculationTypeId
                                                    WHEN 5 THEN ISNULL(FIXED_RATE.dblQty, 0)
                                                    WHEN 4 THEN ISNULL(PERCENTAGE_BY_DISCOUNT.dblQty, 0)
                                                    WHEN 3 THEN ISNULL(PERCENTAGE_BY_ITEM.dblQty, 0)
                                                    WHEN 2 THEN ISNULL(RANGE_BY_GRADEREADING.dblQty, 0)
                                                    WHEN 1 THEN ISNULL(RANGE_BY_UNITS.dblQty, 0)
                                                    ELSE ISNULL(@dblNetUnits, 0)
                                                END)
                                                * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END)
        ,[intChargeAndPremiumItemUOMId]     =   CAP_ITEM_UOM.intItemUOMId
        ,[strChargeAndPremiumUnitMeasure]   =   UOM.strUnitMeasure
        ,[dblCost]                          =   CASE CAPD.intCalculationTypeId
                                                    WHEN 5 THEN ISNULL(FIXED_RATE.dblCost, 0)
                                                    WHEN 4 THEN ISNULL(PERCENTAGE_BY_DISCOUNT.dblCost, 0)
                                                    WHEN 3 THEN ISNULL(PERCENTAGE_BY_ITEM.dblCost, 0)
                                                    WHEN 2 THEN ISNULL(RANGE_BY_GRADEREADING.dblCost, 0)
                                                    WHEN 1 THEN ISNULL(RANGE_BY_UNITS.dblCost, 0)
                                                    ELSE 0
                                                END
        ,[dblAmount]                        =   CASE CAPD.intCalculationTypeId
                                                    WHEN 5 THEN ISNULL(FIXED_RATE.dblCost, 0) * ISNULL(FIXED_RATE.dblQty * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END), 0)
                                                    WHEN 4 THEN ISNULL(PERCENTAGE_BY_DISCOUNT.dblCost, 0) * ISNULL(PERCENTAGE_BY_DISCOUNT.dblQty * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END), 0)
                                                    WHEN 3 THEN ISNULL(PERCENTAGE_BY_ITEM.dblCost, 0) * ISNULL(PERCENTAGE_BY_ITEM.dblQty * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END), 0)
                                                    WHEN 2 THEN ISNULL(RANGE_BY_GRADEREADING.dblCost, 0) * ISNULL(RANGE_BY_GRADEREADING.dblQty * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END), 0)
                                                    WHEN 1 THEN ISNULL(RANGE_BY_UNITS.dblCost, 0) * ISNULL(RANGE_BY_UNITS.dblQty * (CASE WHEN CAPD.ysnDeductVendor = 1 THEN -1 ELSE 1 END), 0)
                                                    ELSE 0
                                                END
        ,[intOtherChargeItemId]             =   OC_ITEM.intItemId
        ,[strOtherChargeItemNo]             =   OC_ITEM.strItemNo
        ,[intInventoryItemId]               =   INV_ITEM.intItemId
        ,[strInventoryItemNo]               =   INV_ITEM.strItemNo
        ,[ysnDeductVendor]                  =   CAPD.ysnDeductVendor
    FROM tblGRChargeAndPremiumId CAP
    INNER JOIN tblGRChargeAndPremiumDetail CAPD
        ON CAPD.intChargeAndPremiumId = CAP.intChargeAndPremiumId
    INNER JOIN tblGRCalculationType CT
        ON CT.intCalculationTypeId = CAPD.intCalculationTypeId
    INNER JOIN tblICItem CAP_ITEM
        ON CAP_ITEM.intItemId = CAPD.intChargeAndPremiumItemId
    INNER JOIN tblICItemUOM CAP_ITEM_UOM
        ON CAP_ITEM_UOM.intItemId = CAP_ITEM.intItemId
        AND CAP_ITEM_UOM.ysnStockUnit = 1
    INNER JOIN tblICUnitMeasure UOM
        ON UOM.intUnitMeasureId = CAP_ITEM_UOM.intUnitMeasureId
    LEFT JOIN tblICItem OC_ITEM
        ON OC_ITEM.intItemId = CAPD.intOtherChargeItemId
    LEFT JOIN tblICItem INV_ITEM
        ON INV_ITEM.intItemId = CAPD.intInventoryItemId
	--OUTER APPLY (
	--	SELECT * 
	--	FROM @settleStorageChargeAndPremium
	--	WHERE ysnOverride = 1
	--		AND intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
	--) _OVERRIDE2
    -- Range By Grade Reading Calculation --OK
    OUTER APPLY (
        SELECT
            [dblQty]    =   CASE CAPD.strRateType
                                WHEN 'Per Unit' THEN @dblNetUnits
                                WHEN 'Flat' THEN 1
                            END
            ,[dblCost]  =   CASE 
								WHEN _OVERRIDE.ysnOverride = 1 THEN 
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN ISNULL(_OVERRIDE.dblRate, 0)
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * ISNULL(_OVERRIDE.dblRate, 0)) / @dblTransactionUnits
									END
								ELSE
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN ISNULL(CAPD_RANGE.dblRangeRate, 0)
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * ISNULL(CAPD_RANGE.dblRangeRate, 0)) / @dblTransactionUnits
									END
							END
            ,[dblRate]  =  CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_RANGE.dblRangeRate, 0) END
        FROM @tblQMDiscountIds QM_ID
        INNER JOIN tblQMTicketDiscount QM
            ON QM.intTicketDiscountId = QM_ID.intId
        INNER JOIN tblGRDiscountScheduleCode DSC
            ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
        INNER JOIN tblGRChargeAndPremiumDetailRange CAPD_RANGE
            ON CAPD_RANGE.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
		OUTER APPLY (
			SELECT * 
			FROM @settleStorageChargeAndPremium
			WHERE ysnOverride = 1
				AND intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
				AND intCustomerStorageId = QM.intTicketFileId
		) _OVERRIDE
        WHERE DSC.intItemId = CAPD.intOtherChargeItemId
        AND QM.dblGradeReading BETWEEN CAPD_RANGE.dblFrom AND CAPD_RANGE.dblTo
        AND CAPD.intCalculationTypeId = 2 --Range By Grade Reading
    ) RANGE_BY_GRADEREADING

    -- Range By Units Calculation
    OUTER APPLY (
        SELECT
            [dblQty]    =   CASE CAPD.strRateType
                                WHEN 'Per Unit' THEN @dblNetUnits
                                WHEN 'Flat' THEN 1
                            END
            ,[dblCost]  =   CASE 
								WHEN _OVERRIDE.ysnOverride = 1 THEN 
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN ISNULL(_OVERRIDE.dblRate, 0)
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * ISNULL(_OVERRIDE.dblRate, 0)) / @dblTransactionUnits
									END
								ELSE
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN ISNULL(CAPD_RANGE.dblRangeRate, 0)
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * ISNULL(CAPD_RANGE.dblRangeRate, 0)) / @dblTransactionUnits
									END
							END
            ,[dblRate]  =   CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_RANGE.dblRangeRate, 0) END
        FROM tblGRChargeAndPremiumDetailRange CAPD_RANGE
		OUTER APPLY (
			SELECT * 
			FROM @settleStorageChargeAndPremium
			WHERE ysnOverride = 1
				AND intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
				AND intCustomerStorageId = ISNULL(@intCustomerStorageId,intCustomerStorageId)
		) _OVERRIDE
        WHERE CAPD_RANGE.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
			--AND CAPD_RANGE.intChargeAndPremiumDetailId = _OVERRIDE.intChargeAndPremiumDetailId
			AND @dblTransactionUnits BETWEEN CAPD_RANGE.dblFrom AND CAPD_RANGE.dblTo
			AND CAPD.intCalculationTypeId = 1 --Range By Units
    ) RANGE_BY_UNITS

    -- Fixed Rate Calculation
    OUTER APPLY (
        SELECT
            [dblQty]    =   CASE CAPD.strRateType
                                WHEN 'Per Unit' THEN @dblNetUnits
                                WHEN 'Flat' THEN 1
                            END
                            --The "Rate From Location" takes precedence over the default rate.
            ,[dblCost]  =   CASE 
								WHEN _OVERRIDE.ysnOverride = 1 THEN 
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN _OVERRIDE.dblRate
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * _OVERRIDE.dblRate) / @dblTransactionUnits
									END
								ELSE
									CASE CAPD.strRateType
										WHEN 'Per Unit' THEN ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD2.dblRate, 0))
										-- Get prorated cost when rate type is "Flat"
										WHEN 'Flat' THEN (@dblNetUnits * ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD2.dblRate, 0))) / @dblTransactionUnits
									END
							END							
            ,[dblRate]  =   CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD2.dblRate, 0)) END
        FROM tblGRChargeAndPremiumDetail CAPD2
        LEFT JOIN tblGRChargeAndPremiumDetailLocation CAPD_LOC
            ON CAPD_LOC.intChargeAndPremiumDetailId = CAPD2.intChargeAndPremiumDetailId
            AND CAPD_LOC.intCompanyLocationId = @intCompanyLocationId
		OUTER APPLY (
			SELECT * 
			FROM @settleStorageChargeAndPremium
			WHERE ysnOverride = 1
				AND intChargeAndPremiumDetailId = CAPD2.intChargeAndPremiumDetailId
				AND intCustomerStorageId = ISNULL(@intCustomerStorageId,intCustomerStorageId)
		) _OVERRIDE
        WHERE CAPD2.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
		--AND CAPD2.intChargeAndPremiumDetailId = _OVERRIDE.intChargeAndPremiumDetailId
        AND CAPD.intCalculationTypeId = 5 --Fixed Rate
    ) FIXED_RATE

    -- Percentage By Discount Calculation
    OUTER APPLY (
        SELECT
            [dblQty]    =   1        
            ,[dblCost]  =   ABS(
                                -- Discount Cost
                                CASE QM.strDiscountChargeType
                                    WHEN 'Percent' THEN QM.dblDiscountAmount * @dblCost
                                    WHEN 'Dollar' THEN QM.dblDiscountAmount
                                END
                                *
                                -- Qty
                                CASE WHEN QM.strCalcMethod = '3' --Check if Gross Weight Calculation
                                    THEN @dblGrossUnits
                                    ELSE @dblNetUnits
                                END
                            )
                            -- Multiply by Charge/Premium Percentage Rate
                            -- The "Rate From Location" takes precedence over the default rate.
                            * (CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD.dblRate, 0)) END / 100)
            ,[dblRate]  =   CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD.dblRate, 0)) END
        FROM @tblQMDiscountIds QM_ID
        INNER JOIN tblQMTicketDiscount QM
            ON QM.intTicketDiscountId = QM_ID.intId
        INNER JOIN tblGRDiscountScheduleCode DSC
            ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
        LEFT JOIN tblGRChargeAndPremiumDetailLocation CAPD_LOC
            ON CAPD_LOC.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
            AND CAPD_LOC.intCompanyLocationId = @intCompanyLocationId
		OUTER APPLY (
			SELECT * 
			FROM @settleStorageChargeAndPremium
			WHERE ysnOverride = 1
				AND intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
				AND intCustomerStorageId = QM.intTicketFileId
		) _OVERRIDE
        WHERE DSC.intItemId = CAPD.intOtherChargeItemId
        AND CAPD.intCalculationTypeId = 4 --Percentage By Discount
    ) PERCENTAGE_BY_DISCOUNT

    -- Percentage By Item Calculation
    OUTER APPLY (
        SELECT
            [dblQty]    =   1    
            ,[dblCost]  =   (@dblNetUnits * @dblCost)
                            -- Multiply by Charge/Premium Percentage Rate
                            -- The "Rate From Location" takes precedence over the default rate.
                            * (CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD.dblRate, 0)) END / 100)
            ,[dblRate]  =   CASE WHEN _OVERRIDE.ysnOverride = 1 THEN _OVERRIDE.dblRate ELSE ISNULL(CAPD_LOC.dblLocationRate, ISNULL(CAPD.dblRate, 0)) END
        FROM tblGRChargeAndPremiumDetail CAPD2
        LEFT JOIN tblGRChargeAndPremiumDetailLocation CAPD_LOC
            ON CAPD_LOC.intChargeAndPremiumDetailId = CAPD2.intChargeAndPremiumDetailId
            AND CAPD_LOC.intCompanyLocationId = @intCompanyLocationId
		OUTER APPLY (
			SELECT * 
			FROM @settleStorageChargeAndPremium
			WHERE ysnOverride = 1
				AND intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
				AND intCustomerStorageId = ISNULL(@intCustomerStorageId,intCustomerStorageId)
		) _OVERRIDE
        WHERE CAPD2.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId
        AND CAPD2.intInventoryItemId = @intInventoryItemId
        AND CAPD.intCalculationTypeId = 3 --Percentage By Item
    ) PERCENTAGE_BY_ITEM

    WHERE CAP.intChargeAndPremiumId = @intChargeAndPremiumId
    AND (
        (CAPD.dtmEffectiveDate IS NULL AND CAPD.dtmTerminationDate IS NULL)
        OR (
            CAPD.dtmEffectiveDate IS NOT NULL AND CAPD.dtmTerminationDate IS NOT NULL
            AND @dtmCalculateOn BETWEEN CAPD.dtmEffectiveDate AND CAPD.dtmTerminationDate
        )
    )
	--AND _OVERRIDE.intChargeAndPremiumDetailId = CAPD.intChargeAndPremiumDetailId

    RETURN
END