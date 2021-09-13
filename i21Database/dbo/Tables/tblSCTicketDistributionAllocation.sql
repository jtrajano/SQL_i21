CREATE TABLE [dbo].[tblSCTicketDistributionAllocation]
(
	[intTicketDistributionAllocationId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [intSourceId] INT NOT NULL, 
    [intSourceType] INT NOT NULL, -- 1-contractused,2-loadused,3-storageused,4-spotused
	CONSTRAINT [PK_tblSCTicketDistributionAllocation_intTicketDistributionAllocationId] PRIMARY KEY (intTicketDistributionAllocationId) 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketDistributionAllocation_intTicketId_intSourceId_intSourceType] ON [dbo].[tblSCTicketDistributionAllocation]
    ([intTicketId] ASC) INCLUDE([intSourceId],[intSourceType])
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketDistributionAllocation_intTicketDistributionAllocationId] ON [dbo].[tblSCTicketDistributionAllocation]
(
	[intTicketDistributionAllocationId] ASC
)INCLUDE([intTicketId],[intSourceId],[intSourceType])
GO