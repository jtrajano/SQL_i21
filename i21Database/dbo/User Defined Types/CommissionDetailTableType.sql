CREATE TYPE [dbo].[CommissionDetailTableType] AS TABLE
(
	 [intId]					INT IDENTITY PRIMARY KEY CLUSTERED
	,[intEntityId]				INT NULL
	,[intCommissionPlanId]		INT NULL
	,[intSourceId]				INT NULL
	,[strSourceType]			NVARCHAR(25) NULL
	,[dtmSourceDate]			DATETIME NULL
	,[dblAmount]				NUMERIC(18,6) NULL
)