CREATE TABLE [dbo].[tblARCustomerContract] (
    [intContractId]       INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strContractNumber]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intContractPlanId]   INT            NULL,
    [intLocationId]       INT            NULL,
    [ysnUnlimitedQty]     BIT            NOT NULL DEFAULT ((0)),
    [dtmDateMade]         DATETIME       NULL,
    [dtmDateDue]          DATETIME       NULL,
    [strPrepaid]		  NVARCHAR (6)	 COLLATE Latin1_General_CI_AS NULL,
    [strComments]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowSubstitutes] BIT            NOT NULL DEFAULT ((0)),
    [ysnMaxPrice]         BIT            NOT NULL DEFAULT ((0)),
    [strPickupDelivery]   NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceLevel]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            NOT NULL,
    CONSTRAINT [PK_tblARCustomerContract] PRIMARY KEY CLUSTERED ([intContractId] ASC)
);

