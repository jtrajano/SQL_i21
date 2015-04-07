﻿CREATE TABLE [dbo].[tblSTRetailPriceAdjustmentDetail]
(
	[intRetailPriceAdjustmentDetailId] INT NOT NULL IDENTITY, 
    [intRetailPriceAdjustmentId] INT NOT NULL, 
    [intCompanyLocationId] INT NULL, 
    [strRegion] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
    [strDestrict] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
    [strState] NVARCHAR(2) COLLATE Latin1_General_CI_AS NULL, 
    [intVendorId] INT NULL, 
    [intCategoryId] INT NULL, 
	[intManufacturerId] INT NULL,
    [intFamilyId] INT NULL, 
    [intClassId] INT NULL, 
    [strUpcCode] NVARCHAR(14) COLLATE Latin1_General_CI_AS NULL,
    [strUpcDescription] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL,
    [ysnPromo] BIT NULL, 
    [strPriceMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblFactor] NUMERIC(10, 6) NULL, 
    [dblPrice] NUMERIC(10, 2) NULL, 
    [ysnActive] BIT NULL, 
    [ysnOneTimeuse] BIT NULL, 
    [ysnChangeCost] BIT NULL, 
    [dblCost] NUMERIC(10, 2) NULL, 
    [dtmSalesStartDate] DATETIME NULL, 
    [dtmSalesEndDate] DATETIME NULL, 
	[ysnPosted] BIT NULL, 
	[strPriceType] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTRetailPriceAdjustmentDetail] PRIMARY KEY CLUSTERED ([intRetailPriceAdjustmentDetailId] ASC), 
    CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblSTRetailPriceAdjustment] FOREIGN KEY ([intRetailPriceAdjustmentId]) REFERENCES [tblSTRetailPriceAdjustment]([intRetailPriceAdjustmentId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]), 
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ,
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblICManufacturer] FOREIGN KEY ([intManufacturerId]) REFERENCES [tblICManufacturer]([intManufacturerId]) ,
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblSTSubcategory_intFamilyId] FOREIGN KEY ([intFamilyId]) REFERENCES [tblSTSubcategory]([intSubcategoryId]), 
	CONSTRAINT [FK_tblSTRetailPriceAdjustmentDetail_tblSTSubcategory_intClassId] FOREIGN KEY ([intClassId]) REFERENCES [tblSTSubcategory]([intSubcategoryId]), 
    CONSTRAINT [AK_tblSTRetailPriceAdjustmentDetail] UNIQUE NONCLUSTERED ([intCompanyLocationId],[strRegion],[strDestrict],[intVendorId],[intCategoryId],[intFamilyId],[intClassId],[strUpcCode]) 
)
