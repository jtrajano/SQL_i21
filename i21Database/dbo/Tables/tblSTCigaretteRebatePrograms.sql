CREATE TABLE [dbo].[tblSTCigaretteRebatePrograms]
(
    [intCigaretteRebateProgramId] INT NOT NULL IDENTITY,
    [strStoreIdList] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intEntityVendorId] INT NULL,   
    [dtmStartDate] DATETIME NULL,
    [dtmEndDate] DATETIME NULL,
	[strPromotionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strProgramName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [dblManufacturerBuyDownAmount] NUMERIC(18, 6) NULL,
	[ysnMultipackFGI] BIT,
	[strManufacturerPromotionDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [dblManufacturerDiscountAmount] NUMERIC(18, 6) NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblSTCigaretteRebatePrograms] PRIMARY KEY CLUSTERED ([intCigaretteRebateProgramId] ASC),
    CONSTRAINT [FK_tblSTCigaretteRebatePrograms_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblEMEntity]([intEntityId]),
)
