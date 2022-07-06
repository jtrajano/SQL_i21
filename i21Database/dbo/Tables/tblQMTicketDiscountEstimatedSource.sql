CREATE TABLE [dbo].[tblQMTicketDiscountEstimatedSource]
(
	[intTicketDiscountEstimatedSourceId] INT NOT NULL IDENTITY
	,[strGrade] NVARCHAR(50) NOT NULL 
	,[intConcurrencyId] INT NULL DEFAULT(0)
	,[dblMin] DECIMAL(24, 10) NULL
	,[dblMax] DECIMAL(24, 10) NULL

	,CONSTRAINT [PK_tblQMTicketDiscountEstimated_intTicketDiscountSourceId] PRIMARY KEY ([intTicketDiscountEstimatedSourceId])
	,CONSTRAINT [UQ_tblQMTicketDiscountEstimated_Grade] UNIQUE ([strGrade])

)