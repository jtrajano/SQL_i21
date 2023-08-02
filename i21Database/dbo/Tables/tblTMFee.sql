CREATE TABLE [dbo].[tblTMFee] (
[intConcurrencyId]   INT  DEFAULT 1 NOT NULL,
[intFeeId] INT IDENTITY (1, 1) NOT NULL,
[dtmDateTime] DATETIME        DEFAULT 0 NULL,
[intFeeTypeId]                    INT DEFAULT 0 NULL,
[strDescription]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
[dblAmount]			NUMERIC (18, 6) DEFAULT 0 NULL,
[strCustomers] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
[ysnUniversal]       BIT             DEFAULT 0 NOT NULL,
[ysnEdited]           BIT             DEFAULT 0 NOT NULL,
CONSTRAINT [PK_tblTMFee] PRIMARY KEY ([intFeeId]),
CONSTRAINT [FK_tblTMFee_tblTMFeeType] FOREIGN KEY ([intFeeTypeId]) REFERENCES [dbo].[tblTMFeeType] ([intFeeTypeId])
)