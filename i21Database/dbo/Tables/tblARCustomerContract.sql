CREATE TABLE [dbo].[tblARCustomerContract] (
    [intContractId]       INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strContractNumber]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intContractPlanId]   INT            NULL,
    [intLocationId]       INT            NULL,
    [ysnUnlimitedQty]     BIT            NULL,
    [dtmDateMade]         DATETIME       NULL,
    [dtmDateDue]          DATETIME       NULL,
    [ysnPrepaid]          BIT            NULL,
    [strComments]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowSubstitutes] BIT            NULL,
    [ysnMaxPrice]         BIT            NULL,
    [strPickupDelivery]   NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceLevel]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            NOT NULL,
    CONSTRAINT [PK_tblARCustomerContract] PRIMARY KEY CLUSTERED ([intContractId] ASC)
);

