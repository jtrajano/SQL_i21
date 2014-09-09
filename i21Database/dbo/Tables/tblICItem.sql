CREATE TABLE [dbo].[tblICItem] (
    [intItemId]                  INT             IDENTITY (1, 1) NOT NULL,
    [strItemNo]                  NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intItemTypeId]              INT             DEFAULT ((1)) NOT NULL,
    [intVendorId]                INT             NULL,
    [strDescription]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strPOSDescription]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intClassId]                 INT             NULL,
    [intManufacturerId]          INT             NULL,
    [intBrandId]                 INT             NULL,
    [intStatusId]                INT             DEFAULT ((1)) NOT NULL,
    [strModelNo]                 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intCostingMethodId]         INT             DEFAULT ((1)) NOT NULL,
    [intCategoryId]              INT             NULL,
    [intPatronageId]             INT             NULL,
    [intTaxClassId]              INT             NULL,
    [ysnStockedItem]             BIT             DEFAULT ((1)) NOT NULL,
    [ysnDyedFuel]                BIT             DEFAULT ((0)) NOT NULL,
    [strBarCodeIndicator]        NVARCHAR (1)    COLLATE Latin1_General_CI_AS NULL,
    [ysnMSDSRequired]            BIT             DEFAULT ((0)) NOT NULL,
    [strEPANumber]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [ysnInboundTax]              BIT             DEFAULT ((0)) NOT NULL,
    [ysnOutboundTax]             BIT             DEFAULT ((0)) NOT NULL,
    [ysnRestrictedChemical]      BIT             DEFAULT ((0)) NOT NULL,
    [ysnTMTankRequired]          BIT             DEFAULT ((0)) NOT NULL,
    [ysnTMAvailable]             BIT             DEFAULT ((0)) NOT NULL,
    [dblTMPercentFull]           NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [strRINFuelInspectFee]       NVARCHAR (1)    COLLATE Latin1_General_CI_AS NULL,
    [strRINRequired]             NVARCHAR (1)    COLLATE Latin1_General_CI_AS NULL,
    [intRINFuelType]             INT             NULL,
    [dblRINDenaturantPercentage] NUMERIC (18, 6) NULL,
    [ysnFeedTonnageTax]          BIT             DEFAULT ((0)) NOT NULL,
    [strFeedLotTracking]         NVARCHAR (1)    COLLATE Latin1_General_CI_AS NULL,
    [ysnFeedLoadTracking]        BIT             DEFAULT ((0)) NOT NULL,
    [intFeedMixOrder]            INT             NULL,
    [ysnFeedHandAddIngredients]  BIT             DEFAULT ((0)) NOT NULL,
    [intFeedMedicationTag]       INT             NULL,
    [intFeedIngredientTag]       INT             NULL,
    [strFeedRebateGroup]         NVARCHAR (2)    COLLATE Latin1_General_CI_AS NULL,
    [intPhysicalItem]            INT             NULL,
    [ysnExtendOnPickTicket]      BIT             DEFAULT ((0)) NOT NULL,
    [ysnExportEDI]               BIT             DEFAULT ((0)) NOT NULL,
    [ysnHazardMaterial]          BIT             DEFAULT ((0)) NOT NULL,
    [ysnMaterialFee]             BIT             DEFAULT ((0)) NOT NULL,
    [ysnAutoCalculateFreight]    BIT             DEFAULT ((0)) NOT NULL,
    [intFreightMethodId]         INT             NULL,
    [dblFreightRate]             NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [intFreightVendorId]         INT             NULL,
    CONSTRAINT [AK_tblICItem_strItemNo] UNIQUE ([strItemNo]), 
    CONSTRAINT [PK_tblICItem] PRIMARY KEY ([intItemId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intItemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique key that corresponds to the item number. Origin: agitm-no ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strItemNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inventory type (e.g. 1=Inventory Item, 2=Service Item, 3=Finished Goods, 4=Bulk, 5=Pre-Mixes, 6=Raw Materials)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intItemTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default vendor of an item. Origin: agitm-vnd-no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intVendorId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Item Description. Origin: agitm-desc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'POS Description. Origin: stpbk_pos_desc ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strPOSDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a class. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intClassId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a manufacturer. Origin: agitm-mfg-id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intManufacturerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a brand. Origin: stpbk_brand_name ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intBrandId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status of an item (e.g. 1=Active, 2=Phased Out, 3=Discontinued)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Model number of an item. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strModelNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inventory Costing Method (e.g. 1=Average, 2=FIFO, 3=LIFO)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intCostingMethodId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a category (Tracking in the screen). Origin: agitm-class', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intCategoryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a patronage. Origin: agitm-pat-cat-code ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intPatronageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. ?? Origin: agitm-tax-cls', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intTaxClassId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Stocked Item (yes or no). Origin: agitm-stk-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnStockedItem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dyed Fuel (yes or no). Origin: agitm-dyed-fuel-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnDyedFuel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'U=UPC, I=Item, N=None. Origin: agitm-bar-code-ind', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strBarCodeIndicator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MSDS Sheet required indicator (yes or no). Origin: agitm-msds-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnMSDSRequired';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Environmental Protection Agency number. Origin: agitm-epa-no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strEPANumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inbound Tax (yes or no). Origin: agitm-intax-rpt-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnInboundTax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Outbound Tax (yes or no). Origin: agitm-outtax-rpt-yn ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnOutboundTax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Restricted Chemical indicator (yes or no). Origin: agitm-rest-chem-rpt-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnRestrictedChemical';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tank required (yes or no). Origin: agitm-tank-req-yn. Used in TM. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnTMTankRequired';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Available for TM (yes or no). Origin: agitm-avail-tm. Used in TM. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnTMAvailable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default % full. Origin: agitm-deflt-percnt. Used in TM. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'dblTMPercentFull';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fuel Inspect Fee. Y=Yes (Fuel Item), N=No (Not Fuel item), F=No (Fuel Item). Origin: agitm-insp-fee-ynf. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strRINFuelInspectFee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RIN Required. N=No Rin, R=Resell RIN Only, I=Issued. Origin: agitm-rin-req-nri', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strRINRequired';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a Fuel type. Origin: agitm-rin-char-cd & agitm-r. Fuel Category and Feed Stock for the selected Fuel. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intRINFuelType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'% Denaturant. Origin: agitm-rin-pct-denaturant', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'dblRINDenaturantPercentage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tonnage tax (yes or no). Origin: agitm-tontax-rpt-yn ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnFeedTonnageTax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lot Tracking (Y=yes, N=no, S=Serial Number). Origin: agitm-lot-yns', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strFeedLotTracking';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Load Tracking (yes or no). Origin: agitm-load-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnFeedLoadTracking';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mix Order. Origin: agitm-mix-order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intFeedMixOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hand Add Ingredients (yes or no). Origin: agitm-hand-add-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnFeedHandAddIngredients';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. Medication Tag. List of Inventory Tags. Origin: agitm-med-tag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intFeedMedicationTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. Ingredient Tag. List of Inventory Tags. Origin: agitm-invc-tag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intFeedIngredientTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Volume Rebate Group. Origin: agitm-rebate-grp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strFeedRebateGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. Physical item will be inventorized instead of the item name. Origin: ptitm-alt-itm', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intPhysicalItem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Extend on Pick Ticket (yes or no). Origin: ptitm-ext-pic-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnExtendOnPickTicket';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Export EDI (yes or no). Origin: ptitm-edi-yn  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnExportEDI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hazard Material (yes or no). Origion: ptitm-hazmat-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnHazardMaterial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this Material Fee (yes or no). Origin: ptitm-amf-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnMaterialFee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Calculate Freight (yes or no). Origin: ptitm-auto-frt-yn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'ysnAutoCalculateFreight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. Freight Terms. Origin: ptitm-auto-frt-method', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intFreightMethodId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Freight Rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'dblFreightRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. Item may have a vendor that provides Freight services. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intFreightVendorId';

