CREATE TABLE [dbo].[tblTMLostCustomerReason] (
    [intLostCustomerReasonId]   INT           IDENTITY (1, 1) NOT NULL,
    [strLostCustomerReason] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMLostCustomerReason] PRIMARY KEY CLUSTERED ([intLostCustomerReasonId] ASC),
    CONSTRAINT [UQ_tblTMFillGroup_strLostCustomerReason] UNIQUE NONCLUSTERED ([strLostCustomerReason] ASC)
);
