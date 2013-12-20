CREATE TABLE [dbo].[tblTMDeliveryMethod] (
    [intConcurrencyID]    INT           CONSTRAINT [DEF_tblTMDeliveryMethod_intConcurrencyID] DEFAULT ((0)) NULL,
    [intDeliveryMethodID] INT           IDENTITY (1, 1) NOT NULL,
    [strDeliveryMethod]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDeliveryMethod_strDeliveryMethod] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMDeliveryMethod] PRIMARY KEY CLUSTERED ([intDeliveryMethodID] ASC)
);

