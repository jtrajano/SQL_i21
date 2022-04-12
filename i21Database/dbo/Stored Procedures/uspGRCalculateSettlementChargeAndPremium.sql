/* The result of this query must have the same columns with vyuGRSettlementChargeAndPremium  */
CREATE PROCEDURE [dbo].[uspGRCalculateSettlementChargeAndPremium]
	@SettleStorageTicketInput AS SettleStorageTicket READONLY,
    @SettleContractInput AS SettleContract READONLY,
	@SettleStorageChargeAndPremium AS SettleStorageChargeAndPremium READONLY,
    @dblSpotUnits DECIMAL(18,6),
    @dblSpotCashPrice DECIMAL(18,6),
    @intSpotCashPriceUOMId INT,
    @dtmCalculateOn DATETIME
AS
BEGIN TRY
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSettleStorageKey INT
	DECLARE @intCustomerStorageId INT
	DECLARE @dblRemainingUnits DECIMAL(18,6)
	DECLARE @dblRemainingSpotUnits DECIMAL(18,6)
	DECLARE @dblContractRemainingUnits DECIMAL(18,6)
	DECLARE @intContractDetailId INT
	DECLARE @intContractPricingTypeId INT
	DECLARE @dblCashPrice DECIMAL(18,6)
	DECLARE @intCompanyLocationId INT
	DECLARE @intNewSettleStorageId INT
	DECLARE @intSettleContractId INT
	DECLARE @dblFutures DECIMAL(18,6)
	DECLARE @dblBasis DECIMAL(18,6)
	DECLARE @dblTotalUnitsForSettle DECIMAL(18,6)
	DECLARE @strType NVARCHAR(20)
	DECLARE @intPriceFixationDetailId INT
	DECLARE @dblPriceFixationRemainingUnits DECIMAL(18,6)
    DECLARE @tblQMDiscountIds Id
	DECLARE @dblVoucherUnits DECIMAL(18,6)
	DECLARE @dblVoucherAmount DECIMAL(18,6)
	DECLARE @ysnSpot BIT
    DECLARE @strMissingUOMItemNo NVARCHAR(50)
    DECLARE @strMissingUOM NVARCHAR(50)

    DECLARE @Result AS TABLE 
	(
        [intAppliedChargeAndPremiumId]  INT NULL
        ,[intTransactionId]             INT NULL
        ,[intTransactionDetailId]		INT NULL
        ,[strTransactionType]    		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
        ,[intParentSettleStorageId]     INT NULL
        ,[intCustomerStorageId] 		INT NOT NULL
        ,[strStorageTicketNumber] 		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
        ,[intChargeAndPremiumId]		INT NOT NULL
        ,[strChargeAndPremiumId]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
        ,[intChargeAndPremiumDetailId]	INT NOT NULL
        ,[intChargeAndPremiumItemId]	INT NOT NULL
        ,[strChargeAndPremiumItemNo]	NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL
        ,[intCalculationTypeId]			INT NOT NULL
        ,[strCalculationType]           NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
        ,[dblRate]						DECIMAL(18,6)
        ,[strRateType]					NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
        ,[dblQty]						DECIMAL(38, 20) NOT NULL
        ,[intChargeAndPremiumItemUOMId]	INT NOT NULL
        ,[strChargeAndPremiumItemUOM]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
        ,[dblCost]						DECIMAL(38, 20) NOT NULL 
        ,[dblAmount]					DECIMAL(38, 20) NOT NULL 
        ,[intOtherChargeItemId]			INT NULL
        ,[strOtherChargeItemNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[intCtOtherChargeItemId]		INT NULL
        ,[strCtOtherChargeItemNo]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
        ,[intInventoryItemId]			INT NULL
        ,[strInventoryItemNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
        ,[dblInventoryItemNetUnits]		DECIMAL(38, 20) NOT NULL 
        ,[dblInventoryItemGrossUnits]	DECIMAL(38, 20) NOT NULL
		,[dblGradeReading]				DECIMAL(18,6)
	)

	DECLARE @SettleStorageToSave AS TABLE 
	(
		intSettleStorageKey INT IDENTITY(1, 1)
		,intCustomerStorageId INT
		,dblSpotUnits DECIMAL(18,6)
		,dblFutures DECIMAL(18,6)
		,dblBasis DECIMAL(18,6)
		,dblSpotCashPrice DECIMAL(18,6)
		,intContractDetailId INT
		,dblContractUnits DECIMAL(18,6)
		,dblCashPrice DECIMAL(18,6)
		,intContractPricingTypeId INT
        ,intPriceFixationDetailId INT NULL
	)

	DECLARE @SettleStorage AS TABLE 
	(
		intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageTicketId INT 
		,intCustomerStorageId INT
		,dblRemainingUnits DECIMAL(18,6)
		,dblRemainingSpotUnits DECIMAL(18,6)
	)

	DECLARE @SettleContract AS TABLE 
	(	
		intSettleContractId INT
		,intContractDetailId INT
		,dblContractRemaningUnits DECIMAL(18,6)
		,dblCashPrice DECIMAL(18,6)
		,intPricingTypeId INT
	)

    DECLARE @SettleContractPricingFixation AS TABLE 
	(	
        intId INT
        ,intPricingFixationDetailId INT
		,intContractDetailId INT
		,dblContractRemaningUnits DECIMAL(18,6)
		,dblFinalPrice DECIMAL(18,6)
	)
	 
	INSERT INTO @SettleStorage
	(
		 intSettleStorageTicketId
		,intCustomerStorageId
		,dblRemainingUnits
		,dblRemainingSpotUnits
	)
	SELECT 
		 intSettleStorageTicketId	= ROW_NUMBER() OVER(ORDER BY (SELECT 1))
		,intCustomerStorageId		= SST.intCustomerStorageId
		,dblRemainingUnits			= SST.dblUnits
		,dblRemainingSpotUnits		= @dblSpotUnits
	FROM @SettleStorageTicketInput SST

	INSERT INTO @SettleContract 
	(
		intSettleContractId
		,intContractDetailId
		,dblContractRemaningUnits
		,dblCashPrice
		,intPricingTypeId
	)
    SELECT
        intSettleContractId			= ROW_NUMBER() OVER(ORDER BY (SELECT 1))
        ,intContractDetailId		= SSC.intContractDetailId
        ,dblContractRemaningUnits	= SSC.dblUnits
        ,dblCashPrice				= CASE WHEN ISNULL(CD.dblCashPrice,0) > 0 THEN CD.dblCashPrice ELSE ISNULL(CD.dblBasis,0) + ISNULL(CD.dblFutures,0) END
        ,intPricingTypeId			= CD.intPricingTypeId
    FROM @SettleContractInput SSC
    INNER JOIN tblCTContractDetail CD
        ON CD.intContractDetailId = SSC.intContractDetailId

    INSERT INTO @SettleContractPricingFixation (
        intId
        ,intPricingFixationDetailId
        ,intContractDetailId
        ,dblContractRemaningUnits
        ,dblFinalPrice
    )
    SELECT
        APV.intId
        ,APV.intPriceFixationDetailId
        ,APV.intContractDetailId
        ,APV.dblAvailableQuantity
        ,APV.dblFinalprice
    FROM  @SettleContract SC
    OUTER APPLY (
		SELECT
            APV.intId
            ,APV.intPriceFixationDetailId
            ,APV.intContractDetailId
            ,APV.dblAvailableQuantity
            ,APV.dblFinalprice
        FROM vyuCTGetAvailablePriceForVoucher APV
        WHERE APV.intContractDetailId = SC.intContractDetailId
        -- This Group By Speeds up the performance of this query :)
		GROUP BY
            APV.intId
            ,APV.intPriceFixationDetailId
            ,APV.intContractDetailId
            ,APV.dblAvailableQuantity
            ,APV.dblFinalprice
    ) APV
    WHERE APV.dblAvailableQuantity > 0
    AND SC.intPricingTypeId = 2

    -- LOOP THRU SETTLE STORAGE TICKETS
	WHILE EXISTS(SELECT TOP 1 1 FROM @SettleStorage)
	BEGIN
		SET @intSettleStorageKey = NULL
		SET @intCustomerStorageId = NULL
		SET @dblRemainingUnits = NULL
		SET @dblRemainingSpotUnits = NULL

		SELECT TOP 1
			@intSettleStorageKey		= intSettleStorageKey
			,@intCustomerStorageId		= intCustomerStorageId
			,@dblRemainingUnits			= dblRemainingUnits
			,@dblRemainingSpotUnits		= dblRemainingSpotUnits
		FROM @SettleStorage
		ORDER BY intSettleStorageKey

		--LOOP THRU CONTRACTS
		WHILE EXISTS(SELECT TOP 1 1 FROM @SettleContract)
		BEGIN 
			SET @dblContractRemainingUnits = NULL
			SET @intContractDetailId = NULL
			SET @intContractPricingTypeId = NULL
			SET @dblCashPrice = NULL

			SELECT @dblRemainingUnits = dblRemainingUnits FROM @SettleStorage WHERE intSettleStorageKey = @intSettleStorageKey

			SELECT TOP 1 
				@intSettleContractId		= intSettleContractId
				,@intContractDetailId		= intContractDetailId
				,@dblContractRemainingUnits	= dblContractRemaningUnits
				,@intContractPricingTypeId	= intPricingTypeId
				,@dblCashPrice				= dblCashPrice
			FROM @SettleContract
			ORDER BY intSettleContractId
			
			IF ISNULL(@dblRemainingUnits,0) > 0
			BEGIN
				IF ISNULL(@dblContractRemainingUnits,0) > 0
				BEGIN
                    -- Process Basis Contract Units
					IF @intContractPricingTypeId = 2
                    BEGIN
                        -- Loop through each pricing layer of the basis contract that has available units
                        WHILE ISNULL(@dblContractRemainingUnits,0) > 0 AND EXISTS (
                            SELECT TOP 1 1
                            FROM @SettleContractPricingFixation
                            WHERE intContractDetailId = @intContractDetailId
                            AND dblContractRemaningUnits > 0
                        )
                        BEGIN
                            -- Get first available pricing layer 
                            SELECT TOP 1 
                                @intPriceFixationDetailId	        = intPricingFixationDetailId
                                ,@dblPriceFixationRemainingUnits	= dblContractRemaningUnits
                                ,@dblCashPrice                      = dblFinalPrice
                            FROM @SettleContractPricingFixation
                            WHERE dblContractRemaningUnits > 0
                            AND intContractDetailId = @intContractDetailId
                            ORDER BY intId
                            -- Insert priced basis contract units
                            INSERT INTO @SettleStorageToSave
                            (
                                intCustomerStorageId
                                ,dblSpotUnits
                                ,dblFutures
                                ,dblBasis
                                ,dblSpotCashPrice
                                ,intContractDetailId
                                ,dblContractUnits
                                ,dblCashPrice
                                ,intContractPricingTypeId
                                ,intPriceFixationDetailId
                            )
                            SELECT
                                intCustomerStorageId		= @intCustomerStorageId
                                ,dblSpotUnits				= 0
                                ,dblFutures					= 0
                                ,dblBasis					= 0
                                ,dblSpotCashPrice			= 0
                                ,intContractDetailId		= @intContractDetailId
                                ,dblContractUnits			= CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END
                                ,dblCashPrice				= @dblCashPrice
                                ,intContractPricingTypeId	= @intContractPricingTypeId
                                ,intPriceFixationDetailId   = @intPriceFixationDetailId
                            
                            -- Deplete units of settle storage ticket
                            UPDATE @SettleStorage
                            SET dblRemainingUnits = @dblRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                            WHERE intCustomerStorageId = @intCustomerStorageId
                            
                            -- Deplete units of settle contract
                            UPDATE @SettleContract
                            SET dblContractRemaningUnits = @dblContractRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                            WHERE intSettleContractId = @intSettleContractId

                            -- Deplete units of contract pricing layer
                            UPDATE @SettleContractPricingFixation
                            SET dblContractRemaningUnits = @dblPriceFixationRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                            WHERE intPricingFixationDetailId = @intPriceFixationDetailId

                            -- Deplete units of remaining storage units
                            SET @dblRemainingUnits = @dblRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)

                            -- Deplete units of remaining contract units
                            SET @dblContractRemainingUnits = @dblContractRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                        END
                        
                        -- Check if there are still remaining units of unpriced basis contract
                        IF ISNULL(@dblContractRemainingUnits, 0) > 0
                        BEGIN
                            -- Insert remaining unpriced basis contract units
                            INSERT INTO @SettleStorageToSave
                            (
                                intCustomerStorageId
                                ,dblSpotUnits
                                ,dblFutures
                                ,dblBasis
                                ,dblSpotCashPrice
                                ,intContractDetailId
                                ,dblContractUnits
                                ,dblCashPrice
                                ,intContractPricingTypeId
                            )
                            SELECT
                                intCustomerStorageId		= @intCustomerStorageId
                                ,dblSpotUnits				= 0
                                ,dblFutures					= 0
                                ,dblBasis					= 0
                                ,dblSpotCashPrice			= 0
                                ,intContractDetailId		= @intContractDetailId
                                ,dblContractUnits			= CASE 
                                                                WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
                                                                ELSE @dblRemainingUnits
                                                            END
                                                            -- Unpriced basis units has no cash price
                                ,dblCashPrice				= 0
                                ,intContractPricingTypeId	= @intContractPricingTypeId
                            
                            -- Deplete units of settle storage ticket
                            UPDATE @SettleStorage
                            SET dblRemainingUnits = @dblRemainingUnits - @dblContractRemainingUnits
                            WHERE intCustomerStorageId = @intCustomerStorageId

                            -- Deplete units of unpriced basis contract
                            UPDATE @SettleContract
                            SET dblContractRemaningUnits = @dblContractRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
                                                                ELSE @dblRemainingUnits
                                                            END)
                            WHERE intSettleContractId = @intSettleContractId

                            -- Deplete units of remaining storage units
                            SET @dblRemainingUnits = @dblRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                        END
                    END
                    -- Process Non-Basis Contract Units
                    ELSE
                    BEGIN
                        INSERT INTO @SettleStorageToSave
                        (
                            intCustomerStorageId
                            ,dblSpotUnits
                            ,dblFutures
                            ,dblBasis
                            ,dblSpotCashPrice
                            ,intContractDetailId
                            ,dblContractUnits
                            ,dblCashPrice
                            ,intContractPricingTypeId
                        )
                        SELECT
                            intCustomerStorageId		= @intCustomerStorageId
                            ,dblSpotUnits				= 0
                            ,dblFutures					= 0
                            ,dblBasis					= 0
                            ,dblSpotCashPrice			= 0
                            ,intContractDetailId		= @intContractDetailId
                            ,dblContractUnits			= CASE 
                                                            WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
                                                            ELSE @dblRemainingUnits
                                                        END
                            ,dblCashPrice				= @dblCashPrice
                            ,intContractPricingTypeId	= @intContractPricingTypeId
                        
                        -- Deplete units of settle storage ticket
                        UPDATE @SettleStorage
                        SET dblRemainingUnits = @dblRemainingUnits - @dblContractRemainingUnits
                        WHERE intCustomerStorageId = @intCustomerStorageId
                        
                        -- Deplete units of non-basis contract
                        UPDATE @SettleContract
                        SET dblContractRemaningUnits = @dblContractRemainingUnits - (CASE 
                                                            WHEN ISNULL(@dblRemainingUnits,0) >= ISNULL(@dblContractRemainingUnits,0) THEN @dblContractRemainingUnits
                                                            ELSE @dblRemainingUnits
                                                        END)
                        WHERE intSettleContractId = @intSettleContractId

                        -- Deplete remaining storage units
                        SET @dblRemainingUnits = @dblRemainingUnits - (CASE 
                                                                WHEN ISNULL(@dblContractRemainingUnits,0) >= ISNULL(@dblPriceFixationRemainingUnits,0) THEN @dblPriceFixationRemainingUnits
                                                                ELSE @dblContractRemainingUnits
                                                            END)
                    END
				END
                -- Once the contract is exhausted, delete contract from the staging table
                ELSE
				BEGIN
					DELETE FROM @SettleContract WHERE intSettleContractId = @intSettleContractId
				END
			END
			ELSE
			BEGIN
				BREAK;
			END
		END
		
		--SPOT UNITS
		IF ISNULL(@dblRemainingUnits,0) > 0 AND ISNULL(@dblRemainingSpotUnits,0) > 0
		BEGIN
			SELECT TOP 1 @dblRemainingUnits	= dblRemainingUnits FROM @SettleStorage WHERE intSettleStorageKey = @intSettleStorageKey

			INSERT INTO @SettleStorageToSave
			(
				intCustomerStorageId
				,dblSpotUnits
				,dblFutures
				,dblBasis
				,dblSpotCashPrice
				,intContractDetailId
				,dblContractUnits
				,dblCashPrice
				,intContractPricingTypeId
			)
			SELECT
				intCustomerStorageId		= @intCustomerStorageId
				,dblSpotUnits				= CASE 
												WHEN @dblRemainingUnits >= @dblRemainingSpotUnits THEN @dblRemainingSpotUnits
												ELSE @dblRemainingUnits
											END
				,dblFutures					= @dblFutures
				,dblBasis					= @dblBasis
				,dblSpotCashPrice			= @dblSpotCashPrice
				,intContractDetailId		= 0
				,dblContractUnits			= 0
				,dblCashPrice				= 0
				,intContractPricingTypeId	= -1
				
			UPDATE @SettleStorage
			SET dblRemainingUnits = @dblRemainingUnits - @dblRemainingSpotUnits
			WHERE intCustomerStorageId = @intCustomerStorageId
		END

		IF ISNULL(@dblRemainingUnits,0) <= 0 or ISNULL(@dblRemainingUnits,0) <= 0.01
		BEGIN
			DELETE FROM @SettleStorage WHERE intCustomerStorageId = @intCustomerStorageId
		END
	END

	SET @intContractDetailId = NULL

    -- Loop through each simulated settle storage voucher and calculate the charges and premiums
    DECLARE @C AS CURSOR;
    SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intCustomerStorageId
            ,dblUnits               =   SUM(CASE WHEN intContractDetailId > 0 
                                            THEN dblContractUnits
                                            ELSE dblSpotUnits
                                        END)
            ,dblSubTotalAmount      =   SUM(CASE WHEN intContractDetailId > 0 
                                            THEN dblContractUnits * dblCashPrice
                                            ELSE dblSpotUnits * dblSpotCashPrice
                                        END)
            ,ysnSpot                =   CAST(CASE WHEN intContractDetailId > 0 THEN 0 ELSE 1 END AS BIT)
			,intContractDetailId
        FROM @SettleStorageToSave SSTS
        WHERE intContractPricingTypeId <> 2
        OR (intContractPricingTypeId = 2 AND intPriceFixationDetailId IS NOT NULL)
        GROUP BY
            intCustomerStorageId
            ,(CASE WHEN intContractDetailId > 0 THEN 0 ELSE 1 END)
			,intContractDetailId
    OPEN @C  
    FETCH NEXT FROM @C INTO @intCustomerStorageId, @dblVoucherUnits, @dblVoucherAmount, @ysnSpot, @intContractDetailId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate and Store the Charges and Premium for the current storage ticket
        DELETE FROM @tblQMDiscountIds
        -- Get storage ticket discounts
        INSERT INTO @tblQMDiscountIds
        SELECT QM.intTicketDiscountId
        FROM tblQMTicketDiscount QM
        WHERE QM.intTicketFileId = @intCustomerStorageId
        AND QM.strSourceType = 'Storage'

        -- For Charges/Premiums with Rate Type of 'Per Unit', there must be a similar UOM conversion with the inventory item in order to calculate the units correctly.
        -- Throw an error if there's no matching UOM conversion in the Charge/Premium item.
        SET @strMissingUOMItemNo = NULL
        SET @strMissingUOM = NULL

        SELECT TOP 1
            @strMissingUOMItemNo = CAP.strChargeAndPremiumItemNo
            ,@strMissingUOM = ISNULL(TO_UOM.strUnitMeasure, FROM_UOM.strUnitMeasure)
        FROM tblGRCustomerStorage CS
        INNER JOIN @SettleStorageTicketInput SSTI
            ON SSTI.intCustomerStorageId = CS.intCustomerStorageId
        OUTER APPLY (
            SELECT *
            FROM dbo.fnGRCalculateChargeAndPremium (
                SSTI.intChargeAndPremiumId --Charge And Premium Header Id
                ,CS.intItemId --Inventory Item Id
                ,CS.intCompanyLocationId --Company Location Id
                ,@dblVoucherUnits --Net Units
                ,@dblVoucherUnits + ((1 - (CS.dblOriginalBalance/CS.dblGrossQuantity)) * @dblVoucherUnits) --Gross Units
                ,@dblVoucherUnits --Transaction/Voucher Total Units
                ,@tblQMDiscountIds --Storage Ticket Discount Ids
                ,@dblVoucherAmount / @dblVoucherUnits --Inventory Item Cost
                ,@dtmCalculateOn --Calculate On
				,@SettleStorageChargeAndPremium
				,CS.intCustomerStorageId
				,@intContractDetailId
            ) CAP
        ) CAP
		LEFT JOIN @SettleStorageChargeAndPremium SSCP
			ON SSCP.intCustomerStorageId = SSTI.intCustomerStorageId
				AND SSCP.intChargeAndPremiumDetailId = CAP.intChargeAndPremiumDetailId
        LEFT JOIN tblICItemUOM SPOT_UOM
            ON CS.intItemId = SPOT_UOM.intItemId
            AND SPOT_UOM.intItemUOMId = @intSpotCashPriceUOMId
        LEFT JOIN tblICUnitMeasure FROM_UOM
            ON FROM_UOM.intUnitMeasureId = CS.intUnitMeasureId
        LEFT JOIN tblICUnitMeasure TO_UOM
            ON TO_UOM.intUnitMeasureId = (CASE WHEN @ysnSpot = 1 THEN SPOT_UOM.intUnitMeasureId ELSE CS.intUnitMeasureId END)
        LEFT JOIN tblICItemUOM CAP_UOM_FROM
            ON CAP_UOM_FROM.intItemId = CAP.intChargeAndPremiumItemId
            AND CAP_UOM_FROM.intUnitMeasureId = CS.intUnitMeasureId
        LEFT JOIN tblICItemUOM CAP_UOM_TO
            ON CAP_UOM_TO.intItemId = CAP.intChargeAndPremiumItemId
            AND CAP_UOM_TO.intUnitMeasureId = CASE WHEN @ysnSpot = 1 THEN SPOT_UOM.intUnitMeasureId ELSE CS.intUnitMeasureId END
        WHERE CS.intCustomerStorageId = @intCustomerStorageId
        AND CAP.strRateType = 'Per Unit'
        AND CAP.dblCost <> 0
        AND (CAP_UOM_FROM.intItemUOMId IS NULL OR CAP_UOM_TO.intItemUOMId IS NULL)

        IF @strMissingUOMItemNo IS NOT NULL
        BEGIN
            SET @ErrMsg = 'Charge/Premium Item ' + @strMissingUOMItemNo + ' has a missing conversion to UOM ' + @strMissingUOM + '.'
            RAISERROR (@ErrMsg, 16, 1);
        END

        INSERT INTO @Result
        (
            [intTransactionId]
            ,[intTransactionDetailId]
            ,[strTransactionType]
            ,[intParentSettleStorageId]
            ,[intCustomerStorageId]
            ,[strStorageTicketNumber]
            ,[intChargeAndPremiumId]
            ,[strChargeAndPremiumId]
            ,[intChargeAndPremiumDetailId]
            ,[intChargeAndPremiumItemId]
            ,[strChargeAndPremiumItemNo]
            ,[intCalculationTypeId]
            ,[strCalculationType]
            ,[dblRate]
            ,[strRateType]
            ,[dblQty]
            ,[intChargeAndPremiumItemUOMId]
            ,[strChargeAndPremiumItemUOM]
            ,[dblCost]
            ,[dblAmount]
            ,[intOtherChargeItemId]
            ,[strOtherChargeItemNo]
			,[intCtOtherChargeItemId]
            ,[strCtOtherChargeItemNo]
            ,[intInventoryItemId]
            ,[strInventoryItemNo]
            ,[dblInventoryItemNetUnits]
            ,[dblInventoryItemGrossUnits]
			,[dblGradeReading]
        )
        SELECT
            [intTransactionId]				= NULL
            ,[intTransactionDetailId]		= NULL
            ,[strTransactionType]			= 'Settlement'
            ,[intParentSettleStorageId]     = NULL
            ,[intCustomerStorageId]         = CS.intCustomerStorageId
            ,[strStorageTicketNumber]       = CS.strStorageTicketNumber
            ,[intChargeAndPremiumId]		= CAP.intChargeAndPremiumId
            ,[strChargeAndPremiumId]		= CAP.strChargeAndPremiumId
            ,[intChargeAndPremiumDetailId]	= CAP.intChargeAndPremiumDetailId
            ,[intChargeAndPremiumItemId]	= CAP.intChargeAndPremiumItemId
            ,[strChargeAndPremiumItemNo]    = CAP.strChargeAndPremiumItemNo
            ,[intCalculationTypeId]			= CAP.intCalculationTypeId
            ,[strCalculationType]			= CAP.strCalculationType
            ,[dblRate]						= CAP.dblRate
            ,[strRateType]					= CAP.strRateType
            ,[dblQty]						= 	CASE WHEN CAP.strRateType = 'Per Unit'
                                                    THEN dbo.fnCalculateQtyBetweenUOM(CAP_UOM_FROM.intItemUOMId, CAP_UOM_TO.intItemUOMId, CAP.dblQty)
                                                    ELSE CAP.dblQty
                                                END
            ,[intChargeAndPremiumItemUOMId]	=	CASE WHEN CAP.strRateType = 'Per Unit'
                                                    THEN CAP_UOM_TO.intItemUOMId
                                                    ELSE CAP.intChargeAndPremiumItemUOMId
                                                END
            ,[strChargeAndPremiumItemUOM]   = CAP.strChargeAndPremiumUnitMeasure
            ,[dblCost]						=   CASE WHEN CAP.strRateType = 'Per Unit'
                                                    THEN dbo.fnCalculateQtyBetweenUOM(CAP_UOM_TO.intItemUOMId, CAP_UOM_FROM.intItemUOMId, CAP.dblCost)
                                                    ELSE CAP.dblCost
                                                END
            ,[dblAmount]					= CAP.dblAmount
            ,[intOtherChargeItemId]			= CAP.intOtherChargeItemId
            ,[strOtherChargeItemNo]			= CAP.strOtherChargeItemNo
			,[intCtOtherChargeItemId]		= CAP.intCtOtherChargeItemId
            ,[strCtOtherChargeItemNo]		= CAP.strCtOtherChargeItemNo
            ,[intInventoryItemId]			= CAP.intInventoryItemId
            ,[strInventoryItemNo]			= CAP.strInventoryItemNo
            ,[dblInventoryItemNetUnits]		= @dblVoucherUnits
            ,[dblInventoryItemGrossUnits]	= @dblVoucherUnits + ((1 - (CS.dblOriginalBalance/CS.dblGrossQuantity)) * @dblVoucherUnits)
			,[dblGradeReading]				= CAP.dblGradeReading
        FROM tblGRCustomerStorage CS
        INNER JOIN @SettleStorageTicketInput SSTI
            ON SSTI.intCustomerStorageId = CS.intCustomerStorageId		
        OUTER APPLY (
            SELECT *
            FROM dbo.fnGRCalculateChargeAndPremium (
                SSTI.intChargeAndPremiumId --Charge And Premium Header Id
                ,CS.intItemId --Inventory Item Id
                ,CS.intCompanyLocationId --Company Location Id
                ,@dblVoucherUnits --Net Units
                ,@dblVoucherUnits + ((1 - (CS.dblOriginalBalance/CS.dblGrossQuantity)) * @dblVoucherUnits) --Gross Units
                ,@dblVoucherUnits --Transaction/Voucher Total Units
                ,@tblQMDiscountIds --Storage Ticket Discount Ids
                ,@dblVoucherAmount / @dblVoucherUnits --Inventory Item Cost
                ,@dtmCalculateOn --Calculate On
				,@SettleStorageChargeAndPremium
				,CS.intCustomerStorageId
				,@intContractDetailId
            ) CAP
        ) CAP
		LEFT JOIN @SettleStorageChargeAndPremium SSCP
			ON SSCP.intCustomerStorageId = SSTI.intCustomerStorageId
				AND SSCP.intChargeAndPremiumDetailId = CAP.intChargeAndPremiumDetailId
        LEFT JOIN tblICItemUOM SPOT_UOM
            ON CS.intItemId = SPOT_UOM.intItemId
            AND SPOT_UOM.intItemUOMId = @intSpotCashPriceUOMId
        LEFT JOIN tblICItemUOM CAP_UOM_FROM
            ON CAP_UOM_FROM.intItemId = CAP.intChargeAndPremiumItemId
            AND CAP_UOM_FROM.intUnitMeasureId = CS.intUnitMeasureId
        LEFT JOIN tblICItemUOM CAP_UOM_TO
            ON CAP_UOM_TO.intItemId = CAP.intChargeAndPremiumItemId
            AND CAP_UOM_TO.intUnitMeasureId = CASE WHEN @ysnSpot = 1 THEN SPOT_UOM.intUnitMeasureId ELSE CS.intUnitMeasureId END
        WHERE CAP.dblAmount <> 0
            AND CS.intCustomerStorageId = @intCustomerStorageId

        FETCH NEXT FROM @C INTO @intCustomerStorageId, @dblVoucherUnits, @dblVoucherAmount, @ysnSpot, @intContractDetailId;
    END
    CLOSE @C
    DEALLOCATE @C

    SELECT * FROM @Result
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH