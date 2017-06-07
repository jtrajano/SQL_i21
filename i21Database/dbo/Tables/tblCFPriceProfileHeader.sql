CREATE TABLE [dbo].[tblCFPriceProfileHeader] (
    [intPriceProfileHeaderId] INT             IDENTITY (1, 1) NOT NULL,
    [strPriceProfile]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dblMinimumMargin]        NUMERIC (18, 6) NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblCFPriceProfileHeader_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPriceProfileHeader] PRIMARY KEY CLUSTERED ([intPriceProfileHeaderId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_tblCFPriceProfileHeader_intPriceProfileHeaderId]
    ON [dbo].[tblCFPriceProfileHeader]([intPriceProfileHeaderId] ASC);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFPriceProfileHeader_UniquePriceProfile
	ON tblCFPriceProfileHeader (strPriceProfile);
