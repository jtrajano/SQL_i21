CREATE TABLE [dbo].[tblLGReasonCode]
(
 [intReasonCodeId] INT NOT NULL IDENTITY,
 [intConcurrencyId] INT NOT NULL,
 [strReasonCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
 [strReasonCodeDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,

 CONSTRAINT [PK_tblLGReasonCode_intReasonCodeId] PRIMARY KEY ([intReasonCodeId]),
 CONSTRAINT [UK_tblLGReasonCode_strReasonCode] UNIQUE ([strReasonCode])
)