CREATE TABLE [dbo].[tblCFPriceProfileHeader] (
    [intPriceProfileHeaderId] INT             IDENTITY (1, 1) NOT NULL,
    [strPriceProfile]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dblMinimumMargin]        NUMERIC (18, 6) NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblCFPriceProfileHeader_intConcurrencyId] DEFAULT ((1)) NULL,
    [ysnGlobalProfile] BIT NULL, 
    [intLinkedProfile] INT NULL, 
    CONSTRAINT [PK_tblCFPriceProfileHeader] PRIMARY KEY CLUSTERED ([intPriceProfileHeaderId] ASC),
	CONSTRAINT [FK_tblCFPriceProfileHeader_tblCFPriceProfileHeader] FOREIGN KEY([intLinkedProfile]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId])
);




GO
CREATE NONCLUSTERED INDEX [IX_tblCFPriceProfileHeader_intPriceProfileHeaderId]
    ON [dbo].[tblCFPriceProfileHeader]([intPriceProfileHeaderId] ASC);

