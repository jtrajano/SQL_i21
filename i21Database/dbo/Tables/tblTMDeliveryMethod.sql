CREATE TABLE [dbo].[tblTMDeliveryMethod] (
    [intConcurrencyId]    INT           DEFAULT 1 NOT NULL,
    [intDeliveryMethodID] INT           IDENTITY (1, 1) NOT NULL,
    [strDeliveryMethod]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMDeliveryMethod] PRIMARY KEY CLUSTERED ([intDeliveryMethodID] ASC)
);

