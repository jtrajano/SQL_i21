CREATE TABLE [dbo].[tblARPOSDetail] (
    [intPOSDetailId]      INT             IDENTITY (1, 1) NOT NULL,
    [intPOSId]            INT             NOT NULL,
    [intItemId]           INT             NULL,
    [strItemNo]           NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]  NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dblQuantity]         NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblQu__1B6860F4] DEFAULT ((0)) NULL,
    [intItemUOMId]        INT             NULL,
    [strItemUOM]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblItemWeight]       NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblIt__1C5C852D] DEFAULT ((0)) NULL,
    [intItemWeightUOMId]  INT             NULL,
    [dblDiscountPercent]  NUMERIC (18, 6) NULL,
    [dblDiscount]         NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblDi__1D50A966] DEFAULT ((0)) NULL,
    [dblItemTermDiscount] NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblIt__1E44CD9F] DEFAULT ((0)) NULL,
    [dblPrice]            NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblPr__1F38F1D8] DEFAULT ((0)) NULL,
    [dblTax]              NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblTo__202D1611] DEFAULT ((0)) NULL,
    [dblExtendedPrice]    NUMERIC (18, 6) CONSTRAINT [DF__tblARPOSD__dblTo__21213A4A] DEFAULT ((0)) NULL,
    [intConcurrencyId]    INT             CONSTRAINT [DF_tblARPOSDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARPOSDetail_intPOSDetailId] PRIMARY KEY CLUSTERED ([intPOSDetailId] ASC),
    CONSTRAINT [FK_tblARPOSDetail] FOREIGN KEY ([intPOSId]) REFERENCES [dbo].[tblARPOS] ([intPOSId]) ON DELETE CASCADE
);

