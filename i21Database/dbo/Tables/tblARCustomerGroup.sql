CREATE TABLE [dbo].[tblARCustomerGroup] (
    [intCustomerGroupId] INT            IDENTITY (1, 1) NOT NULL,
    [strGroupName]       NVARCHAR (50)  NOT NULL,
    [strDescription]     NVARCHAR (255) NULL,
    [intConcurrencyId]   INT            NOT NULL,
    CONSTRAINT [PK_tblARCustomerGroup] PRIMARY KEY CLUSTERED ([intCustomerGroupId] ASC),
    CONSTRAINT [UKstrGroupName] UNIQUE NONCLUSTERED ([strGroupName] ASC)
);

