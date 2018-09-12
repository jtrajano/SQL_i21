CREATE TYPE [dbo].[CustomerStorageStagingTable] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
    [intEntityId] INT NULL,						-- Entity Id
	[intItemId] INT NULL,						-- Item Id
	[intCommodityId] INT NOT NULL,				-- Commodity Id
	[intCompanyLocationId] INT NOT NULL,		-- Company Location Id
	[intCompanyLocationSubLocationId] INT NULL,	-- Company Sub-Location Id
    [intStorageLocationId] INT NULL,			-- Storage Unit Id
	[dblQuantity] NUMERIC(38, 20) NOT NULL,		-- Distributed Quantity
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
	[intUserId]	INT NULL						
)