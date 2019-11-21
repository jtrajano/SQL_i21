CREATE TABLE [dbo].[tblSCDiscountType] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intDiscountTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strDiscountType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnActive]        BIT           DEFAULT 0 NOT NULL,
	[intSort] INT   NOT NULL,
	[strDescription]   NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumnHeader]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblSCDiscountType] PRIMARY KEY CLUSTERED ([intDiscountTypeId] ASC),
    CONSTRAINT [UQ_tblSCDiscountType_strDiscountType] UNIQUE NONCLUSTERED ([strDiscountType] ASC)
);


GO