CREATE TYPE [dbo].[CustomerStorageStagingTable] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
    [intEntityId] INT NULL,						-- Entity Id
	[intItemId] INT NULL,						-- Item Id
	[intCommodityId] INT NOT NULL,				-- Commodity Id
	[intCompanyLocationId] INT NOT NULL,		-- Company Location Id
	[intCompanyLocationSubLocationId] INT NULL,	-- Company Sub-Location Id
    [intStorageLocationId] INT NULL,			-- Storage Unit Id
	[dblQuantity] NUMERIC(38, 20) NOT NULL,		-- Distributed Quantity (Net)
    [intStorageTypeId] INT NULL,				-- Storage Type Id
	[intStorageScheduleId] INT NULL,			-- Storage Schedule Id
    [intDiscountScheduleId] INT NULL,			-- Discount Schedule Id
    [dtmDeliveryDate] DATETIME NULL,			-- Transaction Date Ex: Scale Date
    [dblStorageDue] NUMERIC(38, 20) NULL,		--
	[dblFreightDueRate] NUMERIC(38, 20) NULL,	-- Scale Ticket Freight
    [dblFeesDue] NUMERIC(38, 20) NULL,			-- Scale Ticket Fees
	[dblDiscountsDue] NUMERIC(38, 20) NULL,		-- Scale Ticket Discount Amount
	[dblInsuranceRate] NUMERIC(38, 20) NULL,	-- 
	[intCurrencyId] INT NULL,					-- Transaction Currency Id 
	[intDeliverySheetId] INT NULL,				-- Delivery Sheet Id
	[intTicketId] INT NULL,						-- Scale Ticket Id
	[intContractHeaderId] INT NULL,				-- Contract Header Id
	[intContractDetailId] INT NULL,				-- Contract Detail Id
	[intUnitMeasureId] INT NULL,				-- Unit of measure Id Ex: Bushels,Kilogram,Pounds
	[intItemUOMId] INT NULL,					-- UOM Id of Item Unit Quantity
	[strTransactionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, --Storage Ticket number (Ticket or Delivery sheet number)
	[intUserId]	INT NULL,
	-----------********transfer storage**********-----------	
	[dblTotalPriceShrink] NUMERIC(38, 20) NULL,
	[dblTotalWeightShrink] NUMERIC(38, 20) NULL,
	[dtmZeroBalanceDate] DATETIME NULL,
	[strDPARecieptNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastStorageAccrueDate] DATETIME NULL,
    [dblStoragePaid] NUMERIC(18, 6) NULL,
    [strOriginState] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strInsuranceState] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dblFeesPaid] NUMERIC(18, 6) NULL, 
    [ysnPrinted] BIT NULL, 
    [dblCurrencyRate] NUMERIC(18, 8) NULL, 
    [strDiscountComment] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblDiscountsPaid] NUMERIC(18, 6) NULL, 
    [strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intTransferStorageSplitId] INT NULL,
	[ysnTransferStorage] BIT NULL,
	[dblGrossQuantity] NUMERIC(38, 20) NULL, 	-- Distributed Quantity (Gross)
	[intShipFromLocationId] INT NULL,			--Ship From (for Voucher); Farm/Field in DS or Entity Location
	[intShipFromEntityId] INT NULL,				--Ship From Entity (for Voucher)
	[intSourceCustomerStorageId] [int] NULL,
	[dblUnitQty] [numeric](38, 20) NOT NULL DEFAULT ((0)),
	[dblSplitPercent] [numeric](38, 20) NOT NULL DEFAULT ((0)),
	-------------*******Basis and Settlement Price**************------------------------
	[dblBasis] DECIMAL(18, 6) NOT NULL DEFAULT 0,
    [dblSettlementPrice] DECIMAL(18, 6) NOT NULL DEFAULT 0
)