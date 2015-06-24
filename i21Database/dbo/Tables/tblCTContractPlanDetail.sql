CREATE TABLE [dbo].[tblCTContractPlanDetail]
(
	[intContractPlanDetailId] INT IDENTITY(1,1) NOT NULL, 
    [intContractPlanId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [intAccountStatusId] INT NOT NULL, 
    [dblAdjust] NUMERIC(5, 2) NOT NULL, 
    [dblQuantity] NUMERIC(12, 4) NOT NULL,

	CONSTRAINT [PK_tblCTContractPlanDetail_intContractPlanDetailId] PRIMARY KEY CLUSTERED ([intContractPlanDetailId] ASC),
	CONSTRAINT [FK_tblCTContractPlanDetail_tblCTContractPlan_intContractPlanId] FOREIGN KEY ([intContractPlanId]) REFERENCES [tblCTContractPlan]([intContractPlanId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractPlanDetail_tblARAccountStatus_intAccountStatusId] FOREIGN KEY ([intAccountStatusId]) REFERENCES [tblARAccountStatus]([intAccountStatusId])
)
