CREATE TABLE [dbo].[tblAGApplicationMethodDetail]
(
    [intApplicationMethodDetailId] INT IDENTITY(1,1) NOT NULL,
    [intApplicationMethodId] INT NULL,
    [intProductMixerId] INT NULL,
    [strStagingLocationType] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [intStagingLocationId] INT NULL,
    [intProductionStagingLocationId] INT NULL,
    [ysnDefault] BIT NOT NULL DEFAULT(0),
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_tblAGApplicationMethodDetail_intApplicationMethodDetailId] PRIMARY KEY CLUSTERED ([intApplicationMethodDetailId] ASC),
    CONSTRAINT [FK_tblAGApplicationMethodDetail_tblAGProductMixer_intProductMixerId] FOREIGN KEY ([intProductMixerId]) REFERENCES [dbo].[tblAGProductMixer] ([intProductMixerId]),
    CONSTRAINT [FK_tblAGApplicationMethodDetail_intApplicationMethodId] FOREIGN KEY ([intApplicationMethodId]) REFERENCES [dbo].[tblAGApplicationMethod] ([intApplicationMethodId])
)