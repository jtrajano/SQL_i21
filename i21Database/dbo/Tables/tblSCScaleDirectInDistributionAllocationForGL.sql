CREATE TABLE[dbo].[tblSCScaleDirectInDistributionAllocationForGL] 
(
	[intScaleDirectInDistributionAllocationForGLId]	INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,[intAllocationType] INT NOT NULL						-- 1-Contract, 2-Load, 3-storage, 4-spot
	,[dblQuantity] NUMERIC(38, 20) NOT NULL DEFAULT 0	
	,[intEntityId] INT NULL	
	,[intContractDetailId] INT NULL	
	,[intLoadDetailId]  INT NULL	
	,[intStorageScheduleId]  INT NULL
	,[intStorageScheduleTypeId] INT NULL					
	,[dblFuture] NUMERIC(18, 6)
	,[dblBasis] NUMERIC(18, 6)
	,intTicketDistributionAllocationId INT NULL
	,intTicketId INT NOT NULL
)
