CREATE TABLE [dbo].[tblTMFeeType](
[intConcurrencyId]            INT             DEFAULT 1 NOT NULL,
[intFeeTypeId]                   INT             IDENTITY (1, 1) NOT NULL,
[strFeeTypeDescription]              NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
CONSTRAINT [PK_tblTMFeeType] PRIMARY KEY CLUSTERED ([intFeeTypeId] ASC)
)
